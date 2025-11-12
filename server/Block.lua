---@class Block: Object3D
---@field displayName string
---@field chunk Chunk
local Block = require("Object3D"):extend("Block")

function Block:init(x, y, z, name)
    self.super.init(self, x, y, z)
    self.displayName = name
end

return Block