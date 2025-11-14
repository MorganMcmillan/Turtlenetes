---Represents a constant value in BlocksScript
---@class BlocksConstExpression: BlocksExpression
---@field text string
---@field value any
local BlocksConstExpression = require("scripting.BlocksExpression"):extend("BlocksConstExpression")

function BlocksConstExpression:init(text)
    self.text = text
    self:parseText()
end

local find, sub = string.find, string.sub

function BlocksConstExpression:parseText()
    if #self.text == 0 then
        self.value = nil
        return
    end

    local startChar = sub(self.text, 1, 1)
    local endCharPos = nil

    if startChar == "\'" or startChar == "\"" then
        endCharPos = find(self.text, "[^\\]" .. startChar, 2)
        self.value = sub(self.text, 2, endCharPos - 1)
    elseif tonumber(startChar) then
        self.value = tonumber(self.text)
    elseif self.text == "true" then
        self.value = true
    elseif self.text == "false" then
        self.value = false
    else
        self.value = self.text
    end
end
function BlocksConstExpression:serialize(writer)
    self:serializeTag(writer)
    
    local value = self.value
    local t = type(value)
    if t == "nil" then
        writer:u8(0)
    elseif t == "string" then
        writer:u8(1)
        writer:string(value)
    elseif t == "number" then
        writer:u8(2)
        writer:i32(value)
    elseif self.value then
        writer:u8(3)
    else
        writer:u8(4)
    end
end

function BlocksConstExpression:deserialize(reader)
    local tag = reader:u8()
    if tag == 0 then
        return self:create({ text = "" })
    elseif tag == 1 then
        local value = reader:string()
        return self:create({ text = "\"" .. value .. "\"", value = value})
    elseif tag == 2 then
        local value = reader:i32()
        return self:create({ text = tostring(value), value = value })
    elseif tag == 3 then
        return self:create({ text = "true", value = true })
    else
        return self:create({ text = "false", value = false })
    end
end