---@class StringBuffer: class
---@field contents string
---@field private position integer
local StringBuffer = require("class")

function StringBuffer:init(contents)
    self.contents = contents
    self.position = 1
end

function StringBuffer.fromFile(fileName)
    local file = fs.open(fileName, "rb")
    local contents = file.readAll()
    file.close()
    return StringBuffer:new(contents)
end

function StringBuffer:read(n)
    
end

function StringBuffer:readByte()
    
end

function StringBuffer:readShort()
    
end

function StringBuffer:readInt()
    
end