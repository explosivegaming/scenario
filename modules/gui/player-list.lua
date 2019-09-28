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
local config = require 'config.action_buttons' --- @dep config.action_buttons
local Colors = require 'resources.color_presets' --- @dep resources.color_presets
require 'expcore.toolbar' --- @dep expcore.toolbar

Gui.require_concept('label')
Gui.require_concept('button')
Gui.require_concept('text_field')
Gui.require_concept('frame')
Gui.require_style('expstyle')

local action_player_store = 'gui.left.player-list.action-player'
local action_name_store = 'gui.left.player-list.action-name'

--- Name label that alows zoom to map
-- @element zoom_to_map
local zoom_to_map =
Gui.new_concept('label')
:new_event('on_click',defines.events.on_gui_click)
:on_click(function(event)
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
:define_pre_draw(function(properties,parent,element)
    -- Place the button into a flow
    local flow =
    parent.add{
        type = 'flow',
    }

    return element, flow
end)
:define_draw(function(properties,parent,element,player,role_name)
    local player_name = player.name
    element.caption = player_name
    element.tooltip = {'player-list.open-map',player_name,player.tag,role_name}

    Gui.set_padding(element,0,0,0,2)
    element.style.font_color = player.chat_color
end)

--- Right align for the time label
-- @element right_align
local right_align =
Gui.new_concept('alignment')

--- Shows the players online time
-- @element time_label
local time =
Gui.new_concept('time_label')
:set_time_format{minutes = true}
:set_time(0)
:define_draw(function(properties,parent,element)
    Gui.set_padding(element)
end)

--- Button used to open the action bar
-- @element open_action_bar
local open_action_bar =
Gui.new_concept('button')
:set_sprite('utility/expand_dots_white')
:set_tooltip{'player-list.open-action-bar'}
:define_pre_draw(function(properties,parent,element,action_player_name)
    -- Place the button into a flow
    local flow =
    parent.add{
        type = 'flow',
        name = action_player_name
    }

    return element, flow
end)
:define_draw(function(properties,parent,element)
    -- Update the style of the element
    element.style = 'frame_button'
    local style = element.style
    style.padding = -2
    style.width = 8
    style.height = 14
end)
:on_click(function(event)
    -- Open the action bar when pressed
    local element = event.element
    local player_name = event.player.name
    local new_action_player_name = element.parent.name
    local action_player_name = Store.get(action_player_store,player_name)
    if action_player_name == new_action_player_name then
        Store.clear(action_player_store,player_name) -- will close if already open
    else
        Store.set(action_player_store,player_name,new_action_player_name)
    end
end)

--- Button used to close the action bar
-- @element close_action_bar
local close_action_bar =
Gui.new_concept('button')
:set_sprite('utility/close_black','utility/close_white')
:set_tooltip{'player-list.close-action-bar'}
:define_draw(function(properties,parent,element)
    -- Update the style of the element
    element.style = 'tool_button'
    local style = element.style
    style.padding = -1
    style.height = 28
    style.width = 28
end)
:on_click(function(event)
    -- Close the action bar
    local player_name = event.player.name
    Store.clear(action_player_store,player_name)
    Store.clear(action_name_store,player_name)
end)

--- Adds all the player info into the content table
-- @element player_info
local player_info =
Gui.new_concept()
:define_draw(function(properties,parent,element,player,role_name)
    local player_name = player.name
    open_action_bar:draw(parent,nil,player_name)
    zoom_to_map:draw(parent,nil,player,role_name)
    time:update_time(time:draw(right_align:draw(parent,time.name..player_name)),player.online_time)
end)

--- Stores all the online players
-- @element content_table
local content_table =
Gui.new_concept('scroll_table')
:set_height(188)
:set_column_count(3)

--- Stores all the action buttons
-- @element action_bar
local action_bar =
Gui.new_concept('frame')
:define_draw(function(properties,parent,element)
    element.style = 'subfooter_frame'
    Gui.set_padding(element,1,1,3,3)

    local style = element.style
    style.horizontally_stretchable = true
    style.height = 35

    close_action_bar:draw(element)

    local player = Gui.get_player_from_element(element)
    local action_player = Store.get(action_player_store,player.name)

    for action_name,buttons in pairs(config) do
        local permission_flow =
        element.add{
            type='flow',
            name=action_name
        }

        for _,button in ipairs(buttons) do
            button:draw(permission_flow)
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
end)

--- Text entry for reason
-- @element reason_field
local reason_field =
Gui.new_concept('text_field')
:set_tooltip{'player-list.reason-entry'}
:define_draw(function(properties,parent,element)
    element.style = 'stretchable_textfield'
    local style = element.style
    style.padding = 0
    style.minimal_width = 160
    style.height = 28
end)

--- Button used to confirm a reason
-- @element reason_confirm
local reason_confirm =
Gui.new_concept('button')
:set_sprite('utility/confirm_slot')
:set_tooltip{'player-list.reason-confirm'}
:define_draw(function(properties,parent,element)
    -- Update the style of the element
    element.style = 'tool_button'
    local style = element.style
    style.padding = -1
    style.height = 28
    style.width = 28
end)
:on_click(function(event)
    -- Confirm the reason given
    local element = event.element
    local player_name = event.player.name
    local reason = element.parent.entry.text or 'Non Given'
    local action_name = Store.get(action_name_store,player_name)
    local reason_callback = config[action_name].reason_callback
    reason_callback(event.player,reason)
    Store.clear(action_player_store,player_name)
    Store.clear(action_name_store,player_name)
    element.parent.entry.text = ''
end)

--- Stores the reason entry and confirmation button
-- @element reason_bar
local reason_bar =
Gui.new_concept('frame')
:define_draw(function(properties,parent,element)
    element.style = 'subfooter_frame'
    Gui.set_padding(element,-1,-1,3,3)

    local style = element.style
    style.horizontally_stretchable = true
    style.height = 35

    local player = Gui.get_player_from_element(element)
    local action_name = Store.get(action_name_store,player.name)
    element.visible = action_name ~= nil

    reason_field:draw(element)
    reason_confirm:draw(element)
end)

--- Updates the action bar
local player_list
local function update_action_bar(player)
    local content = player_list:get_content(player)
    local element = Gui.find(content,action_bar)
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
                    print(action_name)
                    element[action_name].visible = false
                elseif Roles.player_allowed(player,action_name) then
                    element[action_name].visible = true
                end
            end
        end
    end
end

--- Adds fake players to the player list
local function add_fake_players(content_area,count)
    local role_name = 'Fake Player'
    for i = 1,count do
        local player = {
            name='Player '..i,
            index=0-i,
            tag='',
            online_time=math.random(0,game.tick),
            afk_time=math.random(0,game.tick),
            chat_color=table.get_random_dictionary_entry(Colors)
        }

        player_info:draw(content_area,nil,player,role_name)
    end
end

--- Registers the player list
-- @element player_list
player_list =
Gui.new_concept('toolbar-frame')
:set_permission_alias('gui/player-list')
:set_sprite('entity/character')
:set_tooltip{'player-list.main-tooltip'}
:set_open_by_default(true)
:set_direction('vertical')
:define_draw(function(properties,parent,element)
    local content_area =
    content_table:draw(element)
    action_bar:draw(element)
    reason_bar:draw(element)

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
                player_info:draw(content_area,nil,next_player,role_name)
            end
        end
    end

    add_fake_players(content_area,4)
end)
:on_update(function(event)
    local list = Gui.find(event.element,content_table,'table')
    for _,next_player in pairs(game.connected_players) do
        local time_element = Gui.find(list,time.name..next_player.name,time)
        if time_element and time_element.valid then
            time:update_time(time_element,next_player.online_time)
        end
    end
end)

--- When the action player is changed the action bar will update
Store.register(action_player_store,function(value,category)
    local player = Game.get_player_from_any(category)
    update_action_bar(player)

    local frame = player_list:get_content(player)
    local data_table = Gui.find(frame,content_table,'table')
    for _,next_player in pairs(game.connected_players) do
        local element = Gui.find(data_table,next_player.name,open_action_bar)
        local style = 'frame_button'
        if next_player.name == value then
            style = 'tool_button'
        end
        element.style = style
        style = element.style
        style.padding = -2
        style.width = 8
        style.height = 14
    end
end)

--- When the action name is changed the reason input will update
Store.register(action_name_store,function(value,category)
    local player = Game.get_player_from_any(category)
    local frame = player_list:get_content(player)
    local element = Gui.find(frame,reason_bar)
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
local update = function(event) player_list:update_all(event) end
Event.on_nth_tick(1800,update)
Event.add(defines.events.on_player_joined_game,update)
Event.add(defines.events.on_player_left_game,update)
Event.add(Roles.events.on_role_assigned,update)
Event.add(Roles.events.on_role_unassigned,update)

return player_list