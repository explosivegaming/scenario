--- Allows syncing with an outside server and info panle.
-- @module ExpGamingCore.Sync
-- @alias Sync
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Game = require('FactorioStdLib.Game@^0.8.0')
local Color = require('FactorioStdLib.Color@^0.8.0')

local Sync = {}
local Sync_updates = {}
local module_verbose = false --true|false

--- Global Table
-- @table global
-- @field server_name the server name
-- @field server_description a short description of the server
-- @field reset_time the reset time of the server
-- @field time the last knowen irl time
-- @field time_set the last in game time that the time was set
-- @field last_update the last time that this info was updated
-- @field time_period how often this infomation is updated
-- @field players a list of different player related states
-- @field ranks a list of player ranks
-- @field rockets the number of rockets launched
-- @field mods the mods which are loaded
local global = global{
    server_name='Factorio Server',
    server_description='A factorio server for everyone',
    reset_time='On Demand',
    time='Day Mth 00 00:00:00 UTC Year',
    date='0000/00/00',
    time_set={0,'0.00M'},
    last_update={0,'0.00M'},
    time_period={18000,'5.00M'},
    game_speed=1.0,
    players={
        online={'Offline'},
        n_online=0,
        all={'Offline'},
        n_all=0,
        admins_online=0,
        afk_players={},
        times={'Offline'} 
    },
    ranks={'Offline'},
    rockets=0,
    mods={'Offline'}
}

--- Player sub-table
-- @table global.players
-- @field online list of all players online
-- @field n_online the number of players online
-- @field all list of all player on or offline
-- @field n_all the number of players who have joined the server
-- @field admins_online the number of admins online
-- @field afk_players the number of afk players
-- @field times the play times of every player

--- Used to standidise the tick format for any sync info
-- @usage Sync.tick_format(60) -- return {60,'1.00M'}
-- @treturn {number,string} table containg both the raw number and clean version of a time
function Sync.tick_format(tick)
    if not is_type(tick,'number') then error('Tick was not given to Sync.tick_format',2) end
    return {tick,tick_to_display_format(tick)}
end

--- Prints to chat as if it were a player
-- @usage Sync.print('Test','Cooldude2606')
-- @tparam string player_message the message to be printed in chat
-- @tparam string player_name the name of the player sending the message
-- @tparam[opt] string player_tag the tag apllied to the player's name
-- @tparam[opt] string player_colour the colour of the message, either hex or named colour
-- @tparam[opt] string prefix add a prefix before the chat eg [IRC]
function Sync.print(player_message,player_name,player_tag,player_colour,prefix)
    if not player_message then error('No message given to Sync.print',2) end
    local player = game.player or game.players[player_name]
    local tag = player_tag and player_tag ~= '' and ' '..player_tag or ''
    local colour = type(player_colour) == 'string' and player_colour or '#FFFFFF'
    local prefix = prefix and prefix..' ' or ''
    -- if it is an ingame player it will over ride the given params
    if player then
        tag = ' '..player.tag
        colour = player.chat_color
        player_name = player.name
    else
        -- converts colour into the accepted factorio version
        if colour:find('#') then colour = Color.from_hex(colour)
        else colour = defines.color[player_colour] end
    end
    game.print(prefix..player_name..tag..': '..player_message,colour)
end

--- Outline of the paramaters accepted by Sync.emit_embeded
-- @table EmitEmbededParamaters
-- @field title the tile of the embed
-- @field color the color given in hex you can use Color.to_hex{r=0,g=0,b=0}
-- @field description the description of the embed
-- @field server_detail sting to add onto the pre-set server detail
-- @field fieldone the filed to add to the embed (key is name) (value is text) (start value with &lt;&lt;inline&gt;&gt; to make inline)
-- @field fieldtwo the filed to add to the embed (key is name) (value is text) (start value with &lt;&lt;inline&gt;&gt; to make inline)

