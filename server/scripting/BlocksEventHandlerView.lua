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

    y = y + 1

    -- Draw vertical scrollbar

    -- Draw empty gray box
    rectangle.draw(x, y, width, height)

    for i = 1, #self.eventOrder do
        local event = self.eventOrder[i]

    end
end