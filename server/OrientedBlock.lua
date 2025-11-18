local Object3D = require("Object3D")
local Block = require("Block")

---@class OrientedBlock: Block
---@field orientation string
local OrientedBlock = Block:extend("OrientedBlock")
OrientedBlock.serializationTag = 1
Block.subclasses[1] = OrientedBlock

local types = require("SerClass").types

OrientedBlock.schema = {
    super = Block,
    {"orientation", types.enum{"North", "East", "South", "West"}}
}

function OrientedBlock:init(x, y, z, orientation)
    Block.init(self, x, y, z)
    self.orientation = orientation or "North"
end

local LEFT_TURN = {
    North = "West",
    West = "South",
    South = "East",
    East = "North"
}

function OrientedBlock:turnLeft()
    self.orientation = LEFT_TURN[self.orientation]
end

local RIGHT_TURN = {
    North = "East",
    East = "South",
    South = "West",
    West = "North"
}

function OrientedBlock:turnRight()
    self.orientation = RIGHT_TURN[self.orientation]
end

function OrientedBlock:movedForwards()
    return Object3D.movedForwards(self, self.orientation)
end

function OrientedBlock:movedBackwards()
    return Object3D.movedBackwards(self, self.orientation)
end

function OrientedBlock:moveForward()
    local moved = self:movedForwards()
    if not self.chunk:getBlockRelative(moved.x, moved.y, moved.z) then
        self:setPosition(moved)
        self.chunk[self.index] = false
        self.chunk:addBlock(self)
        return true
    end
    return false
end

function OrientedBlock:moveBackwards()
    local moved = self:movedBackwards()
    if not self.chunk:getBlockRelative(moved.x, moved.y, moved.z) then
        self:setPosition(moved)
        self.chunk[self.index] = false
        self.chunk:addBlock(self)
        return true
    end
    return false
end



return OrientedBlock