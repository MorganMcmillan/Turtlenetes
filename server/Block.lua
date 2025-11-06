---@class Block: Object3D
---@field name string
---@field chunk Chunk
local Block = require("Object3D"):extend("Block")

function Block:init(x, y, z, name)
    self.super.init(self, x, y, z)
    self.name = name
end

return Block