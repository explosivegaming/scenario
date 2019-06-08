--- Gui left frame define for a player list
local Gui = require 'expcore.gui'
local Roles = require 'expcore.roles'
local Store = require 'expcore.store'
local Game = require 'utils.game'
local Event = require 'utils.event'
local format_time = ext_require('expcore.common','format_time')
local config = require 'config.action_buttons'
local Colors = require 'resources.color_presets'

local action_player_store = 'gui.left.player-list.action-player'
local action_name_store = 'gui.left.player-list.action-name'

--- used on player name label to allow zoom to map
local zoom_to_map_name = Gui.uid_name()
Gui.on_click(zoom_to_map_name,function(event)
    local action_player_name = event.element.caption
    local action_player = Game.get_player_from_any(action_player_name)
    if event.button == defines.mouse_button_type.left then
        -- lmb will zoom to map
        local position = action_player.position
        event.player.zoom_to_world(position,1.75)
    else
        -- rmb will open settings
        local player_name = event.player.name
        local old_action_player_name = Store.get(action_player_store,player_name)
        if action_player_name == old_action_player_name then
            Store.clear(action_player_store,player_name) -- will close if already open
        else
            Store.set(action_player_store,player_name,action_player_name)
        end
    end
end)

--- Button used to open the action bar
local open_action_bar =
Gui.new_button()
:set_sprites('utility/expand_dots_white')
:set_tooltip{'player-list.open-action-bar'}
:set_embeded_flow(function(element,action_player_name)
    return action_player_name
end)
:set_style('frame_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.width = 8
    style.height = 14
end)
:on_click(function(player,element)
    local new_action_player_name = element.parent.name
    local action_player_name = Store.get(action_player_store,player.name)
    if action_player_name == new_action_player_name then
        Store.clear(action_player_store,player.name) -- will close if already open
    else
        Store.set(action_player_store,player.name,new_action_player_name)
    end
end)

--- Button used to close the action bar
local close_action_bar =
Gui.new_button()
:set_sprites('utility/close_black','utility/close_white')
:set_tooltip{'player-list.close-action-bar'}
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-1,-1,-1,-1)
    style.height = 28
    style.width = 28
end)
:on_click(function(player,element)
    Store.clear(action_player_store,player.name)
    Store.clear(action_name_store,player.name)
end)

--- Button used to confirm a reason
local reason_confirm =
Gui.new_button()
:set_sprites('utility/confirm_slot')
:set_tooltip{'player-list.reason-confirm'}
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-1,-1,-1,-1)
    style.height = 28
    style.width = 28
end)
:on_click(function(player,element)
    local reason = element.parent.entry.text or 'Non Given'
    local action_name = Store.get(action_name_store,player.name)
    local reason_callback = config[action_name].reason_callback
    reason_callback(player,reason)
    Store.clear(action_player_store,player.name)
    Store.clear(action_name_store,player.name)
    element.parent.entry.text = ''
end)

--[[ Creates the main gui areas for the player list
    element
    > container
    >> scroll
    >>> table
    >> action_bar
]]
local function generate_container(player,element)
    Gui.set_padding(element,2,2,2,2)
    element.style.minimal_width = 200

    -- main container which contains the other elements
    local container =
    element.add{
        name='container',
        type='frame',
        direction='vertical',
        style='window_content_frame_packed'
    }
    Gui.set_padding(container)

    -- a scroll bar which allows 8 players to be seen at once
    local list_scroll =
    container.add{
        name='scroll',
        type='scroll-pane',
        direction='vertical',
        horizontal_scroll_policy='never',
        vertical_scroll_policy='auto-and-reserve-space'
    }
    Gui.set_padding(list_scroll,1,1,2,2)
    list_scroll.style.horizontally_stretchable = true
    list_scroll.style.maximal_height = 188

    -- 3 wide table to contain: action button, player name, and play time
    local list_table =
    list_scroll.add{
        name='table',
        type='table',
        column_count=3
    }
    Gui.set_padding(list_table)
    list_table.style.horizontally_stretchable = true
    list_table.style.vertical_align = 'center'
    list_table.style.cell_padding = 0

    -- action bar which contains the different action buttons
    local action_bar =
    container.add{
        name='action_bar',
        type='frame',
        style='subfooter_frame'
    }
    Gui.set_padding(action_bar,1,1,3,3)
    action_bar.style.horizontally_stretchable = true
    action_bar.style.height = 35

    -- reason bar which contains the reason text field and confirm button
    local reason_bar =
    container.add{
        name='reason_bar',
        type='frame',
        style='subfooter_frame'
    }
    Gui.set_padding(reason_bar,-1,-1,3,3)
    reason_bar.style.horizontally_stretchable = true
    reason_bar.style.height = 35
    local action_name = Store.get(action_name_store,player.name)
    reason_bar.visible = action_name ~= nil

    -- text entry for the reason bar
    local reason_field =
    reason_bar.add{
        name='entry',
        type='textfield',
        style='stretchable_textfield',
        tooltip={'player-list.reason-entry'}
    }
    Gui.set_padding(reason_field)
    reason_field.style.height = 28
    reason_field.style.minimal_width = 160

    reason_confirm(reason_bar)

    return list_table, action_bar
end

