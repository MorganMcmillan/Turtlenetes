---@class Item: class
---@field name string
---@field mod string
---@field tags table<string, true>
---@field maxCount integer
local Item = require("class"):extend("Item")

function Item:init(name, tags, mod, maxCount)
    self.name = name
    self.tags = tags
    self.mod = mod or "split item name by colon"
    self.maxCount = maxCount or 64
end

function Item:matches(item)
    return self.name == item.name and self.mod == item.mod
end

return Item