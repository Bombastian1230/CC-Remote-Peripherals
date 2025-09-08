local params = {...}

-- Setings
settings.define("is_peripheral.setting", {
    description = "If the computer is a peripheral",
    default = false,
    type = "boolean"
})

settings.define("network_id.setting" ,{
    description = "The network the computer should look in",
    default = 0,
    type = "number"
})

settings.define("device_id.setting", {
    description = "The id of the device on the network",
    default = nil,
    type = "string"
})


settings.define("side.setting", {
    description = "What side this computer sould look on for a peripheral",
    default = nil,
    type = "string"
})

settings.define("type.setting", {
    description = "The peripheral type",
    default = nil,
    type = "string"
})

settings.define("key.setting", {
    description = "The key to include in broadcasts & responses if the network is protected",
    default = nil,
    type = "string"
})

settings.define("has_setup.setting", {
    description = "If the computer has setup",
    default = false,
    type = "boolean"
})


if params[1] then
    settings.unset("is_peripheral.setting")
    settings.unset("network_id.setting")
    settings.unset("device_id.setting")
    settings.unset("side.setting")
    settings.unset("key.setting")
    settings.unset("has_setup.setting")
    
    fs.delete("startup.lua")
end
settings.save()


-- Constant variables 
local VALID_SIDES = {left = true, right = true, top = true, bottom = true, front = true, back= true}


-- Persistant variables
local IS_PERIPHERAL = settings.get("is_peripheral.setting")
local NETWORK_ID = settings.get("network_id.setting")
local DEVICE_ID = settings.get("device_id.setting")
local PERIPHERAL_SIDE = settings.get("side.setting")
local PERIPHERAL_TYPE = settings.get("type.setting")
local KEY = settings.get("key.setting")


-- Utility functions
function downloadFile(url, filename)
    local response = http.get(url)

    local data = response.readAll()
    response.close()

    local file = fs.open(filename, "w")
    file.write(data)
    file.close()
    print(filename .. " downloaded")
end

function queryUser(prompt, answer_type, history, completeFn, replaceCharacter, default)
    local valid_bool_answer = {y = true, n = false}

    prompt = prompt or ""
    answer_type = answer_type or "string"
    history = history or {}
    completeFn = completeFn or nil
    replaceCharacter = replaceCharacter or nil
    default = default or ""

    local user_answer = nil
    local type_valid = false

    -- If it should be a number require answer to be a number
    if answer_type == "number" then
        while not type_valid do
            print(prompt)
            term.write("> ")

            user_answer = read(replaceCharacter, history, completeFn, default)

            if tonumber(user_answer) == nil then
                term.setTextColor(colors.yellow)
                print(string.format("\"%s\" is not a valid number please enter again", user_answer))
                term.setTextColor(colors.white)
            else
                type_valid = true
                user_answer = tonumber(user_answer)
            end
        end

    -- If it should be a boolean require answer to be y or n
    elseif answer_type == "boolean" then
        while not type_valid do
            print(prompt)
            term.write("> ")

            user_answer = read(replaceCharacter, history, completeFn, default)

            if valid_bool_answer[string.lower(user_answer)] == nil then
                term.setTextColor(colors.yellow)
                print(string.format("\"%s\" is not a valid answer please answer with y (yes) or n (no)", user_answer))
                term.setTextColor(colors.white)
            else
                type_valid = true
                user_answer = valid_bool_answer[string.lower(user_answer)]
            end
        end
    
    -- If it should be a string do nothing
    else
        print(prompt)
        term.write("> ")

        user_answer = read(replaceCharacter, history, completeFn, default)
    end
   


    return user_answer
end


function printColor(output, color, background_color, default_color, default_background_color)
    background_color = background_color or colors.black
    default_color = default_color or colors.white
    default_background_color = default_background_color or colors.black
    
    term.setTextColor(color)
    term.setBackgroundColor(background_color)
    print(output)
    term.setTextColor(default_color)
    term.setBackgroundColor(default_background_color)
