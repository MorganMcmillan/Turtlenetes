---@class Object3D: class, Drawable3D
---@field x integer
---@field y integer
---@field z integer
---@field color? integer
local Object3D = require("class"):extend("Object3D")

function Object3D:init(x, y, z)
    self.x = x
    self.y = y
    self.z = z
end

function Object3D:xyz()
    return self.x, self.y, self.z
end

function Object3D:setXYZ(x, y, z)
    self.x = x
    self.y = y
    self.z = z
end

function Object3D:setPosition(other)
    self.x = other.x
    self.y = other.y
    self.z = other.z
end

---Draws this object as a cube
---@param buffer Buffer3D
function Object3D:draw(buffer)
    buffer:drawCube(self.x, self.y, self.z, self.x + 1, self.y + 1, self.z + 1, self.color or colors.lightBlue)
end

---Create a new Object3D moved in the direction
---@param direction string
---@return Object3D
function Object3D:movedInDirection(direction)
    local x, z = self.x, self.z
    if direction == "North" then
        z = z - 1
    elseif direction == "East" then
        x = x + 1
    elseif direction == "South" then
        z = z + 1
    elseif direction == "West" then
        x = x - 1
    else
        error("Invalid direction " .. direction .. ".")
    end
    return Object3D:new(x, self.y, z)
end

---Create a new Object3D moved upwards
---@return Object3D
function Object3D:movedUp()
    return Object3D:new(self.x, self.y + 1, self.z)
end

---Create a new Object3D moved downwards
---@return Object3D
function Object3D:movedDown()
    return Object3D:new(self.x, self.y - 1, self.z)
end

return Object3D