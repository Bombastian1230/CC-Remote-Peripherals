-- Persistant variables
local NETWORK_ID = settings.get("network_id.setting")
local DEVICE_ID = settings.get("device_id.setting")
local PERIPHERAL_SIDE = settings.get("side.setting")
local PERIPHERAL_TYPE = settings.get("type.setting")
local KEY = settings.get("key.setting")


-- General variables
local modem = peripheral.find("modem")
local protocol = "peripheral_network_" .. tostring(NETWORK_ID)
-- local response_protocol = "peripheral_network_" .. tostring(NETWORK_ID) .. "device_" .. DEVICE_ID


function callFunction(func, ...)

    print("Call funciton " .. func .. " with arguments " ..textutils.serialise(...))

    local output = peripheral.call(PERIPHERAL_SIDE, func, ...)

    print("Function Output: " .. textutils.serialise(output))

    return output
end


-- Script starts here
rednet.open(peripheral.getName(modem))
rednet.host(protocol, DEVICE_ID)

print("Network id: " .. tostring(NETWORK_ID))
print("Device id: " .. DEVICE_ID)
print("Peripheral side: " .. PERIPHERAL_SIDE)
print("Peripheral type: " .. PERIPHERAL_TYPE)
print("Protocol: " .. protocol)

while true do
    local id, message = rednet.receive(protocol)
    local func, args call_type = message.func, message.args, message.call_type

    if call_type == "function" then
        local outputs = callFunction(func, args)

        print("Call Output: " .. textutils.serialise(outputs))

        rednet.send(id, outputs, protocol)
    else 
        if args == PERIPHERAL_TYPE then rednet.send(id, DEVICE_ID, protocol .. "_find_response") end
    end
end