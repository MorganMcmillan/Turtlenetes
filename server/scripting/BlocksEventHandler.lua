---@class BlocksScriptState
---@field script BlocksScript
---@field instruction integer

---@class BlocksEventHandler: class, Serializable
---@field handlers table<Event, BlocksScript>
---@field callStack BlocksScriptState[]
---@field variables table
local BlocksEventHandler = require("class"):extend("BlocksEventHandler")

local types = require("SerClass").types
local Event = require("scripting.Event")
local BlocksScript = require("scripting.BlocksScript")

BlocksEventHandler.schema = {
    {"handlers", types.map(Event, BlocksScript)}
}

function BlocksEventHandler:init(variables)
    self.handlers = {}
    self.callStack = {}
    self.variables = variables or {}
end

---Sets the currently active turtle to this turtle
---@param turtle Turtle
function BlocksEventHandler:setCurrentTurtle(turtle)
    self.variables.turtle = turtle
end

function BlocksEventHandler:addEvent(event, script)
    self.handlers[event] = script
end

---Ticks the current script
---@return any | false, string | nil
function BlocksEventHandler:tick()
    local state = self.callStack[#self.callStack]
    if not state then return false, "No script currently associated with handler" end
    local output = state.script:tick(self, state.instruction)
    state.instruction = state.instruction + 1
    return output
end

---Pushes the next script onto the call stack
---@param script BlocksScript
function BlocksEventHandler:push(script)
    table.insert(self.callStack, { script = script, instruction = 1})
end

---Returns from the last script
function BlocksEventHandler:pop()
    self.callStack[#self.callStack] = nil
end

---Jumps back by one instruction. Used to enable loops.
function BlocksEventHandler:jumpBack()
    local state = self.callStack[#self.callStack]
    state.instruction = state.instruction - 1
end

---Returns a variable from the handler by following the path
---@param path VariablePath
---@return any | nil
function BlocksEventHandler:getVariable(path)
    local variable = self.variables
    if type(path) ~= "table" then return end
    for i = 1, #path do
        variable = variable[path[i]]
    end
    return variable
end

---Triggers the script associated with this event
---@param event Event
function BlocksEventHandler:trigger(event)
    local handler = self.handlers[event]
    if handler then
        table.insert(self.callStack, { script = handler, instruction = 1})
    end
end