--- A full ranking system for factorio.
-- @module ExpGamingCore.Commands
-- @alias commands
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Game = require('FactorioStdLib.Game')
local Color = require('FactorioStdLib.Color')
local Ranking -- this is optional and is hanndled by it being present, it is loaded on init

--- Used as an error constant for validation
-- @field commands.error
-- @usage return commands.error, 'err message'
-- @usage return commands.error('err message')
commands.error = setmetatable({},{__call=function(...) return ... end})
commands._add_command = commands.add_command
local data = {}

--- Index of all command data
-- @field commands.data
-- @usage commands.command_name -- returns command data
-- @usage commands.data -- returns all data
-- @tparam ?string|table|event key the command that will be returned: string is the name, table is the command data, event is event from add_command
-- @treturn table the command data
setmetatable(commands,{
    __index=function(tbl,key) return is_type(key,'table') and (key.command and rawget(data,key.name) or key) or key == 'data' and data or rawget(data,key) end
})

--- Collection of funcations that can be used to validate inputs
-- @table commands.validate
-- @usage commands.validate[type](value,event,...)
-- @tparam string type the type that the value should be
-- @param value the value that will be tested
-- @param ... any other data that can be passed to the function
-- @return[1] the validated value
-- @return[2] error constant
-- @return[2] the err message
-- @field __comment replace _ with - the ldoc did not like me using - in the names
-- @field string basicly does nothing but a type filed is required
-- @field string_inf same as string but is infite in length, must be last arg
-- @field string_len same as string but can define a max lengh
-- @field number converts the input into a number
-- @field number_int conerts the input to a number and floors it
-- @field number_range allows a number in a range min < X <= max
-- @field number_range allows a number in a range after it has been floored min < math.floor(X) <= max
-- @field player converts the input into a valid player
-- @field player_online converts the input to a player if the player is online
-- @field player_alive converts the input to a player if the player is online and alive
-- @field player_rank converts the input to a player if the player is a lower rank than the user or if the person is not admin and the user is
-- @field player_rank-online converts the input to a player if the player is a lower rank than the user and online
-- @field player_rank_alive converts the input to a player if the player is a lower rank than the user and online and alive
commands.validate = {
    ['string']=function(value,event) return tostring(value) end,
    ['string-inf']=function(value,event) return tostring(value) end,
    ['string-len']=function(value,event,max) return tostring(value) and tostring(value):len() <= max and tostring(value) or commands.error{'commands.error-string-len'} end,
    ['number']=function(value,event) return tonumber(value) or commands.error{'commands.error-number'} end,
    ['number-int']=function(value,event) return tonumber(value) and math.floor(tonumber(value)) or commands.error{'commands.error-number'} end,
    ['number-range']=function(value,event,min,max) return tonumber(value) and tonumber(value) > min and tonumber(value) <= max and tonumber(value) or commands.error{'commands.error-number-range'} end,
    ['number-range-int']=function(value,event,min,max) return tonumber(value) and math.floor(tonumber(value)) > min and math.floor(tonumber(value)) <= max and math.floor(tonumber(value)) or commands.error{'commands.error-number-range'} end,
    ['player']=function(value,event) return Game.get_player(player) or commands.error{'commands.error-player'} end,
    ['player-online']=function(value,event) local player,err = commands.validate['player'](value) return err and commands.error(err) or player.conected and player or commands.error{'commands.error-player-online'} end,
    ['player-alive']=function(value,event) local player,err = commands.validate['player-online'](value) return err and commands.error(err) or player.character and player.character.health > 0 and player or commands.error{'commands.error-player-alive'} end,
    ['player-rank']=function(value,event) local player,err = commands.validate['player'](value) return err and commands.error(err) or Ranking and Ranking.get_rank(player).power > Ranking.get_rank(event).power or not player.admin and Game.get_player(event).admin or commands.error{'commands.error-player-rank'} end,
    ['player-rank-online']=function(value,event) local player,err = commands.validate['player-online'](value) return err and commands.error(err) or Ranking and Ranking.get_rank(player).power > Ranking.get_rank(event).power or not player.admin and Game.get_player(event).admin or commands.error{'commands.error-player-rank'} end,
    ['player-rank-alive']=function(value,event) local player,err = commands.validate['player-alive'](value) return err and commands.error(err) or Ranking and Ranking.get_rank(player).power > Ranking.get_rank(event).power or not player.admin and Game.get_player(event).admin or commands.error{'commands.error-player-rank'} end
}

