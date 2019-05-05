--- Factorio command making module that makes commands with better parse and more modularity
-- @author Cooldude2606
-- @module Commands
--[[
>>>>Example Authenticator:
    The command system is most useful when you can control who can use commands; to do this would would need to
    define an authenticator which is ran every time a command is run; in this example I will show a simple one
    that requires some commands to require the user to be a game admin:

    When the authenticator is called be the command handler it will be passed 4 vales:
    1) the player who used the command
    2) the name of the command that is being used
    3) any flags which have been set for this command, this is a table of values set using :set_flag(name,value)
    4) the reject function which is the preferred method to prevent execution of the command

    For our admin only example we will set a flag to true when we want it do be admin only so when we define the
    command will will use :set_flag('admin_only',true) and then inside the authenticator we will test if the flag
    is present using: if flags.admin_only then

    Although no return is required to allow the command to execute it is best practice to return true; we do this in
    two cases in our authenticator:
    1) when the "admin_only" flag is not set, which we take to mean any one can use it
    2) when the "admin_only" flag is set, and the player is admin

    Now when the user is not an admin and the command requires you to be an admin then we must reject the request:
    1) return false -- this is the most basic block and should only be used while testing
    2) return reject -- returning the reject function is only an option as a fail safe, same as returning false
    3) reject() -- this will block execution without returning to allow further code to be ran in the authenticator
    4) reject('This command is for admins only!') -- Using reject as a function allows a error message to be returned
    5) return reject() -- using return on either case above is best practice as you should execute all code before rejecting

    Example Code:
    Commands.add_authenticator(function(player,command,flags,reject)
        if flags.admin_only then -- our test for the "admin_only" flag
            if player.admin then
                return true -- true return 2
            else
                return reject('This command is for admins only!') -- reject return 5 with a custom error message
            end
        else
            return true -- true return 1
        end
    end)

>>>>Example Parse:
    Before you go making commands it is important to understand the most powerful feature of this command handler,
    when you define a command you are able to type the params and have then be parsed by an handler so before your
    command is ever executed you can be sure that all the params are valid. This module should be paired with a general
    command parse but you may want to create your own:

    For our example we will create a parse to accept only integer numbers in a given range:
    1) we will give it the name "number-range-int" this is the "type" that the input is expected to be
    2) when we define the type we will also define the min and max of the range so we can use the function more than once
    Example parse usage:
    :add_param('repeat_count',false,'number-range-int',5,10) -- range 5 to 10 inclusive

    The command parse will be passed 3 params and any other you define, in our case:
    1) the input that has been given by the user for this param, the role of this function is to transform this value
    nb: the input is a string but can be nil if the param is marked as optional
    2) the player who is using the command, this is always present
    3) the reject function to throw an error to the user, this is always present
    4) the range min, this is user defined and has the value given when the param is defined
    5) the range max, this is user defined and has the value given when the param is defined

    When returning from the param parse you again have a few options with how to do this:
    1) you return the new value for the param (any non nil value) this value is then passed to the command callback
    2) not returning will cause a generic invalid error and the command callback is blocked, not recommenced
    3) return reject -- this is just a failsafe in case the function is not called, same as no return
    4) return reject() -- will give a shorter error message as you pass a nil custom error
    5) return reject('Number entered is not in range: '..range_min..', '..range_max) -- returns a custom error the the user
    nb: if you do not return reject after you call it then you are still returning nil so there will be a duplicate message

    It should be noted that if you want to expand on an existing parse you can use Commands.parse(type,input,player,reject)
    and this value will either return a new value for the input or nil, if it is nil you should return nil to prevent dobble
    messages to the user:
    input = Commands.parse('number-int',input,player,reject)
    if not input then return end -- nil check

    Example Code:
    Commands.add_parse('number-range-int',function(input,player,reject,range_min,range_max)
        local rtn = tonumber(input) and math.floor(tonumber(input)) or nil -- converts input to number
        if not rtn or rtn < range_min or rtn > range_max then
            -- the input is either not a number or is outside the range
            return reject('Number entered is not in range: '..range_min..', '..range_max)
        else
            -- returns the input as a number value rather than a string, thus the param is now the correct type
            return rtn
        end
    end)

