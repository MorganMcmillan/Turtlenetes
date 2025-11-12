---@class WhileBlock: class, BlocksInstruction
---@field condition BlocksExpression
local WhileBlock = require("class"):extend("WhileBlock")
WhileBlock.displayName = "While"
WhileBlock.inputs = 1
WhileBlock.branches = 1

function WhileBlock:init(body, condition)
    self.condition = condition
    self.body = body
end

---@param handler BlocksEventHandler
function WhileBlock:run(handler)
    local condition = self.condition:evaluate(handler)
    if condition then
        handler:jumpBack()
        handler:push(self.body)
    end
end

return WhileBlock