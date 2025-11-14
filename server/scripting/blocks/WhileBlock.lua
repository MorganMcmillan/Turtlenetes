local BlocksExpression = require("scripting.BlocksExpression")
local BlocksScript = require("BlocksScript")

---@class WhileBlock: BlocksInstruction
local WhileBlock = require("scripting.blocks.BlocksInstruction"):extend("WhileBlock")
WhileBlock.displayName = "While"
WhileBlock.inputCount = 1
WhileBlock.branchCount = 1

---@param handler BlocksEventHandler
function WhileBlock:run(handler)
    local condition = self.inputs[1]:evaluate(handler)
    if condition then
        handler:jumpBack()
        handler:push(self.branches[1])
    end
end

function WhileBlock:deserialize(reader)
    local condition = BlocksExpression:deserialize(reader)
    local body = BlocksScript:deserialize(reader)
    return self:new({condition}, {body})
end

return WhileBlock