--- Adds buttons and permission flows to the action bar
local function generate_action_bar(player,element)
    close_action_bar(element)
    local action_player = Store.get(action_player_store,player.name)

    for action_name,buttons in pairs(config) do
        local permission_flow =
        element.add{
            type='flow',
            name=action_name
        }

        for _,button in ipairs(buttons) do
            button(permission_flow)
        end

        if not Roles.player_allowed(player,action_name) then
            permission_flow.visible = false
        end

        if buttons.auth and action_player and not buttons.auth(player,action_player) then
            permission_flow.visible = false
        end
    end

    if not action_player then
        element.visible = false
    end
end

--- Updates the action bar
local player_list_name
local function update_action_bar(player)
    local frame = Gui.classes.left_frames.get_frame(player_list_name,player)
    local element = frame.container.action_bar
    local action_player_name = Store.get(action_player_store,player.name)

    if not action_player_name then
        element.visible = false
    else
        local action_player = Game.get_player_from_any(action_player_name)
        if not action_player.connected then
            element.visible = false
            Store.clear(action_player_store,player.name) -- clears store if player is offline
            Store.clear(action_name_store,player.name)
        else
            element.visible = true
            for action_name,buttons in pairs(config) do
                if buttons.auth and not buttons.auth(player,action_player) then
                    element[action_name].visible = false
                elseif Roles.player_allowed(player,action_name) then
                    element[action_name].visible = true
                end
            end
        end
    end
end

--- Adds a player to the player list
local function add_player(list_table,player,role_name)
    open_action_bar(list_table,player.name)

    -- flow to contain player_name to allow all to have trigger for zoom to map
    local player_name_flow =
    list_table.add{
        type='flow'
    }
    Gui.set_padding(player_name_flow)

    -- player name with the tooltip of their highest role and in they colour
    local player_name =
    player_name_flow.add{
        name=zoom_to_map_name,
        type='label',
        caption=player.name,
        tooltip={'player-list.open-map',player.name,player.tag,role_name}
    }
    Gui.set_padding(player_name,0,0,0,2)
    player_name.style.font_color = player.chat_color

    -- flow which allows right align for the play time
    local time_flow = Gui.create_right_align(list_table,'player-time-'..player.index)

    -- time given in Xh Ym and is right aligned
    local tick = game.tick > 0 and game.tick or 1
    local percent = math.round(player.online_time/tick,3)*100
    local time =
    time_flow.add{
        name='label',
        type='label',
        caption=format_time(player.online_time),
        tooltip={'player-list.afk-time',percent,format_time(player.afk_time,{minutes=true,long=true})}
    }
    Gui.set_padding(time)
end

--- Adds fake players to the player list
local function add_fake_players(list_table,count)
    local role_name = 'Fake Player'
    for i = 1,count do
        add_player(list_table,{
            name='Player '..i,
            index=0-i,
            tag='',
            online_time=math.random(0,game.tick),
            afk_time=math.random(0,game.tick),
            chat_color=table.get_random_dictionary_entry(Colors)
        },role_name)
    end
end

--- Registers the player list
local player_list =
Gui.new_left_frame('gui/player-list')
:set_sprites('entity/character')
:set_tooltip{'player-list.main-tooltip'}
:set_open_by_default()
:set_direction('vertical')
:on_draw(function(player,element)
    local list_table,action_bar = generate_container(player,element)
    generate_action_bar(player,action_bar)

    local players = {}
    for _,next_player in pairs(game.connected_players) do
        local highest_role = Roles.get_player_highest_role(next_player)
        if not players[highest_role.name] then
            players[highest_role.name] = {}
        end
        table.insert(players[highest_role.name],next_player)
    end

    for _,role_name in pairs(Roles.config.order) do
        if players[role_name] then
            for _,next_player in pairs(players[role_name]) do
                add_player(list_table,next_player,role_name)
            end
        end
    end

    --add_fake_players(list_table,6)
    --add_fake_players(list_table,20)
end)
:on_update(function(player,element)
    local list = element.container.scroll.table
    for _,next_player in pairs(game.connected_players) do
        local time_element_name = 'player-time-'..next_player.index
        local time_element = list[time_element_name]
        if time_element and time_element.valid then
            time_element.label.caption = format_time(next_player.online_time)
            local tick = game.tick > 0 and game.tick or 1
            local percent = math.round(next_player.online_time/tick,3)*100
            time_element.label.tooltip = {'player-list.afk-time',percent,format_time(next_player.afk_time,{minutes=true,long=true})}
        end
    end
end)

player_list_name = player_list:uid()

--- When the action player is changed the action bar will update
Store.register(action_player_store,function(value,category)
    local player = Game.get_player_from_any(category)
    update_action_bar(player)
end)

--- When the action name is changed the reason input will update
Store.register(action_name_store,function(value,category)
    local player = Game.get_player_from_any(category)
    local frame = Gui.classes.left_frames.get_frame(player_list_name,player)
    local element = frame.container.reason_bar
    if value then
        local action_player_name = Store.get(action_player_store,category)
        local action_player = Game.get_player_from_any(action_player_name)
        if action_player.connected then
            element.visible = true
        else
            Store.clear(action_player_store,category) -- clears store if player is offline
            Store.clear(action_name_store,category)
        end
    else
        element.visible = false
    end
end)

--- Many events which trigger the gui to be re drawn, it will also update the times every 30 seconds
Event.on_nth_tick(1800,player_list 'update_all')
Event.add(defines.events.on_player_joined_game,player_list 'redraw_all')
Event.add(defines.events.on_player_left_game,player_list 'redraw_all')
Event.add(Roles.player_role_assigned,player_list 'redraw_all')
Event.add(Roles.player_role_unassigned,player_list 'redraw_all')

return player_list