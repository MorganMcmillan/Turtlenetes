---Buffer3D is used as a facade to the Pine3D rendering library
---It contains every 3D element needed to represent a project space
---@class Buffer3D: class
---@field objects table[]
local Buffer3D = require("class"):extend("Buffer3D")

function Buffer3D:drawCube(x, y, z, x2, y2, z2, color)
    -- I think this works. I ended up generating it.
    local cube = {
        -- Right face (x)
        {x, y, z, x, y, z2, x, y2, z2, false, color, color},
        {x, y, z, x, y2, z, x, y2, z2, false, color, color},
        -- Left face (x2)
        {x2, y, z, x2, y2, z2, x2, y, z2, false, color, color},
        {x2, y, z, x2, y2, z, x2, y2, z2, false, color, color},
        -- Bottom face (y)
        {x, y, z, x2, y, z, x2, y, z2, false, color, color},
        {x, y, z, x2, y, z2, x, y, z2, false, color, color},
        -- Top face (y2)
        {x, y2, z, x2, y2, z2, x2, y2, z, false, color, color},
        {x, y2, z, x, y2, z2, x2, y2, z2, false, color, color},
        -- Back face (z)
        {x, y, z, x2, y2, z, x2, y, z, false, color, color},
        {x, y, z, x, y2, z, x2, y2, z, false, color, color},
        -- Front face (z2)
        {x, y, z2, x2, y, z2, x2, y2, z2, false, color, color},
        {x, y, z2, x2, y2, z2, x, y2, z2, false, color, color},
    }
    table.insert(self.objects, cube)
end

return Buffer3D