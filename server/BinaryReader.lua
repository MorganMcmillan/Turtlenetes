---@class BinaryReader: class
---@field contents string
---@field private position integer
local BinaryReader = require("class"):extend("BinaryReader")

function BinaryReader:init(contents)
    self.contents = contents
    self.position = 1
end

function BinaryReader.fromFile(fileName)
    local file = fs.open(fileName, "rb")
    local contents = file.readAll()
    file.close()
    return BinaryReader:new(contents)
end

local unpack = string.unpack

function BinaryReader:u8()
    local byte, position = unpack("<B", self.contents, self.position)
    self.position = position
    return byte
end

function BinaryReader:i8()
    local byte, position = unpack("<b", self.contents, self.position)
    self.position = position
    return byte
end

function BinaryReader:u16()
    local short, position = unpack("<H", self.contents, self.position)
    self.position = position
    return short
end

function BinaryReader:i16()
    local short, position = unpack("<h", self.contents, self.position)
    self.position = position
    return short
end

function BinaryReader:u32()
    local int, position = unpack("<I", self.contents, self.position)
    self.position = position
    return int
end

function BinaryReader:i32()
    local int, position = unpack("<i", self.contents, self.position)
    self.position = position
    return int
end

function BinaryReader:string()
    local string, position = unpack("<s4", self.contents, self.position)
    self.position = position
    return string
end

function BinaryReader:boolean()
    local byte, position = unpack("<B", self.contents, self.position)
    self.position = position
    return byte ~= 0
end

---Deserializes an array of a single type
---@generic T
---@param type fun(self): T
---@return T[]
function BinaryReader:arrayOf(type)
    local array = {}
    local length = self:u16()
    for i = 1, length do
        array[i] = type(self)
    end
    return array
end

---Deserializes an array of a Serializable class
---@generic T
---@param class Serializable | T
---@return (Serializable | T)[]
function BinaryReader:arrayOfClass(class)
    local array = {}
    local length = self:u16()
    for i = 1, length do
        array[i] = class:deserialize(self)
    end
    return array
end

return BinaryReader