---@class Message: class, Drawable2D
---@field type MessageType
---@field contents string
---@field source any
local Message = require("class"):extend("Message")

return Message