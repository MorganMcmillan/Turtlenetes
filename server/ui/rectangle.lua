-- rectangle.lua: a collection of utilities for drawing rectangles

local rectangle = {}

---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@param color integer
function rectangle.draw(x, y, width, height, color)
    paintutils.drawFilledBox(x, y, x + width, y + height, color)
end

---Draws text centered within a rectangle
---Does not support line-breaks
---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@param text string
---@param bg? integer
---@param fg? integer
function rectangle.drawTextCentered(x, y, width, height, text, bg, fg)
    bg = bg or colors.black
    fg = fg or colors.white
	-- Width allowed with 1 character of padding on each end
	local width = width - 2

    -- Center y
    local cy = height - math.floor(y / 2)
    -- Center x
    local textWidth = #text
	local cx = ((width - textWidth) / 2) + x + 1

    -- Draw
    term.setCursorPos(cx, cy)
    term.setBackgroundColor(bg)
    term.setTextColor(fg)
    term.write(text)
end

---@param x integer
---@param y integer
---@param text string
---@param bg? integer
---@param fg? integer
function rectangle.drawText(x, y, text, bg, fg)
    term.setCursorPos(x, y)
    term.setBackgroundColor(bg or colors.black)
    term.setTextColor(fg or colors.white)
    term.write(text)
end

return rectangle