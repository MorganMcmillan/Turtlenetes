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

local types = require("SerClass").types
local BlocksScript = require("scripting.BlocksScript")
local BlocksExpression = require("scripting.BlocksExpression")

-- TODO: add the ability to read static fields from subclasses and use them for deserialization
-- probably save this for the far future
BlocksInstruction.schema = {
    {"branches", types.array(BlocksScript)},
    {"inputs", types.array(BlocksExpression)}
}

function BlocksInstruction:init(inputs, branches)
    if self.inputCount then
        self.inputs = inputs or {}
    end
    if self.branchCount then
        self.branches = branches or {}
    end
end

function BlocksInstruction:getHeight()
    local height = 1
    if self.branchCount then
        for i = 1, self.branchCount do
            height = height + self.branches[i]:getHeight() + 1 -- extra height for branch separator
        end
    end
    return height
end

local rectangle = require("ui.rectangle")
local floor = math.floor

function BlocksInstruction:ui(x, y, width, height)
    rectangle.draw(x, y, width, height, self.color)
    local tx = x + 1
    local ty = y + floor(height / 2) - 1
    tx = rectangle.drawText(tx, ty, self.displayName, self.color)

    -- Draw inputs
    if self.inputCount then
        for i = 1, self.inputCount do
            local input = self.inputs[i]
            tx = input:ui(tx, ty)
        end
    end

    -- Draw branches
    if self.branchCount then
        for i = 1, self.branchCount do
            local branch = self.branches[i]
            y = y + height
            branch:ui(x, y, width, height)

            -- Draw branch separator
            y = y + 1
            rectangle.draw(x, y, width, 1, self.color)
        end
    end
end

---Runs this block's code
---@param handler BlocksEventHandler
function BlocksInstruction:run(handler)
    error("Blocks must be subclassed with a `run` function to be used.")
end

return BlocksInstruction