local Object3D = require("Object3D")

---@class Volume: Object3d, Serializable
---@field length integer x-axis length
---@field height integer y-axis height
---@field width integer z-axis width
---@field parent Volume
---@field children Volume[]
local Volume = Object3D:extend("Volume")

function Volume:init(x, y, z, length, height, width)
    self.super.init(self, x, y, z)
    self.length = length
    self.height = height or length
    self.width = width or length
    self.children = {}
end

function Volume:__tostring()
    return "{\n\tx: " .. self.x ..
    "\n\ty: " .. self.y ..
    "\n\tz: " .. self.z ..
    "\n\tlength: " .. self.length ..
    "\n\theight: " .. self.height ..
    "\n\twidth: " .. self.width ..
    "\n}"
end

function Volume.fromObject3D(object, length, height, width)
    return Volume:new(object.x, object.y, object.z, length, height, width)
end

---Tests if an object is contained within this volume
---@param object Object3d | Volume
---@return boolean
function Volume:contains(object)
    return
        object.x > self.x and object.x <= self.x + self.length and
        object.y > self.y and object.y <= self.y + self.height and
        object.z > self.z and object.z <= self.z + self.width and
        (getmetatable(object) ~= Volume or self:contains(
            Object3D:new(
                object.x + object.length,
                object.y + object.width,
                object.z + object.height
        )))
end

---Creates a new volume contained within this volume, ensuring it fits
---@param x any
---@param y any
---@param z any
---@param length any
---@param height any
---@param width any
function Volume:createSubVolume(x, y, z, length, height, width)
    x = x or self.x
    y = y or self.y
    z = z or self.z
    length = length or self.length - (x - self.x)
    height = height or self.height - (y - self.y)
    width = width or self.width - (z - self.z)

    local subVolume = Volume:new(x, y, z, length, height, width)
    if not self:contains(subVolume) then
        error("subVolume cannot be contained within this volume: " .. subVolume:__tostring())
    end
    subVolume.parent = self
    table.insert(self.children, subVolume)
end

return Volume