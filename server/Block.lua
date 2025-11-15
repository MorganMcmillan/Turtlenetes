local SerClass = require("SerClass")
local types = SerClass.types

---@class Block: Object3D
---@field displayName string
---@field chunk Chunk
---@field serializationTag integer
---@field subclasses Block[]
local Block = require("Object3D"):extend("Block")
Block.subclasses = {}

Block.schema = {
    super = Block.super,
    {"displayName", types.string}
}

function Block:init(x, y, z, name)
    Block.super.init(self, x, y, z)
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