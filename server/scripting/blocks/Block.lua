---@class BlocksInstruction: class, UiComponent
---@field displayName string
---@field inputCount integer | nil
---@field branchCount integer | nil
---@field inputs VariablePath[] | nil
---@field branches BlocksScript[] | nil
local BlocksInstruction = require("class"):extend("BlocksInstruction")

local function fillFalse(count)
    local filled = {}
    for i = 1, count do
        filled[i] = false
    end
    return filled
end

---@param handler BlocksEventHandler
function BlocksInstruction:init(handler)
    if self.inputCount then
        self.inputs = fillFalse(self.inputCount)
    end
    if self.branchCount then
        self.branches = fillFalse(self.branchCount)
    end
end

---Runs this block's code
---@param handler BlocksEventHandler
function BlocksInstruction:run(handler)
    error("Blocks must be subclassed with a `run` function to be used.")
end