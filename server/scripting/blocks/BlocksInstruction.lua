---(Abstract)
---@class BlocksInstruction: class, UiComponent, SerializeSubclassMixin
---@field displayName string
---@field inputCount integer | nil
---@field branchCount integer | nil
---@field inputs BlocksExpression[] | nil
---@field branches BlocksScript[] | nil
---@field color integer
---@field instructions table<string, BlocksInstruction>
local BlocksInstruction = require("class"):extend("BlocksInstruction")
BlocksInstruction:with(require("SerializeSubclassMixin"))
BlocksInstruction.subclasses = {}
BlocksInstruction.instructions = {}
BlocksInstruction.color = colors.yellow

function BlocksInstruction:init(inputs, branches)
    if self.inputCount then
        self.inputs = inputs or {}
    end
    if self.branchCount then
        self.branches = branches or {}
    end
end

function BlocksInstruction:ui(x, y)
    --TODO: figure out how to draw blocks, especially ones with multiple branches
end

function BlocksInstruction:serialize(writer)
    self:serializeTag(writer)
    for i = 1, self.inputCount or 0 do
        self.inputs[i]:serialize(writer)
    end
    for i = 1, self.branchCount or 0 do
        self.branches[i]:serialize(writer)
    end
end

---Runs this block's code
---@param handler BlocksEventHandler
function BlocksInstruction:run(handler)
    error("Blocks must be subclassed with a `run` function to be used.")
end

return BlocksInstruction