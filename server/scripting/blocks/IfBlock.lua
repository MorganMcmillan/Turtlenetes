---@class IfBlock: class, BlocksInstruction
---@field [true] BlocksScript
---@field [false] BlocksScript
local IfBlock = require("class"):extend("IfBlock")
IfBlock.name = "If"
IfBlock.inputs = 1
IfBlock.branches = 2

function IfBlock:init(handler)
    self[true] = self.branches[1]
    self[false] = self.branches[2]
end

function IfBlock:run(handler)
    local condition = self.inputs[1]
    local result = condition and condition:evaluate(handler)
    local branch = self[result]
    if branch then
        handler:push(branch)
    end
end

return IfBlock