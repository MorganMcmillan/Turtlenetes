---@meta
---Interface definition for Turtle.lua: Used because turtle methods are automatically generated.

---@class ITurtle
local ITurtle

---@param item string
function ITurtle:findItem(item) end

---@param items string[]
function ITurtle:findItems(items) end

---@param item string
---@param amount? integer
function ITurtle:craft(item, amount) end