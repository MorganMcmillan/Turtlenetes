---@class IfBlock: BlocksInstruction
---@field [true] BlocksScript
---@field [false] BlocksScript
local IfBlock = require("scripting.blocks.BlocksInstruction"):extend("IfBlock")
IfBlock.displayName = "If"
IfBlock.inputs = 1
IfBlock.branches = 2

function IfBlock:init(condition, ifBranch, elseBranch)
    IfBlock.super.init(self, {condition}, {ifBranch, elseBranch})
    self:initBranches()
end

function IfBlock:initBranches()
    self[true] = self.branches[1]
    self[false] = self.branches[2]
end

IfBlock.onDeserialize = IfBlock.initBranches

function IfBlock:run(handler)
    local condition = self.inputs[1]
    local result = condition and condition:evaluate(handler)
    local branch = self[result]
    if branch then
        handler:push(branch)
    end
end

return IfBlock