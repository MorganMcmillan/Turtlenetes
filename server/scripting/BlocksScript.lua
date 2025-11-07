---@class BlocksScript
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
    end
    handler:pop()
end