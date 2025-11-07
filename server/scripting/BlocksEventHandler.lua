local BlocksScript = require("BlocksScript")

---@class BlocksScriptState
---@field script BlocksScript
---@field instruction integer

---@class BlocksEventHandler: class
---@field handlers table<Event, BlocksScript>
---@field callStack BlocksScriptState[]
local BlocksEventHandler = require("class"):extend("BlocksEventHandler")

function BlocksEventHandler:init()
    self.handers = {}
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

---Triggers the script associated with this event
---@param event Event
function BlocksEventHandler:trigger(event)
    local handler = self.handlers[event]
    if handler then
        table.insert(self.callStack, { script = handler, instruction = 1})
    end
end