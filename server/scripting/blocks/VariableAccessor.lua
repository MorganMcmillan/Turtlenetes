---@alias VariableAccessor fun(): any

---@param table table
---@param path VariablePath
---@return VariableAccessor
function VariableAccessor(table, path)
    return function()
        local value = table
        for i = 1, #path do
            value = value[path[i]]
        end
        return value
    end
end

return VariableAccessor