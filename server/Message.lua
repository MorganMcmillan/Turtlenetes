local MessageType = require("MessageType")
local rectangle = require("rectangle")

---@class Message: class, UiComponent
---@field type MessageType
---@field contents string
---@field source any
---@field color integer
local Message = require("class"):extend("Message")

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
	self.color = messageTypeColor(type)
end

function Message:draw(x, y, width, height)
	rectangle.draw(x, y, width, height, self.color)
	rectangle.drawText(x + 1, y, self.type, self.color)
	rectangle.drawTextWrapped(x + 1, y + 2, width - 1, height - 2, self.contents, self.color)
end

return Message
