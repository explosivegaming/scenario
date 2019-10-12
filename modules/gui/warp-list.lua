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

-- Table that stores a boolean value of weather to keep the warp gui open
local keep_gui_open = {}
Global.register(keep_gui_open,function(tbl)
    keep_gui_open = tbl
end)

--- Returns if a player is allowed to edit the given warp
local function player_allowed_edit(player,warp)
    if warp then
        local spawn_id = Warps.get_spawn_warp_id(player.force.name)
        if spawn_id == warp.warp_id then
            return false
        end
        if config.user_can_edit_own_warps and warp.last_edit_name == player.name then
            return true
        end
    else
        if config.any_user_can_add_new_warp then
            return true
        end
    end

    if config.only_admins_can_edit and not player.admin then
        return false
    end

    if config.edit_warps_role_permission and not Roles.player_allowed(player,config.edit_warps_role_permission) then
        return false
    end

    return true
end

--- Used on the name label to allow zoom to map
-- @element zoom_to_map
local zoom_to_map_name = Gui.uid_name()
Gui.on_click(zoom_to_map_name,function(event)
    local warp_id = event.element.parent.name
    local warp = Warps.get_warp(warp_id)
    local position = warp.position
    event.player.zoom_to_world(position,1.5)
end)


--- This timer controls when a player is able to warp, eg every 60 seconds
-- @element warp_timer
local warp_timer =
Gui.new_progressbar()
:set_tooltip{'warp-list.timer-tooltip',config.recharge_time}
:set_default_maximum(math.floor(config.recharge_time*config.update_smoothing))
:add_store(Gui.categorize_by_player)
:set_style(nil,function(style)
    style.horizontally_stretchable = true
    style.color = Colors.light_blue
end)
:on_store_complete(function(player_name,reset)
    Store.trigger(player_in_range_store,player_name)
end)

--- When the button is clicked it will teleport the player
-- @element goto_warp
local goto_warp =
Gui.new_button()
:set_sprites('item/'..config.default_icon)
:set_tooltip{'warp-list.goto-tooltip',0,0}
:set_style('quick_bar_slot_button',function(style)
    style.height = 32
    style.width = 32
end)
:on_click(function(player,element)
    local warp_id = element.parent.caption
    Warps.teleport_player(warp_id,player)

    -- Reset the warp cooldown if the player does not have unlimited warps
    if config.bypass_warp_limits_permision and not Roles.player_allowed(player,config.bypass_warp_limits_permision) then
        warp_timer:set_store(player.name,0)
        Store.trigger(player_in_range_store,player)
    end
end)

--- Will add a new warp to the list, checks if the player is too close to an existing one
-- @element add_new_warp
local add_new_warp =
Gui.new_button()
:set_sprites('utility/add')
:set_tooltip{'warp-list.add-tooltip'}
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.height = 20
    style.width = 20
end)
:on_click(function(player,element)
    local force_name = player.force.name
    local surface = player.surface
    local position = player.position
    local px = position.x
    local py = position.y
    local dist2 = config.minimum_distance^2

    -- Check the distance to all existing warps
    local warp_ids = Warps.get_force_warp_ids(force_name)
    for _,warp_id in pairs(warp_ids) do
        local warp = Warps.get_warp(warp_id)
        local pos = warp.position
        if surface == warp.surface and (px-pos.x)^2+(py-pos.y)^2 < dist2 then
            player.print{'warp-list.too-close',warp.name}
            return
        end
    end

    -- Add the new warp
    local warp_id = Warps.add_warp(force_name,surface,position,player.name)
    Warps.make_warp_tag(warp_id)
    Warps.make_warp_area(warp_id)
end)

--- Confirms the edit to name or icon of the warp
-- @element confirm_edit
local confirm_edit =
Gui.new_button()
:set_sprites('utility/downloaded')
:set_tooltip{'warp-list.confirm-tooltip'}
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.height = 20
    style.width = 20
end)
:on_click(function(player,element)
    local warp_id = element.parent.name
    local warp_name = element.parent.warp.text
    local warp_icon = element.parent.parent['icon-'..warp_id].icon.elem_value
    Warps.set_editing(warp_id,player.name)
    Warps.update_warp(warp_id,warp_name,warp_icon,player.name)
end)

--- Cancels the editing changes of the selected warp name or icon
-- @element cancel_edit
local cancel_edit =
Gui.new_button()
:set_sprites('utility/close_black')
:set_tooltip{'warp-list.cancel-tooltip'}
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.height = 20
    style.width = 20
end)
:on_click(function(player,element)
    local warp_id = element.parent.name
    Warps.set_editing(warp_id,player.name)
end)

--- Removes a warp from the list, including the physical area and map tag
-- @element discard_warp
local discard_warp =
Gui.new_button()
:set_sprites('utility/trash')
:set_tooltip{'warp-list.discard-tooltip'}
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.height = 20
    style.width = 20
end)
:on_click(function(player,element)
    local warp_id = element.parent.name
    Warps.remove_warp(warp_id)
end)

