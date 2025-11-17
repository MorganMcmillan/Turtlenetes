local rectangle = require("ui.rectangle")

---@alias VariablePath (string|integer)[]
---@alias Constant number | string | boolean | nil

---A binary expression
---@class BlocksExpression: class, UiComponent, SerializeSubclassMixin
---@field evaluate fun(self: self, handler: BlocksEventHandler): any
---@field inputs BlocksExpression[] | nil
---@field inputCount integer
---@field operator string
---@field color integer
---@field expressions table<string, BlocksExpression>
local BlocksExpression = require("class"):extend("BlocksExpression")
BlocksExpression:with(require("SerializeSubclassMixin"))
BlocksExpression.subclasses = {}
BlocksExpression.color = colors.lime
BlocksExpression.expressions = {}

local types = require("SerClass").types

BlocksExpression.schema = {
    {"inputs", types.array(BlocksExpression)}
}

function BlocksExpression:init()
    if self.inputCount then
        self.inputs = {}
    end
end

function BlocksExpression:ui(x, y)
    local color = self.color
    -- Draw enclosing "[ ]" to signify where the expression is
    x = rectangle.drawText(x, y, "[", color)

    if self.inputCount == 2 then
        x = self.inputs[1]:ui(x, y)
        paintutils.drawPixel(x, y, color)
        x = x + 1
        x = rectangle.drawText(x, y, self.operator, color)
        paintutils.drawPixel(x, y, color)
        x = x + 1
        x = self.inputs[2]:ui(x, y)
        paintutils.drawPixel(x, y, color)
        
    else
        x = rectangle.drawText(x, y, self.operator, color)
        paintutils.drawPixel(x, y, color)
        x = x + 1
        if self.inputCount then
            for i = 1, self.inputCount do
                x = self.inputs[i]:ui(x, y)
                paintutils.drawPixel(x, y, color)
                x = x + 1
            end
        end
    end

    return rectangle.drawText(x, y, "]", color)
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
        left = left:evaluate(handler)
        local right = self.inputs[2]
        right = right:evaluate(handler)
        return opFn(left, right)
    end

    BlocksExpression.expressions[className] = Expression
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

BlocksExpression.expressions.NotExpression = NotExpression

return BlocksExpression