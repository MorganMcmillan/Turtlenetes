local Rectangle = require("Rectangle")
local MessageType = require("MessageType")

---@class Message: Rectangle
---@field type MessageType
---@field contents string
---@field source any
local Message = Rectangle:extend("Message")

local function messageTypeColor(type)
	if type == MessageType.Success then
		return colors.green
	elseif type == MessageType.Info then
		return colors.blue
	elseif type == MessageType.Warning then
		return colors.yellow
	elseif type == MessageType.Error then
		return colors.red
	elseif type == MessageType.Fatal then
		return colors.black
	end
end

function Message:init(type, contents, source)
    self.type = type
    self.contents = contents
		self.source = source
		Rectangle.init(self, 16, 5, messageTypeColor(type))
end

function Message:ui(ui)
    Rectangle.ui(self, ui)
    self:drawTextCentered(ui, self.contents)
end

return Message
