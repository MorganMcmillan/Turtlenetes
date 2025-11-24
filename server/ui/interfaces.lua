---@class UiComponent
local UiComponent

function UiComponent:ui(...) end

---@class Clickable
local Clickable

---Handler for when the mouse clicks on an object
---@param mouseButton "left" | "right" | "middle"
---@param x integer
---@param y integer
function Clickable:onClick(mouseButton, x, y) end