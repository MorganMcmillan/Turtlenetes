---@class ForBlock: class, BlocksInstruction
---@field body BlocksScript
---@field first number
---@field last number
---@field step number
---@field current number
local ForBlock = require("class"):extend("ForBlock")
ForBlock.name = "For"
ForBlock.inputs = 3

function ForBlock:init(body, first, last, step)
    if step == 0 then error("Step value cannot be zero") end
    self.body = body
    if not last then
        last = first
        first = 1
    end
    self.first = first
    self.last = last
    self.step = step or 1
    self.current = first
end

---@param handler BlocksEventHandler
function ForBlock:run(handler)
    local condition = self.step > 0 and self.current >= self.last or self.current <= self.first
    if condition then
        self.current = self.current + self.step
        handler:jumpBack()
        handler:push(self.body)
    else
        handler:initBlock(self)
    end
end

return ForBlock