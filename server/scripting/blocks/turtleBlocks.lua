local BlocksInstruction = require("scripting.blocks.BlocksInstruction")
local BlocksExpression = require("scripting.BlocksExpression")

local function defineTurtleBlock(methodName, inputCount)
    local displayName = string.upper(methodName:sub(1, 1)) .. methodName:sub(2)
    local className = displayName .. "Block"
    local Block = BlocksInstruction:extend(className)
    Block.inputCount = inputCount
    Block.displayName = displayName

    if inputCount then
        function Block:run(handler)
            local evaluatedInputs = {}
            for i = 1, inputCount do
                evaluatedInputs[i] = self.inputs[i]:evaluate(handler)
            end
            local turtle = handler.variables.turtle
            return turtle[methodName](turtle, unpack(evaluatedInputs))
        end
    
        function Block:deserialize(reader)
            local inputs = {}
            for i = 1, inputCount do
                inputs[i] = BlocksExpression:deserialize(reader)
            end
            return self:new(inputs)
        end
    else
        function Block:run(handler)
            local turtle = handler.variables.turtle
            return turtle[methodName](turtle)
        end

        function Block:deserialize(_)
            -- Pass, return new
            return self:new()
        end
    end

    BlocksInstruction.instructions[className] = Block
end

local function defineTurtleBlockUpDown(command)
    for _, suffix in ipairs({"", "Up", "Down"}) do
        defineTurtleBlock(command .. suffix)
    end
end

defineTurtleBlock"getFuelLevel"
defineTurtleBlock"getInventory"
defineTurtleBlock("findItem", 1)
defineTurtleBlock("findItems", 1)
defineTurtleBlock("craft", 1)
defineTurtleBlock"getLeftPeripheral"
defineTurtleBlock"getRightPeripheral"
defineTurtleBlock"forward"
defineTurtleBlock"back"
defineTurtleBlock"up"
defineTurtleBlock"down"
defineTurtleBlockUpDown"dig"
defineTurtleBlockUpDown"place"
defineTurtleBlockUpDown"drop"
defineTurtleBlockUpDown"suck"
defineTurtleBlockUpDown"compare"
defineTurtleBlockUpDown"inspect"
defineTurtleBlock"turnLeft"
defineTurtleBlock"turnRight"