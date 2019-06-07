local Gui = require 'expcore.gui'
local Store = require 'expcore.store'
local Global = require 'utils.global'
local Event = require 'utils.event'
local Game = require 'utils.game'
local Roles = require 'expcore.roles'
local Token = require 'utils.token'
local Colors = require 'resources.color_presets'
local config = require 'config.warps'
local format_time,table_keys,table_values,table_keysort = ext_require('expcore.common','format_time','table_keys','table_values','table_keysort')

local warp_list
local goto_warp = Gui.uid_name()
local warp_name_store = 'gui.left.warps.names'
local warp_icon_store = 'gui.left.warps.tags'
local warp_allowed_store = 'gui.left.warps.allowed'

local warp_details = {}
local force_warps = {}
Global.register({
    warp_details=warp_details,
    force_warps=force_warps
},function(tbl)
    force_warps = tbl.force_warps
    warp_details = tbl.warp_details
end)

local function player_allowed_edit(player,warp_id)
    if warp_id then
        local details = warp_details[warp_id]
        if not details.editing then
            return false
        end
        if config.user_can_edit_own_tasks and details.last_edit_player == player.name then
            return true
        end
    else
        if config.any_user_can_add_new_task then
            return true
        end
    end

    if config.only_admins_can_edit and not player.admin then
        return false
    end

    if config.edit_warps_role_permision and not Roles.player_allowed(player,config.edit_warps_role_permision) then
        return false
    end

    return true
end

local function make_warp_tag(warp_id)
    local warp = warp_details[warp_id]
    if not warp then return end

    local icon = Store.get(warp_icon_store,warp_id)
    local name = Store.get(warp_name_store,warp_id)

    if warp.tag and warp.tag.valid then
        warp.tag.text = 'Warp: '..name
        warp.tag.icon = {type='item',name=icon}
        return
    end

    local force = game.forces[warp.force]
    local surface = warp.surface
    local position = warp.position

    local tag = force.add_chart_tag(surface,{
        position={position.x+0.5,position.y+0.5},
        text='Warp: '..name,
        icon={type='item',name=icon}
    })

    warp.tag = tag
end

local function make_warp_area(warp_id)
    local warp = warp_details[warp_id]
    if not warp then return end

    local position = warp.position
    local posx = position.x
    local posy = position.y
    local surface = warp.surface
    local radius = config.warp_radius
    local radius2 = radius^2

    local old_tile = surface.get_tile(position).name
    warp.old_tile = old_tile

    local base_tile = config.base_tile
    local base_tiles = {}
    local tiles = {}
    -- this makes a base plate to make the warp point
    for x = -radius, radius do
        local x2 = x^2
        for y = -radius, radius do
            local y2 = y^2
            if x2+y2 < radius2 then
                table.insert(base_tiles,{name=base_tile,position={x+posx,y+posy}})
            end
        end
    end
    surface.set_tiles(base_tiles)

    -- this adds the pattern and entities
    for _,pos in pairs(config.tiles) do
        table.insert(tiles,{name=base_tile,position={pos[1]+posx,pos[2]+posy}})
    end
    surface.set_tiles(tiles)

    for _,entity in pairs(config.entities) do
        entity = surface.create_entity{
            name=entity[1],
            position={entity[2]+posx,entity[3]+posy},
            force='neutral'
        }
        entity.destructible = false
        entity.health = 0
        entity.minable = false
        entity.rotatable = false
    end
end

local function clear_warp_area(warp_id)
    local warp = warp_details[warp_id]
    if not warp then return end

    local position = warp.position
    local surface = warp.surface
    local radius = config.warp_radius
    local radius2 = radius^2

    local tiles = {}
    -- clears the area where the warp was
    for x = -radius, radius do
        local x2 = x^2
        for y = -radius, radius do
            local y2 = y^2
            if x2+y2 < radius2 then
                table.insert(tiles,{name=warp.old_tile,position={x+position.x,y+position.y}})
            end
        end
    end
    surface.set_tiles(tiles)

    local entities = surface.find_entities_filtered{
        force='neutral',
        area={
            {position.x-radius,position.y-radius},
            {position.x+radius,position.y+radius}
        }
    }
    for _,entity in pairs(entities) do if entity.name ~= 'player' then entity.destroy() end end

    if warp.tag and warp.tag.valid then warp.tag.destroy() end
end

