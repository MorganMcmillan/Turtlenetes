local BlocksExpression = require("scripting.BlocksExpression")
local BlocksScript = require("BlocksScript")
-- TODO: this block will be finished later

---@class ForBlock: BlocksInstruction
---@field body BlocksScript
---@field first number
---@field last number
---@field step number
---@field current number
local ForBlock = require("scripting.blocks.BlocksInstruction"):extend("ForBlock")
ForBlock.displayName = "For"
ForBlock.inputCount = 3
ForBlock.branchCount = 1

function ForBlock:init(first, last, step, body)
    self.super.init(self, {first, last, step}, {body})
end

function ForBlock:deserialize(reader)
    local first = BlocksExpression:deserialize(reader)
    local last = BlocksExpression:deserialize(reader)
    local step = BlocksExpression:deserialize(reader)
    local body = BlocksScript:deserialize(reader)
    return self:new(first, last, step, body)
end

function ForBlock:initLoop(handler)
    local
        first,
        last,
        step
        =
        self.inputs[1]:evaluate(handler)
        self.inputs[2]:evaluate(handler)
        self.inputs[3]:evaluate(handler)

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