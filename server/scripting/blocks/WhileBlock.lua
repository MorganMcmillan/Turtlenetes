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

return WhileBlock