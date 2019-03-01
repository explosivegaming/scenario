local Event = require 'utils.event'

function thisIsATestFunction(...)
    game.print(serpent.line({...}))
end

Event.add(defines.events.on_console_chat,function(event)
    if event.player_index then game.print('Message: '..event.message) end
end)



local Commands = require 'expcore.commands' -- require the Commands module

-- adds an admin only authenticator where if a command has the tag admin_only: true
-- then will only allow admins to use this command
Commands.add_authenticator(function(player,command,tags,reject)
    if tags.admin_only then -- the command has the tag admin_only set to true
        if player.admin then -- the player is an admin
            return true -- no return is needed for success but is useful to include
        else -- the player is not admin
            -- you must return to block a command, they are a few ways to do this:
            -- return false -- most basic and has no custom error message
            -- return reject -- sill no error message and is here in case people dont know its a function
            -- reject() -- rejects the player, return not needed but please return if possible
            -- return reject() -- rejects the player and has a failsafe return to block command
            -- reject('This command is for admins only!') -- reject but with custom error message, return not needed but please return if possible
            return reject('This command is for admins only!') -- reject but with custom error message and has return failsafe
        end
    else -- command does not require admin
        return true -- no return is needed for success but is useful to include
    end
end)

-- adds a parse that will cover numbers within the given range
-- input, player and reject are common to all parse functions
-- range_min and range_max are passed to the function from add_param
Commands.add_parse('number_range_int',function(input,player,reject,range_min,range_max)
    local rtn = tonumber(input) or nil -- converts input to number
    rtn = type(rtn) == 'number' and math.floor(rtn) or nil -- floor the number
    if not rtn or rtn < range_min or rtn > range_max then -- check if it is nil or out of the range
        -- invalid input for we will reject the input, they are a few ways to do this:
        -- dont return anything -- will print generic input error
        -- return false -- this WILL NOT reject the input as false can be a valid output
        -- return reject -- will print generic input error
        -- return reject() -- will print generic input error with no please check type message
        -- reject() -- if you do not return the value then they will be a duplicate message
        return reject('Number entered is not in range: '..range_min..', '..range_max) -- reject with custom error
    else
        return rtn -- returns the number value this will be passed to the command callback
    end
end)

-- adds a command that will print the players name a given number of times
-- and can only be used by admin to show how auth works
Commands.add_command('repeat-name','Will repeat you name a number of times in chat.') -- creates the new command with the name "repeat-name" and a help message
:add_param('repeat-count',false,'number_range_int',1,5) -- adds a new param called "repeat-count" that is required and is type "number_range_int" the name can be used here as add_parse was used
:add_param('smiley',true,function(input,player,reject) -- this param is optional and has a custom parse function where add_parse was not used before hand
    if not input then return false end -- here you can see the default check
    if input:lower() == 'true' or input:lower() == 'yes' then
        return true -- the value is truthy so true is returned
    else
        -- it should be noted that this function will be ran even when the param is not present
        -- in this case input is nil and so a default can be returned, see above
        return false -- false is returned other wise
    end
end)
:add_tag('admin_only',true) -- adds the tag admin_only: true which because of the above authenticator means you must be added to use this command
:add_alias('name','rname') -- adds two aliases "name" and "rname" for this command which will work as if the ordinal name was used
--:auto_concat() -- cant be used due to optional param here, but this will make all user input params after the last expected one be added to the last expected one
:register(function(player,repeat_count,smiley,raw) -- this registers the command to the game, notice the params are what were defined above
    -- prints the raw input to show that it can be used
    game.print(player.name..' used a command with input: '..raw)
    -- some smiley logic
    local msg
    if smiley then
        msg = ':) '..player.name
    else
        msg = ') '..player.name
    end
    -- prints your name alot
    for i = 1,repeat_count do
        Commands.print(i..msg) -- this command is an alias for ("expcore.common").player_return it will print any value to the player/server not just strings
    end
    -- if you wanted to you can return some values here
    -- no return -- only success message is printed
    -- Commands.error('optional message here') -- prints an error message
    -- return Commands.error('optional message here') -- prints an error message, and stops success message being printed
    -- Commands.success('optional message here') -- same as below but success message is printed twice DONT DO this
    -- return Commands.success('optional message here') -- prints your message and then the success message
end)