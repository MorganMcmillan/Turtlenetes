local types = require("SerClass").types
local Item = require("Item")

---@class Inventory: class, Serializable
---An abstract, server-side representation of an inventory
---@field lastEmptySlot integer the last empty slot since an item was added or removed
---@field itemsList [Item, integer][] the item and its count in this slot
---@field itemsMap table<Item, { totalCount: integer, [integer]: integer}> a mapping of items to their counts and a map of slots to individual slot counts
local Inventory = require("class"):extend("Inventory")

Inventory.schema = {
    {"lastEmptySlot", types.u16},
    {"itemsList", types.map(types.u16, types.tuple(Item, types.u8))}
}

---@param physicalInventory PhysicalInventory
---@param itemRepository ItemRepository
function Inventory:refresh(physicalInventory, itemRepository)
    self.itemsList = {}
    self.itemsMap = {}
    
    for i, itemData in pairs(physicalInventory) do
        local item = itemRepository:get(itemData.name)
        self.itemsList[i] = { item , itemData.count }

        local slotsRef = self.itemsMap[item] or { totalCount = 0 }
        slotsRef.totalCount = slotsRef.totalCount + itemData.count
        slotsRef[i] = itemData.count
        self.itemsMap[item] = slotsRef
    end
end

---Update the last empty slot to point at the one with no items in it.
function Inventory:updateLastEmptySlot()
    local i = self.lastEmptySlot
    while self[i] do
        i = i + 1
    end
    self.lastEmptySlot = i
end

---@param item Item
---@param count integer
function Inventory:addItem(item, count)
    count = count or 1
    slotsRef = self[item]
    if not slotsRef then
        -- TODO: handle counts higher than 64
        self[item] = { totalCount = count, [self.lastEmptySlot] = count }
        self[self.lastEmptySlot] = { item, count }
        self:updateLastEmptySlot()
    else
        -- Fill up currently empty slots
        for i, lastCount in pairs(slotsRef) do
            if count <= 0 then return end
            if i ~= "totalCount" and lastCount < item.maxCount then
                local emptyCount = item.maxCount - lastCount
                emptyCount = math.min(emptyCount, count)
                slotsRef[i] = lastCount + emptyCount
                count = count - emptyCount
            end
        end
    end
end