end


-- Setup functions
function PeripheralSetup()
    NETWORK_ID = queryUser("What network should the peripheral be exposed to? (number)", "number")
    settings.set("network_id.setting", NETWORK_ID)
    print("--------------------------------")

    local IS_PROTECTED = queryUser("Is this network protected? y/n (yes/no)" , "boolean")
    print("--------------------------------")

    if IS_PROTECTED then
        KEY = queryUser("The key for this network" , "string")
        settings.set("key.setting", KEY)
        print("--------------------------------")
    end

    DEVICE_ID = queryUser("What should this device be called?")
    settings.set("device_id.setting", DEVICE_ID)
    print("--------------------------------")

    -- Set peripheral side
    while PERIPHERAL_SIDE == nil do
        local query = string.lower(queryUser("What side is the peripheral connected on? (left, right, top, down, front, back)"))

        if VALID_SIDES[query] then
            PERIPHERAL_SIDE = query
        else
            printColor(string.format("\"%s\" is not a valid side.", query), colors.green)
        end
    end
    settings.set("side.setting", PERIPHERAL_SIDE)

    -- Make sure peripheral exists
    local error_printed = false
    local periph = peripheral.wrap(PERIPHERAL_SIDE)
    while periph == nil do
        if not error_printed then
            printColor(string.format("No peripheral found on the %s side. Please connect a peripheral.", PERIPHERAL_SIDE), colors.yellow)
            error_printed = true
        end
        periph = peripheral.wrap(PERIPHERAL_SIDE)
        sleep(0.5)
    end
    print(string.format("Peripheral of type %s found...", peripheral.getType(periph)))
    PERIPHERAL_TYPE = peripheral.getType(periph)
    settings.set("type.setting", PERIPHERAL_TYPE)

    -- Download peripheral file
    downloadFile("https://raw.githubusercontent.com/Bombastian1230/CC-Remote-Peripherals/refs/heads/main/remote_peripheral.lua", "remote_peripheral.lua")

    -- Set remote_peripheral to run on startup
    local setup_file = fs.open("startup.lua", "w")
    setup_file.write("shell.run(\"remote_peripheral.lua\")")
    setup_file.close()
end

function ControllerSetup()
    NETWORK_ID = queryUser("What network should this controller look for peripherals on? (number)")
    settings.set("network_id.setting", NETWORK_ID)
    print("--------------------------------")

    local IS_PROTECTED = queryUser("Should this network be protected? y/n (yes/no)" , "boolean")
    print("--------------------------------")

    if IS_PROTECTED then
        KEY = queryUser("The key for this network" , "string")
        settings.set("key.setting", KEY)
        print("--------------------------------")
    end

    -- Set remote_peripheral to run on startup
    local setup_file = fs.open("startup.lua", "w")
    setup_file.write("shell.run(\"remote_controller.lua\")")
    setup_file.close()
end

function Setup()
    term.clear()
    term.setCursorPos(1,1)
    print("Welcome! Please answer these questions to setup!")
    print("--------------------------------")

    IS_PERIPHERAL = queryUser("Is this computer a peripheral? y/n (yes/no)" , "boolean")
    settings.set("is_peripheral.setting", IS_PERIPHERAL)
    print("--------------------------------")

    if IS_PERIPHERAL then
        PeripheralSetup()
    else
        ControllerSetup()
    end

    local modem = peripheral.find("modem")
    local error_printed = false
    while modem == nil do
        if not error_printed then printColor("No modem found. Please connect a non wired modem to computer", colors.yellow) end
        error_printed = true
        modem = peripheral.find("modem")
        sleep(0.25)
    end
    print("Modem detected")

    settings.set("has_setup.setting", true)
    print(settings.get("has_setup.setting"))

    sleep(0.25)
    print("Saving settings")
    settings.save()

    printColor("Setup done. Rebooting", colors.lime)
    sleep(3)
    os.reboot()
end


-- Script starts here
if not settings.get("has_setup.setting") then
    Setup()
end


