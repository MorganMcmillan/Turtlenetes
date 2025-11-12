-- TODO: this block will be finished later

---@class ForBlock: class, BlocksInstruction
---@field body BlocksScript
---@field first number
---@field last number
---@field step number
---@field current number
local ForBlock = require("Block"):extend("ForBlock")
ForBlock.displayName = "For"
ForBlock.inputCount = 3
ForBlock.branchCount = 1

function ForBlock:init(handler)
    self.super.init(self, handler)
    self:initLoop(handler)
end

function ForBlock:initLoop(handler)
    local
        first,
        last,
        step
        =
        handler:getVariable(self.inputs[1]),
        handler:getVariable(self.inputs[2]),
        handler:getVariable(self.inputs[3])

    if step == 0 then error("Step value cannot be zero") end
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
        self:initLoop(handler)
    end
end

return ForBlock