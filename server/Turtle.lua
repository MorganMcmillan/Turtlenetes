local Volume = require("Volume")
local Block = require("Block")
-- TODO

---@class Turtle: OrientedBlock
---@field address integer
---@field volume Volume
---@field inventory Inventory
---@field left Item
---@field right Item
local Turtle = require("OrientedBlock"):extend("Turtle")
Turtle.serializationTag = 3
Block.subclasses[3] = Turtle

function Turtle:init(x, y, z, direction, volume, address)
    self.super.init(self, x, y, z, direction)
    self.volume = volume
    self.address = address
end

function Turtle:sendCommand(method, ...)
    rednet.send(self.address, {method, ...}, "t8s")
    -- Await client's response
    local _, results = rednet.receive("t8s")
    return unpack(results)
end

local function defineCommand(command)
    Turtle[command] = function(self, ...)
        return self:sendCommand(command, ...)
    end
end

local function defineCommandUpDown(command)
    for _, suffix in ipairs({"", "Up", "Down"}) do
        defineCommand(command .. suffix)
    end
end

defineCommand"getFuelLevel"
defineCommand"getInventory"
defineCommand"findItem"
defineCommand"findItems"
defineCommand"craft"
defineCommand"getLeftPeripheral"
defineCommand"getRightPeripheral"
defineCommand"forward"
defineCommand"back"
defineCommand"up"
defineCommand"down"
defineCommandUpDown"dig"
defineCommandUpDown"place"
defineCommandUpDown"drop"
defineCommandUpDown"suck"
defineCommandUpDown"compare"
defineCommandUpDown"inspect"

function Turtle:turnLeft()
    self.super.turnLeft(self)
    self:sendCommand("turnLeft")
end

function Turtle:turnRight()
    self.super.turnRight(self)
    self:sendCommand("turnRight")
end

function Turtle:serialize(writer)
    -- TODO: serialize connection, inventory, equipment, 
end

return Turtle