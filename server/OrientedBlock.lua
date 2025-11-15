local SerClass = require("SerClass")
local types = SerClass.types
local Block = require("Block")

---@class OrientedBlock: Block
---@field orientation string
local OrientedBlock = Block:extend("OrientedBlock")
OrientedBlock.serializationTag = 1
Block.subclasses[1] = OrientedBlock

OrientedBlock.schema = {
    super = Block,
    {"orientation", types.enum{"North", "East", "South", "West"}}
}

function OrientedBlock:init(x, y, z, orientation)
    self.super.init(self, x, y, z)
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

return OrientedBlock