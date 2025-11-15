---Allows deserializing subclasses by associating them with a tag.
---This requires the classes to be subclassed in a specific order, otherwise the wrong class will be deserialized.
---Note: `subclasses` static field needs to be added manually.
---@class SerializeSubclassMixin: Serializable
---@field serializationTag integer
---@field subclasses self[]
local SerializeSubclassMixin = {}

-- Because deserialization creates a subclass, we need to know ahead-of-time what that subclass is
function SerializeSubclassMixin:__extend(subclass)
    local subclasses = self.subclasses
    subclasses[#subclasses+1] = subclass
    subclass.serializationTag = #subclasses
end

return SerializeSubclassMixin
