--[[-- Gui Module - Player List
    - Adds a player list to show names and play time; also includes action buttons which can apply to players
    @gui Player-List
    @alias player_list
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Store = require 'expcore.store' --- @dep expcore.store
local Game = require 'utils.game' --- @dep utils.game
local Event = require 'utils.event' --- @dep utils.event
local format_time = ext_require('expcore.common','format_time') --- @dep expcore.common
local config = require 'config.action_buttons' --- @dep config.action_buttons
local Colors = require 'resources.color_presets' --- @dep resources.color_presets

-- Stores the name of the player a player has selected
local selected_player_store = Store.register(function(player)
    return player.name
end)

-- Stores the current action that a player wants to do
local selected_action_store = Store.register(function(player)
    return player.name
end)

-- Set the config to use these stores
config.set_store_uids(selected_player_store,selected_action_store)

--- Used to open the map on a player or toggle the settings
local zoom_to_map_name = Gui.uid_name()
Gui.on_click(zoom_to_map_name,function(event)
    local selected_player_name = event.element.caption
    local selected_player = Game.get_player_from_any(selected_player_name)
    if event.button == defines.mouse_button_type.left then
        -- LMB will open the map to the selected player
        local position = selected_player.position
        event.player.zoom_to_world(position,1.75)
    else
        -- RMB will toggle the settings
        local player = event.player
        local old_selected_player_name = Store.get(selected_player_store,player)
        if selected_player_name == old_selected_player_name then
            Store.clear(selected_player_store,player)
        else
            Store.set(selected_player_store,player,selected_player_name)
        end
    end
end)

--- Button used to open the action bar
-- @element open_action_bar
local open_action_bar =
Gui.new_button()
:set_sprites('utility/expand_dots_white')
:set_tooltip{'player-list.open-action-bar'}
:set_embedded_flow(function(element,selected_player_name)
    return selected_player_name
end)
:set_style('frame_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.width = 8
    style.height = 14
end)
:on_click(function(player,element)
    local selected_player_name = element.parent.name
    local old_selected_player_name = Store.get(selected_player_store,player)
    if selected_player_name == old_selected_player_name then
        Store.clear(selected_player_store,player)
    else
        Store.set(selected_player_store,player,selected_player_name)
    end
end)

--- Button used to close the action bar
-- @element close_action_bar
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
    Store.clear(selected_player_store,player)
    Store.clear(selected_action_store,player)
end)

--- Button used to confirm a reason
-- @element reason_confirm
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
    local action_name = Store.get(selected_action_store,player)
    local reason_callback = config.buttons[action_name].reason_callback
    reason_callback(player,reason)
    Store.clear(selected_player_store,player)
    Store.clear(selected_action_store,player)
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

    -- 3 wide table to contain: action button, player name, and play time
    local list_table = Gui.create_scroll_table(container,3,188)

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
    local action_name = Store.get(selected_action_store,player)
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
    local selected_player_name = Store.get(selected_player_store,player)

    for action_name,buttons in pairs(config.buttons) do
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

        if buttons.auth and selected_player_name and not buttons.auth(player,selected_player_name) then
            permission_flow.visible = false
        end
    end

    if not selected_player_name then
        element.visible = false
    end
end

--- Updates the action bar
local player_list_name
local function update_action_bar(player)
    local frame = Gui.classes.left_frames.get_frame(player_list_name,player)
    local element = frame.container.action_bar
    local selected_player_name = Store.get(selected_player_store,player)

    if not selected_player_name then
        element.visible = false

    else
        local selected_player = Game.get_player_from_any(selected_player_name)
        if not selected_player.connected then
            -- If the player is offline then reest stores
            element.visible = false
            Store.clear(selected_player_store,player)
            Store.clear(selected_action_store,player)

        else
            -- Otherwise check what actions the player is allowed to use
            element.visible = true
            for action_name,buttons in pairs(config.buttons) do
                if buttons.auth and not buttons.auth(player,selected_player) then
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
    local time_flow = Gui.create_alignment(list_table,'player-time-'..player.index)

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
-- @element player_list
local player_list =
Gui.new_left_frame('gui/player-list')
:set_sprites('entity/character')
:set_tooltip{'player-list.main-tooltip'}
:set_open_by_default()
:set_direction('vertical')
:on_creation(function(player,element)
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
Store.watch(selected_player_store,function(value,player_name)
    local player = Game.get_player_from_any(player_name)
    update_action_bar(player)

    -- Change the style of the option buttons
    local frame = player_list:get_frame(player)
    local data_table = frame.container.scroll.table
    for _,next_player in pairs(game.connected_players) do
        local element = data_table[next_player.name][open_action_bar.name]
        local style = 'frame_button'
        if next_player.name == value then
            style = 'tool_button'
        end
        element.style = style
        Gui.set_padding(element,-2,-2,-2,-2)
        element.style.width = 8
        element.style.height = 14
    end
end)

--- When the action name is changed the reason input will update
Store.watch(selected_action_store,function(value,player_name)
    local player = Game.get_player_from_any(player_name)
    local frame = Gui.classes.left_frames.get_frame(player_list_name,player)
    local element = frame.container.reason_bar
    if value then
        -- if there is a new value then check the player is still online
        local selected_player_name = Store.get(selected_player_store,player_name)
        local selected_player = Game.get_player_from_any(selected_player_name)
        if selected_player.connected then
            element.visible = true
        else
            -- Clear if the player is offline
            Store.clear(selected_player_store,player_name)
            Store.clear(selected_action_store,player_name)
        end

    else
        element.visible = false

    end
end)

--- Many events which trigger the gui to be re drawn, it will also update the times every 30 seconds
Event.on_nth_tick(1800,player_list 'update_all')
Event.add(defines.events.on_player_joined_game,player_list 'redraw_all')
Event.add(defines.events.on_player_left_game,player_list 'redraw_all')
Event.add(Roles.events.on_role_assigned,player_list 'redraw_all')
Event.add(Roles.events.on_role_unassigned,player_list 'redraw_all')

return player_list