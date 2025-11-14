---@class Item: class, Serializable
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

function Item:serialize(writer)
    writer:string(self.name)
    
    local tagCount = 0
    for _ in pairs(self.tags) do
        tagCount = tagCount + 1
    end
    writer:u16(tagCount)
    for tag in pairs(self.tags) do
        writer:string(tag)
    end

    writer:string(self.mod)
    writer:u8(self.maxCount)
end

function Item:deserialize(reader)
    local name = reader:string()
    
    local tags = {}
    local tagCount = reader:u16()
    for i = 1, tagCount do
        tags[reader:string()] = true
    end
    
    local mod = reader:string()
    local maxCount = reader:u8()
    return self:new(name, tags, mod, maxCount)
end

return Item