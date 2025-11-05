---@class Item: class
---@field name string
---@field mod string
---@field tags table<string, true>
local Item = require("class"):extend("Item")

function Item:init(name, tags, mod)
    self.name = name
    self.tags = tags
    self.mod = mod or "split item name by colon"
end