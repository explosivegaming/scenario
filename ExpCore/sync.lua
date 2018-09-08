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
local Sync_gui_functions = {}
local Sync_updates = {}

--- Used as a faster way to get to the ranking function, overrides previous
-- @usage Sync.set_ranks{name=rank_name}
function Sync.set_ranks(...)
    Ranking._base_preset(...)
end

--- Used to standidise the tick format for any sync info
-- @usage Sync.tick_format(60) -- return {60,'1.00M'}
function Sync.tick_format(tick)
    return {tick,tick_to_display_format(tick)}
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
        colour = player.chat_color
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
    local mods_online = 'Mods Online: '..Sync.info().players.admins_online
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

-- set up error handle
verbose('Set New Error Handle')
_G.error_handle = function(err)
    local color = _G.Color and Color.to_hex(defines.text_color.bg) or '0x0'
    Sync.emit_embeded{title='SCRIPT ERROR',color=color,description='There was an error in the script @Developers ',Error=err}
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
function Sync.count_afk_times(time)
    if not game then return 0 end
    local time = time or 7200
    local rtn = {}
    for _,player in pairs(game.connected_players) do 
        if player.afk_time > time then rtn[player.name] = Sync.tick_format(player.afk_time) end
    end
    return rtn
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

--- used to get the number of players either online or all
-- @usage Sync.count_players()
-- @tparam bolean online if true only get online players
-- @treturn table contains player names
function Sync.count_players(online)
    if not game then return {'Offline'} end
    local _players = {}
    local players = {}
    if online then _players = game.connected_players else _players = game.players end
    for k,player in pairs(_players) do table.insert(players,player.name) end
    return players
end

--- used to get the number of players resulting in there play times
-- @usage Sync.count_player_times()
-- @treturn table contains players and each player is given a tick amount and a formated string
function Sync.count_player_times()
    if not game then return {'Offline'} end
    local _players = {}
    for index,player in pairs(game.players) do
        _players[player.name] = Sync.tick_format(player.online_time)
    end
    return _players
end