--- Opens edit mode for the warp
-- @element edit_warp
local edit_warp =
Gui.new_button()
:set_sprites('utility/rename_icon_normal')
:set_tooltip{'warp-list.edit-tooltip-none'}
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.height = 20
    style.width = 20
end)
:on_click(function(player,element)
    local warp_id = element.parent.name
    Warps.set_editing(warp_id,player.name,true)
end)

--[[ Generates each warp, handles both view and edit mode
    element
    > icon-"warp_id"
    >> goto_warp or icon
    > "warp_id"
    >> warp
    >> cancel_edit (edit mode)
    >> confirm_edit (edit mode)
    > edit-"warp_id"
    >> "warp_id"
    >>> edit_warp
    >>> discard_warp
]]
local function generate_warp(player,element,warp_id)
    local warp = Warps.get_warp(warp_id)
    if not warp then
        -- warp is nil so remove it from the list
        Gui.destroy_if_valid(element['icon-'..warp_id])
        Gui.destroy_if_valid(element['edit-'..warp_id])
        Gui.destroy_if_valid(element[warp_id])

    else
        local warp_name = warp.name
        local warp_icon = warp.icon
        local editing = warp.currently_editing[player.name]
        local last_edit_name = warp.last_edit_name
        local last_edit_time = warp.last_edit_time
        local position = warp.position

        -- if it is not already present then add it now
        local warp_area = element[warp_id]
        local icon_area = element['icon-'..warp_id]
        if not warp_area then
            -- area to store the warp icon
            icon_area =
            element.add{
                name='icon-'..warp_id,
                type='flow',
                caption=warp_id
            }
            Gui.set_padding(icon_area)

            -- area which stores the warp and buttons
            warp_area =
            element.add{
                name=warp_id,
                type='flow',
            }
            Gui.set_padding(warp_area)

            -- if the player can edit then it adds the edit and delete button
            local flow = Gui.create_alignment(element,'edit-'..warp_id)
            local sub_flow = flow.add{type='flow',name=warp_id}

            edit_warp(sub_flow)
            discard_warp(sub_flow)

        end

        local edit_area = element['edit-'..warp_id][warp_id]
        local players = warp.currently_editing and table_keys(warp.currently_editing) or {}
        local allowed = player_allowed_edit(player,warp)

        edit_area.visible = allowed

        if #players > 0 then
            edit_area[edit_warp.name].tooltip = {'warp-list.edit-tooltip',table.concat(players,', ')}
        else
            edit_area[edit_warp.name].tooltip = {'warp-list.edit-tooltip-none'}
        end

        -- draws/updates the warp area
        local label_element = warp_area.warp or warp_area[zoom_to_map_name] or nil
        local element_type = label_element and label_element.type or nil
        if not editing and element_type == 'label' then
            -- update the label already present
            label_element.caption = warp_name
            label_element.tooltip = {'warp-list.last-edit',last_edit_name,format_time(last_edit_time)}
            icon_area[goto_warp.name].sprite = 'item/'..warp_icon

        elseif not editing then
            -- create the label, view mode
            if edit_area then
                edit_area[edit_warp.name].enabled = true
            end

            -- redraws the icon for the warp
            icon_area.clear()

            local btn = goto_warp(icon_area)
            btn.sprite = 'item/'..warp_icon
            btn.tooltip = {'warp-list.goto-tooltip',position.x,position.y}

            local timer = warp_timer:get_store(player.name)
            local enabled = not timer and Store.get(player_in_range_store,player)
            or Roles.player_allowed(player,config.bypass_warp_limits_permission)
            if not enabled then
                btn.enabled = false
                btn.tooltip = {'warp-list.goto-disabled'}
            end

            -- redraws the label for the warp name
            warp_area.clear()

            local label =
            warp_area.add{
                name=zoom_to_map_name,
                type='label',
                caption=warp_name,
                tooltip={'warp-list.last-edit',last_edit_name,format_time(last_edit_time)}
            }
            label.style.single_line = false
            label.style.maximal_width = 150

        elseif editing and element_type ~= 'textfield' then
            -- create the text field, edit mode, update it omitted as value is being edited
            if edit_area then
                edit_area[edit_warp.name].enabled = false
            end

            -- redraws the icon for the warp and allows selection
            icon_area.clear()

            local btn =
            icon_area.add{
                name='icon',
                type='choose-elem-button',
                elem_type='item',
                item=warp_icon,
                tooltip={'warp-list.goto-edit'},
            }
            btn.style.height = 32
            btn.style.width = 32

            -- redraws the label for the warp name and allows editing
            warp_area.clear()

            local entry =
            warp_area.add{
                name='warp',
                type='textfield',
                text=warp_name
            }
            entry.style.maximal_width = 150
            entry.style.height = 20

            cancel_edit(warp_area)
            confirm_edit(warp_area)

        end

    end

end

