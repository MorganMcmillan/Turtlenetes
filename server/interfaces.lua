---@meta

-- Interface definitions. This file contains no code and is never required directly.

---@class Drawable3D
local Drawable3D

---Draws self to the buffer as a 3D object
---@param buffer Buffer3D
function Drawable3D:draw(buffer) end

---@class ItemProvider
local ItemProvider

---Checks if this provider has the specified item
---@param item Item
---@return boolean
function ItemProvider:providesItem(item) end

---Removes an item from this provider
---@param item Item
---@param count? integer
function ItemProvider:takeItem(item, count) end

---@class Iterator
local Iterator

function Iterator:iter() end

---@class ActionProvider
local ActionProvider

---@param actor any
function ActionProvider:initAction(actor) end

---@param actor any
function ActionProvider:act(actor) end

---@alias PhysicalInventory table<integer, { name: string, count: integer }>