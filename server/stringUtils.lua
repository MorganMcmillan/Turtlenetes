local stringUtils = {}

---Splits a string into two parts
---@param s string
---@param sep string
---@return string, string
function stringUtils.split(s, sep)
    return string.match(s, "([^" .. sep .. "]+)" .. sep .. "(.+)")
end

return stringUtils