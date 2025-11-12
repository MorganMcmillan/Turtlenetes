---@class VariableAccessor: BlocksExpression
---@field path VariablePath
local VariableAccessor = require("BlocksExpression"):extend("VariableAccessor")

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