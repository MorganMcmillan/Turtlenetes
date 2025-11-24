local Volume = require("Volume")
local MetaChunk = require("MetaChunk")
local Turtle = require("Turtle")
local BlocksEventHandler = require("scripting.BlocksEventHandler")
local BlocksEventHandlerView = require("scripting.BlocksEventHandlerView")
local Tool = require("Tool")
local Camera = require("Camera")

---@class Project: Volume, UiComponent, Clickable, Serializable
---@field super Volume
---@field name string
---@field turtles table<integer, Turtle>
---@field chunks MetaChunk
---@field messages Message[]
---@field handler BlocksEventHandler
---@field tools Tool[]
---@field camera Camera
local Project = require("Volume"):extend("Project")

local types = require("SerClass").types

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
    local handler = BlocksEventHandler:new()
    self.handlerView = BlocksEventHandlerView:new(handler)
    self.tools = Tool:initProjectTools()
    self.camera = Camera:new(0, 0, 0)
end

---Ticks time forward for the project
function Project:tick()
    for _, turtle in ipairs(self.turtles) do
        turtle:tick()
    end
end

-- Impl UiComponent

function Project:ui()
    local width, height = term.getSize()
    -- Render left sidebar: 5 px wide
    self:leftSideBar(height)
    -- Render project view
    width = width - 5
    local x = 6
    -- Width 3/5 remaining width
    local viewWidth = math.floor(width * 3 / 5)
    self:renderView(x, viewWidth, height)
    -- Render right sidebar
    x = x + viewWidth
    width = width - viewWidth
    self:rightSideBar(x, width, height)
end

function Project:leftSideBar(height)
    local i = 1
    for y = 1, height, 5 do
        self.tools[i]:ui(y)
        i = i + 1
    end
end

local sub = string.sub

-- Renders a representation of the world chunks
function Project:renderView(x, width, height)
    -- TODO use 2D rendering given a specific Y coordinate of the camera
    for bz = 1, height do
        for bx = 1, width do
            local block = self.chunks:getBlock(self.camera.x + bx, self.camera.y, self.camera.z + bz)
            term.setCursorPos(x + bx - 1, bz)
            term.setBackgroundColor(block and block.color or colors.black)
            term.setTextColor(colors.white)
            term.write(block and sub(block.name, 1, 1):upper() or "")
        end
    end
end

function Project:rightSideBar(x, width, height)
    -- TODO render sidebar tabs based on context
    -- For now we will render just the event view
    self.handlerView:ui(x, 1, width, height)
end

-- Impl Clickable

local floor = math.floor

function Project:onClick(button, x, y)
    local width, height = term.getSize()
    if x >= 6 then
        local toolIndex = floor((y - 1) / 5) + 1
        self.tools[toolIndex]:onClick(button, x, y)
    else
        width = width - 5
        local viewWidth = math.floor(width * 3 / 5)
        x = x + 6
        if x <= viewWidth then
            self:blockClicked(button, x - viewWidth, y)
        else
            self:rightSideBarClicked(button, x - (width - viewWidth), y)
        end
    end
end

function Project:blockClicked(button, x, y)
    
end

function Project:rightSideBarClicked(button, x, y)
    -- TODO render based on sidebar tab
    self.handlerView:onClick(button, x, y)
end

return Project