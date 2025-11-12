local rectangle = require("rectangle")

---@alias VariablePath (string|integer)[]
---@alias Constant number | string | boolean | nil

---A binary expression
---@class BlocksExpression: class, Serializable
---@field evaluate fun(self: self, handler: BlocksEventHandler): any
---@field inputs BlocksExpression[] | nil
---@field inputCount integer
---@field operator string
---@field color integer
---@field private subclasses BlocksExpression[]
---@field private serializationTag integer
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

---Writes this class's serialization tag
---This method MUST be called on every subclass that implements serialization
---@param writer BinaryWriter
function BlocksExpression:serializeTag(writer)
    writer:u8(self.serializationTag)
end

---@param reader BinaryReader
function BlocksExpression:deserialize(reader)
    local tag = reader:u8()
    local subclass = self.subclasses[tag]
    return subclass:deserialize(reader)
end

function BlocksExpression:draw(x, y)
    local color = self.color
    paintutils.drawPixel(x, y, color)
    x = x + 1

    if self.inputCount == 2 then
        x = self.inputs[1]:draw(x, y)
        paintutils.drawPixel(x, y, color)
        x = x + 1
        x = rectangle.drawText(x, y, self.operator, color)
        paintutils.drawPixel(x, y, color)
        x = x + 1
        x = self.inputs[2]:draw(x, y)
        paintutils.drawPixel(x, y, color)
        
    else
        x = rectangle.drawText(x, y, self.operator, color)
        paintutils.drawPixel(x, y, color)
        x = x + 1
        if self.inputCount then
            for i = 1, self.inputCount do
                x = self.inputs[i]:draw(x, y)
                paintutils.drawPixel(x, y, color)
                x = x + 1
            end
        end
    end

    paintutils.drawPixel(x, y, color)
    return x + 1
    -- Draw enclosing "[ ]" to signify where the expression is
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

    function Expression:serialize(writer)
        self:serializeTag(writer)
        for i = 1, self.inputCount do
            self.inputs[i]:serialize(writer)
        end
    end

    function Expression:deserialize(reader)
        local instance = self:new()
        for i = 1, instance.inputCount do
            instance.inputs[i] = BlocksExpression:deserialize(reader)
        end
        return instance
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

function NotExpression:serialize(writer)
    self:serializeTag(writer)
    self.inputs[1]:serialize(writer)
end

function NotExpression:deserialize(reader)
    local instance = self:new()
    instance.inputs[1] = BlocksExpression:deserialize(reader)
    return instance
end

return BlocksExpression