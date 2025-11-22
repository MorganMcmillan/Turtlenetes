local scrollbar = {}

local min, floor = math.min, math.floor

local function calculateBarSize(width, rangeEnd)
    -- Lets say width is 5, current is 2, and end is 10.
    -- That means the inner content is twice as wide as the scrollbar
    -- Therefor the little draggy thing is half the size of the entire scrollbar
    -- min is used to prevent the draggy from being drawn offscreen
    return floor(width / rangeEnd)
end

local function calculateBarPosition(current, rangeEnd, width)
    -- If current is 2, end is 10, then it is 1/5 along width
    return floor(width * (current / rangeEnd))
end

function scrollbar.horizontal(x, y, width, current, rangeEnd, barColor, color)
    -- Current and rangeEnd are expected to be in pixels
    -- Which means the little thing you drag on has an exact size
    local x2 = x + width - 1
    paintutils.drawLine(x, y, x2, y, color or colors.gray)

    local barSize = calculateBarSize(width, rangeEnd)
    local barPosition = x + calculateBarPosition(current, rangeEnd, width)

    paintutils.drawLine(barPosition, y, min(x2 ,barPosition + barSize - 1), y, barColor or colors.lightGray)
end

function scrollbar.vertical(x, y, height, current, rangeEnd, barColor, color)
    local y2 = y + height - 1
    paintutils.drawLine(x, y, x, y2, color or colors.gray)

    local barSize = calculateBarSize(height, rangeEnd)
    local barPosition = y + calculateBarPosition(current, rangeEnd, height)

    paintutils.drawLine(x, barPosition, x, min(y2 ,barPosition + barSize - 1), barColor or colors.lightGray)
end

return scrollbar