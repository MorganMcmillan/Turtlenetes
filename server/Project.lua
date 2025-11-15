local Volume = require("Volume")
local MetaChunk = require("MetaChunk")
local Turtle = require("Turtle")
local SerClass = require("SerClass")
local types = SerClass.types

---@class Project: Volume, Serializable
---@field super Volume
---@field name string
---@field turtles table<integer, Turtle>
---@field chunks MetaChunk
---@field messages Message[]
local Project = require("Volume"):extend("Project")

Project.schema = {
    super = Project.super,
    {"name", types.string},
    {"chunks", MetaChunk},
}

function Project:init(volume, name)
    -- Don't do this: I'm abusing mixins to copy table fields
    self:with(volume)
    self.name = name
    self.turtles = {}
    self.chunks = MetaChunk:new()
    self.messages = {}
end

return Project