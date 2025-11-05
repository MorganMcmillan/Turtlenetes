function prompt(message)
    write(message)
    return read()
end

local function sendCommand(client, command)
    rednet.send(client, command, "t8s")
    -- Await client's response
    local _, results = rednet.receive("t8s")
    return results
end

local serverName = arg[1] or prompt("Enter server name: ")
local password = arg[2] or prompt("Enter password: ")

-- Find first available modem
local modem = peripheral.find("modem")
if not modem then
    error("Modem not found. Please ensure that a modem is attached before running this program.")
end
rednet.open(peripheral.getName(modem))

rednet.host("t8s" ,serverName)

---@type table<integer, true>
local turtles = {}

-- Receive messages from clients
while true do
    local client, message = rednet.receive("t8s")
    if not turtles[client] then
        print("Got client ", client)
        if message == password then
            rednet.send(client, "Password accepted", "t8s")
            -- turtles[client] = true
            -- TEST client consuming commands
            sendCommand(client, {"dig"})
            sendCommand(client, {"forward"})
            sendCommand(client, {"forward"})
        end
    end
end