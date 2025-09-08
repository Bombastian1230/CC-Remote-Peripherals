local NETWORK_ID = settings.get("network_id.setting")
local DEVICE_ID = "controller"

-- Other variables
local modem = peripheral.find("modem")
local protocol = "peripheral_network_" .. tostring(NETWORK_ID)

rednet.open(modem)

function find(type) 
    rednet.broadcast({
        call_type = "type",
        args = type,
        func = nil
    }, protocol)

    local device_ids = {}
    while true do
        local not_failed, message = rednet.receive(protocol .. "_find_response", 1)
        if not_failed == nil then break end
        table.insert(device_ids, message)
    end

    return device_ids
end

print("Network ID: " .. tostring(NETWORK_ID))

print("\n To use this module add ")
term.setTextColor(colors.yellow)
term.write("local remote_peripheral = require(\"remote_controller\")")
term.setTextColor(colors.white)
print(" to the start of your program")