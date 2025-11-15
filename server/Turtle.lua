local Volume = require("Volume")
local Inventory = require("Inventory")
local Item = require("Item")
local Block = require("Block")
local SerClass = require("SerClass")
local types = SerClass.types
-- TODO

---@class Turtle: OrientedBlock, ITurtle
---@field address integer
---@field volume Volume
---@field fuel integer
---@field inventory Inventory
---@field left Item
---@field right Item
local Turtle = require("OrientedBlock"):extend("Turtle")
Turtle.serializationTag = 3
Block.subclasses[3] = Turtle

Turtle.schema = {
    super = Turtle.super,
    {"address", types.u16},
    {"fuel", types.u32},
    {"inventory", Inventory},
    {"left", Item},
    {"right", Item}
}

function Turtle:init(x, y, z, direction, volume, address)
    self.super.init(self, x, y, z, direction)
    self.volume = volume
    self.address = address
    self:refresh()
end

function Turtle:sendCommand(method, ...)
    rednet.send(self.address, {method, ...}, "t8s")
    -- Await client's response
    local _, results = rednet.receive("t8s")
    return unpack(results)
end

---Synchronizes virtual turtle state with real turtle state
function Turtle:refresh()
    self:getPosition()
    self:getOrientation()
    self:getInventory()
    self:getLeftPeripheral()
    self:getRightPeripheral()
    self:getFuelLevel()
end

function Turtle:getPosition()
    local ok, x, y, z = self:sendCommand("getPosition")
    self:setXYZ(x, y, z)
    return x, y, z
end

function Turtle:getOrientation()
    local ok, orientation = self:sendCommand("getOrientation")
    self.orientation = orientation
    return orientation
end

function Turtle:getInventory()
    local ok, inventory = self:sendCommand("getInventory")
    self.inventory:refresh(inventory)
    return inventory
end

function Turtle:getLeftPeripheral()
    local ok, peripheral = self:sendCommand("getLeftPeripheral")
    self.left = peripheral
    return peripheral
end

function Turtle:getRightPeripheral()
    local ok, peripheral = self:sendCommand("getRightPeripheral")
    self.left = peripheral
    return peripheral
end

function Turtle:getFuelLevel()
    local ok, fuel = self:sendCommand("getFuelLevel")
    self.fuel = fuel
    return fuel
end

function Turtle:forward()
    local ok = self:sendCommand("forward")
    if ok and not self:moveForward() then
        -- There is a conflict between the server chunk and physical chunk
    end
    return ok
end

function Turtle:back()
    local ok = self:sendCommand("back")
    if ok and not self:moveBackwards() then
        -- There is a conflict between the server chunk and physical chunk
    end
    return ok
end

function Turtle:up()
    local ok = self:sendCommand("up")
    if ok and not self:moveUp() then
        -- There is a conflict between the server chunk and physical chunk
    end
    return ok
end

function Turtle:down()
    local ok = self:sendCommand("down")
    if ok and not self:moveDown() then
        -- There is a conflict between the server chunk and physical chunk
    end
    return ok
end

function Turtle:dig()
    local ok = self:sendCommand("dig")
    if ok then
        self.chunk:deleteBlockRelative(self:movedForwards():xyz())
    end
    return ok
end

function Turtle:digUp()
    local ok = self:sendCommand("digUp")
    if ok then
        self.chunk:deleteBlockRelative(self:movedUp():xyz())
    end
    return ok
end

function Turtle:digDown()
    local ok = self:sendCommand("digDown")
    if ok then
        self.chunk:deleteBlockRelative(self:movedDown():xyz())
    end
    return ok
end

function Turtle:place()
    local ok, name = self:sendCommand("place")
    if ok then
        local x, y, z = self:movedForwards():xyz()
        local block = Block:new(x, y, z, name)
        if not self.chunk:addBlock(block) then
            -- Chunk conflict
        end
    end
    return ok
end

function Turtle:placeUp()
    local ok, name = self:sendCommand("placeUp")
    if ok then
        local x, y, z = self:movedUp():xyz()
        local block = Block:new(x, y, z, name)
        if not self.chunk:addBlock(block) then
            -- Chunk conflict
        end
    end
    return ok
end

function Turtle:placeDown()
    local ok, name = self:sendCommand("placeDown")
    if ok then
        local x, y, z = self:movedDown():xyz()
        local block = Block:new(x, y, z, name)
        if not self.chunk:addBlock(block) then
            -- Chunk conflict
        end
    end
    return ok
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

defineCommand"findItem"
defineCommand"findItems"
defineCommand"craft"
defineCommandUpDown"place"
defineCommandUpDown"drop"
defineCommandUpDown"suck"
defineCommandUpDown"compare"
defineCommandUpDown"inspect"

function Turtle:turnLeft()
    ---@diagnostic disable-next-line: undefined-field
    Turtle.super.turnLeft(self)
    self:sendCommand("turnLeft")
end

function Turtle:turnRight()
    ---@diagnostic disable-next-line: undefined-field
    Turtle.super.turnRight(self)
    self:sendCommand("turnRight")
end

return Turtle