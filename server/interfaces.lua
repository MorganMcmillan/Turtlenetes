-- Interface definitions. This file contains no code and is never required directly.

---@class Drawable3D
---@field draw fun(self: self, buffer: Buffer3D)

---@class Drawable2D
---@field draw fun(self: self, buffer: Buffer2D)

---@class Serializable
---@field serialize fun(self: self, buffer: StringBuffer)
---@field deserialize fun(self: self, contents: string): self