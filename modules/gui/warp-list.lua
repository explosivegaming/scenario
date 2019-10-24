--[[-- Gui Module - Warp List
    - Adds a warp list gui which allows players to add and remove warp points
    @gui Warps-List
    @alias warp_list
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Store = require 'expcore.store' --- @dep expcore.store
local Global = require 'utils.global' --- @dep utils.global
local Event = require 'utils.event' --- @dep utils.event
local Game = require 'utils.game' --- @dep utils.game
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Colors = require 'resources.color_presets' --- @dep resources.color_presets
local config = require 'config.warps' --- @dep config.warps
local format_time,table_keys = ext_require('expcore.common','format_time','table_keys') --- @dep expcore.common
local Warps = require 'modules.control.warps' --- @dep modules.control.warps

-- Stores a boolean value indexed by player name
local player_in_range_store = Store.register(function(player)
    return player.name
end)

-- Stores the time remaing for a players warp cooldown
local player_warp_cooldown_store = Store.register(function(player)
    return player.name
end)

-- Table that stores a boolean value of weather to keep the warp gui open
local keep_gui_open = {}
Global.register(keep_gui_open,function(tbl)
    keep_gui_open = tbl
end)

--- Returns if a player is allowed to edit the given warp
--- If a player is allowed to use the edit buttons
local function check_player_permissions(player,action,warp)
    -- Check if the action is allow edit and then check bypass settings
    if action == 'allow_edit_warp' then
        -- Check if the warp is the spawn then it cant be edited
        local spawn_id = Warps.get_spawn_warp_id(player.force.name)
        if spawn_id == warp.warp_id then
            return false
        end

        -- Check if the player being the last to edit will override existing permisisons
        if config.user_can_edit_own_warps and warp.last_edit_name == player.name then
            return true
        end
    end

    -- Check player has permisison based on value in the config
    local action_config = config[action]
    if action_config == 'all' then
        return true
    elseif action_config == 'admin' then
        return player.admin
    elseif action_config == 'expcore.roles' then
        return Roles.player_allowed(player,config['expcore_roles_'..action])
    end

    -- Return false as all other condidtions have not been met
    return false
end

--- Will add a new warp to the list, checks if the player is too close to an existing one
-- @element add_new_warp
local add_new_warp =
Gui.element{
    type = 'sprite-button',
    sprite = 'utility/add',
    tooltip = {'warp-list.add-tooltip'},
    style = 'tool_button'
}
:style{
    padding = -2,
    height = 20,
    width = 20
}
:on_click(function(player,element)
    -- Add the new warp
    local force_name = player.force.name
    local surface = player.surface
    local position = player.position
    local warp_id = Warps.add_warp(force_name,surface,position,player.name)
    Warps.make_warp_tag(warp_id)
    Warps.make_warp_area(warp_id)
end)

--- Removes a warp from the list, including the physical area and map tag
-- @element discard_warp
local discard_warp =
Gui.element{
    type = 'sprite-button',
    sprite = 'utility/trash',
    tooltip = {'warp-list.discard-tooltip'},
    style = 'tool_button'
}
:style{
    padding = -2,
    height = 20,
    width = 20
}
:on_click(function(_,element)
    local warp_id = element.parent.name:sub(6)
    Warps.remove_warp(warp_id)
end)

--- Opens edit mode for the warp
-- @element edit_warp
local edit_warp =
Gui.element{
    type = 'sprite-button',
    sprite = 'utility/rename_icon_normal',
    tooltip = {'warp-list.edit-tooltip-none'},
    style = 'tool_button'
}
:style{
    padding = -2,
    height = 20,
    width = 20
}
:on_click(function(player,element)
    local warp_id = element.parent.name:sub(6)
    Warps.set_editing(warp_id,player.name,true)
end)

--- Set of three elements which make up each row of the warp table
-- @element add_warp_base
local add_warp_base =
Gui.element(function(_,parent,warp_id)
    -- Add the icon flow
    local icon_flow =
    parent.add{
        name = 'icon-'..warp_id,
        type = 'flow',
        caption = warp_id
    }

    -- Change the style of the flow
    icon_flow.style.padding = 0

    -- Add a flow which will contain the warp name and edit buttons
    local warp_flow =
    parent.add{
        name = warp_id,
        type = 'flow',
    }

    -- Set the padding on the warp flow
    warp_flow.style.padding = 0

    -- Add the two edit buttons outside the warp flow
    local edit_flow = Gui.alignment(parent,nil,nil,'edit-'..warp_id)
    edit_warp(edit_flow)
    discard_warp(edit_flow)

    -- Return the warp flow as the main element
    return warp_flow
end)

-- Removes the three elements that are added as part of the warp base
local function remove_warp_base(parent,warp_id)
    Gui.destroy_if_valid(parent['icon-'..warp_id])
    Gui.destroy_if_valid(parent['edit-'..warp_id])
    Gui.destroy_if_valid(parent[warp_id])
end

--- Confirms the edit to name or icon of the warp
-- @element confirm_edit
local warp_editing
local warp_icon_button
local confirm_edit =
Gui.element{
    type = 'sprite-button',
    sprite = 'utility/downloaded',
    tooltip = {'warp-list.confirm-tooltip'},
    style = 'shortcut_bar_button_green'
}
:style{
    padding = -2,
    right_margin = -3,
    height = 22,
    width = 22
}
:on_click(function(player,element)
    local warp_id = element.parent.name
    local warp_name = element.parent[warp_editing.name].text
    local warp_icon = element.parent.parent['icon-'..warp_id][warp_icon_button.name].elem_value
    Warps.set_editing(warp_id,player.name)
    Warps.update_warp(warp_id,warp_name,warp_icon,player.name)
end)

--- Cancels the editing changes of the selected warp name or icon
-- @element cancel_edit
local cancel_edit =
Gui.element{
    type = 'sprite-button',
    sprite = 'utility/close_black',
    tooltip = {'warp-list.cancel-tooltip'},
    style = 'shortcut_bar_button_red'
}
:style{
    padding = -2,
    right_margin = -3,
    height = 22,
    width = 22
}
:on_click(function(player,element)
    local warp_id = element.parent.name
    Warps.set_editing(warp_id,player.name)
end)

--- Editing state for a warp, contrins a text field and the two edit buttons
-- @element warp_editing
warp_editing =
Gui.element(function(event_trigger,parent,warp)
    local name = warp.name

    -- Draw the element
    local element =
    parent.add{
        name = event_trigger,
        type = 'textfield',
        text = name,
        clear_and_focus_on_right_click = true
    }

    -- Change the style
    local style = element.style
    style.maximal_width = 110
    style.height = 20

    -- Add the edit buttons
    cancel_edit(parent)
    confirm_edit(parent)

    -- Return the element
    return element
end)
:on_confirmed(function(player,element,_)
    local warp_id = element.parent.name
    local warp_name = element.text
    local warp_icon = element.parent.parent['icon-'..warp_id][warp_icon_button.name].elem_value
    Warps.set_editing(warp_id,player.name)
    Warps.update_warp(warp_id,warp_name,warp_icon,player.name)
end)

--- Default state for a warp, contains only a label with the warp name
-- @element warp_label
local warp_label =
Gui.element(function(event_trigger,parent,warp)
    local name = warp.name
    local last_edit_name = warp.last_edit_name
    local last_edit_time = warp.last_edit_time

    -- Draw the element
    local element =
    parent.add{
        name = event_trigger,
        type = 'label',
        caption = name,
        tooltip = {'warp-list.last-edit',last_edit_name,format_time(last_edit_time)}
    }

    -- Change the style
    local style = element.style
    style.single_line = false
    style.maximal_width = 150

    -- Return the element
    return element
end)
:on_click(function(player,element,_)
    local warp_id = element.parent.name
    local warp = Warps.get_warp(warp_id)
    local position = warp.position
    player.zoom_to_world(position,1.5)
end)


--- Default state for the warp icon, when pressed teleports the player
-- @element warp_icon_button
warp_icon_button =
Gui.element(function(event_trigger,parent,warp)
    local warp_position = warp.position

    -- Draw the element
    local element =
    parent.add{
        name = event_trigger,
        type = 'sprite-button',
        sprite = 'item/'..warp.icon,
        tooltip = {'warp-list.goto-tooltip',warp_position.x,warp_position.y},
        style = 'quick_bar_slot_button'
    }

    -- Change the style
    local style = element.style
    style.height = 32
    style.width = 32

    -- Return the element
    return element
end)
:on_click(function(player,element,_)
    local warp_id = element.parent.caption
    Warps.teleport_player(warp_id,player)

    -- Reset the warp cooldown if the player does not have unlimited warps
    if not check_player_permissions(player,'bypass_warp_cooldown') then
        Store.set(player_warp_cooldown_store,player,config.cooldown_duraction)
        Store.trigger(player_in_range_store,player)
    end
end)

--- Editing state for the warp icon, chose elem used to chosse icon
-- @element warp_icon_editing
local warp_icon_editing =
Gui.element(function(event_trigger,parent,warp)
    local warp_icon = warp.icon

    -- Draw the element
    local element =
    parent.add{
        name = warp_icon_button.name,
        type = 'choose-elem-button',
        elem_type = 'item',
        item = warp_icon,
        tooltip = {'warp-list.goto-edit'},
    }

    -- Change the style
    local style = element.style
    style.height = 32
    style.width = 32

    -- Return the element
    return element
end)

--- This timer controls when a player is able to warp, eg every 60 seconds
-- @element warp_timer
local warp_timer =
Gui.element{
    type = 'progressbar',
    tooltip = {'warp-list.timer-tooltip',config.cooldown_duraction},
    minimum_value = 0,
    maximum_value = config.cooldown_duraction*config.update_smoothing
}
:style{
    horizontally_stretchable = true,
    color = Colors.light_blue
}

--- Updates a warp for a player
local function update_warp(player,warp_table,warp_id)
    local warp = Warps.get_warp(warp_id)

    -- Warp no longer exists so should be removed from the list
    if not warp then
        remove_warp_base(warp_table,warp_id)
        return
    end

    -- Get the warp flow for this warp
    local warp_flow = warp_table[warp_id] or add_warp_base(warp_table,warp_id)
    local icon_flow = warp_table['icon-'..warp_id]

    -- Update the edit flow
    local edit_flow = warp_table['edit-'..warp_id]
    local player_allowed_edit = check_player_permissions(player,'allow_edit_warp',warp)
    local players_editing = table_keys(warp.currently_editing)
    local edit_warp_element = edit_flow[edit_warp.name]
    local discard_warp_element = edit_flow[discard_warp.name]

    edit_warp_element.visible = player_allowed_edit
    discard_warp_element.visible = player_allowed_edit
    if #players_editing > 0 then
        edit_warp_element.hovered_sprite = 'utility/warning_icon'
        edit_warp_element.tooltip = {'warp-list.edit-tooltip',table.concat(players_editing,', ')}
    else
        edit_warp_element.hovered_sprite = edit_warp_element.sprite
        edit_warp_element.tooltip = {'warp-list.edit-tooltip-none'}
    end

    -- Check if the player is was editing and/or currently editing
    local warp_label_element = warp_flow[warp_label.name] or warp_label(warp_flow,warp)
    local icon_entry = icon_flow[warp_icon_button.name] or warp_icon_button(icon_flow,warp)
    local player_was_editing = icon_entry.type == 'choose-elem-button'
    local player_is_editing = warp.currently_editing[player.name]

    -- Update the warp and icon flow
    if not player_was_editing and not player_is_editing then
        -- Update the warp name label and icon
        local warp_name = warp.name
        local warp_icon = warp.icon
        local last_edit_name = warp.last_edit_name
        local last_edit_time = warp.last_edit_time
        warp_label_element.caption = warp_name
        warp_label_element.tooltip = {'warp-list.last-edit',last_edit_name,format_time(last_edit_time)}
        icon_entry.sprite = 'item/'..warp_icon

    elseif player_was_editing and not player_is_editing then
        -- Player was editing but is no longer, remove text field and add label
        edit_warp_element.enabled = true
        warp_flow.clear()
        warp_label(warp_flow,warp)

        icon_flow.clear()
        local warp_icon_element = warp_icon_button(icon_flow,warp)
        local timer = Store.get(player_warp_cooldown_store,player)
        local in_range = Store.get(player_in_range_store,player)
        local apply_proximity = not check_player_permissions(player,'bypass_warp_proximity')
        if (timer and timer > 0) or (apply_proximity and not in_range) then
            warp_icon_element.enabled = false
            warp_icon_element.tooltip = {'warp-list.goto-disabled'}
        end

    elseif not player_was_editing and player_is_editing then
        -- Player was not editing but now is, remove label and add text field
        edit_warp_element.enabled = false
        warp_flow.clear()
        warp_editing(warp_flow,warp).focus()
        icon_flow.clear()
        warp_icon_editing(icon_flow,warp)

    end
end

local function update_all_warps(player,warp_table)
    local warp_ids = Warps.get_force_warp_ids(player.force.name)
    if #warp_ids > 0 then
        for _,warp_id in ipairs(warp_ids) do
            update_warp(player,warp_table,warp_id)
        end
    end
end

--- Main warp list container for the left flow
-- @element warp_list_container
local warp_list_container =
Gui.element(function(event_trigger,parent)
    -- Draw the external container
    local frame =
    parent.add{
        name = event_trigger,
        type = 'frame'
    }

    -- Set the frame style
    local frame_style = frame.style
    frame_style.padding = 2
    frame_style.minimal_width = 200

    -- Draw the internal container
    local container =
    frame.add{
        name = 'container',
        type = 'frame',
        direction = 'vertical',
        style = 'window_content_frame_packed'
    }

    -- Set the container style
    local style = container.style
    style.vertically_stretchable = false

    -- Draw the header
    local header = Gui.header(
        container,
        {'warp-list.main-caption'},
        {'warp-list.sub-tooltip', config.cooldown_duraction, config.standard_proximity_radius},
        true
    )

    -- Draw the new warp button
    local player = Gui.get_player_from_element(parent)
    local add_new_warp_element = add_new_warp(header)
    add_new_warp_element.visible = check_player_permissions(player,'allow_add_warp')

    -- Draw the scroll table for the warps
    local scroll_table = Gui.scroll_table(container,258,3)

    -- Change the style of the scroll table
    local scroll_table_style = scroll_table.style
    scroll_table_style.top_cell_padding = 3
    scroll_table_style.bottom_cell_padding = 3

    -- Draw the warp cooldown progress bar
    local warp_timer_element = warp_timer(container)

    -- Change the progress of the warp timer
    local progress = 1
    local timer = Store.get(player_warp_cooldown_store,player)
    if timer and timer > 0 then
        progress = 1 - (timer/config.cooldown_duraction)
    end
    warp_timer_element.value = progress

    -- Add any existing warps
    update_all_warps(player,scroll_table)

    -- Return the exteral container
    return frame
end)
:add_to_left_flow()

--- Button on the top flow used to toggle the warp list container
-- @element warp_list_toggle
Gui.element{
    type = 'sprite-button',
    sprite = 'item/'..config.default_icon,
    tooltip = {'warp-list.main-tooltip',config.standard_proximity_radius},
    style = Gui.top_flow_button_style
}
:style{
    padding = -2
}
:add_to_top_flow(function(player)
    return Roles.player_allowed(player,'gui/warp-list')
end)
:on_click(function(player,_,_)
    local visible_state = Gui.toggle_left_element(player, warp_list_container)
    keep_gui_open[player.name] = visible_state
end)

--- When the name of a warp is updated this is triggered
Warps.on_update(function(warp,_,removed_warp)
    -- Get the force to update, warp is nil when removed
    local force
    if warp then
        force = game.forces[warp.force_name]
    else
        force = game.forces[removed_warp.force_name]
    end

    -- Update the gui for selected players
    local warp_ids = Warps.get_force_warp_ids(force.name)
    for _,player in pairs(force.connected_players) do
        local left_flow = Gui.get_left_flow(player)
        local frame = left_flow[warp_list_container.name]
        local scroll_table = frame.container.scroll.table

        -- Update the gui
        scroll_table.clear()
        for _,next_warp_id in ipairs(warp_ids) do
            update_warp(player,scroll_table,next_warp_id)
        end
    end
end)

--- Update the warps when the player joins
Event.add(defines.events.on_player_joined_game,function(event)
    local player = game.players[event.player_index]
    local left_flow = Gui.get_left_flow(player)
    local frame = left_flow[warp_list_container.name]
    local scroll_table = frame.container.scroll.table
    update_all_warps(player,scroll_table)
end)

--- Makes sure the right buttons are present when roles change
local function role_update_event(event)
    local player = game.players[event.player_index]
    local left_flow = Gui.get_left_flow(player)
    local container = left_flow[warp_list_container.name].container

    -- Update the warps, incase the user can now edit them
    local scroll_table = container.scroll.table
    update_all_warps(player,scroll_table)

    -- Update the new warp button incase the user can now add them
    local add_new_warp_element = container.header.alignment[add_new_warp.name]
    add_new_warp_element.visible = check_player_permissions(player,'allow_add_warp')
end

Event.add(Roles.events.on_role_assigned,role_update_event)
Event.add(Roles.events.on_role_unassigned,role_update_event)

--- When the player leaves or enters range of a warp this is triggered
Store.watch(player_in_range_store,function(value,player_name)
    local player = game.players[player_name]
    local force = player.force

    -- Change if the frame is visible based on if the player is in range
    if not keep_gui_open[player.name] then
        Gui.toggle_left_element(player,warp_list_container,value)
    end

    -- Check if the player requires proximity
    if check_player_permissions(player,'bypass_warp_proximity') then
        return
    end

    -- Get the warp table
    local left_flow = Gui.get_left_flow(player)
    local frame = left_flow[warp_list_container.name]
    local scroll_table = frame.container.scroll.table

    -- Check if the buttons should be active
    local timer = Store.get(player_warp_cooldown_store,player)
    local button_disabled = timer and timer > 0 or not value

    -- Change the enabled state of the warp buttons
    local warp_ids = Warps.get_force_warp_ids(force.name)
    for _,warp_id in pairs(warp_ids) do
        local element = scroll_table['icon-'..warp_id][warp_icon_button.name]
        if element and element.valid then
            element.enabled = not button_disabled
            if button_disabled then
                element.tooltip = {'warp-list.goto-disabled'}
            else
                local position = Warps.get_warp(warp_id).position
                element.tooltip = {'warp-list.goto-tooltip',position.x,position.y}
            end
        end
    end
end)

--- Update the warp cooldown progress bars to match the store
Store.watch(player_warp_cooldown_store,function(value,player_name,old_value)
    if value == old_value then return end
    -- Get the progress bar element
    local player = game.players[player_name]
    local left_flow = Gui.get_left_flow(player)
    local frame = left_flow[warp_list_container.name]
    local warp_timer_element = frame.container[warp_timer.name]

    -- Set the progress
    local progress = 1
    local timer = Store.get(player_warp_cooldown_store,player)
    if timer and timer > 0 then
        progress = 1 - (timer/config.cooldown_duraction)
    end
    warp_timer_element.value = progress

    -- Trigger update of buttons if cooldown is now 0
    if value == 0 then
        Store.trigger(player_in_range_store,player_name)
    end
end)

--- Handles updating the timer and checking distance from a warp
local r2 = config.standard_proximity_radius^2
local rs2 = config.spawn_proximity_radius^2
local mr2 = config.minimum_distance^2
Event.on_nth_tick(math.floor(60/config.update_smoothing),function()
    Store.map(player_warp_cooldown_store,function(value)
        if value > 0 then
            return value - 1
        end
    end)

    local force_warps = {}
    local warps = {}
    for _,player in pairs(game.connected_players) do
        local was_in_range = Store.get(player_in_range_store,player)

        -- Get the ids of all the warps on the players force
        local force_name = player.force.name
        local warp_ids = force_warps[force_name]
        if not warp_ids then
            warp_ids = Warps.get_force_warp_ids(force_name)
            force_warps[force_name] = warp_ids
        end

        -- Check if the force has any warps
        local closest_warp
        local closest_distance
        if #warp_ids > 0 then
            local surface = player.surface
            local pos = player.position
            local px,py = pos.x,pos.y

            -- Loop over each warp
            for _,warp_id in ipairs(warp_ids) do
                -- Check if warp id is chached
                local warp = warps[warp_id]
                if not warp then
                    warp = Warps.get_warp(warp_id)
                    warps[warp_id] = warp
                end

                -- Check if the player is within range
                local warp_pos = warp.position
                if warp.surface == surface then
                    local dx, dy = px-warp_pos.x, py-warp_pos.y
                    local dist = (dx*dx)+(dy*dy)
                    if closest_distance == nil or dist < closest_distance then
                        closest_warp = warp
                        closest_distance = dist
                        if dist < r2 then break end
                    end
                end
            end

            -- Check the dist to the closest warp
            local in_range = closest_warp.warp_id == warp_ids.spawn and closest_distance < rs2 or closest_distance < r2
            if was_in_range and not in_range then
                Store.set(player_in_range_store,player,false)
            elseif not was_in_range and in_range then
                Store.set(player_in_range_store,player,true)
            end

            -- Change the enabled state of the add warp button
            local left_flow = Gui.get_left_flow(player)
            local frame = left_flow[warp_list_container.name]
            local add_warp_element = frame.container.header.alignment[add_new_warp.name]
            local was_able_to_make_warp = add_warp_element.enabled
            local can_make_warp = closest_distance > mr2
            if can_make_warp and not was_able_to_make_warp then
                add_warp_element.enabled = true
                add_warp_element.tooltip = {'warp-list.add-tooltip'}
            elseif not can_make_warp and was_able_to_make_warp then
                add_warp_element.enabled = false
                add_warp_element.tooltip = {'warp-list.too-close',closest_warp.name}
            end

        end

    end

end)

--- When a player is created make sure that there is a spawn warp created
Event.add(defines.events.on_player_created,function(event)
    -- If the force has no spawn then make a spawn warp
    local player = Game.get_player_by_index(event.player_index)
    local force = player.force
    local spawn_id = Warps.get_spawn_warp_id(force.name)
    if not spawn_id then
        local spawn_position = force.get_spawn_position(player.surface)
        spawn_id = Warps.add_warp(force.name,player.surface,spawn_position,nil,'Spawn')
        Warps.set_spawn_warp(spawn_id,force)
        Store.trigger(Warps.store,spawn_id)
        Warps.make_warp_tag(spawn_id)
    end
end)

--- When a chart tag is removed or edited make sure it is not one that belongs to a warp
local function maintain_tag(event)
    if not event.player_index then return end
    local tag = event.tag
    local force_name = event.force.name
    local warp_ids = Warps.get_force_warp_ids(force_name)
    for _,warp_id in pairs(warp_ids) do
        local warp = Warps.get_warp(warp_id)
        local wtag = warp.tag
        if not wtag or not wtag.valid or wtag == tag then
            if event.name == defines.events.on_chart_tag_removed then
                warp.tag = nil
            end
            Warps.make_warp_tag(warp_id)
        end
    end
end

Event.add(defines.events.on_chart_tag_modified,maintain_tag)
Event.add(defines.events.on_chart_tag_removed,maintain_tag)