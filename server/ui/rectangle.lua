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
	local cx = ((width - #text) / 2) + x + 1

    -- Draw
    term.setCursorPos(cx, cy)
    term.setBackgroundColor(bg)
    term.setTextColor(fg)
    term.write(text)
end

---Draws text wrapped around a box
---@param x integer
---@param y integer
---@param width integer
---@param text string
---@param bg? integer
---@param fg? integer
function rectangle.drawTextWrapped(x, y, width, height, text, bg, fg)
    -- Split text into lines long enough to fit into width
    term.setTextColor(fg or colors.white)
    term.setBackgroundColor(bg or colors.black)
    for i = 1, #text, width do
        term.setCursorPos(x, y)
        term.write(text:sub(i, i + width - 1))
        y = y + 1
        if y > height then return end
    end
end

---@param x integer
---@param y integer
---@param text string
---@param bg? integer
---@param fg? integer
---@return integer x
function rectangle.drawText(x, y, text, bg, fg)
    term.setCursorPos(x, y)
    term.setBackgroundColor(bg or colors.black)
    term.setTextColor(fg or colors.white)
    term.write(text)
    return x + #text
end

return rectangle