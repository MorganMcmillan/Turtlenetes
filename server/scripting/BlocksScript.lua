---@class BlocksScript
---@field instructions BlocksInstruction[]
local BlocksScript = require("class"):extend("BlocksScript")

function BlocksScript:init(instructions)
    self.instructions = instructions or {}
end

function BlocksScript:tick(handler, instruction)
    return self.instructions[instruction]:run(handler)
end