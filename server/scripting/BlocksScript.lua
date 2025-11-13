local BlocksInstruction = require("BlocksInstruction")

---@class BlocksScript: class, Serializable
---@field instructions BlocksInstruction[]
local BlocksScript = require("class"):extend("BlocksScript")

function BlocksScript:init(instructions)
    self.instructions = instructions or {}
end

---Runs a single block instruction
---@param handler BlocksEventHandler
---@param pc integer
---@return any
function BlocksScript:tick(handler, pc)
    local instruction = self.instructions[pc]
    if instruction then
        return instruction:run(handler)
    else
        handler:pop()
    end
end

function BlocksScript:serialize(writer)
    writer:arrayOfClass(self.instructions)
end

function BlocksScript:deserialize(reader)
    return self:new(reader:arrayOfClass(BlocksInstruction))
end

return BlocksScript