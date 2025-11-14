---@class BinaryWriter: class
local BinaryWriter = require("class"):extend("BinaryWriter")

local pack = string.pack

function BinaryWriter:u8(byte)
    self[#self+1] = pack("<B", byte)
end

function BinaryWriter:i8(byte)
    self[#self+1] = pack("<b", byte)
end

function BinaryWriter:u16(short)
    self[#self+1] = pack("<H", short)
end

function BinaryWriter:i16(short)
    self[#self+1] = pack("<h", short)
end

function BinaryWriter:u32(int)
    self[#self+1] = pack("<I", int)
end

function BinaryWriter:i32(int)
    self[#self+1] = pack("<i", int)
end

function BinaryWriter:string(string)
    self[#self+1] = pack("<s4", string)
end

function BinaryWriter:boolean(bool)
    self[#self+1] = pack("<B", bool and 1 or 0)
end

---Serializes an array of a single type
---@generic T
---@param type fun(self, data: T)
---@param array T[]
function BinaryWriter:arrayOf(type, array)
    local length = #array
    self:u16(length)
    for i = 1, length do
        type(self, array[i])
    end
end

---Serializes an array of a Serializable class
---@param array Serializable[]
function BinaryWriter:arrayOfClass(array)
    local length = #array
    self:u16(length)
    for i = 1, length do
        array[i]:serialize(self)
    end
end

function BinaryWriter:__tostring()
    return table.concat(self)
end

return BinaryWriter