>>>>Example Command:
    How for the fun part making the commands, the commands can be set up with any number of params and flags that you want,
    you can add aliases for the commands and set default values for optional params and of course register your command callback
    in our example we will just have a command that will repeat the users name in chat X amount of times and only allow admins to use it.

    First we create the new command, nb this will not register the command to the game this is done at the end, we will call
    the command "repeat-name" and set the help message as follows:
    Commands.new_command('repeat-name','Will repeat you name a number of times in chat.')

    Now for our first param we will call "repeat-count" and it will be a required value between 1 and 5 inclusive:
    :add_param('repeat-count',false,'number-range-int',1,5)

    Our second param we need a custom parse for but we have not defined it, this is an option for when it is unlikely for
    any other command to use the same input type; however in our case it will just be a boolean which should be noted as being
    included in the general command parse config. As for the param its self it will be called "smiley" and will be optional with
    a default value of false:
    :add_param('smiley',true,function(input,player,reject)
        -- since it is optional the input can be nil, in which case we just return
        if not input then return end
        -- if it is not nil then we check for a truthy value
        if input:lower() == 'true' or input:lower() == 'yes' then
            return true
        else
            -- note that because we did not return nil or reject then false will be passed to command callback, see example parse
            return false
        end
    end)

    Once all params are defined you can now define some default values if you have optional params, the default value will be used only
    when no value is given as input, if an invalid value is given then the command will still fail and this value will not be used, the
    default can also be a function which is passed the player using the command and returns a value. Here we set the default for "smiley" to false:
    :set_defaults{smiley=false}

    Another example of defaults if we have: item, amount[opt], player[opt]
    :set_defaults{
        amount = 50, -- more than one value can be set at a time
        player = function(player)
            return player -- default is the player using the command
        end
    }

    Now the params are set up we can alter how the command works, we can set auth flags, add aliases to this command or enable "auto concat"
    which is when you want all extra words to be concatenated onto the end of the last param, useful for reason or messages:
    :set_flag('admin_only',true) -- in our case we want "admin_only" to be set to true so only admins can use the command
    :add_alias('name','rname') -- we also add two aliases here: "name" and "rname" which point to this command
    -- :enable_auto_concat() we do not use this in our case but this can also be used to enable the "auto concat" feature

    And finally we want to register a callback to this command, the callback is what defines what the command does, can be as complex as you
    want it to be to as simple as our example; the command receives two params plus all that you have defines:
    1) the player who used the command
    2) in our case repeat_count which will be a number
    3) in our case smiley which will be a boolean
    4) the raw input; this param is always last as is always present as a catch all
    :register(function(player,repeat_count,smiley,raw)
        -- this is to show the value for raw as this is an example command, the log file will also show this
        game.print(player.name..' used a command with input: '..raw)
        local msg = ') '..player.name
        if smiley then
            -- this is where that smiley param is used
            msg = ':'..msg
        end
        for 1 = 1,repeat_count do
            -- this print function will return ANY value to the user in a desync safe manor, this includes if the command was used through rcon
            Command.print(1..msg)
        end
        -- see below for what else can be used here
    end)

    Some other useful functions that can be used are:
    Commands.print(any,colour[opt]) -- this will return any value value to the user including if it is ran through rcon console
    Commands.error(message[opt]) -- this returns a warning to the user, aka an error that does not prevent execution of the command
    return Commands.error(message[opt]) -- this returns an error to the user, and will halt the command execution, ie no success message is returned
    Commands.success(message[opt]) -- used to return a success message however dont use this method see below
    return Commands.success(message[opt]) -- will return the success message to the user and your given message, halts execution
    return <any> if any value is returned then it will be returned to the player via a Commands.success call

    Example Code:
    Commands.new_command('repeat-name','Will repeat you name a number of times in chat.')
    :add_param('repeat-count',false,'number-range-int',1,5) -- required int in range 1 to 5 inclusive
    :add_param('smiley',true,function(input,player,reject) -- optional boolean default false
        if not input then return end
        if input:lower() == 'true' or input:lower() == 'yes' then
            return true
        else
            return false
        end
    end)
    :set_defaults{smiley=false}
    :set_flag('admin_only',true) -- command is admin only
    :add_alias('name','rname') -- allow alias: name and rname
    :register(function(player,repeat_count,smiley,raw)
        game.print(player.name..' used a command with input: '..raw)
        local msg = ') '..player.name
        if smiley then
            msg = ':'..msg
        end
        for 1 = 1,repeat_count do
            Command.print(1..msg)
        end
    end)

