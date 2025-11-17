---Represents a constant value in BlocksScript
---@class BlocksConstExpression: BlocksExpression
---@field text string
---@field value any
local BlocksConstExpression = require("scripting.BlocksExpression"):extend("BlocksConstExpression")

local types = require("SerClass").types

BlocksConstExpression.schema = {
    super = BlocksConstExpression.super,
    {"text", types.string}
}

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

BlocksConstExpression.onDeserialize = BlocksConstExpression.parseText