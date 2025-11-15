local Block = require("Block")
local Item = require("Item")
local ItemFilter = require("ItemFilter")
local Inventory = require("Inventory")
local SerClass = require("SerClass")
local types = SerClass.types

---@class Chest: OrientedBlock, ItemProvider, Serializable
---@field filter Item | ItemFilter | nil
---@field connectedChest Chest | nil
---@field inventory Item[]
local Chest = require("OrientedBlock"):extend("Chest")
Chest.serializationTag = 2
Block.subclasses[2] = Chest

Chest.schema = {
    super = Chest.super,
    {"filter", types.either(Item, ItemFilter)},
    {"inventory", Inventory}
}

function Chest:updateInventory()
-- TODO
end

---Checks if the item is in the inventory and returns its index
---@param item Item
---@return integer | nil
function Chest:contains(item)
    -- TODO: add a map cache for items, perhaps create an inventory class
    local inventory = self.inventory
    for i = 1, #inventory do
        local inventoryItem = inventory[i]
        if inventoryItem and inventoryItem:matches(item) then
            return i
        end
    end
end

function Chest:providesItem(item)
    local matches
    if self.filter then
        matches = self.filter:matches(item)
    else
        matches = true
    end

    return matches and self:contains(item)
end

function Chest:takeItem(item, count)
    for i, v in pairs(self.inventory) do
        if v == item then
            -- TODO
            self.inventory[i] = nil
        end
    end

    local connectedChest = self.connectedChest
    if connectedChest then
        for i, v in pairs(connectedChest.inventory) do
            if v == item then
                -- TODO
                connectedChest.inventory[i] = nil
            end
        end
    end
end