local function add_spawn(player)
    local warp_id = tostring(Token.uid())
    local force = player.force
    local force_name = force.name
    local surface = player.surface
    local spawn = force.get_spawn_position(surface)

    if not force_warps[force_name] then
        force_warps[force_name] = {}
    end
    table.insert(force_warps[force_name],warp_id)

    warp_details[warp_id] = {
        warp_id = warp_id,
        force = force.name,
        position = {
            x=math.floor(spawn.x),
            y=math.floor(spawn.y)
        },
        surface = surface,
        last_edit_player='System',
        last_edit_time=game.tick,
        editing=false
    }

    Store.set(warp_name_store,warp_id,'Spawn')
    Store.set(warp_icon_store,warp_id,config.default_icon)
end

local function add_warp(player)
    local warp_id = tostring(Token.uid())
    local force_name = player.force.name

    if not force_warps[force_name] then
        add_spawn(player)
    end
    table.insert(force_warps[force_name],warp_id)

    local position = player.position

    warp_details[warp_id] = {
        warp_id = warp_id,
        force = force_name,
        position = {
            x=math.floor(position.x),
            y=math.floor(position.y)
        },
        surface = player.surface,
        last_edit_player=player.name,
        last_edit_time=game.tick,
        editing={[player.name]=true}
    }

    Store.set(warp_name_store,warp_id,'New warp')
    Store.set(warp_icon_store,warp_id,config.default_icon)

    make_warp_area(warp_id)
end

local function remove_warp(warp_id)
    local force_name = warp_details[warp_id].force
    local key = table.index_of(force_warps[force_name],warp_id)
    force_warps[force_name][key] = nil
    Store.clear(warp_name_store,warp_id)
    Store.clear(warp_icon_store,warp_id)
    warp_details[warp_id] = nil
end

local warp_timer =
Gui.new_progressbar()
:set_tooltip{'warp-list.timer-tooltip',config.time_limit}
:set_default_maximum(config.time_limit*config.time_smothing)
:add_store(Gui.player_store)
:set_style(nil,function(style)
    style.horizontally_stretchable = true
    style.color = Colors.light_blue
end)
:on_store_complete(function(player_name,reset)
    Store.set(warp_allowed_store,player_name,true)
end)

Gui.on_click(goto_warp,function(event)
    local player = event.player
    local warp_id = event.element.parent.caption
    local warp = warp_details[warp_id]
    local surface = warp.surface
    local position = warp.position
    local goto_position = surface.find_non_colliding_position('character',position,32,1)
    if player.driving then player.driving = false end
    player.teleport(goto_position,surface)
    if config.no_warp_limit_permision and not Roles.player_allowed(player,config.no_warp_limit_permision) then
        warp_timer:set_store(player.name,0)
        Store.set(warp_allowed_store,player.name,false)
    end
end)

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
    local posx = position.x
    local posy = position.y
    local dist2 = config.minimum_distance^2

    local warps = Store.get_children(warp_name_store)
    for _,warp_id in pairs(warps) do
        local warp = warp_details[warp_id]
        local pos = warp.position
        if (posx-pos.x)^2+(posy-pos.y)^2 < dist2 then
            local warp_name = Store.get(warp_name_store,warp_id)
            player.print{'warp-list.too-close',warp_name}
            return
        end
    end

    add_warp(player)
end)

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
    local warp = warp_details[warp_id]
    warp.editing[player.name] = nil
    warp.last_edit_player = player.name
    warp.last_edit_time = game.tick
    Store.set(warp_name_store,warp_id,warp_name)
    Store.set(warp_icon_store,warp_id,warp_icon)
end)

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
    local details = warp_details[warp_id]
    details.editing[player.name] = nil
    generate_warp(player,element.parent.parent,warp_id)
end)

local discord_warp =
Gui.new_button()
:set_sprites('utility/trash')
:set_tooltip{'warp-list.discord-tooltip'}
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.height = 20
    style.width = 20
end)
:on_click(function(player,element)
    local warp_id = element.parent.name
    remove_warp(warp_id)
end)

--- Opens edit mode for the task
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
    local details = warp_details[warp_id]
    details.editing[player.name] = true
    generate_warp(player,element.parent.parent.parent,warp_id)
end)

