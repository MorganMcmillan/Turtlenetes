local MetaChunk = require("MetaChunk")

---@class Project: Volume, Serializable
---@field name string
---@field turtles table<integer, Turtle>
---@field chunks MetaChunk
---@field messages Message[]
local Project = require("Volume"):extend("Project")

function Project:init(volume, name)
    -- TODO add persistence to disk
    self.super.init(self, volume.x, volume.y, volume.z, volume.width, volume.height, volume.length)
    self.name = name
    self.turtles = {}
    self.chunks = MetaChunk:new()
    self.messages = {}
end

return Project