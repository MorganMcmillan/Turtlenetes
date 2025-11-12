local Volume = require("Volume")

---Chunks are the primary container for blocks.
---Blocks are indexed using zero-based coordinates, unlike Lua's one-based indexes.
---@class Chunk: Object3D, Serializable
---@field blocks (BlocksInstruction | false)[]
---@field neighbors Chunk[] chunks neighboring on each side, in the order of North, East, South, West, Up, Down
local Chunk = require("Object3D"):extend("Chunk")

function Chunk:init(x, y, z)
    self.super.init(self, x, y, z)
    local blocks = {}
    for i = 1, 4096 do
        blocks[i] = false
    end
    self.blocks = blocks
    self.neighbors = {}
end

---Converts local coordinates into an index in the range 1-4096
---@param x integer
---@param y integer
---@param z integer
---@return integer
local function blockIndex(x, y, z)
    return (x % 16 + (y * 16) % 16 + (z * 256) % 16) + 1
end

---Gets the index of this chunk's neighbor from absolute coordinates, if the coordinates falls outside of it.
---@param x integer
---@param y integer
---@param z integer
---@return integer | nil
local function neighborIndex(x, y, z)
    if z < 0 then
        return 1
    elseif x >= 16 then
        return 2
    elseif z >= 16 then
        return 3
    elseif x < 0 then
        return 4
    elseif y >= 16 then
        return 5
    elseif y < 0 then
        return 6
    end
end

---Prepares the coordinates for getting and setting a block
---@private
---@param x integer
---@param y integer
---@param z integer
---@return integer, Chunk
function Chunk:prepareCoordinates(x, y, z)
    local index = blockIndex(x, y, z)
    local neighbor = neighborIndex(x, y, z)
    return index, neighbor and self.neighbors[neighbor] or self
end

---Get a block by relative (world) coordinates
---@param x integer
---@param y integer
---@param z integer
---@return BlocksInstruction | false
function Chunk:getBlockRelative(x, y, z)
    return self:getBlockAbsolute(x - self.x, y - self.y, z - self.z)
end

---Get a block by absolute (local) coordinates
---@param x integer
---@param y integer
---@param z integer
---@return BlocksInstruction | false
function Chunk:getBlockAbsolute(x, y, z)
    local i, chunk = self:prepareCoordinates(x, y, z)
    return chunk.blocks[i]
end

---Set a block by relative (world) coordinates, if it isn't occupied
---@param x integer
---@param y integer
---@param z integer
---@param block BlocksInstruction
---@return boolean
function Chunk:setBlockRelative(x, y, z, block)
    return self:setBlockAbsolute(x - self.x, y - self.y, z - self.z, block)
end

---Set a block by absolute (local) coordinates, if it isn't occupied
---@param x integer
---@param y integer
---@param z integer
---@param block BlocksInstruction
---@return boolean
function Chunk:setBlockAbsolute(x, y, z, block)
    local i, chunk = self:prepareCoordinates(x, y, z)
    if chunk.blocks[i] then
        return false
    end
    chunk.blocks[i] = block
    block.chunk = chunk
    return true
end

---Adds a block to this chunk
---@param block BlocksInstruction
---@return boolean
function Chunk:addBlock(block)
    return self:setBlockRelative(block.x, block.y, block.z, block)
end

---Deletes a block by relative (world) coordinates
---@param x integer
---@param y integer
---@param z integer
---@return BlocksInstruction | false
function Chunk:deleteBlockRelative(x, y, z)
    return self:deleteBlockAbsolute(x - self.x, y - self.y, z - self.z)
end

---Deletes a block by absolute (local) coordinates
---@param x integer
---@param y integer
---@param z integer
---@return BlocksInstruction | false
function Chunk:deleteBlockAbsolute(x, y, z)
    local i, chunk = self:prepareCoordinates(x, y, z)
    local block = chunk.blocks[i]
    if block then
        chunk.blocks[i] = false
        block.chunk = nil
    end
    return block
end

---Create a volume from this chunk
---@return Volume
function Chunk:asVolume()
    return Volume.fromObject3D(self, 16)
end

return Chunk