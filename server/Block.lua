local SerClass = require("SerClass")
local types = SerClass.types

---@class Block: Object3D
---@field displayName string
---@field chunk Chunk
---@field index integer
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

function Block:moveUp()
    local moved = self:movedUp()
    if not self.chunk:getBlockRelative(moved.x, moved.y, moved.z) then
        self:setPosition(moved)
        self.chunk[self.index] = false
        self.chunk:addBlock(self)
        return true
    end
    return false
end

function Block:moveDown()
    local moved = self:movedDown()
    if not self.chunk:getBlockRelative(moved.x, moved.y, moved.z) then
        self:setPosition(moved)
        self.chunk[self.index] = false
        self.chunk:addBlock(self)
        return true
    end
    return false
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

return Block