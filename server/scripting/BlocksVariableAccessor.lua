---@class VariableAccessor: BlocksExpression
---@field path VariablePath
local VariableAccessor = require("scripting.BlocksExpression"):extend("VariableAccessor")
VariableAccessor.color = colors.orange

local types = require("SerClass").types

VariableAccessor.schema = {
    {"path", types.array(types.string)}
}

function VariableAccessor:init(path)
    self.path = path
    self.operator = table.concat(path, ".")
end

function VariableAccessor:fromString(str)
    local path = {}
    for part in str:gmatch("[^.]+") do
        path[#path+1] = part
    end
    return self:new(path)
end

---@param handler BlocksEventHandler
---@return any
function VariableAccessor:evaluate(handler)
    return handler:getVariable(self.path)
end