local BlocksInstruction = require("BlocksInstruction")

local function defineTurtleBlock(methodName, inputs)
    local displayName = string.upper(methodName:sub(1, 1)) .. methodName:sub(2)
    local className = displayName .. "Block"
    local Block = BlocksInstruction:extend(className)
    Block.inputCount = inputs
    Block.displayName = displayName

    function Block:run(handler)
        local evaluatedInputs = {}
        for i = 1, inputs do
            evaluatedInputs[i] = self.inputs[i]:evaluate(handler)
        end
        local turtle = handler.variables.turtle
        return turtle[methodName](turtle, unpack(evaluatedInputs))
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