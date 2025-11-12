---@alias VariablePath (string|integer)[]
---@alias Constant number | string | boolean | nil

---A binary expression
---@class BlocksExpression: class, Serializable
---@field evaluate fun(self: self, handler: BlocksEventHandler): any
---@field operator string
---@field inputs BlocksExpression[] | nil
---@field inputCount integer
---@field subclasses BlocksExpression[]
local BlocksExpression = require("class"):extend("BlocksExpression")
BlocksExpression.subclasses = {}

function BlocksExpression:init()
    if self.inputCount then
        self.inputs = {}
    end
end

-- Because deserialization creates a subclass, we need to know ahead-of-time what that subclass is
function BlocksExpression:__extend(subclass)
    local subclasses = self.subclasses
    subclasses[#subclasses+1] = subclass
    subclass.serializationTag = #subclasses
end

function BlocksExpression:deserialize(reader)
    local tag = reader:u8()
    local Expression = self.subclasses[tag]
    return Expression:deserialize(reader)
end

-- Operations like addition, subtractions, concatenation, and comparisons are implemented as subclasses of BlocksExpression

local function defineBinaryExpression(name, operator)
    local className = name .. "Expression"
    local Expression = BlocksExpression:extend(className)
    Expression.inputCount = 2
    Expression.operator = operator

    local opFn = load("return function(a, b) return a " .. operator .. " b end")()

    function Expression:evaluate(handler)
        local left = self.inputs[1]
        if type(left) == "table" then
            left = left:evaluate(handler)
        end
        local right = self.inputs[2]
        if type(right) == "table" then
            right = right:evaluate(handler)
        end
        return opFn(left, right)
    end

    BlocksExpression[className] = Expression
end

defineBinaryExpression("Add", "+")
defineBinaryExpression("Sub", "-")
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

local NotExpression = BlocksExpression:extend("NotExpression")
NotExpression.inputCount = 1
NotExpression.operator = "Not"

function NotExpression:evaluate(handler)
    local value = self.inputs[1]
    if type(value) == "table" then
        value = value:evaluate(handler)
    end
    return not value
end

-- Needed for consistent serialization tag
require("BlocksVariableAccessor")

return BlocksExpression