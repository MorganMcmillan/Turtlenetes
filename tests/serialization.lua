-- Run commands:
-- cd server
-- lua5.4 ../tests/serialization.lua

-- TODO: this file needs to be rewritten for SerClass

colors = {}

---@type xtest
local x = loadfile("../tests/xtest.lua")()

local SerClass = require("SerClass")
local Volume = require("Volume")
local BlocksInstruction = require("scripting.blocks.BlocksInstruction")
require("scripting.blocks.turtleBlocks")

local function test(value, typename)
    local serialized = SerClass.serialize(value, typename)
    local deserialized = SerClass.deserialize(typename, serialized)
    x.assertEq(value, deserialized)
end

x.run{
    "Primitives deserialize correctly",
    function ()
        test(50, "u8")
        test(50, "u16")
        test(50, "u32")
        test(-50, "i8")
        test(-500, "i16")
        test(-5000000, "i32")
        test("hello world", "string")
    end,

    "Classes deserialize correctly",
    function ()
        local v = Volume:new(0, 1, 2, 3, 4, 5)
        test(v, Volume)
    end,

    "Arrays of primitives deserialize correctly",
    function ()
        test({1, 2, 3, 4}, "u8")
        test({1, 2, 323, 4}, "u16")
        test({10000000, 2, 3, 4}, "u32")
        test({1, -100, 3, 4}, "i8")
        test({1, -2, 3, 400}, "i16")
        test({1, 2, -30000000, 4}, "i32")
        test({"hello", "there", "world"}, "string")
    end,

    "Arrays of classes deserialize correctly",
    function ()
        local volumes = {
            Volume:new(1, 2, 3, 4, 5, 6),
            Volume:new(2, 3, 4, 5, 6, 7),
            Volume:new(10, 15, 20, 5, 5, 5),
        }

        test(volumes, SerClass.types.array(Volume))
    end,

    "Subclasses deserialize correctly",
    function ()
        local BlocksExpression = require("scripting.BlocksExpression")

        test(BlocksInstruction.instructions.DigBlock:new(), BlocksInstruction)
        test(BlocksInstruction.instructions.ForwardBlock:new(), BlocksInstruction)
        test(BlocksInstruction.instructions.TurnLeftBlock:new(), BlocksInstruction)
        test(BlocksInstruction.instructions.FindItemBlock:new(BlocksExpression.expressions.ConcatExpression:new()), BlocksInstruction)
    end
}