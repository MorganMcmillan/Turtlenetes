local split = require("stringUtils").split
local Item = require("Item")

---@class ItemRepository: class, Serializable
---@field items table<string, Item>
local ItemRepository = require("class"):extend("ItemRepository")

local types = require("SerClass").types

ItemRepository.schema = {
    {"items", types.map(types.string, Item)}
}

function ItemRepository:get(name)
    local name, modname = split(name, ":")
    local item = self.items[name]
    if item then return item end

    item = Item:new(name, {}, modname)
    self.items[name] = item
    return item
end

return ItemRepository