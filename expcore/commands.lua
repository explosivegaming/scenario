--- Factorio command making module that makes commands with better parse and more modularity
-- @author Cooldude2606
-- @module Commands
--[[
>>>>Example Authenticator

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

>>>>Example Parse

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

>>>>Example Command

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

>>>>Examples With No Comments (for example formatting)

    Commands.add_authenticator(function(player,command,tags,reject)
        if tags.admin_only then
            if player.admin then
                return true
            else
                return reject('This command is for admins only!')
            end
        else
            return true
        end
    end)

    Commands.add_parse('number_range_int',function(input,player,reject,range_min,range_max)
        local rtn = tonumber(input) or nil
        rtn = type(rtn) == 'number' and math.floor(rtn) or nil
        if not rtn or rtn < range_min or rtn > range_max then
            return reject('Number entered is not in range: '..range_min..', '..range_max)
        else
            return rtn
        end
    end)

    Commands.add_command('repeat-name','Will repeat you name a number of times in chat.')
    :add_param('repeat-count',false,'number_range_int',1,5)
    :add_param('smiley',true,function(input,player,reject)
        if not input then return false end
        if input:lower() == 'true' or input:lower() == 'yes' then
            return true
        else
            return false
        end
    end)
    :add_tag('admin_only',true)
    :add_alias('name','rname')
    :register(function(player,repeat_count,smiley,raw)
        game.print(player.name..' used a command with input: '..raw)
        local msg = ') '..player.name
        if smiley then
            msg = ':'..msg
        end
        for i = 1,repeat_count do
            Commands.print(i..msg)
        end
    end)
]]

local Game = require 'utils.game'
local player_return = require('expcore.common').player_return

local Commands = {
    defines={
        -- common values are stored error like signals
        error='CommandError',
        unauthorized='CommandErrorUnauthorized',
        success='CommandSuccess'
    },
    commands={
        -- custom command data will be stored here
    },
    authorization_fail_on_error=false, -- set due to have authorize fail if a callback fails to run, more secure
    authorization={
        -- custom function are stored here which control who can use what commands
    },
    _prototype={
        -- used to store functions which gets added to new custom commands
    },
    parse={
        -- used to store default functions which are common parse function such as player or number in range
    },
    print=player_return -- short cut so player_return does not need to be required in every module
}

--- Adds an authorization callback, function used to check if a player if allowed to use a command
-- @see Commands.authorize
-- @tparam callback function the callback you want to register as an authenticator
-- callback param - player: LuaPlayer - the player who is trying to use the command
-- callback param - command: string - the name of the command which is being used
-- callback param - tags: table - any tags which have been set for the command
-- callback param - reject: function(error_message?: string) - call to fail authorize with optional error message
-- @treturn number the index it was inserted at use to remove the callback, if anon function used
function Commands.add_authenticator(callback)
    return table.insert(Commands.authorization,callback)
end

--- Removes an authorization callback
-- @see Commands.add_authenticator
-- @tparam callback function|number the callback to remove, an index returned by add_authenticator can be passed
-- @treturn boolean was the callback found and removed
function Commands.remove_authenticator(callback)
    if type(callback) == 'number' then
        -- if a number is passed then it is assumed to be the index
        if Commands.authorization[callback] then
            table.remove(Commands.authorization,callback)
            return true
        end
    else
        -- will search the array and remove the key
        local index
        for key,value in pairs(Commands.authorization) do
            if value == callback then
                index = key
                break
            end
        end
        -- if the function was found it is removed
        if index then
            table.remove(Commands.authorization,index)
            return true
        end
    end
    return false
end

