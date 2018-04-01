--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
-- this file is used to allow easy syncing with out side programes
local Sync = {}

-- only used as a faster way to get to the ranking function
function Sync.set_ranks(...)
    Ranking._base_preset(...)
end

--- Prints to chat as if it were a player
-- @usage Sync.print('Test','Cooldude2606')
-- @param player_message the message to be printed in chat
-- @param player_name the name of the player sending the message
-- @param[opt] player_tag the tag apllied to the player's name
-- @param[opt] plyaer_colour the colour of the message
-- @param[opt] prefix add a prefix before the chat eg [IRC]
function Sync.print(player_message,player_name,player_tag,player_colour,prefix)
    if not player_message then return 'No Message Found' end
    local player = game.player or game.players[player_name]
    local tag = player_tag and player_tag ~= '' and ' '..player_tag or ''
    local colour = player_colour and player_colour ~= '' and player_colour or '#FFFFFF'
    local prefix = prefix and prefix..' ' or ''
    if player then
        tag = ' '..player.tag
        colour = player.color
        player_name = player.name
    else
        if colour:find('#') then
            colour = Color.from_hex(colour)
        else
            colour = defines.color[player_colour]
        end
    end
    game.print(prefix..player_name..tag..': '..player_message,colour)
end

--- Logs an embed to the json.data we use a js script to add things we cant here
-- @usage Sync.emit_embeded{title='BAN',color='0x0',description='A player was banned' ... }
-- @tparam table arg a table which contains everything that the embeded will use
-- @param[opt=''] title the tile of the embed
-- @param[opt='0x0'] color the color given in hex you can use Color.to_hex{r=0,g=0,b=0}
-- @param[opt=''] description the description of the embed
-- @param[opt=''] server_detail sting to add onto the pre-set server detail
-- @param[opt] fieldone the filed to add to the embed (key is name) (value is text) (start value with <<inline>> to make inline)
-- @param[optchain] fieldtwo 
function Sync.emit_embeded(args)
    if not is_type(args,'table') then return end
    local title = is_type(args.title,'string') and args.title or ''
    local color = is_type(args.color,'string') and args.color:find("0x") and args.color or '0x0'
    local description = is_type(args.description,'string') and args.description or ''
    local server_detail = is_type(args.server_detail,'string') and args.server_detail or ''
    local mods_online = 'Mods Online: '..Sync.info().admins
    local done, fields = {title=true,color=true,description=true,server_detail=true}, {{
         name='Server Details',
        value='Server Name: {{ serverName }} Online Players: '..#game.connected_players..' '..mods_online..' Server Time: '..tick_to_display_format(game.tick)..' '..server_detail
    }}
    for key, value in pairs(args) do
        if not done[key] then
            done[key] = true
            local f = {name=key,value='',inline=false}
            local value, inline = value:gsub("<<inline>>",'',1)
            f.value = value
            if inline > 0 then f.inline = true end
            table.insert(fields,f)
        end
    end
    local log_data = {
        title=title,
        description=description,
        color=color,
        fields=fields
    }
    game.write_file('embeded.json',table.json(log_data)..'\n',true,0)
end

--- used to get the number of admins currently online
-- @usage Sync.count_admins()
-- @treturn int the number of admins online
function Sync.count_admins()
    if not game then return 0 end
    local _count = 0
    for _,player in pairs(game.connected_players) do 
        if player.admin then _count=_count+1 end
    end
    return _count
end

--- used to get the number of afk players defined by 2 min by default
-- @usage Sync.count_afk()
-- @tparam[opt=7200] int time in ticks that a player is called afk
-- @treturn int the number of afk players
function Sync.count_afk(time)
    if not game then return 0 end
    local time = time or 7200
    local _count = 0
    for _,player in pairs(game.connected_players) do 
        if player.afk_time > time then _count=_count+1 end
    end
    return _count
end

--- used to get the number of players in each rank and currently online
-- @usage Sync.count_ranks()
-- @treturn table contains the ranks and the players in that rank
function Sync.count_ranks()
    if not game then return {'Offline'} end
    local _ranks = {}
    for power,rank in pairs(Ranking._ranks()) do
        local players = rank:get_players()
        for k,player in pairs(players) do players[k] = player.name end
        local online = rank:get_players(true)
        for k,player in pairs(online) do online[k] = player.name end
        _ranks[rank.name] = {players=players,online=online,n_players=#players,n_online=#online}
    end
    return _ranks
end

--- used to return the global list and set values in it
-- @usage Sync.info{server_name='Factorio Server 2'}
-- @tparam[opt=nil] table keys to be replaced in the server info
-- @return either returns success when setting or the info when not setting
function Sync.info(set)
    if not global.exp_core then global.exp_core = {} end
    if not global.exp_core.sync then global.exp_core.sync = {
        server_name='Factorio Server',
        reset_time='On Demand',
        time='Day Mth 00 00:00:00 UTC Year',
        time_set=0,
        last_update=0,
        time_period=18000,
        online=#game.connected_players,
        players=#game.players,
        admins=Sync.count_admins(),
        afk=Sync.count_afk(),
        ranks=Sync.count_ranks(),
        rockets=game.forces['player'].get_item_launched('satellite'),
        mods={'base'}
    } end
    if not set then return global.exp_core.sync
    else
        if not is_type(set,'table') then return false end
        for key,value in pairs(set) do 
            global.exp_core.sync[key] = value
        end
        return true
    end
end

--- used to return the global time and set its value
-- @usage Sync.time('Sun Apr  1 18:44:30 UTC 2018')
-- @tparam[opt=nil] string the date time to be set
-- @return either true false if setting or the date time and tick off set
function Sync.time(set)
    local info = Sync.info()
    if not set then return info.time..'('..(game.tick-info.time_set)..')'
    else
        if not is_type(set,'string') then return false end
        info.time = set
        info.time_set = game.tick
        return true
    end
end

--- called to update values inside of the info
-- @usage Sync.update()
-- @return all of the new info
function Sync.update()
    local info = Sync.info()
    info.last_update = game.tick
    info.online = #game.connected_players
    info.players = #game.players
    info.admins = Sync.count_admins()
    info.afk = Sync.count_afk()
    info.ranks = Sync.count_ranks()
    info.rockets = game.forces['player'].get_item_launched('satellite')
    return info
end

--- outputs the curent server info into a file
-- @usage Sync.emit_data()
function Sync.emit_data()
    local info = Sync.info()
    game.write_file('server-info.json',table.json(info),false,0)
end

-- will auto replace the file every 5 min by default
Event.register(defines.events.on_tick,function(event)
    local time = Sync.info().time_period
    if (event.tick%time)==0 then Sync.update() Sync.emit_data() end
end)

return Sync