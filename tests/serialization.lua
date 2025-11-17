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

x.run{
    "Primitives deserialize correctly",
    function ()
        local function test(value, typename)
            local writer = BinaryWriter:new()
            writer[typename](writer, value)
            local reader = BinaryReader:new(writer:__tostring())
            local deserialized = reader[typename](reader)
            x.assertEq(value, deserialized)
        end

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
        local function test(value, class)
            local writer = BinaryWriter:new()
            value:serialize(writer)
            local reader = BinaryReader:new(writer:__tostring())
            local deserialized = class:deserialize(reader)
            x.assertDeepEq(value, deserialized)
        end
    
        local v = Volume:new(0, 1, 2, 3, 4, 5)
        test(v, Volume)
    end,

    "Arrays of primitives deserialize correctly",
    function ()
        local function test(value, typename)
            local writer = BinaryWriter:new()
            writer:arrayOf(writer[typename], value)
            local reader = BinaryReader:new(writer:__tostring())
            local deserialized = reader:arrayOf(reader[typename])
            x.assertShallowEq(value, deserialized)
        end

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
        local function test(value, class)
            print(x.stringify(value))
            local writer = BinaryWriter:new()
            writer:arrayOfClass(value)
            local bin = writer:__tostring()
            print(string.format("%q", bin))
            local reader = BinaryReader:new(bin)
            local deserialized = reader:arrayOfClass(class)
            x.assertDeepEq(value, deserialized)
        end

        local volumes = {
            Volume:new(1, 2, 3, 4, 5, 6),
            Volume:new(2, 3, 4, 5, 6, 7),
            Volume:new(10, 15, 20, 5, 5, 5),
        }

        test(volumes, Volume)
    end,

    "Subclasses deserialize correctly",
    function ()
        local function test(value, class)
            local writer = BinaryWriter:new()
            value:serialize(writer)
            local reader = BinaryReader:new(writer:__tostring())
            x.debug(reader.contents)
            local deserialized = class:deserialize(reader)
            x.assertEq(getmetatable(value), getmetatable(deserialized))
        end

        local BlocksExpression = require("scripting.BlocksExpression")

        test(BlocksInstruction.instructions.DigBlock:new(), BlocksInstruction)
        test(BlocksInstruction.instructions.ForwardBlock:new(), BlocksInstruction)
        test(BlocksInstruction.instructions.TurnLeftBlock:new(), BlocksInstruction)
        test(BlocksInstruction.instructions.FindItemBlock:new(BlocksExpression.expressions.ConcatExpression:new()), BlocksInstruction)


    end
}