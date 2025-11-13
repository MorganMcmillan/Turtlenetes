---@class Block: Object3D, Serializable
---@field displayName string
---@field chunk Chunk
---@field serializationTag integer
---@field subclasses Block[]
local Block = require("Object3D"):extend("Block")
Block.subclasses = {}
-- Note: I don't use the SerializeSubclassMixin because of how blocks are stored using a palette

function Block:init(x, y, z, name)
    self.super.init(self, x, y, z)
    self.displayName = name
end

local byte, char, pack, sub = string.byte, string.char, string.pack, string.sub

function Block:toBinary()
    return char(self.serializationTag) .. pack("<s4", self.displayName)
end

---(Static) retrieves the block's class and name from a binary palette record
---@param binary string
---@return Block class, string name
function Block:fromBinary(binary)
    local tag = byte(binary)
    return self.subclasses[tag] or self, sub(binary, 2)
end

---(Static)
function Block:deserialize(_)
    -- Pass, return new instance instead
    return self:create()
end

return Block