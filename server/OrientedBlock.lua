---@class OrientedBlock: Block
---@field orientation string
local OrientedBlock = require("Block"):extend("OrientedBlock")

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