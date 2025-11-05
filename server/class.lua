-- Lua doesn't natively support OOP, so it needs to be programmed in manually using language constructs

---@class class
---@field name string
---@field super class
---@field init fun(self, ...)
local class = {name = "class"}
class.__index = class
function class:__tostring()
    return "class '" .. self.name .. "'"
end

--- @generic T
--- @param self T | class
--- @return T
function class:extend(name)
    local heir = setmetatable({name = name, super = self}, self)
    heir.__index = heir
    heir.__tostring = self.__tostring
    return heir
end

--- @generic T
--- @param self T | class
--- @return T
function class:new(...)
    local instance = setmetatable({}, self)
    local init = self.init
    if init then
        init(instance, ...)
    end
    return instance
end

function class:with(mixin)
    for k, f in pairs(mixin) do
        self[k] = f
    end
    return self
end

class.cast = setmetatable

return class
