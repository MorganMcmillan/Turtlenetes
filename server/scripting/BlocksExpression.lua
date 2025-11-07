---@alias VariablePath (string|integer)[]
---@alias Constant number | string | boolean | nil

---Follows a list of variable names/indexes and returns what's found
---@param table table
---@param path VariablePath
---@return any
local function followVariablePath(table, path)
    for i = 1, #path do
        table = table[path[i]]
    end
    return table
end

---A binary expression
---@class BlocksExpression: class
---@field evaluate fun(self: self, handler: BlocksEventHandler): any
---@field operator string
---@field left VariablePath | Constant
---@field right VariablePath | Constant
local BlocksExpression = require("class"):extend("BlocksExpression")

function BlocksExpression:init(left, right)
    self.left = left
    self.right = right
end

-- Operations like addition, subtractions, concatenation, and comparisons are implemented as subclasses of BlocksExpression

local function defineBinaryExpression(name, operator)
    local className = name .. "Expression"
    local Expression = BlocksExpression:extend(className)
    local opFn = load("return function(a, b) return a " .. operator .. " b end")()

    function Expression:evaluate(handler)
        local left = self.left
        if type(left) == "table" then
            left = followVariablePath(handler, left)
        end
        local right = self.right
        if type(right) == "table" then
            right = followVariablePath(handler, right)
        end
        return opFn(left, right)
    end

    Expression.operator = operator
    BlocksExpression[className] = Expression
end

defineBinaryExpression("Add", "+")
defineBinaryExpression("Add", "+")
defineBinaryExpression("Mul", "*")
defineBinaryExpression("Div", "/")
defineBinaryExpression("Mod", "%")
defineBinaryExpression("Concat", "..")
defineBinaryExpression("Equal", "==")
defineBinaryExpression("NotEqual", "~=")
defineBinaryExpression("LessThan", "<")
defineBinaryExpression("LessThanEqual", "<=")
defineBinaryExpression("GreaterThan", ">")
defineBinaryExpression("GreaterThanEqual", ">=")
defineBinaryExpression("And", "and")
defineBinaryExpression("Or", "or")

return BlocksExpression