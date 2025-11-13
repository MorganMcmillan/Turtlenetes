local RedBlackTree = require("RedBlackTree")
local search = RedBlackTree.search
local insert = RedBlackTree.insert
local serialize, deserialize = RedBlackTree.serialize, RedBlackTree.deserialize
local Chunk = require("Chunk")

---@class MetaChunk: class, Serializable
---@field root RedBlackTree
local MetaChunk = require("class"):extend("MetaChunk")

function MetaChunk:init()
    local chunk = Chunk:new(0, 0, 0)
    self.root = RedBlackTree.createNode(0, 0, 0, chunk)
end

---Gets a chunk using relative (global) coordinates
---@return Chunk
function MetaChunk:getChunk(x, y, z)
    return search(self.root, x / 16, y / 16, z / 16)
end

function MetaChunk:addChunk(x, y, z)
    local chunk = Chunk:new(x / 16, y / 16, z / 16)
    insert(self, x, y, z, chunk)
    -- TODO: Add chunk neighbors
end

function MetaChunk:serialize(writer)
    serialize(self.root, writer)
end

---(Static)
function MetaChunk:deserialize(reader)
    local instance = self:create()
    instance.root = deserialize(reader, Chunk)
    return instance
end

---Gets a block using relative (global) coordinates
---@return Block | false
function MetaChunk:getBlock(x, y, z)
    return self:getChunk(x, y, z):getBlockRelative(x, y, z)
end

function MetaChunk:setBlock(x, y, z, block)
    return self:getChunk(x, y, z):setBlockRelative(x, y, z, block)
end