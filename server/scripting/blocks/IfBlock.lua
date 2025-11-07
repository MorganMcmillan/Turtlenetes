---@class IfBlock: class, BlocksInstruction
---@field condition BlocksCondition
---@field [true] BlocksScript
---@field [false] BlocksScript
local IfBlock = require("class"):extend("IfBlock")

function IfBlock:init(condition, trueBranch, falseBranch)
    self.condition = condition
    self[true] = trueBranch
    self[false] = falseBranch
end

function IfBlock:run(handler)
    -- TODO: figure out how conditions are going to work in BlocksScript
    local result = self.condition:evaluate(handler)
    local branch = self[result]
    if branch then
        handler:push(branch)
    end
end