--- Logs an embed to the json.data we use a js script to add things we cant here
-- @usage Sync.emit_embeded{title='BAN',color='0x0',description='A player was banned' ... }
-- @tparam table args a table which contains everything that the embeded will use
-- @see EmitEmbededParamaters
function Sync.emit_embeded(args)
    if not is_type(args,'table') then error('Args table not given to Sync.emit_embeded',2) end
    if not game then error('Game has not loaded',2) end
    local title = is_type(args.title,'string') and args.title or ''
    local color = is_type(args.color,'string') and args.color:find("0x") and args.color or '0x0'
    local description = is_type(args.description,'string') and args.description or ''
    local server_detail = is_type(args.server_detail,'string') and args.server_detail or ''
    local mods_online = 'Mods Online: '..Sync.info.players.admins_online
    -- creates the first field given for every emit
    local done, fields = {title=true,color=true,description=true,server_detail=true}, {{
        name='Server Details',
        value='Server Name: {{ serverName }} Online Players: '..#game.connected_players..' '..mods_online..' Server Time: '..tick_to_display_format(game.tick)..' '..server_detail
    }}
    -- for each value given in args it will create a new field for the embed
    for key, value in pairs(args) do
        if not done[key] then
            done[key] = true
            local f = {name=key,value='',inline=false}
            -- if <<inline>> is present then it will cause the field to be inline if the previous
            local value, inline = value:gsub("<<inline>>",'',1)
            if inline > 0 then f.inline = true end
            f.value = value
            table.insert(fields,f)
        end
    end
    -- forms the data that will be emited to the file
    local log_data = {
        title=title,
        description=description,
        color=color,
        fields=fields
    }
    game.write_file('embeded.json',table.json(log_data)..'\n',true,0)
end

--- The error handle setup by sync to emit a discord embed for any errors
-- @local here
-- @function errorHandler
-- @tparam string err the error passed by the err control
error.addHandler('Discord Emit',function(err)
    if not game then return error(error()) end
    local color = Color and Color.to_hex(defines.textcolor.bg) or '0x0'
    Sync.emit_embeded{title='SCRIPT ERROR',color=color,description='There was an error in the script @Developers ',Error=err}
end)

--- Used to get the number of admins currently online
-- @usage Sync.count_admins() -- returns number
-- @treturn number the number of admins online
function Sync.count_admins()
    -- game check
    if not game then return 0 end
    local _count = 0
    for _,player in pairs(game.connected_players) do 
        if player.admin then _count=_count+1 end
    end
    return _count
end

--- Used to get the number of afk players defined by 2 min by default
-- @usage Sync.count_afk_times()
-- @tparam[opt=7200] int time in ticks that a player is called afk
-- @treturn number the number of afk players
function Sync.count_afk_times(time)
    if not game then return 0 end
    local time = time or 7200
    local rtn = {}
    for _,player in pairs(game.connected_players) do 
        if player.afk_time > time then rtn[player.name] = Sync.tick_format(player.afk_time) end
    end
    return rtn
end

--- Used to get the number of players in each rank and currently online; if ExpGamingCore/Role is present then it will give more than admin and user
-- @usage Sync.count_roles()
-- @treturn table contains the ranks and the players in that rank
function Sync.count_roles()
    if not game then return {'Offline'} end
    local _roles = {admin={online={},players={}},user={online={},players={}}}
    for index,player in pairs(game.players) do
        if player.admin then
            table.insert(_roles.admin.players,player.name)
            if player.connected then table.insert(_roles.admin.online,player.name) end
        else
            table.insert(_roles.user.players,player.name)
            if player.connected then table.insert(_roles.user.online,player.name) end
        end
    end
    _roles.admin.n_players,_roles.admin.n_online=#_roles.admin.players,#_roles.admin.online
    _roles.user.n_players,_roles.user.n_online=#_roles.user.players,#_roles.user.online
    return _roles
end

--- Used to get a list of every player name with the option to limit to only online players
-- @usage Sync.count_players()
-- @tparam boolean online true will get only the online players
-- @treturn table table of player names
function Sync.count_players(online)
    if not game then return {'Offline'} end
    local _players = {}
    local players = {}
    if online then _players = game.connected_players else _players = game.players end
    for k,player in pairs(_players) do table.insert(players,player.name) end
    return players
end

