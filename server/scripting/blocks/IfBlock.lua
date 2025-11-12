local BlocksExpression = require("BlocksExpression")
local BlocksScript = require("BlocksScript")

---@class IfBlock: BlocksInstruction
---@field [true] BlocksScript
---@field [false] BlocksScript
local IfBlock = require("BlocksInstruction"):extend("IfBlock")
IfBlock.displayName = "If"
IfBlock.inputs = 1
IfBlock.branches = 2

function IfBlock:init(condition, ifBranch, elseBranch)
    self.super.init(self, {condition}, {ifBranch, elseBranch})
    self[true] = ifBranch
    self[false] = elseBranch
end

function IfBlock:run(handler)
    local condition = self.inputs[1]
    local result = condition and condition:evaluate(handler)
    local branch = self[result]
    if branch then
        handler:push(branch)
    end
end

function IfBlock:deserialize(reader)
    local condition = BlocksExpression:deserialize(reader)
    local ifBranch = BlocksScript:deserialize(reader)
    local elseBranch = BlocksScript:deserialize(reader)
    return self:new(condition, ifBranch, elseBranch)
end

return IfBlock