--- Mostly used internally, calls all authorization callbacks, returns if the player is authorized
-- @tparam player LuaPlayer the player that is using the command, passed to callbacks
-- @tparam command_name string the command that is being used, passed to callbacks
-- @treturn[1] boolean true player is authorized
-- @treturn[1] string commands const for success
-- @treturn[2] boolean false player is unauthorized
-- @treturn[2] string|locale_string the reason given by the authenticator
function Commands.authorize(player,command_name)
    local failed
    if not player then return true end
    local command_data = Commands.commands[command_name]
    if not command_data then return false end

    -- function passed to authorization callback to make it simpler to use
    local auth_fail = function(error_message)
        failed = error_message or {'ExpGamingCore_Command.unauthorized'}
        return Commands.defines.unauthorized
    end

    -- loops over each authorization callback if any return false or unauthorized command will fail
    for _,callback in pairs(Commands.authorization) do
        -- callback(player: LuaPlayer, command: string, tags: table, reject: function(error_message?: string))
        local success, rtn = pcall(callback,player,command_name,command_data.tags,auth_fail)
        -- error handler
        if not success then
            -- the callback failed to run
            log('[ERROR] Authorization failed: '..rtn)
            if Commands.authorization_fail_on_error then
                failed = 'Internal Error'
            end
        elseif rtn == false or rtn == Commands.defines.unauthorized or rtn == auth_fail or failed then
            -- the callback returned unauthorized, failed be now be set if no value returned
            failed = failed or {'ExpGamingCore_Command.unauthorized'}
            break
        end
    end

    -- checks if the authorization failed
    if failed then
        return false, failed
    else
        return true, Commands.defines.success
    end
end

--- Adds a common parse that can be called by name when it wants to be used
-- nb: this is not needed as you can use the callback directly this just allows it to be called by name
-- @tparam name string the name of the parse, should be the type like player or player_alive, must be unique
-- @tparam callback function the callback that is ran to prase the input
-- parse param - input: string - the input given by the user for this param
-- parse param - player: LuaPlayer - the player who is using the command
-- parse param - reject: function(error_message) - use this function to send a error to the user and fail running
-- parse return - the value that will be passed to the command callback, must not be nil and if reject then command is not run
-- @treturn boolean was the parse added will be false if the name is already used
function Commands.add_parse(name,callback)
    if Commands.parse[name] then
        return false
    else
        Commands.parse[name] = callback
        return true
    end
end

--- Creates a new command object to added details to, note this does not register the command to the game
-- @tparam name string the name of the command to be created
-- @tparam help string the help message for the command
-- @treturn Commands._prototype this will be used with other functions to generate the command functions
function Commands.add_command(name,help)
    local command = setmetatable({
        name=name,
        help=help,
        callback=function() Commands.internal_error(false,name,'No callback registered') end,
        auto_concat=false,
        min_param_count=0,
        max_param_count=0,
        tags={
            -- stores tags that can be used by auth
        },
        aliases={
            -- n = name: string
        },
        params={
            -- [param_name] = {optional: boolean, parse: function}
        }
    }, {
        __index= Commands._prototype
    })
    Commands.commands[name] = command
    return command
end

--- Adds a new param to the command this will be displayed in the help and used to parse the input
-- @tparam name string the name of the new param that is being added to the command
-- @tparam[opt=true] optional is this param required for this command, these must be after all required params
-- @tparam[opt=pass through] parse function this function will take the input and return a new (or same) value
-- @param[opt] ... extra args you want to pass to the parse function; for example if the parse is general use
-- parse param - input: string - the input given by the user for this param
-- parse param - player: LuaPlayer - the player who is using the command
-- parse param - reject: function(error_message) - use this function to send a error to the user and fail running
-- parse return - the value that will be passed to the command callback, must not be nil and if reject then command is not run
-- @treturn Commands._prototype pass through to allow more functions to be called
function Commands._prototype:add_param(name,optional,parse,...)
    if optional ~= false then optional = true end
    parse = parse or function(string) return string end
    self.params[name] = {
        optional=optional,
        parse=parse,
        parse_args={...}
    }
    self.max_param_count = self.max_param_count+1
    if not optional then
        self.min_param_count = self.min_param_count+1
    end
    return self
end

--- Adds a tag to the command which is passed via the tags param to the authenticators, can be used to assign command roles or type
-- @tparam name string the name of the tag to be added; used to keep tags separate
-- @tparam value any the tag that you want can be anything that the authenticators are expecting
-- nb: if value is nil then name will be assumed as the value and added at a numbered index
-- @treturn Commands._prototype pass through to allow more functions to be called
function Commands._prototype:add_tag(name,value)
    if not value then
        -- value not given so name is the value
        table.insert(self.tags,name)
    else
        -- name is given so its key: value
        self.tags[name] = value
    end
    return self