--- Used to get a list of every player name with the amount of time they have played for
-- @usage Sync.count_player_times()
-- @treturn table table indexed by player name, each value contains the raw tick and then the clean string
function Sync.count_player_times()
    if not game then return {'Offline'} end
    local _players = {}
    for index,player in pairs(game.players) do
        _players[player.name] = Sync.tick_format(player.online_time)
    end
    return _players
end

--- used to get the global list that has been defined, also used to set that list
-- @usage Sync.info{server_name='Factorio Server 2'} -- returns true
-- @usage Sync.info -- table of info
-- @tparam[opt=nil] table set keys to be replaced in the server info
-- @treturn boolean success was the data set
Sync.info = setmetatable({},{
    __index=global,
    __newindex=global,
    __call=function(tbl,set)
        if not is_type(set,'table') then return false end
        for key,value in pairs(set) do global[key] = value end
        return true
    end
})

--- Called to update values inside of the info
-- @usage Sync.update()
-- @return all of the new info
function Sync.update()
    local info = Sync.info
    info.time_period[2] = tick_to_display_format(info.time_period[1])
    info.last_update[1] = game.tick
    info.last_update[2] = tick_to_display_format(game.tick)
    info.game_speed = game.speed
    info.players={
        online=Sync.count_players(true),
        n_online=#game.connected_players,
        all=Sync.count_players(),
        n_all=#game.players,
        admins_online=Sync.count_admins(),
        afk_players=Sync.count_afk_times(),
        times=Sync.count_player_times()
    }
    info.ranks = Sync.count_roles()
    info.rockets = game.forces['player'].get_item_launched('satellite')
    for key,callback in pairs(Sync_updates) do info[key] = callback() end
    return info
end

--- Adds a callback to be called when the info is updated
-- @usage Sync.add_update('players',function() return #game.players end)
-- @tparam string key the key that the value will be stored in
-- @tparam function callback the function which will return this value
function Sync.add_update(key,callback)
    if game then return end
    if not is_type(callback,'function') then return end
    Sync_updates[key] = callback
end

--- Outputs the curent server info into a file
-- @usage Sync.emit_data()
function Sync.emit_data()
    local info = Sync.info
    game.write_file('server-info.json',table.json(info),false,0)
end

--- Updates the info and emits the data to a file
-- @usage Sync.emit_update()
function Sync.emit_update()
    Sync.update() Sync.emit_data()  
end

--- Used to return and set the current IRL time; not very good need a better way to do this
-- @usage Sync.time('Sun Apr  1 18:44:30 UTC 2018')
-- @usage Sync.time -- string
-- @tparam[opt=nil] string set the date time to be set
-- @treturn boolean if the datetime set was successful
Sync.time=add_metatable({},function(full,date)
    local info = Sync.info
    if not is_type(full,'string') then return false end
    info.time = full
    info.date = date
    info.time_set[1] = Sync.tick_format(game.tick)
    return true
end,function() local info = Sync.info return info.time..' (+'..(game.tick-info.time_set[1])..' Ticks)' end)

-- will auto replace the file every 5 min by default
script.on_event('on_tick',function(event)
    local time = Sync.info.time_period[1]
    if (event.tick%time)==0 then Sync.emit_update() end
end)

script.on_event('on_player_joined_game',Sync.emit_update)
script.on_event('on_pre_player_left_game',Sync.emit_update)
script.on_event('on_rocket_launched',Sync.emit_update)

function Sync:on_init()
    if loaded_modules['ExpGamingCore.Gui@^4.0.0'] then verbose('ExpGamingCore.Gui is installed; Loading gui src') require(module_path..'/src/gui',{Sync=Sync,module_path=module_path}) end
    if loaded_modules['ExpGamingCore.Role@^4.0.0'] then verbose('ExpGamingCore.Role is installed; Loading role src') require(module_path..'/src/ranking',{Sync=Sync}) end
    if loaded_modules['ExpGamingCore.Server@^4.0.0'] then require('ExpGamingCore.Server@^4.0.0').add_module_to_interface('Sync','ExpGamingCore.Sync') end
end

function Sync:on_post()
    Sync.info{mods=table.keys(loaded_modules)}
end

return Sync