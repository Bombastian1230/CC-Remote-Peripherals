local valid_bool_answer = {y = true, n = false}

function queryUser(prompt, answer_type, history, completeFn, replaceCharacter, default)
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

            user_answer = _G.read(replaceCharacter, history, completeFn, default)

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

            user_answer = _G.read(replaceCharacter, history, completeFn, default)

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

        user_answer = _G.read(replaceCharacter, history, completeFn, default)
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