end

--- Adds an alias or multiple that will also be registered with the same callback, eg /teleport can be /tp with both working
-- @usage command:add_alias('aliasOne','aliasTwo','etc')
-- @tparam ... string any amount of aliases that you want this command to be callable with
-- @treturn Commands._prototype pass through to allow more functions to be called
function Commands._prototype:add_alias(...)
    for _,alias in pairs({...}) do
        table.insert(self.aliases,alias)
        --Commands.alias_map[alias] = self.name
    end
    return self
end

--- Enables auto concatenation of any params on the end so quotes are not needed for last param
-- nb: this will disable max param checking as they will be concated onto the end of that last param
-- this can be useful for reasons or longs text, can only have one per command
-- @treturn Commands._prototype pass through to allow more functions to be called
function Commands._prototype:auto_concat()
    self.auto_concat = true
    return self
end

--- Adds the callback to the command and registers all aliases, params and help message with the game
-- nb: this must be the last function ran on the command and must be done for the command to work
-- @tparam callback function the callback for the command, will receive the player running command, and params added with add_param
-- callback param - player: LuaPlayer - the player who used the command
-- callback param - ... - any params which were registered with add_param in the order they where registered
-- callback param - raw: string - the raw input from the user, comes after every param added with add_param
function Commands._prototype:register(callback)
    -- generates a description to be used
    self.callback = callback
    local params = self.params
    local description = ''
    for param_name,param_details in pairs(self.params) do
        if param_details.optional then
            description = string.format('%s [%s]',description,param_name)
        else
            description = string.format('%s <%s>',description,param_name)
        end
    end
    self.description = description
    -- registers the command under its own name
    commands.add_command(self.name,description..' '..self.help,function(command_event)
        local success, err = pcall(Commands.run_command,command_event)
        if not success then log('[ERROR] command/'..self.name..' :: '..err) end
    end)
    -- adds any aliases that it has
    for _,alias in pairs(self.aliases) do
        if not commands.commands[alias] and not commands.game_commands[alias] then
            commands.add_command(alias,description..' '..self.help,function(command_event)
                command_event.name = self.name
                local success, err = pcall(Commands.run_command,command_event)
                Commands.internal_error(success,self.name,err)
            end)
        end
    end
end

--- Sends an error message to the player and returns a constant to return to command handler to exit execution
-- nb: this is for non fatal errors meaning there is no log of this event
-- nb: if reject is giving as a param to the callback use that instead
-- @usage return Commands.error()
-- @tparam[opt] error_message string an optional error message that can be sent to the user
-- @tparam[opt] play_sound string the sound to play for the error
-- @treturn Commands.defines.error return this to command handler to exit execution
function Commands.error(error_message,play_sound)
    error_message = error_message or ''
    player_return({'ExpGamingCore_Command.command-fail',error_message},'orange_red')
    if play_sound ~= false then
        play_sound = play_sound or 'utility/wire_pickup'
        if game.player then game.player.play_sound{path=play_sound} end
    end
    return Commands.defines.error
end

--- Sends an error to the player and logs the error, used with pcall within command handler please avoid direct use
-- nb: use error(error_message) within your callback to trigger do not trigger directly as the handler may still continue
-- @tparam success boolean the success value returned from pcall, or just false to trigger error
-- @tparam command_name string the name of the command this is used within the log
-- @tparam error_message string the error returned by pcall or some other error, this is logged and not returned to player
-- @treturn boolean the opposite of success so true means to cancel execution, used internally
function Commands.internal_error(success,command_name,error_message)
    if not success then
        Commands.error('Internal Error, Please contact an admin','utility/cannot_build')
        log('[ERROR] command/'..command_name..' :: '..error_message)
    end
    return not success
end

--- Sends a value to the player, followed by a command complete message
-- nb: either return a value from your callback to trigger or return the return of this to prevent two messages
-- @tparam[opt] value any the value to return to the player, if nil then only success message returned
-- @treturn Commands.defines.success return this to the command handler to prevent two success messages
function Commands.success(value)
    if value then player_return(value) end
    player_return({'ExpGamingCore_Command.command-ran'},'cyan')
    return Commands.defines.success
end

