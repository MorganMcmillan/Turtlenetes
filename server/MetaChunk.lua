local RedBlackTree = require("RedBlackTree")
local search = RedBlackTree.search
local Chunk = require("Chunk")

---@class MetaChunk: class, Serializable
---@field chunks RedBlackTree
local MetaChunk = require("class"):extend("MetaChunk")

function MetaChunk:init()
    local chunk = Chunk:new(0, 0, 0)
    self.chunks = RedBlackTree.createNode(0, 0, 0, chunk)
end

---Gets a chunk using relative (global) coordinates
---@return Chunk
function MetaChunk:getChunk(x, y, z)
    return search(self.chunks, x / 16, y / 16, z / 16)
end

---Gets a block using relative (global) coordinates
---@return Block | false
function MetaChunk:getBlock(x, y, z)
    return self:getChunk(x, y, z):getBlockRelative(x, y, z)
end

function MetaChunk:setBlock(x, y, z, block)
    return self:getChunk(x, y, z):setBlockRelative(x, y, z, block)
end