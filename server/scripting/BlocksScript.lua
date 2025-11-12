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
    local length = #self.instructions
    writer:u16(length)
    for i = 1, length do
        self.instructions[i]:serialize(writer)
    end
end

function BlocksScript:deserialize(reader)
    local instructions = {}
    local length = reader:u16()
    for i = 1, length do
        instructions[i] = BlocksInstruction:deserialize(reader)
    end
    return self:new(instructions)
end

return BlocksScript