--- Returns the inputs of this command as a formated string
-- @usage commands.format_inputs('interface') -- returns <code> (if you have ExpGamingCore.Server)
-- @tparam ?string|table|event command the command to get the inputs of
-- @treturn string the formated string for the inputs
function commands.format_inputs(command)
    local command = commands[command]
    if not is_type(command,'table') then error('Command is not valid',2) end
    local rtn = ''
    for name,data in pairs(command.inputs) do
        if data[1] == false then rtn=rtn..string.format('[%s] ',name)
        else rtn=rtn..string.format('<%s> ',name) end
    end
    return rtn
end

--- Used to validate the arguments of a command, will understand strings with "" as a single param else spaces divede the params
-- @usage commands.validate_args(event) -- returns args table
-- @tparam table event this is the event created by add_command not on_console_command
-- @treturn[1] table the args for this command
-- @return[2] command.error
-- @treturn string the error that happend while parsing the args
function commands.validate_args(event)
    local command = commands[event.name]
    if not is_type(command,'table') then error('Command not valid',2) end
    local rtn = {}
    local count = 0
    local count_opt = 0
    for name,data in pairs(command.inputs) do count = count + 1 if data[1] == false then count_opt = count_opt + 1 end end
    -- checks that there is some args given if there is ment to be
    if not event.parameter then
        if count == count_opt then return rtn
        else return commands.error('invalid-inputs') end
    end
    -- splits the args into words so that it can be used to asign values
    local words = string.split(event.parameter,' ')
    local index = 0
    for _,word in pairs(words) do
        index = index+1
        if not word then break end
        local pos, _pos = word:find('"')
        while pos and pos == _pos do
            local next = table.remove(words,index+1)
            if not next then return commands.error('invalid-parse') end
            words[index] = words[index]..' '..next
            _pos = words[index]:find('"',pos+1)
        end
    end
    -- assigns the values from the words to the args
    local index = 0
    for name,data in pairs(command.inputs) do
        index = index+1
        local arg = words[index]
        if not arg and not data[1] then return commands.error('invalid-inputs') end
        if data[2] == 'string-inf' then rtn[name] = table.concat(words,' ',index) break end
        local valid = is_type(data[2],'function') and data[2] or commands.validate[data[2]] or error('Invalid type for command: "'..command.name..'/'..name..'"')
        local temp_tbl = table.deep_copy(data) table.remove(temp_tbl,1) table.remove(temp_tbl,2)
        local value, err = valid(arg,event,unpack(temp_tbl))
        if value == commands.error then return value, err end
        rtn[name] = value
    end
    return rtn
end

--- Used to return all the commands a player can use
-- @usage get_commands(1) -- return table of command data for each command that the player can use
-- @tparam ?index|name|player| player the player to test as
-- @treturn table a table containg all the commands the player can use
function commands.get_commands(player)
    local commands = {}
    local player = Game.get_player(player)
    if not player then return error('Invalid player',2) end
    local rank = Ranking.get_rank(player)
    for name,data in pairs(data) do
        if rank:allowed(name) then table.insert(commands,data) end
    end
    return commands
end

