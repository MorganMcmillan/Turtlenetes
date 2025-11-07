---@class ForBlock: class, BlocksInstruction
---@field condition BlocksExpression
---@field body BlocksScript
local ForBlock = require("class"):extend("IfBlock")

function ForBlock:init(condition, body)
    self.condition = condition
    self.body = body
end

function ForBlock:run(handler)
    local result = self.condition:evaluate(handler)
    local branch = self[result]
    if branch then
        handler:push(branch)
    end
end

return ForBlock