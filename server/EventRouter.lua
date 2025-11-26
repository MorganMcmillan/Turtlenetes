---@alias Router function

local sub, match = string.sub, string.match

---@enum
local TOKEN = {
    DOT = 1,
    FIELD = 2,
    ARRAY_FOREACH = 3,
    KEYS_FOREACH = 4,
    CLASS_NAME = 5,
    DEEP_SEARCH = 6
}

local function parseRoute(route)
    -- Tokenize route string
    local function makeToken(type, data)
        return {
            type = type,
            data = data
        }
    end

    local tokens = {}
    local i = 1
    while i < #route do
        local token
        local c = sub(route, i, i)
        if c == '.' then
            token = makeToken(TOKEN.DOT)
            i = i + 1
        elseif c == '*' then
            token = makeToken(TOKEN.ARRAY_FOREACH)
            i = i + 1
        elseif c == '$' then
            token = makeToken(TOKEN.KEYS_FOREACH)
            i = i + 1
        elseif c == '>' then
            token = makeToken(TOKEN.DEEP_SEARCH)
            i = i + 1
        elseif c == '@' then
            i = i + 1
            local identifier
            identifier, i = match(route, "%w", i)
            token = makeToken(TOKEN.CLASS_NAME, identifier)
        else
            local identifier
            identifier, i = match(route, "%w", i)
            token = makeToken(TOKEN.FIELD, identifier)
        end

        tokens[#tokens+1] = token
    end

    -- Parse routes from tokens
    -- Uses recursive parsing to construct a chain of closures
    local function terminalOp(method, ...)
        method(...)
    end

    local parseTokens

    local function foo(i)
        local nextToken = tokens[i + 1]
        if nextToken then
            local tType = nextToken.type
            local nextFn = parseTokens(i + 2)
            if tType == TOKEN.DOT then
                return nextFn
            elseif tType == TOKEN.DEEP_SEARCH then
                -- A set to prevent cycles
                local seen = {}
                -- Deeply searches the object for the matching field
                local function deepSearch(method, object, ...)
                    if type(object) ~= "table" then return false end
                    for _, v in pairs(object) do
                        if not seen[v] then
                            seen[v] = true
                            if nextFn(method, v, ...) or deepSearch(method, v, ...) then
                                return true
                            end
                        end
                    end
                end
                return deepSearch
            end
        else
            return terminalOp
        end
    end

    parseTokens = function(i)
        local token = tokens[i]
        if token == nil then
            return terminalOp
        end
        local tType, tData = token.type, token.data
        local nextFn

        if tType == TOKEN.FIELD then
            nextFn = foo(i)
            
            return function (method, object, ...)
                object = object[tData]
                if not object then return false end
                return nextFn(method, object, ...)
            end
        elseif tType == TOKEN.CLASS_NAME then
            nextFn = foo(i)
            
            return function (method, object, ...)
                for _, v in pairs(object) do
                    if type(v) == "table" and v.class.name == tData then
                        return nextFn(method, v, ...)
                    end
                end
                return false
            end
        elseif tType == TOKEN.ARRAY_FOREACH then
            nextFn = foo(i)

            return function (method, object, ...)
                if type(object) ~= "table" then return false end
                for i = 1, #object do
                    nextFn(method, object[i], ...)
                end
                return true
            end
        elseif tType == TOKEN.KEYS_FOREACH then
            nextFn = foo(i)

            return function (method, object, ...)
                if type(object) ~= "table" then return false end
                for str, value in pairs(object) do
                    if type(str) == "string" then
                        nextFn(method, value, ...)
                    end
                end
                return true
            end
        end
    end

    return parseTokens(1)
end

---@class EventRouter
---@field listeners { [1]: fun(...), [2]: class, router: Router }[]
---Singleton event router
local EventRouter = {}

function EventRouter:init()
    self.listeners = {}
    self.routers = {}
end

---Adds a new event listener 
---@param event string
---@param object class | fun(...)
---@param method fun(...)
---@param route string
function EventRouter:addListener(event, object, method, route)
    local listener = self.listeners[event]
    if not listener then
        listener = {}
        self.listeners[event] = listener
    end
---@diagnostic disable-next-line: missing-fields
    listener[#listener+1] = {method or object, object, router = route and parseRoute(route)}
end

---Adds an event route.
---@param event any
---@param route any
---@param method any
function EventRouter:addRoute(event, route, method)
    local listener = self.listeners[event]
    if not listener then
        listener = {}
        self.listeners[event] = listener
    end

---@diagnostic disable-next-line: missing-fields
    listener[#listener+1] = {method, route = parseRoute(route)}
end

function EventRouter:pullOsEvent()
    local event = {os.pullEvent()}
    self:emit(event[1], nil, unpack(event, 2))
end

function EventRouter:emit(event, object, ...)
    local listeners = self.listeners[event[1]]
    if listeners then
        for i = 1, #listeners do
            local listener = listeners[i]
            local method, boundObject = listener[1], listener[2] or object
            local router = listener.router

            if router then
                router(method, boundObject, ...)
            elseif boundObject then
                method(boundObject, ...)
            else
                method(...)
            end
        end
    end
end

return EventRouter