--- Used to call the custom commands
-- @usage You dont its an internal command
-- @tparam table command the event rasied by the command
local function run_custom_command(command)
    local data = commands.data[command.name]
    local player_name = Game.get_player(command) and Game.get_player(command).name or 'server'
    -- is the player allowed to use this command, if no ExpGamingCore.Ranking then this is ingroned
    if Ranking and Ranking.meta and Ranking.meta.rank_count > 0 and not Ranking.get_rank(player_name):allowed(command.name) then
        player_return({'commands.unauthorized'},defines.textcolor.crit)
        if game.player then game.player.play_sound{path='utility/cannot_build'} end
        game.write_file('commands.log',
            game.tick
            ..' Player: "'..player_name..'"'
            ..' Failed to use command (Unauthorized): "'..command.name..'"'
            ..' With args of: '..table.tostring(commands.validate_args(command))
            ..'\n'
        , true, 0)
        return
    end
    -- gets the args for the command
    local args, err = commands.validate_args(command)
    if args == commands.error then
        player_return({'commands.'..err,command.name,commands.format_inputs(data)},defines.textcolor.high)
        if game.player then game.player.play_sound{path='utility/deconstruct_big'} end
        game.write_file('commands.log',
            game.tick
            ..' Player: "'..player_name..'"'
            ..' Failed to use command (Invalid Args): "'..command.name..'"'
            ..' With args of: '..table.tostring(args)
            ..'\n'
        , true, 0)
        return
    end
    -- runs the command
    local success, err = pcall(data.callback,command,args)
    if not success then error(err) end
    if err ~= commands.error and player_name ~= 'server' then player_return({'commands.command-ran'},defines.textcolor.info) end
    game.write_file('commands.log',
        game.tick
        ..' Player: "'..player_name..'"'
        ..' Used command: "'..command.name..'"'
        ..' With args of: '..table.tostring(args)
        ..'\n'
    , true, 0)
end

--- Used to define commands
-- @usage --see examples in file
-- @tparam string name the name of the command
-- @tparam[opt='No Description'] string description the description of the command
-- @tparam[opt=an infite string] table inputs a table of the inputs to be used, last index being true makes the last parameter open ended (longer than one word)
-- @tparam function callback the function to call on the event
commands.add_command = function(name, description, inputs, callback)
    if commands[name] then error('That command is already registered',2) end
    if not is_type(name,'string') then error('Command name has not been given') end
    if not is_type(callback,'function') or not is_type(inputs,'table') then
        if is_type(inputs,'function') then commands._add_command(name,description,inputs) 
        else error('Invalid args given to add_command') end
    end
    verbose('Created Command: '..name)
    -- test for string and then test for locale string
    local description = is_type(description,'string') and description 
    or is_type(description,'table') and is_type(description[1],'string') and string.find(description[1],'.+[.].+') and {description,''}
    or 'No Description'
    local inputs = is_type(inputs,'table') and inputs or {['param']={false,'string-inf'}}
    data[name] = {
        name=name,
        description=description,
        inputs=inputs,
        callback=callback
    }
    local help = is_type(description,'string') and commands.format_inputs(name)..'- '..description
    or is_type(description,'table') and is_type(description[1],'string') and string.find(description[1],'.+[.].+') and {description,commands.format_inputs(name)..'- '}
    or commands.format_inputs(name)
    data[name].help = help
    commands._add_command(name,help,function(...)
        local success, err = pcall(run_custom_command,...)
        if not success then error(err) end
    end)
end

function commands:on_init()
    if loaded_modules['ExpGamingCore.Ranking'] then Ranking = require('ExpGamingCore.Ranking') end
end

return commands

--[[
    command example

    locale file
    [foo]
    description=__1__ this is a command

    commands.add_command('foo',{'foo.description'},{
        ['player']={true,'player'}, -- a required arg that must be a valid player
        ['number']={true,'number-range',0,10}, -- a required arg that must be a number 0<X<=10
        ['reason']={false,'string-inf'} -- an optinal arg that is and infite lengh (useful for reasons)
    },function(event,args)
        args.player.print(args.number)
        if args.reasons then args.player.print(args.reason) end
    end)
]]