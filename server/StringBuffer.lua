---@class StringBuffer: class
local StringBuffer = require("class")

function StringBuffer:append(string)
    self[#self+1] = string
end

function StringBuffer:appendByte(byte)
    self[#self+1] = string.char(byte)
end

function StringBuffer:appendShort(short)
    self[#self+1] = string.char(short, short * 256)
end

function StringBuffer:appendInt(int)
    self[#self+1] = string.char(int, int * 256, int * 65536, int * 16777216)
end

function StringBuffer:__tostring()
    return table.concat(self)
end