--[[ generates the main gui structure
    element
    > container
    >> header
    >>> right aligned add_new_warp
    >> scroll
    >>> table
    >> warp_timer
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
    container.style.vertically_stretchable = false

    -- main header for the gui
    local header_area = Gui.create_header(
        container,
        {'warp-list.main-caption'},
        {'warp-list.sub-tooltip',config.recharge_time,config.activation_range},
        true
    )

    --- Right aligned button to toggle the section
    if player_allowed_edit(player) then
        add_new_warp(header_area)
    end

    -- table that stores all the data
    local flow_table = Gui.create_scroll_table(container,3,258)
    flow_table.style.top_cell_padding = 3
    flow_table.style.bottom_cell_padding = 3

    warp_timer(container)

    return flow_table
end

--- Registers the warp list
-- @element warp_list
local warp_list =
Gui.new_left_frame('gui/warp-list')
:set_sprites('item/'..config.default_icon)
:set_tooltip{'warp-list.main-tooltip',config.activation_range}
:set_direction('vertical')
:on_creation(function(player,element)
    local data_table = generate_container(player,element)
    local warp_ids = Warps.get_force_warp_ids(player.force.name)

    for _,warp_id in ipairs(warp_ids) do
        generate_warp(player,data_table,warp_id)
    end
end)
:on_update(function(player,element)
    local data_table = element.container.scroll.table
    local warp_ids = Warps.get_force_warp_ids(player.force.name)

    data_table.clear()
    for _,warp_id in ipairs(warp_ids) do
        generate_warp(player,data_table,warp_id)
    end
end)
:on_player_toggle(function(player,element,visible)
    keep_gui_open[player.name] = visible
end)

--- When the name of a warp is updated this is triggered
Warps.on_update(warp_list 'update_all')

--- When the player leaves or enters range of a warp this is triggered
Store.register(player_in_range_store,function(value,player_name)
    local player = game.players[player_name]
    local force = player.force
    local frame = warp_list:get_frame(player_name)
    local table_area = frame.container.scroll.table
    local timer = warp_timer:get_store(player_name)
    local state = not timer and value

    if not keep_gui_open[player.name] then
        Gui.toggle_left_frame(warp_list.name,player,value)
    end

    if Roles.player_allowed(player,config.bypass_warp_limits_permission) then
        return
    end

    local warp_ids = Warps.get_force_warp_ids(force.name)
    for _,warp_id in pairs(warp_ids) do
        local element = table_area['icon-'..warp_id][goto_warp.name]
        if element and element.valid then
            element.enabled = state
            if state then
                local position = Warps.get_details(warp_id).position
                element.tooltip = {'warp-list.goto-tooltip',position.x,position.y}
            else
                element.tooltip = {'warp-list.goto-disabled'}
            end
        end
    end
end)

--- Handles updating the timer and checking distance from a warp
local r2 = config.activation_range^2
local rs2 = config.spawn_activation_range^2
Event.on_nth_tick(math.floor(60/config.update_smoothing),function()
    local categories = Store.get(warp_timer.store) or {}
    for category,_ in pairs(categories) do
        warp_timer:increment(1,category)
    end

    local force_warps = {}
    local warps = {}
    for _,player in pairs(game.connected_players) do
        local was_in_range = Store.get(player_in_range_store,player)

        -- Get the ids of all the warps on the players force
        local force_name = player.force
        local warp_ids = force_warps[force_name]
        if not warp_ids then
            warp_ids = Warps.get_force_warp_ids(force_name)
            force_warps[force_name] = warp_ids
        end

        -- Check if the force has any warps
        if #warp_ids > 0 then
            local surface = player.surface
            local pos = player.position
            local px,py = pos.x,pos.y

            -- Loop over each warp
            for _,warp_id in pairs(warp_ids) do
                -- Check if warp id is chached
                local warp = warps[warp_id]
                if not warp then
                    warp = Warps.get(warp_id)
                    warps[warp_id] = warp
                end

                -- Check if the player is within range
                local warp_pos = warp.position
                if warp.surface == surface then
                    local dx, dy = px-warp_pos.x, py-warp_pos.y
                    if (dx*dx)+(dy*dy) < rs2 or (dx*dx)+(dy*dy) < r2 then
                        -- Set in range to true if the player was preiovusly out of range
                        if not was_in_range then
                            Store.set(player_in_range_store,player,true)
                        end
                        break
                    end
                end
            end

            -- Set in range to false if the player was preiovusly in range
            if was_in_range then
                Store.set(player_in_range_store,player,false)
            end

        end

    end

end)

--- When a player is created it will set them being in range to false to stop warping on join
Event.add(defines.events.on_player_created,function(event)
    local player = Game.get_player_by_index(event.player_index)

    -- Check if a player is allowed unlimited warps
    local allowed = config.bypass_warp_limits_permission and Roles.player_allowed(player,config.bypass_warp_limits_permission) or false
    Store.set(player_in_range_store,player,allowed)
    if allowed then
        warp_timer:set_store(player.name,1)
    end

    -- If the force has no spawn then make a spawn warp
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

return warp_list