>>>>Functions List (see function for more detail):
    Commands.add_authenticator(callback) --- Adds an authorization callback, function used to check if a player if allowed to use a command
    Commands.remove_authenticator(callback) --- Removes an authorization callback, see add_authenticator for adding them
    Commands.authorize(player,command_name) --- Mostly used internally, calls all authorization callbacks, returns if the player is authorized

    Commands.get(player) --- Gets all commands that a player is allowed to use, game commands not included
    Commands.search(keyword,allowed_player) --- Searches command names and help messages to find possible commands, game commands included

    Commands.add_parse(name,callback) --- Adds a parse function which can be called by name rather than callback (used in add_param)
    Commands.remove_parse(name) --- Removes a parse function, see add_parse for adding them
    Commands.parse(name,input,player,reject,...) --- Intended to be used within other parse functions, runs a parse and returns success and new value

    Commands.new_command(name,help) --- Creates a new command object to added details to, note this does not register the command to the game
    Commands._prototype:add_param(name,optional,parse,...) --- Adds a new param to the command this will be displayed in the help and used to parse the input
    Commands._prototype:set_defaults(defaults) --- Adds default values to params only matters if the param is optional
    Commands._prototype:set_flag(name,value) --- Adds a tag to the command which is passed via the flags param to the authenticators, can be used to assign command roles or type
    Commands._prototype:add_alias(...) --- Adds an alias or multiple that will also be registered with the same callback, eg /teleport can be /tp with both working
    Commands._prototype:enable_auto_concat() --- Enables auto concatenation of any params on the end so quotes are not needed for last param
    Commands._prototype:register(callback) --- Adds the callback to the command and registers all aliases, params and help message with the game

    Commands.error(error_message,play_sound) --- Sends an error message to the player and returns a constant to return to command handler to exit execution
    Commands.internal_error(success,command_name,error_message) --- Sends an error to the player and logs the error, used with pcall within command handler please avoid direct use
    Commands.success(value) --- Sends a value to the player, followed by a command complete message
    Commands.print(value) --- Short cut for player_return, will return any value given to it (not just strings) in a string format to the player/server

    Commands.run_command(command_event) --- Main event function that is ran for all commands, used internally please avoid direct use
]]

local Game = require 'utils.game'
local player_return,write_json = ext_require('expcore.common','player_return','write_json')

local Commands = {
    defines={ -- common values are stored error like signals
        error='CommandError',
        unauthorized='CommandErrorUnauthorized',
        success='CommandSuccess'
    },
    commands={}, -- custom command data will be stored here
    authorization_fail_on_error=false, -- set true to have authorize fail if a callback fails to run, more secure
    authorization={}, -- custom function are stored here which control who can use what commands
    parse_functions={}, -- used to store default functions which are common parse function such as player or number in range
    print=player_return, -- short cut so player_return does not need to be required in every module
    _prototype={}, -- used to store functions which gets added to new custom commands
}

