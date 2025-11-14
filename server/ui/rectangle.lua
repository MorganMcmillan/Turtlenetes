-- rectangle.lua: a collection of utilities for drawing rectangles

local rectangle = {}

---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@param color integer
---@return integer x, integer y next coordinates (horizontal or vertical exclusive)
function rectangle.draw(x, y, width, height, color)
    local x2, y2 = x + width, y + height
    local sWidth, sHeight = term.getSize()
    
    -- Check if on screen, and cull if not
    if not (
        x <= 0 and x2 <= 0 or
        y <= 0 and y2 <= 0 or
        x > sWidth and x2 > sWidth or
        y > sHeight and y2 > sHeight
    ) then
        paintutils.drawFilledBox(x, y, x2, y2, color)
    end
    return x2 + 1, y2 + 1
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