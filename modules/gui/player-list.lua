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

--- Button used to open the action bar
local open_action_bar =
Gui.new_button()
:set_sprites('utility/expand_dots_white')
:set_tooltip('Options')
:set_embeded_flow(function(element,action_player_name)
    return action_player_name
end)
:set_style('frame_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.width = 8
    style.height = 14
end)
:on_click(function(player,element)
    Store.set_child(action_player_store,player.name,element.parent.name)
end)

--- Button used to close the action bar
local close_action_bar =
Gui.new_button()
:set_sprites('utility/close_black')
:set_tooltip('Close options')
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-1,-1,-1,-1)
    style.height = 28
    style.width = 28
end)
:on_click(function(player,element)
    Store.set_child(action_player_store,player.name,nil)
end)

--[[ Creates the main gui areas for the player list
    element
    > container
    >> scroll
    >>> table
    >> action_bar
]]
local function generate_container(element)
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
    list_scroll.style.maximal_height = 200

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

    return list_table, action_bar
end

--- Adds buttons and permission flows to the action bar
local function generate_action_bar(player,element)
    close_action_bar(element)
    local action_player = Store.get_child(action_player_store,player.name)

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
            --permission_flow.visible = false
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
    local action_player = Store.get_child(action_player_store,player.name)

    if not action_player then
        element.visible = false
    else
        element.visible = true
        for action_name,buttons in pairs(config) do
            if buttons.auth and not buttons.auth(player,action_player) then
                --element[action_name].visible = false
            else
                element[action_name].visible = true
            end
        end
    end
end

local function add_player(list_table,player,role_name)
    open_action_bar(list_table,player.name)

    -- player name with the tooltip of their highest role and in they colour
    local player_name =
    list_table.add{
        type='label',
        caption=player.name,
        tooltip=role_name
    }
    Gui.set_padding(player_name,0,0,0,2)
    player_name.style.font_color = player.chat_color

    -- flow which allows right align for the play time
    local time_flow =
    list_table.add{
        type='flow'
    }
    Gui.set_padding(time_flow)
    time_flow.style.horizontal_align = 'right'
    time_flow.style.horizontally_stretchable = true

    -- time given in Xh Ym and is right aligned
    local time =
    time_flow.add{
        type='label',
        caption=format_time(player.online_time)
    }
    Gui.set_padding(time)
end

--- Adds fake players to the player list
local function add_fake_players(list_table,count)
    local role_name = 'Fake Player'
    for i = 1,count do
        add_player(list_table,{
            name='Player '..i,
            online_time=math.random(0,game.tick),
            chat_color=table.get_random_dictionary_entry(Colors)
        },role_name)
    end
end

--- Registers the player list
local player_list =
Gui.new_left_frame('gui/player-list')
:set_sprites('entity/character')
:set_open_by_default()
:set_direction('vertical')
:on_draw(function(player,element)
    local list_table,action_bar = generate_container(element)
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

    add_fake_players(list_table,20)
end)

player_list_name = player_list:uid()

--- When the action player is changed the action bar will update
Store.register(action_player_store,function(value,category)
    local player = Game.get_player_from_any(category)
    update_action_bar(player)
end)

--- Many events which trigger the gui to be re drawn
Event.add(defines.events.on_player_joined_game,player_list 'redraw_all')
Event.add(defines.events.on_player_left_game,player_list 'redraw_all')
Event.add(Roles.player_role_assigned,player_list 'redraw_all')
Event.add(Roles.player_role_unassigned,player_list 'redraw_all')

return player_list