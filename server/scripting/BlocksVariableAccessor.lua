---@class VariableAccessor: BlocksExpression
---@field path VariablePath
local VariableAccessor = require("BlocksExpression"):extend("VariableAccessor")
VariableAccessor.color = colors.orange

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

---@param writer BinaryWriter
function VariableAccessor:serialize(writer)
    self:serializeTag(writer)
    writer:arrayOf(writer.string, self.path)
end

function VariableAccessor:deserialize(reader)
    return self:new(reader:arrayOf(reader.string))
end

---@param handler BlocksEventHandler
---@return any
function VariableAccessor:evaluate(handler)
    return handler:getVariable(self.path)
end