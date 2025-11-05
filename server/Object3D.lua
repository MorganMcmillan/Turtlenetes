---@class Object3d: class, Drawable3D
---@field x integer
---@field y integer
---@field z integer
---@field color? integer
local Object3D = require("class"):extend("Object3d")

function Object3D:init(x, y, z)
    self.x = x
    self.y = y
    self.z = z
end

function Object3D:setPosition(other)
    self.x = other.x
    self.y = other.y
    self.z = other.z
end

---comment
---@param buffer Buffer3D
function Object3D:draw(buffer)
    buffer:drawCube(self.x, self.y, self.z, self.x, self.y, self.z, self.color or colors.lightBlue)
end

---Create a new Object3d moved in the direction
---@param direction string
---@return Object3d
function Object3D:moveInDirection(direction)
    local x, z = self.x, self.z
    if direction == "North" then
        -- was is x or z
    elseif direction == "East" then
    elseif direction == "South" then
    elseif direction == "West" then
    else
        error("Invalid direction " .. direction .. ".")
    end
    return Object3D:new(x, self.y, z)
end

function Object3D:moveUp()
    return Object3D:new(self.x, self.y + 1, self.z)
end

function Object3D:moveDown()
    return Object3D:new(self.x, self.y - 1, self.z)
end

return Object3D