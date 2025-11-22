---@class BlocksEventHandlerView: class, UiComponent
---@field handler BlocksEventHandler
---@field eventOrder Event[]
---@field horizontalScrollbar integer
---@field verticalScrollbar integer
---@field width integer
---@field height integer
local BlocksEventHandlerView = require("class"):extend("BlocksEventHandlerView")

local BLOCKS_WIDTH = 16
local BLOCKS_HEIGHT = 3

local max = math.max

---@param handler BlocksEventHandler
function BlocksEventHandlerView:init(handler)
    self.handler = handler

    local handlerOrder = {}
    for event in pairs(handler.handlers) do
        handlerOrder[#handlerOrder+1] = event
    end
    self.eventOrder = handlerOrder
    self:recalculateSize()
end

function BlocksEventHandlerView:recalculateSize()
    local maxScriptHeight = 0
    for _, script in pairs(self.handler.handlers) do
        maxScriptHeight = max(maxScriptHeight, script:getHeight())
    end

    self.width = BLOCKS_WIDTH * #self.eventOrder
    self.height = BLOCKS_HEIGHT * maxScriptHeight
end

local rectangle = require("ui.rectangle")
local scrollbar = require("ui.scrollbar")

function BlocksEventHandlerView:ui(x, y, width, height)
    -- Draw horizontal scrollbar
    scrollbar.horizontal(x, y, width, self.horizontalScrollbar, self.width)
    y = y + 1
    height = height - 1

    -- Draw vertical scrollbar to the right
    scrollbar.vertical(width, y, height, self.verticalScrollbar, self.height)
    width = width - 1

    -- Draw empty gray box
    rectangle.draw(x, y, width, height, colors.lightGray)

    -- Draw event handler scripts
    for i = 1, #self.eventOrder do
        local event = self.eventOrder[i]
        local script = self.handler.handlers[event]

        -- Cull offscreen scripts
        local scriptX = x + self.horizontalScrollbar + (BLOCKS_WIDTH * (i - 1))
        if scriptX <= (x + width) and (scriptX + BLOCKS_WIDTH) > x then
            script:ui(x, y, BLOCKS_WIDTH, BLOCKS_HEIGHT)
        end
    end
end