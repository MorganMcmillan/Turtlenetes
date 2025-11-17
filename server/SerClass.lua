---@class Serializable
---@field schema Schema
---@field onDeserialize fun(self) | nil

---@class Schema
---@field [integer] [string, Serializer<any>]
---@field super Serializable | nil

---@alias Buffer string[]
---@alias Serializer<T> string | { serialize: fun(T, Buffer), deserialize: fun(string, integer): T, integer } | Serializable

local SerClass = {}

-- Note: this could be more efficient by grouping schema into 3 groups: primitives, composites, and classes
-- This would require preprocessing the class

local pack, unpack, sub = string.pack, string.unpack, string.sub
local concat = table.concat

---@generic T
---@param value T | Serializer<T>
---@param T? Serializer<T>
---@param buffer Buffer
local function serialize(value, T, buffer)
    local tName = type(T)
    if tName == "string" then
        buffer[#buffer+1] = pack(T, value --[[@as number]])
    elseif tName == "table" then
        -- Serialize using the class type's schema
        local schema = T.schema
        if schema then
            serializeClass(value, schema, buffer)
        else
            T.serialize(value, buffer)
        end
    else
        -- Serialize using the instance class' schema
        serializeClass(value, value.schema, buffer)
    end
end

function serializeClass(object, schema, buffer)
    -- Recursively traverse schema superclasses, until the base schema is reached
    if schema.super then
        serializeClass(object, schema.super.schema, buffer)
    end

    if schema then
        for i = 1, #schema do
            local entry = schema[i]
            serialize(object[entry[1]], entry[2], buffer)
        end
    end
end

---@generic T
---@param T Serializer<T>
---@param bin string
---@param pos integer
---@return T, integer
local function deserialize(T, bin, pos)
    local tName = type(T)
    if tName == "string" then
        return unpack(T, bin, pos)
    elseif tName == "table" then
        local schema = T.schema
        if schema then
            local value = {}
            pos = deserializeClass(value, T, schema, bin, pos)
            return value, pos
        else
            return T.deserialize(bin, pos)
        end
    end
    return nil, pos
end

function deserializeClass(value, Class, schema, bin, pos)
    -- Recursively traverse schema superclasses, until the base schema is reached
    if schema.super then
        local super = Class.super
        pos = deserializeClass(value, super, super.schema, bin, pos)
    end

    for i = 1, #schema do
        local entry = schema[i]
        value[entry[1]], pos = deserialize(entry[2], bin, pos)
    end
    SerClass.onClassCreate(value, Class)
    return pos
end

---Serializes a value into a binary format given a schema.
---Classes which have a schema don't need to provide a type.
---@generic T
---@param value T
---@param T? Serializer<T>
---@return string
function SerClass.serialize(value, T)
    local buffer = {}
    serialize(value, T, buffer)
    return concat(buffer)
end

---Deserializes a value from a binary format given a schema.
---Classes which have a schema MUST STILL provide a type, as their own type is not not at deserialization time.
---@generic T
---@param bin string
---@param T Serializer<T>
---@return T, integer
function SerClass.deserialize(T, bin)
    return deserialize(T, bin, 1)
end

SerClass.rawSerialize = serialize
SerClass.rawDeserialize = deserialize

---Function to construct a class from a pure table. The default is to call the class method `create` which accepts a table, followed by `onDeserialize` if present.
---@generic T
---@param table table
---@param class T | table
---@return T
function SerClass.onClassCreate(table, class)
    local instance = class:create(table)
    local onDeserialize = class.onDeserialize
    if onDeserialize then
        -- Used to add/configure extra fields that were's covered by the deserialization
        onDeserialize(instance)
    end
    return instance
end

--[[ Type Definitions ]]
SerClass.types = {}

---@type Serializer<integer>
SerClass.types.u8 = "<B"
---@type Serializer<integer>
SerClass.types.i8 = "<b"
---@type Serializer<integer>
SerClass.types.u16 = "<H"
---@type Serializer<integer>
SerClass.types.i16 = "<h"
---@type Serializer<integer>
SerClass.types.u32 = "<I"
---@type Serializer<integer>
SerClass.types.i32 = "<i"
---@type Serializer<number>
SerClass.types.f32 = "<f"
---@type Serializer<number>
SerClass.types.f64 = "<d"
---@type Serializer<string>
SerClass.types.string = "<s4"

---@type Serializer<boolean>
SerClass.types.boolean = {
    serialize = function (value, buffer)
        buffer[#buffer+1] = pack("<B", value and 1 or 0)
    end,
    deserialize = function (bin, pos)
        local value
        value, pos = unpack("<B", bin, pos)
        return value ~= 0, pos
    end
}

---Serializes a value that is either a value or false (or nil)
---Used to simulate Rust's Option<T> type
---@generic T
---@param T Serializer<T>
---@param nonZero? boolean If the serialized value is guaranteed to never begin with a zero. Used for space optimization.
---@return Serializer<T | false>
function SerClass.types.optional(T, nonZero)
    if nonZero then
        return {
            serialize = function (value, buffer)
                if value then
                    serialize(value, T, buffer)
                else
                    buffer[#buffer+1] = "\0"
                end
            end,
            deserialize = function (bin, pos)
                if sub(bin, pos, pos) == "\0" then
                    return false, pos + 1
                else
                    return deserialize(T, bin, pos)
                end
            end
        }
    else
        return {
            serialize = function (value, buffer)
                if value then
                    buffer[#buffer+1] = "\1"
                    serialize(value, T, buffer)
                else
                    buffer[#buffer+1] = "\0"
                end
            end,
            deserialize = function (bin, pos)
                if sub(bin, pos, pos) == "\0" then
                    return false, pos + 1
                else
                    -- Skip tag byte
                    return deserialize(T, bin, pos + 1)
                end
            end
        }
    end
end

---Serializes an enumerated list of names as a single byte.
---@param enum (string|integer)[]
---@return Serializer<string>
function SerClass.types.enum(enum)
    -- Reverse name index
    for i = 1, #enum do
        enum[enum[i]] = i
    end

    return {
        serialize = function (value, buffer)
            buffer[#buffer+1] = pack("<B", enum[value])
        end,
        deserialize = function (bin, pos)
            local tag
            tag, pos = unpack("<B", bin, pos)
            return enum[tag], pos
        end
    }
end

---Serializes any type using a tag. Implicitly allows nil values.
---Only supports classes
---@param ... Serializable
---@return Serializer<Serializable>
function SerClass.types.either(...)
    local types = {...}
    local n = #types
    return {
        serialize = function (value, buffer)
            if value == nil then
                buffer[#buffer+1] = "\0"
                return
            end
            for i = 1, n do
                local T = types[i]
                if getmetatable(value) == T then
                    buffer[#buffer+1] = pack(">B", i)
                    serialize(value, T, buffer)
                    return
                end
            end
        end,
        deserialize = function (bin, pos)
            local tag
            tag, pos = unpack("<B", bin, pos)
            if tag == 0 then return nil, pos end
            local T = types[tag]
            return deserialize(T, bin, pos)
        end
    }
end

---Serializes a fixed size array of multiple types. Similar to using a schema, but creates a plain table instead.
---@param ... Serializer<any>
---@return Serializer<any[]>
function SerClass.types.tuple(...)
    local types = {...}
    local n = #types
    return {
        serialize = function (tuple, buffer)
            for i = 1, n do
                serialize(tuple[i], types[i], buffer)
            end
        end,
        deserialize = function (bin, pos)
            local tuple = {}
            for i = 1, n do
                tuple[i], pos = deserialize(types[i], bin, pos)
            end
            return tuple, pos
        end
    }
end

---Serializes a table with known key-value pairs. Similar to using a schema, but creates a plain table instead.
---@param namedTypes [any, Serializer<any>][]
---@return Serializer<table>
function SerClass.types.namedTuple(namedTypes)
    local n = #namedTypes
    return {
        serialize = function (namedTuple, buffer)
            for i = 1, n do
                local field = namedTypes[i]
                local name, T = field[1], field[2]
                serialize(namedTuple[name], T, buffer)
            end
        end,
        deserialize = function (bin, pos)
            local namedTuple = {}
            for i = 1, n do
                local field = namedTypes[i]
                local name, T = field[1], field[2]
                namedTuple[name], pos = deserialize(T, bin, pos)
            end
            return namedTuple, pos
        end
    }
end

---Used to deserialize a subclass instead of a base class.
---Requires that each subclass has a tag field corresponding to an index in the base class's array of subclasses.
---The tag field must be named "serializationTag" unless a custom one is provided.
---The subclass field must be named "subclasses" unless a custom one is provided.
---@generic T
---@param Super Serializer<T>
---@param tagFieldName? string the name of the subclass's field containing the serialization tag
---@param subclassFieldName? string the name of the superclass's field containing the serializable subclasses
---@return Serializer<T>
function SerClass.types.subclass(Super, tagFieldName, subclassFieldName)
    tagFieldName = tagFieldName or "serializationTag"
    subclassFieldName = subclassFieldName or "subclasses"

    return {
        serialize = function (object, buffer)
            buffer[#buffer+1] = pack("<B", object[tagFieldName])
            serialize(object, nil, buffer)
        end,
        deserialize = function (bin, pos)
            local tag
            tag, pos = unpack("<B", bin, pos)

            local Subclass = Super[subclassFieldName][tag] --[[@as Serializer<any>]]
            return deserialize(Subclass, bin, pos)
        end
    }
end

---Serializes an array of a type.
---@generic T
---@param T Serializer<T>
---@param length? integer The length of the array. If it is not provided then a dynamic length will be serialized and used.
---@return Serializer<T[]>
function SerClass.types.array(T, length)
    if length then
        return {
            serialize = function (array, buffer)
                for i = 1, length do
                    serialize(array[i], T, buffer)
                end
            end,
            deserialize = function (bin, pos)
                local array = {}
                for i = 1, length do
                    array[i], pos = deserialize(T, bin, pos)
                end
                return array, pos
            end
        }
    else
        return {
            serialize = function (array, buffer)
                local length = #array
                buffer[#buffer+1] = pack("<H", length)
                for i = 1, length do
                    serialize(array[i], T, buffer)
                end
            end,
            deserialize = function (bin, pos)
                local array, length = {}, nil
                length, pos = unpack("<H", bin, pos)
                for i = 1, length do
                    array[i], pos = deserialize(T, bin, pos)
                end
                return array, pos
            end
        }
    end
end

---Serializes a set of values as an array.
---@generic T
---@param T Serializer<T>
---@return Serializer<table<T, true>>
function SerClass.types.set(T)
    return {
        serialize = function (set, buffer)
            local length = 0
            for _ in next, set do
                length = length + 1
            end
            buffer[#buffer+1] = pack("<H", length)
            for k in next, set do
                serialize(k, T, buffer)
            end
        end,
        deserialize = function (bin, pos)
            local set, length, value = {}, nil, nil
            length, pos = unpack("<H", bin, pos)
            for _ = 1, length do
                value, pos = deserialize(T, bin, pos)
                set[value] = true
            end
            return set, pos
        end
    }
end

---Serializes a map into an array of key-value pairs.
---@generic K, V
---@param K Serializer<K>
---@param V Serializer<V>
---@return Serializer<table<K, V>>
function SerClass.types.map(K, V)
    return {
        serialize = function (map, buffer)
            local length = 0
            for _ in next, map do
                length = length + 1
            end
            buffer[#buffer+1] = pack("<H", length)
            for k, v in next, map do
                serialize(k, K, buffer)
                serialize(v, V, buffer)
            end
        end,
        deserialize = function (bin, pos)
            local map, length, k, v = {}, nil, nil, nil
            length, pos = unpack("<H", bin, pos)
            for _ = 1, length do
                k, pos = deserialize(K, bin, pos)
                v, pos = deserialize(V, bin, pos)
                map[k] = v
            end
            return map, pos
        end
    }
end

return SerClass
