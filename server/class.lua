-- Lua doesn't natively support OOP, so it needs to be programmed in manually using language constructs

---@class class
---@field name string
---@field super class
---@field __extend fun(self, subclass: class) called whenever the class is extended
---@field init fun(self, ...)
local class = {name = "class"}
class.__index = class
function class:__tostring()
    return "class '" .. self.name .. "'"
end

--- Extends a base class
--- @generic T
--- @param self T | class
--- @return T
function class:extend(name)
    local heir = setmetatable({name = name, super = self}, self)
    heir.__index = heir
    heir.__tostring = self.__tostring
    local onExtend = self.__extend
    if onExtend then
        onExtend(self, heir)
    end
    return heir
end

--- Create a new instance of this class, calling `init` with parameters if it exists
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

--- Create a new instance of this class without calling `init`
--- @generic T
--- @param self T | class
--- @param object? T
--- @return T
function class:create(object)
    return setmetatable(object or {}, self)
end

---Applies a mixin to the class, allowing code reuse without inheritance
---@param mixin table
---@return self
function class:with(mixin)
    for k, f in pairs(mixin) do
        self[k] = f
    end
    return self
end

class.cast = setmetatable

return class
