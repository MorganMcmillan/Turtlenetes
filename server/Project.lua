local Volume = require("Volume")
local MetaChunk = require("MetaChunk")
local Turtle = require("Turtle")

---@class Project: Volume, Serializable
---@field super Volume
---@field name string
---@field turtles table<integer, Turtle>
---@field chunks MetaChunk
---@field messages Message[]
local Project = require("Volume"):extend("Project")

function Project:init(volume, name)
    -- Don't do this: I'm abusing mixins to copy table fields
    self:with(volume)
    self.name = name
    self.turtles = {}
    self.chunks = MetaChunk:new()
    self.messages = {}
end

function Project:serialize(writer)
    self.super.serialize(self, writer)

    writer:string(self.name)
    writer:arrayOfClass(self.turtles)
    self.chunks:serialize(writer)
    -- Ignore messages (may be a mistake)
end

function Project:deserialize(reader)
    ---@type Project
    local instance = self.super:deserialize(reader):cast(self)

    instance.name = reader:string()
    instance.turtles = reader:arrayOfClass(Turtle)
    instance.chunks = MetaChunk:deserialize(reader)

    return instance
end

return Project