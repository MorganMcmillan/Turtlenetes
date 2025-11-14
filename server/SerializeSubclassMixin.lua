---Allows deserializing subclasses by associating them with a tag.
---This requires the classes to be subclassed in a specific order, otherwise the wrong class will be deserialized.
---Note: `subclasses` static field needs to be added manually.
---@class SerializeSubclassMixin: Serializable
---@field serializationTag integer
---@field subclasses self[]
local SerializeSubclassMixin = {}

-- Because deserialization creates a subclass, we need to know ahead-of-time what that subclass is
function SerializeSubclassMixin:__extend(subclass)
    local subclasses = self.subclasses
    subclasses[#subclasses+1] = subclass
    subclass.serializationTag = #subclasses
end

---Writes this class's serialization tag
---This method MUST be called on every subclass that implements serialization
---@param writer BinaryWriter
function SerializeSubclassMixin:serializeTag(writer)
    writer:u8(self.serializationTag)
end

-- Note: subclasses must implement their own deserialize method, otherwise this will be called endlessly
function SerializeSubclassMixin:deserialize(reader)
    local tag = reader:u8()
    local subclass = self.subclasses[tag]
    return subclass:deserialize(reader)
end

return SerializeSubclassMixin
