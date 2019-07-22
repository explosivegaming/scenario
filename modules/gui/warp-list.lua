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

local warp_player_in_range_store = 'gui.left.warps.in_range'
local warp_list

local keep_open = {}
Global.register(keep_open,function(tbl)
    keep_open = tbl
end)

--- Returns if a player is allowed to edit the given warp
local function player_allowed_edit(player,warp_id)
    if warp_id then
        local details = Warps.get_details(warp_id)
        local warps = Warps.get_warps(player.force.name)
        if warps.spawn == warp_id then
            return false
        end
        if config.user_can_edit_own_warps and details.last_edit_player == player.name then
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
local zoom_to_map_name = Gui.uid_name()
Gui.on_click(zoom_to_map_name,function(event)
    local warp_id = event.element.parent.name
    local warp = Warps.get_details(warp_id)
    local position = warp.position
    event.player.zoom_to_world(position,1.5)
end)


--- This timer controls when a player is able to warp, eg every 60 seconds
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
    -- this is to force an update of the button
    local in_range = Store.get(warp_player_in_range_store,player_name)
    Store.set(warp_player_in_range_store,player_name,in_range)
end)

--- When the button is clicked it will teleport the player
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

    if config.bypass_warp_limits_permision and not Roles.player_allowed(player,config.bypass_warp_limits_permision) then
        warp_timer:set_store(player.name,0)
        -- this is to force an update of the buttons
        local in_range = Store.get(warp_player_in_range_store,player.name)
        Store.set(warp_player_in_range_store,player.name,in_range)
    end
end)

--- Will add a new warp to the list, checks if the player is too close to an existing one
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
    local position = player.position
    local px = position.x
    local py = position.y
    local dist2 = config.minimum_distance^2

    local warps = Warps.get_all_warps()
    for warp_id,warp in pairs(warps) do
        local pos = warp.position
        if (posx-pos.x)^2+(posy-pos.y)^2 < dist2 then
            local warp_name = Warps.get_warp_name(warp_id)
            player.print{'warp-list.too-close',warp_name}
            return
        end
    end

    Warps.new_warp(player.force.name,player.surface,position,player.name)
end)

--- Confirms the edit to name or icon of the warp
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
local generate_warp
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
    generate_warp(player,element.parent.parent,warp_id)
end)

--- Removes a warp from the list, including the physical area and map tag
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
    generate_warp(player,element.parent.parent.parent,warp_id)
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
function generate_warp(player,element,warp_id)
    local warp_name = Warps.get_warp_name(warp_id)
    local warp_icon = Warps.get_warp_icon(warp_id)
    local warp = Warps.get_details(warp_id)

    local editing = Warps.is_editing(warp_id,player.name)
    local last_edit_player = warp.last_edit_player
    local last_edit_time = warp.last_edit_time
    local position = warp.position

    if not warp_name then
        -- warp is nil so remove it from the list
        Gui.destroy_if_valid(element['icon-'..warp_id])
        Gui.destroy_if_valid(element['edit-'..warp_id])
        Gui.destroy_if_valid(element[warp_id])

    else
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
        local players = warp.editing and table_keys(warp.editing) or {}
        local allowed = player_allowed_edit(player,warp_id)

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
            label_element.tooltip = {'warp-list.last-edit',last_edit_player,format_time(last_edit_time)}
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
            local enabled = not timer and Store.get(warp_player_in_range_store,player.name)
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
                tooltip={'warp-list.last-edit',last_edit_player,format_time(last_edit_time)}
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
warp_list =
Gui.new_left_frame('gui/warp-list')
:set_sprites('item/'..config.default_icon)
:set_tooltip{'warp-list.main-tooltip',config.activation_range}
:set_direction('vertical')
:on_creation(function(player,element)
    local data_table = generate_container(player,element)
    local warps = Warps.get_warps(player.force.name)

    for key,warp_id in pairs(warps) do
        if key ~= 'spawn' then
            generate_warp(player,data_table,warp_id)
        end
    end
end)
:on_update(function(player,element)
    local data_table = element.container.scroll.table
    local warps = Warps.get_warps(player.force.name)

    data_table.clear()
    for key,warp_id in pairs(warps) do
        if key ~= 'spawn' then
            generate_warp(player,data_table,warp_id)
        end
    end
end)
:on_player_toggle(function(player,element,visible)
    keep_open[player.name] = visible
end)

--- When the name of a warp is updated this is triggered
Warps.add_handler(function(force,warp_id)
    for _,player in pairs(force.players) do
        warp_list:update(player)
    end
end)

--- When the player leaves or enters range of a warp this is triggered
Store.register(warp_player_in_range_store,function(value,player_name)
    local player = game.players[player_name]
    local force = player.force
    local frame = warp_list:get_frame(player_name)
    local table_area = frame.container.scroll.table
    local timer = warp_timer:get_store(player_name)
    local state = not timer and value

    if not keep_open[player.name] then
        Gui.toggle_left_frame(warp_list.name,player,value)
    end

    if Roles.player_allowed(player,config.bypass_warp_limits_permission) then
        return
    end

    local warps = Warps.get_warps(force.name)
    for _,warp_id in pairs(warps) do
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
    local categories = Store.get_children(warp_timer.store)
    for _,category in pairs(categories) do
        warp_timer:increment(1,category)
    end

    for _,player in pairs(game.connected_players) do
        local was_in_range = Store.get(warp_player_in_range_store,player.name)
        local force = player.force
        local warps = Warps.get_warps(force.name)

        if #warps > 0 then
            local surface = player.surface.index
            local pos = player.position
            local px,py = pos.x,pos.y
            for _,warp_id in pairs(warps) do
                local warp = Warps.get_details(warp_id)
                local wpos = warp.position
                if warp.surface.index == surface then
                    local dx,dy = px-warp_pos.x,py-warp_pos.y
                    if not warp.editing and (dx*dx)+(dy*dy) < rs2 or (dx*dx)+(dy*dy) < r2 then
                        if not was_in_range then
                            Store.set(warp_player_in_range_store,player.name,true)
                        end
                        return
                    end
                end
            end
            if was_in_range then
                Store.set(warp_player_in_range_store,player.name,false)
            end
        end


    end

end)

--- When a player is created it will set them being in range to false to stop warping on join
Event.add(defines.events.on_player_created,function(event)
    local player = Game.get_player_by_index(event.player_index)

    local allowed = config.bypass_warp_limits_permission and Roles.player_allowed(player,config.bypass_warp_limits_permission) or false
    Store.set(warp_player_in_range_store,player.name,allowed)
    if allowed then
        warp_timer:set_store(player.name,1)
    end

    local force = player.force
    local spawn_position = force.get_spawn_position(player.surface)
    Warps.new_warp(force.name,player.surface,spawn_position,nil,'Spawn',true,true)
end)

local function maintain_tag(event)
    local tag = event.tag
    local force = event.force
    local warps = Warps.get_warps(force.name)
    for _,warp_id in pairs(warps) do
        local warp = Warps.get_warps(force.name)
        if not warp.tag or not warp.tag.valid or warp.tag == tag then
            if event.name == defines.events.on_chart_tag_removed then
                warp.tag = nil
            end
            Warps.make_chart_tag(warp_id)
        end
    end
end

Event.add(defines.events.on_chart_tag_modified,maintain_tag)
Event.add(defines.events.on_chart_tag_removed,maintain_tag)

return warp_list