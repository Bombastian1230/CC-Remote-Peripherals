local NETWORK_ID = settings.get("network_id.setting")
local DEVICE_ID = "controller"

-- Other variables
local modem = peripheral.find("modem")
local protocol = "peripheral_network_" .. tostring(NETWORK_ID)

rednet.open(peripheral.getName(modem))

function findRemote(type) 
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

textutils.pagedPrint("\nTo use this module add require(remote_controller) to your program. To call a function on a peripheral use callRemote(device_name). device_name is the name you gave to the peripheral during the setup. Alternativly you can use findRemote(type) to the names of every remote peripheral of a certain type.")