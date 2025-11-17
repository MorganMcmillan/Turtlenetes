local Volume = require("Volume")
local Inventory = require("Inventory")
local Item = require("Item")
local Block = require("Block")
local SerClass = require("SerClass")
local types = SerClass.types
-- TODO

---@class Turtle: OrientedBlock, UiComponent, ITurtle
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

-- Impl UiComponent

local rectangle = require("ui.rectangle")

---Draw this turtle's information onto the right sidebar
function Turtle:ui(x, y, width)
    -- Address
    y = rectangle.drawTextCentered(x, y, width, 1, "Address: " .. self.address)
    -- position
    local tx = x + 1
    tx = rectangle.drawText(tx, y, "X: " .. self.x) + 1
    tx = rectangle.drawText(tx, y, "Y: " .. self.y) + 1
    rectangle.drawText(tx, y, "Z: " .. self.z)
    y = y + 1
    -- Facing direction
    rectangle.drawText(x + 1, y, "Direction: " .. self.orientation)
    y = y + 1
    -- Fuel
    rectangle.drawText(x + 1, y, "Fuel: " .. self.fuel)
    y = y + 2
    -- Split horizontally
    local split = math.floor(width / 2)
    -- Tools
    self:drawTools(x, y, split)
    -- Inventory
    self:drawInventory(split + 1, y, split)
end

function Turtle:drawTools(x, y, width)
    -- Left tool
    rectangle.drawText(x + 1, y, "Left Tool")
    y = y + 1
    _, y = rectangle.draw(x + 1, y, width - 2, width - 1, self.left and colors.blue or colors.gray)
    y = y + 1
    -- Right tool
    rectangle.drawText(x + 1, y, "Right Tool")
    y = y + 1
    rectangle.draw(x + 1, y, width - 2, width - 1, self.right and colors.blue or colors.gray)
end

function Turtle:drawInventory(x, y, width)
    rectangle.drawText(x + 1, y, "Inventory")
    for i = 1, 4 do
        y = y + 2
        local ox = x
        for j = 0, 3 do
            local item = self.inventory.itemsList[i + j * 4]
            local color, count
            if item then
                color = colors.lightBlue
                count = tostring(item[2])
            else
                color = colors.gray
                count = "0"
            end

            ox = rectangle.drawBoxedText(ox, y, 4, 4, count, colors.lightGray, color) + 1
        end
    end
end

return Turtle