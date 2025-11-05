---@class Chest: OrientedBlock, ItemProvider, Serializable
---@field filter Item | ItemFilter | nil
---@field connectedChest Chest | nil
---@field inventory Item[]
local Chest = require("OrientedBlock"):extend("Chest")

function Chest:updateInventory()
-- TODO
end

function Chest:contains(item)
    
end

function Chest:providesItem(item)
    return filter:matches(item) and self:contains(item)
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