--- Main event function that is ran for all commands, used internally please avoid direct use
-- @tparam command_event table passed directly from command event from the add_command function
function Commands.run_command(command_event)
    local command_data = Commands.commands[command_event.name]
    local player = Game.get_player_by_index(command_event.player_index)

    -- checks if player is allowed to use the command
    local authorized, auth_fail = Commands.authorize(player,command_data.name)
    if not authorized then
        Commands.error(auth_fail,'utility/cannot_build')
        return
    end

    -- null param check
    if command_data.min_param_count > 0 and not command_event.parameter then
        Commands.error({'ExpGamingCore_Command.invalid-inputs',command_data.name,command_data.description})
        return
    end

    -- splits the arguments
    local input_string = command_event.parameter
    local quote_params = {} -- stores any " " params
    input_string = input_string:gsub('"[^"]-"',function(w)
        -- finds all " " params are removes spaces for the next part
        local no_qoutes = w:sub(2,-2)
        local no_spaces = no_qoutes:gsub('%s','_')
        quote_params[no_spaces]=no_qoutes
        if command_data.auto_concat then
            -- if auto concat then dont remove quotes as it should be included later
            quote_params[w:gsub('%s','_')]=w
        end
        return no_spaces
    end)

    local raw_params = {} -- stores all params
    local param_number = 0
    local last_index = 0
    for word in input_string:gmatch('%S+') do
        param_number = param_number + 1
        if param_number > command_data.max_param_count then
            -- there are too many params given to the command
            if not command_data.auto_concat then
                -- error as they should not be more
                Commands.error({'ExpGamingCore_Command.invalid-inputs',command_data.name,command_data.description})
                return
            else
                -- concat to the last param
                if quote_params[word] then
                    -- if it was a " " param then the spaces are re added now
                    raw_params[last_index]=raw_params[last_index]..' '..quote_params[word]
                else
                    raw_params[last_index]=raw_params[last_index]..' '..word
                end
            end
        else
            -- new param that needs to be added
            -- all words are added to an array
            if quote_params[word] then
                -- if it was a " " param then the spaces are re added now
                last_index = table.insert(raw_params,quote_params[word])
            else
                last_index = table.insert(raw_params,word)
            end
        end
    end

    -- checks param count
    local param_count = #raw_params
    if param_count < command_data.min_param_count then
        Commands.error({'ExpGamingCore_Command.invalid-inputs',command_data.name,command_data.description})
        return
    end

    -- parses the arguments
    local index = 1
    local params = {}
    for param_name, param_data in pairs(command_data.params) do
        local parse_callback = param_data.parse
        if type(parse_callback) == 'string' then
            -- if its a string this allows it to be pulled from the common store
            parse_callback = Commands.parse[parse_callback]
        end
        if not type(parse_callback) == 'function' then
            -- if its not a function throw and error
            Commands.internal_error(success,command_data.name,'Invalid param parse '..tostring(param_data.parse))
            return
        end
        -- used below as the reject function
        local parse_fail = function(error_message)
            error_message = error_message or ''
            Commands.error('Invalid Param "'..param_name..'"; '..error_message)
            return
        end
        -- input: string, player: LuaPlayer, reject: function, ... extra args
        local success,param_parsed = pcall(parse_callback,raw_params[index],player,parse_fail,unpack(param_data.parse_args))
        if Commands.internal_error(success,command_data.name,param_parsed) then return end
        -- param_data.optional == false is so that optional parses are still ran even when not present
        if (param_data.optional == false and param_parsed == nil) or param_parsed == Commands.defines.error or param_parsed == parse_fail then
            -- no value was returned or error was returned, if nil then give error
            if not param_parsed == Commands.defines.error then Commands.error('Invalid Param "'..param_name..'"; please make sure it is the correct type') end
            return
        end
        -- adds the param to the table to be passed to the command callback
        table.insert(params,param_parsed)
        index=index+1
    end

    -- runs the command
    -- player: LuaPlayer, ... command params, raw: string
    table.insert(params,input_string)
    local success, err = pcall(command_data.callback,player,unpack(params))
    if Commands.internal_error(success,command_data.name,err) then return end
    if err ~= Commands.defines.error and err ~= Commands.defines.success then Commands.success(err) end
end

return Commands