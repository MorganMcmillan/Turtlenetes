local split = require("stringUtils").split
local Item = require("Item")

---@class ItemRepository: class, Serializable
---@field items table<string, Item>
local ItemRepository = require("class"):extend("ItemRepository")

function ItemRepository:get(name)
    local name, modname = split(name, ":")
    local item = self.items[name]
    if item then return item end

    item = Item:new(name, {}, modname)
    self.items[name] = item
    return item
end

function ItemRepository:serialize(writer)
    local count = 0
    for _ in pairs(self.items) do
        count = count + 1
    end
    writer:u16(count)

    for name, item in pairs(self.items) do
        writer:string(name)
        item:serialize(writer)
    end
end

function ItemRepository:deserialize(reader)
    local items = {}
    local count = reader:u16()
    for i = 1, count do
        local name = reader:string()
        local item = Item:deserialize(reader)
        items[name] = item
    end
    return self:create({ items = items })
end