local BlocksInstruction = require("scripting.blocks.BlocksInstruction")

---@class BlocksScript: class, Serializable, UiComponent
---@field instructions BlocksInstruction[]
local BlocksScript = require("class"):extend("BlocksScript")

local types = require("SerClass").types

BlocksScript.schema = {
    {"instructions", types.array(BlocksInstruction)}
}

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

return BlocksScript