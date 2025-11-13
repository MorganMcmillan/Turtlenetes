---@class ItemFilter: class, Serializable
local ItemFilter = require("class"):extend("ItemFilter")

local function listToSet(list)
    local set = {}
    for i = 1, #list do
        set[list[i]] = true
    end
    return set
end

function ItemFilter:init(items, tags)
    self.items = items and listToSet(items)
    self.tags = tags and listToSet(tags)
end

function ItemFilter:addItem(item)
    self.items[item] = true
end

function ItemFilter:addTag(tag)
    self.tags[tag] = true
end

function ItemFilter:removeItem(item)
    self.items[item] = nil
end

function ItemFilter:removeTag(tag)
    self.tags[tag] = nil
end

---Checks that an item matches this filter
---@param item Item
---@return boolean
function ItemFilter:matches(item)
    if self.items and self.items[item] then
        return true
    elseif self.tags then
        -- TODO: tag matching currently only checks if all tags match
        -- Perhaps there could be an interface for tag matching or an entire query language
        for _, tag in ipairs(item.tags) do
            if not self.tags[tag] then
                return false
            end
        end
        return true
    end
    return false
end