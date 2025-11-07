local LayoutMode = require("LayoutMode")

---@class UI: class
---@field px integer the current x position of the next UI component
---@field py integer the current y position of the next UI component
---@field container Rectangle
local UI = require("class"):extend("UI")

function UI:init(container, layoutMode)
    self.container = container
    self.px = container.x
    self.py = container.y
    self.layoutMode = layoutMode or LayoutMode.horizontal
end

---Draws a UI component and prepares the position for the next one
---@param component Rectangle
---@return self for chained use
function UI:draw(component)
    component:ui(self)
    self.layoutMode:updatePosition(self, component)
    return self
end

function UI:horizontal(container, callback)
    callback(UI:new(container, LayoutMode.horizontal))
end

function UI:vertical(container, callback)
    callback(UI:new(container, LayoutMode.vertical))
end