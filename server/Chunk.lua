local Volume = require("Volume")

---@class Chunk: Object3d
---@field blocks Block[]
---@field neighbors Chunk[]
local Chunk = require("Object3d"):extend("Chunk")

function Chunk:init(x, y, z)
    self.super.init(self, x, y, z)
    local blocks = {}
    for i = 1, 4096 do
        blocks[i] = false
    end
    self.blocks = blocks
    self.neighbors = {}
end

---Get a block by relative (world) coordinates
---@param x integer
---@param y integer
---@param z integer
---@return Block
function Chunk:getBlockRelative(x, y, z)
    return self:getBlockAbsolute(x - self.x, y - self.y, z - self.z)
end

---Get a block by absolute (local) coordinates
---@param x integer
---@param y integer
---@param z integer
---@return Block
function Chunk:getBlockAbsolute(x, y, z)
    return self.blocks[x + y * 16 + z * 256]
end

---Create a volume from this chunk
---@return Volume
function Chunk:asVolume()
    return Volume.fromObject3D(self, 16)
end

return Chunk