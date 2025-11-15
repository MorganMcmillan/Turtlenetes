---@class Event: class
---@field repository table<table, Event> (Static)
---@field eventData table
local Event = require("class"):extend("Event")
Event.repository = {}

-- TODO: figure out how events are going to be created, managed, and compared
-- I specifically need a way to get the same instance with the same input.

function Event:new(eventData)
    local cachedEvent = Event:findEvent(eventData)
    if cachedEvent then
        return cachedEvent
    end
    local event = Event:create({eventData = eventData})
    Event.repository[eventData] = event
    return event
end

---@private
function Event:findEvent(eventData)
    for _, event in pairs(self.repository) do
        if event:match(eventData) then
            return event
        end
    end
end

function Event:match(data)
    for k, v in pairs(data) do
        if self.eventData[k] ~= v then return false end
    end
    return true
end

return Event