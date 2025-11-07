---@class Rectangle: class
---@field width integer
---@field height integer
---@field color integer
---@field x integer
---@field y integer
local Rectangle = require("class"):extend("Rectangle")

function Rectangle:init(width, height, color)
    self.width = width
    self.height = height
    self.color = color
end

function Rectangle:ui(ui)
    if self.color then
        paintutils.drawFilledBox(ui.px, ui.py, ui.px + self.width, ui.py + self.height)
    end
    self.x = ui.px
    self.y = ui.py
end

function Rectangle:drawTextCentered(ui, text)
	-- Width allowed with 1 character of padding on each end
	local width = self.width - 2
	local length = #text
	-- Center = (width - text_width) / 2
	-- TODO: split text among multiple lines
	-- Allow 1 character of vertical padding
	local ty = self.y + 1
	local tx = (width - length) / 2
end