--- Adds an authorization callback, function used to check if a player if allowed to use a command
-- @see Commands.authorize
-- @tparam callback function the callback you want to register as an authenticator
-- callback param - player: LuaPlayer - the player who is trying to use the command
-- callback param - command: string - the name of the command which is being used
-- callback param - flags: table - any flags which have been set for the command
-- callback param - reject: function(error_message?: string) - call to fail authorize with optional error message
-- @treturn number the index it was inserted at use to remove the callback, if anon function used
function Commands.add_authenticator(callback)
    table.insert(Commands.authorization,callback)
    return #Commands.authorization
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
        failed = error_message or {'expcore-commands.unauthorized'}
        return Commands.defines.unauthorized
    end

    -- loops over each authorization callback if any return false or unauthorized command will fail
    for _,callback in pairs(Commands.authorization) do
        -- callback(player: LuaPlayer, command: string, flags: table, reject: function(error_message?: string))
        local success, rtn = pcall(callback,player,command_name,command_data.flags,auth_fail)
        -- error handler
        if not success then
            -- the callback failed to run
            log('[ERROR] Authorization failed: '..rtn)
            if Commands.authorization_fail_on_error then
                failed = 'Internal Error'
            end
        elseif rtn == false or rtn == Commands.defines.unauthorized or rtn == auth_fail or failed then
            -- the callback returned unauthorized, failed be now be set if no value returned
            failed = failed or {'expcore-commands.unauthorized'}
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

--- Gets all commands that a player is allowed to use, game commands not included
-- @tparam[opt] player LuaPlayer the player that you want to get commands of, nil will return all commands
-- @treturn table all commands that that player is allowed to use, or all commands
function Commands.get(player)
    player = Game.get_player_from_any(player)
    if not player then return Commands.commands end
    local allowed = {}
    for name,command_data in pairs(Commands.commands) do
        if Commands.authorize(player,name) then
            allowed[name]=command_data
        end
    end
    return allowed
end

--- Searches command names and help messages to find possible commands, game commands included
-- @tparam keyword string the word which you are trying to find
-- @tparam[opt] allowed_player LuaPlayer the player to get allowed commands of, if nil all commands are searched
-- @treturn table all commands that contain the key word, and allowed by player if player given
function Commands.search(keyword,allowed_player)
    local custom_commands = Commands.get(allowed_player)
    local matches = {}
    keyword = keyword:lower()
    -- loops over custom commands
    for name,command_data in pairs(custom_commands) do
        -- combines name help and aliases into one message to be searched
        local search = string.format('%s %s %s',name,command_data.help,table.concat(command_data.aliases,' '))
        if search:lower():match(keyword) then
            matches[name] = command_data
        end
    end
    -- loops over the names of game commands
    for name,description in pairs(commands.game_commands) do
        if name:lower():match(keyword) then
            -- because game commands lack some stuff that the custom ones have they are formated
            matches[name] = {
                name=name,
                help=description,
                description='',
                aliases={}
            }
        end
    end
    return matches
end

--- Adds a parse function which can be called by name rather than callback (used in add_param)
-- nb: this is not needed as you can use the callback directly this just allows it to be called by name
-- @tparam name string the name of the parse, should be the type like player or player_alive, must be unique
-- @tparam callback function the callback that is ran to parse the input
-- parse param - input: string - the input given by the user for this param
-- parse param - player: LuaPlayer - the player who is using the command
-- parse param - reject: function(error_message) - use this function to send a error to the user and fail running
-- parse return - the value that will be passed to the command callback, must not be nil and if reject then command is not run
-- @treturn boolean was the parse added will be false if the name is already used
function Commands.add_parse(name,callback)
    if Commands.parse_functions[name] then
        return false
    else
        Commands.parse_functions[name] = callback
        return true
    end
end

--- Removes a parse function, see add_parse for adding them
-- @tparam name string the name of the parse to remove
function Commands.remove_parse(name)
    Commands.parse_functions[name] = nil
end

--- Intended to be used within other parse functions, runs a parse and returns success and new value
-- @tparam name string the name of the parse to call, must be registered and cant be a function
-- @tparam input string the input to pass to the parse, will always be a string but might not be the orginal input
-- @treturn any the new value for the input, may be nil, if nil then either there was an error or input was nil
function Commands.parse(name,input,player,reject,...)
    if not Commands.parse_functions[name] then return end
    local success,rtn = pcall(Commands.parse_functions[name],input,player,reject,...)
    if not success then error(rtn,2) return end
    if not rtn then return end
    if rtn == Commands.defines.error then return end
    return rtn
end

