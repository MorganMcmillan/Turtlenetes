---@meta

-- Interface definitions. This file contains no code and is never required directly.

---@class Drawable3D
local Drawable3D

---Draws self to the buffer as a 3D object
---@param buffer Buffer3D
function Drawable3D:draw(buffer) end

---@class Serializable
local Serializable

---Serializes this object into a binary format
---@param writer BinaryWriter
function Serializable:serialize(writer) end

---Deserializes this object from a binary format
---@param reader BinaryReader
---@return self
function Serializable:deserialize(reader) end

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

---@alias PhysicalInventory table<integer, { name: string, count: integer }>