--- used to return the global list and set values in it
-- @usage Sync.info{server_name='Factorio Server 2'}
-- @tparam[opt=nil] table keys to be replaced in the server info
-- @return either returns success when setting or the info when not setting
function Sync.info(set)
    if not global.exp_core then global.exp_core = {} end
    if not global.exp_core.sync then global.exp_core.sync = {
        server_name='Factorio Server',
        server_description='A factorio server for everyone',
        reset_time='On Demand',
        time='Day Mth 00 00:00:00 UTC Year',
        game_speed=game.speed,
        time_set=Sync.tick_format(0),
        last_update=Sync.tick_format(0),
        time_period=Sync.tick_format(18000),
        players={
            online=Sync.count_players(true),
            n_online=#game.connected_players,
            all=Sync.count_players(),
            n_all=#game.players,
            admins_online=Sync.count_admins(),
            afk_players=Sync.count_afk_times(),
            times=Sync.count_player_times()
        },
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
    if not set then return info.time..' (+'..(game.tick-info.time_set[1])..' Ticks)'
    else
        if not is_type(set,'string') then return false end
        info.time = set
        info.time_set[1] = game.tick
        info.time_set[2] = tick_to_display_format(game.tick)
        return true
    end
end

--- called to update values inside of the info
-- @usage Sync.update()
-- @return all of the new info
function Sync.update()
    local info = Sync.info()
    info.time_period[2] = tick_to_display_format(info.time_period[1])
    info.last_update[1] = game.tick
    info.last_update[2] = tick_to_display_format(game.tick)
    info.game_speed=game.speed
    info.players={
        online=Sync.count_players(true),
        n_online=#game.connected_players,
        all=Sync.count_players(),
        n_all=#game.players,
        admins_online=Sync.count_admins(),
        afk_players=Sync.count_afk_times(),
        times=Sync.count_player_times()
    }
    info.ranks = Sync.count_ranks()
    info.rockets = game.forces['player'].get_item_launched('satellite')
    for key,callback in pairs(Sync_updates) do info[key] = callback() end
    return info
end

--- Adds a callback to be called when the info is updated
-- @usage Sync.add_update('players',function() return #game.players end)
-- @tparam key string the key that the value will be stored in
-- @tparam callback function the function which will return this value
function Sync.add_update(key,callback)
    if game then return end
    if not is_type(callback,'function') then return end
    Sync_updates[key] = callback
end

--- outputs the curent server info into a file
-- @usage Sync.emit_data()
function Sync.emit_data()
    local info = Sync.info()
    game.write_file('server-info.json',table.json(info),false,0)
end

-- will auto replace the file every 5 min by default
Event.register(defines.events.on_tick,function(event)
    local time = Sync.info().time_period[1]
    if (event.tick%time)==0 then Sync.update() Sync.emit_data() end
end)

--- Adds a emeltent to the sever info gui
-- @usage Sync.add_to_gui('string') -- return trues
-- @param element see examples before for what can be used, it can also be a return from Gui.inputs.add
-- @treturn bolean based on weather it was successful or not
function Sync.add_to_gui(element,...)
    if game then return false end
    if is_type(element,'function') then
        table.insert(Sync_gui_functions,{'function',element,...})
    elseif is_type(element,'table') then
        if element.draw then table.insert(Sync_gui_functions,{'gui',element})
        else table.insert(Sync_gui_functions,{'table',element}) end
    else table.insert(Sync_gui_functions,{'string',element}) end
    return true
end

-- Examples for Sync.add_to_gui
-- adds a basic string to the table
Sync.add_to_gui('Welcome to the Explosive Gaming comunity! This is one of many servers which we host.')
-- adds a string that can have depentant values
Sync.add_to_gui(function(player,frame)
    return 'You have been assigned the rank \''..Ranking.get_rank(player).name..'\''
end)
Sync.add_to_gui(function(player,frame)
    return 'This server\'s next reset: '..Sync.info().reset_time
end)
-- if readme is included then see addons/guis/readme.lua for more examples

-- used to load the gui infomation when _G.Gui is not yet loaded
-- internal use not recomend to be used
function Sync._load()
    local function label_format(label,width)
        label.style.width = width
        label.style.align = 'center'
        label.style.single_line = false
    end
    Gui.center.add{
        name='server-info',
        caption='Server Info',
        tooltip='Basic info about the current server',
        draw=function(self,frame)
            frame.caption = ''
            local info = Sync.info()
            local frame = frame.add{type='flow',direction='vertical'}
            local _flow = frame.add{type='flow'}
            Gui.bar(_flow,200)
            label_format(_flow.add{
                type='label',
                caption='Welcome To '..info.server_name,
                style='caption_label'
            },180)
            Gui.bar(_flow,200)
            label_format(frame.add{
                type='label',
                caption=info.server_description,style='description_label'
            },600)
            Gui.bar(frame,600)
            local _frame = frame
            local frame = frame.add{
                type='frame',
                direction='vertical',
                style='image_frame'
            }
            frame.style.width = 600
            local text_flow = frame.add{type='flow',direction='vertical'}
            local button_flow = frame.add{type='table',column_count=3}
            for _,element in pairs(table.deepcopy(Sync_gui_functions)) do
                local _type = table.remove(element,1)
                if _type == 'function' then
                    local success, err = pcall(table.remove(element,1),frame.player_index,frame,unpack(element))
                    if not success then error(err) else
                        if is_type(err,'table') then
                            if element.draw then element:draw(button_flow).style.width = 195
                            else label_format(text_flow.add{type='label',caption=err},585) end
                        else label_format(text_flow.add{type='label',caption=tostring(err)},585) end
                    end
                elseif _type == 'gui' then element[1]:draw(button_flow).style.width = 195
                elseif _type == 'string' then label_format(text_flow.add{type='label',caption=tostring(element[1])},585)
                elseif _type == 'table' then label_format(text_flow.add{type='label',caption=element[1]},585) end
            end
            _frame.add{
                type='label',
                caption='Press Esc or E to close; this is only visible once!',
                style='fake_disabled_label'
            }.style.font='default-small'
    end}
end

-- opens the server info gui for all new joins except admins
Event.register(defines.events.on_player_joined_game,function(event)
    local player = Game.get_player(event)
    Gui.center.open(player,'server-info')
end)

return Sync