--- Creates a new command object to added details to, note this does not register the command to the game
-- @tparam name string the name of the command to be created
-- @tparam help string the help message for the command
-- @treturn Commands._prototype this will be used with other functions to generate the command functions
function Commands.new_command(name,help)
    local command = setmetatable({
        name=name,
        help=help,
        callback=function() Commands.internal_error(false,name,'No callback registered') end,
        auto_concat=false,
        min_param_count=0,
        max_param_count=0,
        flags={}, -- stores flags that can be used by auth
        aliases={}, -- n = name: string
        params={}, -- [param_name] = {optional: boolean, default: any, parse: function, parse_args: table}
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

--- Adds default values to params only matters if the param is optional, if default value is a function it is called with param player
-- @tparam defaults table a table keyed by the name of the param with the value as the default value {paramName=defaultValue}
-- callback param - player: LuaPlayer - the player using the command, default value does not need to be a function callback
-- @treturn Commands._prototype pass through to allow more functions to be called
function Commands._prototype:set_defaults(defaults)
    for name,value in pairs(defaults) do
        if self.params[name] then
            self.params[name].default = value
        end
    end
    return self
end

--- Adds a tag to the command which is passed via the flags param to the authenticators, can be used to assign command roles or type
-- @tparam name string the name of the tag to be added; used to keep flags separate
-- @tparam value any the tag that you want can be anything that the authenticators are expecting
-- nb: if value is nil then name will be assumed as the value and added at a numbered index
-- @treturn Commands._prototype pass through to allow more functions to be called
function Commands._prototype:set_flag(name,value)
    if not value then
        -- value not given so name is the value
        table.insert(self.flags,name)
    else
        -- name is given so its key: value
        self.flags[name] = value
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
function Commands._prototype:enable_auto_concat()
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
    commands.add_command(self.name,{'expcore-commands.command-help',description,self.help},function(command_event)
        local success, err = pcall(Commands.run_command,command_event)
        if not success then log('[ERROR] command/'..self.name..' :: '..err) end
    end)
    -- adds any aliases that it has
    for _,alias in pairs(self.aliases) do
        if not commands.commands[alias] and not commands.game_commands[alias] then
            commands.add_command(alias,{'expcore-commands.command-help',description,self.help},function(command_event)
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
    player_return({'expcore-commands.command-fail',error_message},'orange_red')
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
        log{'expcore-commands.command-error-log-format',command_name,error_message}
    end
    return not success
end

--- Sends a value to the player, followed by a command complete message
-- nb: either return a value from your callback to trigger or return the return of this to prevent two messages
-- @tparam[opt] value any the value to return to the player, if nil then only success message returned
-- @treturn Commands.defines.success return this to the command handler to prevent two success messages
function Commands.success(value)
    if value ~= nil then player_return(value) end
    player_return({'expcore-commands.command-ran'},'cyan')
    return Commands.defines.success
end

-- logs command usage to file
local function command_log(player,command,comment,params,raw,details)
    local player_name = player and player.name or '<Server>'
    write_json('log/commands.log',{
        player_name=player_name,
        command_name=command.name,
        comment=comment,
        details=details,
        params=params,
        raw=raw
    })
end

--- Main event function that is ran for all commands, used internally please avoid direct use
-- @tparam command_event table passed directly from command event from the add_command function
function Commands.run_command(command_event)
    local command_data = Commands.commands[command_event.name]
    -- player can be nil when it is the server
    local player
    if command_event.player_index and command_event.player_index > 0 then
        player = Game.get_player_by_index(command_event.player_index)
    end

    -- checks if player is allowed to use the command
    local authorized, auth_fail = Commands.authorize(player,command_data.name)
    if not authorized then
        command_log(player,command_data,'Failed Auth',{},command_event.parameter)
        Commands.error(auth_fail,'utility/cannot_build')
        return
    end

    -- null param check
    if command_data.min_param_count > 0 and not command_event.parameter then
        command_log(player,command_data,'No Params Given',{},command_event.parameter)
        Commands.error({'expcore-commands.invalid-inputs',command_data.name,command_data.description})
        return
    end

    -- splits the arguments
    local input_string = command_event.parameter or ''
    local quote_params = {} -- stores any " " params
    input_string = input_string:gsub('"[^"]-"',function(w)
        -- finds all " " params are removes spaces for the next part
        local no_spaces = w:gsub('%s','_')
        local no_quotes = w:sub(2,-2)
        quote_params[no_spaces]=no_quotes
        if command_data.auto_concat then
            -- if auto concat then dont remove quotes as it should be included later
            quote_params[no_spaces]=w
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
                command_log(player,command_data,'Invalid Input: Too Many Params',raw_params,input_string)
                Commands.error({'expcore-commands.invalid-inputs',command_data.name,command_data.description})
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
                table.insert(raw_params,quote_params[word])
                last_index = last_index + 1
            else
                table.insert(raw_params,word)
                last_index = last_index + 1
            end
        end
    end

    -- checks param count
    local param_count = #raw_params
    if param_count < command_data.min_param_count then
        command_log(player,command_data,'Invalid Input: Not Enough Params',raw_params,input_string)
        Commands.error({'expcore-commands.invalid-inputs',command_data.name,command_data.description})
        return
    end

    -- parses the arguments
    local index = 1
    local params = {}
    for param_name, param_data in pairs(command_data.params) do
        local parse_callback = param_data.parse
        if type(parse_callback) == 'string' then
            -- if its a string this allows it to be pulled from the common store
            parse_callback = Commands.parse_functions[parse_callback]
        end
        if not type(parse_callback) == 'function' then
            -- if its not a function throw and error
            Commands.internal_error(false,command_data.name,'Invalid param parse '..tostring(param_data.parse))
            command_log(player,command_data,'Internal Error: Invalid Param Parse',params,command_event.parameter,tostring(param_data.parse))
            return
        end
        -- used below as the reject function
        local parse_fail = function(error_message)
            error_message = error_message or ''
            command_log(player,command_data,'Invalid Param Given',raw_params,input_string)
            return Commands.error{'expcore-commands.invalid-param',param_name,error_message}
        end
        -- input: string, player: LuaPlayer, reject: function, ... extra args
        local success,param_parsed = pcall(parse_callback,raw_params[index],player,parse_fail,unpack(param_data.parse_args))
        if Commands.internal_error(success,command_data.name,param_parsed) then
            return command_log(player,command_data,'Internal Error: Param Parse Fail',params,command_event.parameter,param_parsed)
        end
        if param_data.optional == true and raw_params[index] == nil then
            -- if it is optional and param is nil then it is set to default
            param_parsed = param_data.default
            if type(param_parsed) == 'function' then
                -- player: LuaPlayer
                success,param_parsed = pcall(param_parsed,player)
                if Commands.internal_error(success,command_data.name,param_parsed) then
                    return command_log(player,command_data,'Internal Error: Default Value Fail',params,command_event.parameter,param_parsed)
                end
            end
        elseif param_parsed == nil or param_parsed == Commands.defines.error or param_parsed == parse_fail then
            -- no value was returned or error was returned, if nil then give generic error
            if not param_parsed == Commands.defines.error then
                command_log(player,command_data,'Invalid Param Given',raw_params,input_string,param_name)
                Commands.error{'expcore-commands.command-error-param-format',param_name,'please make sure it is the correct type'}
            end
            return
        end
        -- adds the param to the table to be passed to the command callback
        table.insert(params,param_parsed)
        index=index+1
    end

    -- runs the command
    -- player: LuaPlayer, ... command params, raw: string
    table.insert(params,command_data.max_param_count+1,input_string)
    local success, err = pcall(command_data.callback,player,unpack(params))
    if Commands.internal_error(success,command_data.name,err) then
        return command_log(player,command_data,'Internal Error: Command Callback Fail',raw_params,command_event.parameter,err)
    end
    if err == Commands.defines.error or err == Commands.error then
        return command_log(player,command_data,'Custom Error',raw_params,input_string)
    elseif err ~= Commands.defines.success and err ~= Commands.success then
        -- in this case the user has not received any output
        Commands.success(err)
    end
    command_log(player,command_data,'Success',raw_params,input_string)
end

return Commands