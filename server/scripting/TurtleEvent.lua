---@class TurtleEvent: Event
---@field isObstructive boolean
---@field isDestructive boolean
local TurtleEvent = require("scripting.Event"):extend("TurtleEvent")

return TurtleEvent