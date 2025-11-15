---@class SpaceFillingCurve: class, ActionProvider
---@field handler BlocksEventHandler
---@field forwardAction Event
---@field backwardAction Event
---@field upAction Event
---@field downAction Event
local SpaceFillingCurve = require("class"):extend("SpaceFillingCurve")

---@param turtle Turtle
function SpaceFillingCurve:initAction(turtle)
    -- Reset state
    -- Check turtle fuel and resources
    -- Request resources if there is not enough fuel
    if self.downAction and not turtle.volume:contains(turtle:movedDown()) then
        turtle:up()
    end
end

return SpaceFillingCurve