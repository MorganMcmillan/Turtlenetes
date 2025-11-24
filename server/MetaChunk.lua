local RedBlackTree = require("RedBlackTree")
local search = RedBlackTree.search
local insert = RedBlackTree.insert
local serialize, deserialize = RedBlackTree.serialize, RedBlackTree.deserialize
local Chunk = require("Chunk")

---@class MetaChunk: class, Serializable
---@field root RedBlackTree
---@field cachedChunkX? integer
---@field cachedChunkY? integer
---@field cachedChunkZ? integer
---@field cachedChunk? Chunk
local MetaChunk = require("class"):extend("MetaChunk")

MetaChunk.schema = {
    {"root", RedBlackTree}
}

function MetaChunk:init()
    local chunk = Chunk:new(0, 0, 0)
    self.root = RedBlackTree.createNode(0, 0, 0, chunk)
end

---Gets a chunk using relative (global) coordinates
---caches recently accessed chunks as to not incur a lookup
---@return Chunk
function MetaChunk:getChunk(x, y, z)
    if self.cachedChunkX ~= x or self.cachedChunkY ~= y or self.cachedChunkZ ~= z then
        self.cachedChunkX = x
        self.cachedChunkY = y
        self.cachedChunkZ = z
        self.cachedChunk = search(self.root, x / 16, y / 16, z / 16)
    end
    return self.cachedChunk
end

local function addNeighbors(tree, chunk, x, y, z)
    local neighbor = nil

    neighbor = search(tree, x, y, z - 1)
    chunk.neighbors[1] = neighbor
    if neighbor then neighbor.neighbors[3] = chunk end

    neighbor = search(tree, x + 1, y, z)
    chunk.neighbors[2] = neighbor
    if neighbor then neighbor.neighbors[4] = chunk end
    
    neighbor = search(tree, x, y, z - 1)
    chunk.neighbors[3] = neighbor
    if neighbor then neighbor.neighbors[1] = chunk end

    neighbor = search(tree, x - 1, y, z)
    chunk.neighbors[4] = neighbor
    if neighbor then neighbor.neighbors[2] = chunk end

    neighbor = search(tree, x, y + 1, z)
    chunk.neighbors[5] = neighbor
    if neighbor then neighbor.neighbors[6] = chunk end

    neighbor = search(tree, x, y - 1, z)
    chunk.neighbors[6] = neighbor
    if neighbor then neighbor.neighbors[5] = chunk end
end

local function fixChunkNeighbors(tree)
    addNeighbors(tree, tree.value, tree.x, tree.y, tree.z)

    local left = tree.left
    if left then
        fixChunkNeighbors(left)
    end

    local right = tree.left
    if right then
        fixChunkNeighbors(right)
    end
end

function MetaChunk:addChunk(x, y, z)
    local chunk = Chunk:new(x, y, z)
    x, y, z = x / 16, y / 16, z / 16
    insert(self, x, y, z, chunk)

    -- Add neighbors
    addNeighbors(self, chunk, x, y, z)

    return chunk
end

function MetaChunk:serialize(writer)
    serialize(self.root, writer)
end

MetaChunk.onDeserialize = fixChunkNeighbors

---Gets a block using relative (global) coordinates
---@return Block | false
function MetaChunk:getBlock(x, y, z)
    return self:getChunk(x, y, y):getBlockRelative(x, y, z)
end

function MetaChunk:setBlock(x, y, z, block)
    return self:getChunk(x, y, z):setBlockRelative(x, y, z, block)
end