--[[ Generates each task, handles both view and edit mode
    element
    > count-"task_id"
    >> label
    > "task_id"
    >> task
    >> cancel_edit (edit mode)
    >> confirm_edit (edit mode)
    > edit-"task_id"
    >> edit_warp
    >> discord_warp
]]
function generate_warp(player,element,warp_id)
    local warp_name = Store.get(warp_name_store,warp_id)
    local warp_icon = Store.get(warp_icon_store,warp_id) or config.default_icon
    local warp = warp_details[warp_id]

    local editing = warp.editing and warp.editing[player.name]
    local last_edit_player = warp.last_edit_player
    local last_edit_time = warp.last_edit_time
    local warps = force_warps[player.force.name]
    local position = warp.position

    if not warp_name then
        -- task is nil so remove it from the list
        element.parent.no_warps.visible = #warps == 0
        Gui.destory_if_valid(element['icon-'..warp_id])
        Gui.destory_if_valid(element['edit-'..warp_id])
        Gui.destory_if_valid(element[warp_id])

    else
        element.parent.no_warps.visible = false
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

            -- area which stores the task and buttons
            warp_area =
            element.add{
                name=warp_id,
                type='flow',
            }
            Gui.set_padding(warp_area)

            -- if the player can edit then it adds the edit and delete button
            local flow = Gui.create_right_align(element,'edit-'..warp_id)
            local sub_flow = flow.add{type='flow',name=warp_id}

            edit_warp(sub_flow)
            discord_warp(sub_flow)

        end

        local edit_area = element['edit-'..warp_id][warp_id]
        local players = warp.editing and table_keys(warp.editing) or {}
        local allowed = player_allowed_edit(player,warp_id)

        edit_area.visible = allowed

        if #players > 0 then
            edit_area[edit_warp.name].tooltip = {'task-list.edit-tooltip',table.concat(players,', ')}
        else
            edit_area[edit_warp.name].tooltip = {'task-list.edit-tooltip-none'}
        end

        -- draws/updates the warp area
        local element_type = warp_area.warp and warp_area.warp.type or nil
        if not editing and element_type == 'label' then
            -- update the label already present
            warp_area.warp.caption = warp_name
            warp_area.warp.tooltip = {'warp-list.last-edit',last_edit_player,format_time(last_edit_time)}
            icon_area[goto_warp].sprite = 'item/'..warp_icon

        elseif not editing then
            -- create the label, view mode
            if edit_area then
                edit_area[edit_warp.name].enabled = true
            end

            warp_area.clear()

            local label =
            warp_area.add{
                name='warp',
                type='label',
                caption=warp_name,
                tooltip={'warp-list.last-edit',last_edit_player,format_time(last_edit_time)}
            }
            label.style.single_line = false
            label.style.maximal_width = 150

            icon_area.clear()

            local btn =
            icon_area.add{
                name=goto_warp,
                type='sprite-button',
                sprite='item/'..warp_icon,
                style='quick_bar_slot_button',
                tooltip={'warp-list.cords',position.x,position.y},
            }
            btn.style.height = 32
            btn.style.width = 32

            local timer = warp_timer:get_store(player_name)
            local enabled = not timer and Store.get(warp_allowed_store,player.name)
            btn.enabled = enabled
            if not enabled then
                btn.tooltip = {'warp-list.goto-disabled'}
            end

        elseif editing and element_type ~= 'textfield' then
            -- create the text field, edit mode, update it omited as value is being edited
            if edit_area then
                edit_area[edit_warp.name].enabled = false
            end

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

            icon_area.clear()

            local btn =
            icon_area.add{
                name='icon',
                type='choose-elem-button',
                elem_type='item',
                item=warp_icon,
                tooltip={'warp-list.cords',position.x,position.y},
            }
            btn.style.height = 32
            btn.style.width = 32

        end

    end

end

