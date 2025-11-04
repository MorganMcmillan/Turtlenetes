-- Turtle helper functions
-- These are put into the turtle library because that's where the functions called over rednet live

function turtle.findItem(itemName)
    for i = 1, 16 do
        local details = turtle.getItemDetail(i)
        if details and details.name == itemName then
            return i
        end
    end
    return false, "Item not found: " .. itemName
end

function turtle.selectItem(itemName)
    turtle.select(assert(turtle.findItem(itemName)))
end

function turtle.getInventory()
    local inventory = {}
    for i = 1, 16 do
        inventory[i] = turtle.getItemDetail(i)
    end
    return inventory
end

-- Prompt utilities

function prompt(message)
    write(message)
    return read()
end

function promptInt(message)
    write(message)
    repeat
        local intInput = tonumber(read())
        if not intInput then
            write("\nInput must be a number. Please try again: ")
        end
    until intInput
    return intInput
end

-- Parse arguments
-- Args: server password [x y z]
-- If any args are missing, prompt for them

local serverName = arg[1] or prompt("Enter server name: ")
local password = arg[2] or prompt("Enter password: ")
local x = tonumber(arg[3]) or promptInt("Enter x: ")
local y = tonumber(arg[4]) or promptInt("Enter y: ")
local z = tonumber(arg[5]) or promptInt("Enter z: ")

-- Find first available modem
local modem = peripheral.find("modem")
if not modem then
    error("Modem not found. Please ensure that a modem is attached before running this program.")
end
rednet.open(modem)

-- Connect to the server
local server = rednet.lookup("t8s", serverName)
if server == nil then
    error("Server " .. serverName .. " not found. Check if your server is up and has the correct name.")
end

-- Convenience function for sending data to the server
local function send(message)
    return rednet.send(server, message, "t8s")
end

-- Convenience function for receiving data from the server
-- Ensures that the sender is the server
local function receive()
    local sender, message
    repeat
        sender, message = rednet.receive("t8s")
    until sender == server
    return message
end

-- Log in to the server
send(password)
local message = receive()

if message ~= "Password accepted" then
    error("Password denied. Check the server for the password.")
end

-- Loop and receive commands from the server
while true do
    message = receive()
    local method = turtle[message[1]]
    if method then
        -- Note: pcall in lua acts like try-catch, returning false as its first return value if the function errors
        local results = {pcall(method, unpack(messsage, 2))}
        send(results)
    else
        send({false, "Method " .. message[1] .. "not found."})
    end
end