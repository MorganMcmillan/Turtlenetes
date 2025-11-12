-- Interface definitions. This file contains no code and is never required directly.

---@class Drawable3D
---@field draw fun(self: self, buffer: Buffer3D)

---@class Serializable
---@field serialize fun(self: self, writer: BinaryWriter)
---@field deserialize fun(self: self, reader: BinaryReader): self

---@class ItemProvider
---@field providesItem fun(self: self, item: Item): boolean
---@field takeItem fun(self: self, item: Item)

---@alias PhysicalInventory table<integer, { name: string, count: integer }>