---@class ScreenContainer: Rectangle
local ScreenContainer = require("Rectangle"):extend("ScreenContainer")

function ScreenContainer:init()
    self.x = 1
    self.y = 1
    self:updateSize()
end

---Update this container's size to reflect the screen's size
function ScreenContainer:updateSize()
    self.width, self.height = term.getSize();
end