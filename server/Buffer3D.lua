---Buffer3D is used as a facade to the Pine3D rendering library
---It contains every 3D element needed to represent a project space
---@class Buffer3D: class
---@field objects table[]
local Buffer3D = require("class"):extend("Buffer3D")

function Buffer3D:drawCube(x, y, z, x2, y2, z2, color)
    -- I think this works. I ended up generating it.
    local cube = {
        -- Right face (x)
        {x, y, z, x, y, z2, x, y2, z2, false, color},
        {x, y, z, x, y2, z, x, y2, z2, false, color},
        -- Left face (x2)
        {x2, y, z, x2, y2, z2, x2, y, z2, false, color},
        {x2, y, z, x2, y2, z, x2, y2, z2, false, color},
        -- Bottom face (y)
        {x, y, z, x2, y, z, x2, y, z2, false, color},
        {x, y, z, x2, y, z2, x, y, z2, false, color},
        -- Top face (y2)
        {x, y2, z, x2, y2, z2, x2, y2, z, false, color},
        {x, y2, z, x, y2, z2, x2, y2, z2, false, color},
        -- Back face (z)
        {x, y, z, x2, y2, z, x2, y, z, false, color},
        {x, y, z, x, y2, z, x2, y2, z, false, color},
        -- Front face (z2)
        {x, y, z2, x2, y, z2, x2, y2, z2, false, color},
        {x, y, z2, x2, y2, z2, x, y2, z2, false, color},
    }
    table.insert(self.objects, cube)
end

function Buffer3D:render(frame)
    frame:drawObjects(self.objects)
    frame:drawBuffer()
end

function Buffer3D:clear()
    self.objects = {}
end

return Buffer3D