--[[ generates the main gui structure
    element
    > container
    >> header
    >>> right aligned add_new_task
    >> scroll
    >>> no_tasks
    >>> table
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
    local header =
    container.add{
        name='header',
        type='frame',
        style='subheader_frame'
    }
    Gui.set_padding(header,2,2,4,4)
    header.style.horizontally_stretchable = true
    header.style.use_header_filler = false

    --- Caption for the header bar
    header.add{
        type='label',
        style='heading_1_label',
        caption={'warp-list.main-caption'},
        tooltip={'warp-list.sub-tooltip',config.time_limit,config.warp_radius}
    }

    --- Right aligned button to toggle the section
    if player_allowed_edit(player) then
        local right_align = Gui.create_right_align(header)
        add_new_warp(right_align)
    end

    -- main flow for the data
    local flow =
    container.add{
        name='scroll',
        type='scroll-pane',
        direction='vertical',
        horizontal_scroll_policy='never',
        vertical_scroll_policy='auto-and-reserve-space'
    }
    Gui.set_padding(flow,1,1,2,2)
    flow.style.horizontally_stretchable = true
    flow.style.maximal_height = 258

    -- message to say that you have no tasks
    local non_made =
    flow.add{
        name='no_warps',
        type='label',
        caption={'warp-list.no-warps'}
    }
    non_made.style.width = 200
    non_made.style.single_line = false

    -- table that stores all the data
    local flow_table =
    flow.add{
        name='table',
        type='table',
        column_count=3
    }
    Gui.set_padding(flow_table)
    flow_table.style.horizontally_stretchable = true
    flow_table.style.top_cell_padding = 3
    flow_table.style.bottom_cell_padding = 3

    warp_timer(container)

    return flow_table
end

--- Registers the warp list
warp_list =
Gui.new_left_frame('gui/warp-list')
:set_sprites('item/'..config.default_icon)
:set_tooltip{'warp-list.main-tooltip',config.warp_radius}
:set_direction('vertical')
:on_draw(function(player,element)
    local data_table = generate_container(player,element)
    local force_name = player.force.name

    local warps = force_warps[force_name] or {}
    for _,warp_id in pairs(warps) do
        generate_warp(player,data_table,warp_id)
    end
end)
:on_update(function(player,element)
    local data_table = element.container.scroll.table
    local force_name = player.force.name

    data_table.clear()

    local warps = force_warps[force_name] or {}
    for _,warp_id in pairs(warps) do
        generate_warp(player,data_table,warp_id)
    end
end)

Store.register(warp_name_store,function(value,warp_id)
    local warp = warp_details[warp_id]
    local force = game.forces[warp.force]

    local names = {}
    local spawn_id
    for _,_warp_id in pairs(force_warps[force.name]) do
        local name = Store.get(warp_name_store,_warp_id)
        if not warp_details[_warp_id].editing then
            spawn_id = _warp_id
        else
            names[name.._warp_id] = _warp_id
        end
    end

    force_warps[force.name] = table_values(table_keysort(names))
    table.insert(force_warps[force.name],1,spawn_id)

    for _,player in pairs(force.players) do
        warp_list:update(player)
    end
end)

Store.register(warp_icon_store,function(value,warp_id)
    local warp = warp_details[warp_id]
    local force = game.forces[warp.force]

    for _,player in pairs(force.players) do
        local frame = warp_list:get_frame(player)
        local element = frame.container.scroll.table
        generate_warp(player,element,warp_id)
    end

    if value then
        make_warp_tag(warp_id)
    else
        clear_warp_area(warp_id)
    end
end)

Store.register(warp_allowed_store,function(value,player_name)
    local player = game.players[player_name]
    local force = player.force
    local frame = warp_list:get_frame(player_name)
    local table_area = frame.container.scroll.table
    local timer = warp_timer:get_store(player_name)
    local state = not timer and value

    if force_warps[force.name] then
        for _,warp_id in pairs(force_warps[force.name]) do
            local element = table_area['icon-'..warp_id][goto_warp]
            if element and element.valid then
                element.enabled = state
                if state then
                    local position = warp_details[warp_id].position
                    element.tooltip = {'warp-list.cords',position.x,position.y}
                else
                    element.tooltip = {'warp-list.goto-disabled'}
                end
            end
        end
    end
end)

local r2 = config.warp_radius^2
local rs2 = (config.warp_radius*config.spawn_radius_scale)^2
Event.on_nth_tick(60/config.time_smothing,function()
    local categories = Store.get_children(warp_timer.store)
    for _,category in pairs(categories) do
        warp_timer:increment(1,category)
    end

    for _,player in pairs(game.connected_players) do
        local timer = warp_timer:get_store(player.name)
        local role = config.no_warp_limit_permision and Roles.player_allowed(player,config.no_warp_limit_permision)
        if not timer and not role then
            local force = player.force
            local warps = force_warps[force.name]
            if warps then
                local surface = player.surface.index
                local pos = player.position
                local px,py = pos.x,pos.y

                for _,warp_id in pairs(warps) do
                    local warp = warp_details[warp_id]
                    local wpos = warp.position
                    if warp.surface.index == surface then
                        local dx,dy = px-wpos.x,py-wpos.y
                        if not warp.editing and (dx*dx)+(dy*dy) < rs2 or (dx*dx)+(dy*dy) < r2 then
                            Store.set(warp_allowed_store,player.name,true)
                            return
                        end
                    end
                end

                Store.set(warp_allowed_store,player.name,false)
            end
        end
    end

end)

Event.add(defines.events.on_player_created,function(event)
    local player = Game.get_player_by_index(event.player_index)
    local force_name = player.force.name

    local allowed = config.no_warp_limit_permision and Roles.player_allowed(player,config.no_warp_limit_permision) or false
    Store.set(warp_allowed_store,player.name,allowed)

    if not force_warps[force_name] then
        add_spawn(player)
    end
end)

return warp_list