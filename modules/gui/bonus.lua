--[[-- Gui Module - Bonus
    @gui Bonus
    @alias bonus_container
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.bonus' --- @dep config.bonus
local format_number = require('util').format_number --- @dep util
local bonus_container

local function bonus_gui_pts_needed(player)
    local frame = Gui.get_left_element(player, bonus_container)
    local disp = frame.container['bonus_st_2'].disp.table
    local total = 0

    total = total + (disp['bonus_display_cmms_slider'].slider_value / config.player_bonus['character_mining_speed_modifier'].cost_scale * config.player_bonus['character_mining_speed_modifier'].cost)
    total = total + (disp['bonus_display_crs_slider'].slider_value / config.player_bonus['character_running_speed_modifier'].cost_scale * config.player_bonus['character_running_speed_modifier'].cost)
    total = total + (disp['bonus_display_ccs_slider'].slider_value / config.player_bonus['character_crafting_speed_modifier'].cost_scale * config.player_bonus['character_crafting_speed_modifier'].cost)
    total = total + (disp['bonus_display_cisb_slider'].slider_value / config.player_bonus['character_inventory_slots_bonus'].cost_scale * config.player_bonus['character_inventory_slots_bonus'].cost)
    total = total + (disp['bonus_display_chb_slider'].slider_value / config.player_bonus['character_health_bonus'].cost_scale * config.player_bonus['character_health_bonus'].cost)
    total = total + (disp['bonus_display_crdb_slider'].slider_value / config.player_bonus['character_reach_distance_bonus'].cost_scale * config.player_bonus['character_reach_distance_bonus'].cost)

    return total
end

local function apply_bonus(player)
    if not Roles.player_allowed(player, 'gui/bonus') then
        player['character_mining_speed_modifier'] = 0
        player['character_running_speed_modifier'] = 0
        player['character_crafting_speed_modifier'] = 0
        player['character_inventory_slots_bonus'] = 0
        player['character_health_bonus'] = 0
        player['character_reach_distance_bonus'] = 0
        player['character_resource_reach_distance_bonus'] = 0
        player['character_build_distance_bonus'] = 0

        return
    end

    if not player.character then
        return
    end

    local frame = Gui.get_left_element(player, bonus_container)
    local disp = frame.container['bonus_st_2'].disp.table

    player['character_mining_speed_modifier'] = disp['bonus_display_cmms_slider'].slider_value
    player['character_running_speed_modifier'] = disp['bonus_display_crs_slider'].slider_value
    player['character_crafting_speed_modifier'] = disp['bonus_display_ccs_slider'].slider_value
    player['character_inventory_slots_bonus'] = disp['bonus_display_cisb_slider'].slider_value
    player['character_health_bonus'] = disp['bonus_display_chb_slider'].slider_value
    player['character_reach_distance_bonus'] = disp['bonus_display_crdb_slider'].slider_value
    player['character_resource_reach_distance_bonus'] = disp['bonus_display_crdb_slider'].slider_value
    player['character_build_distance_bonus'] = disp['bonus_display_crdb_slider'].slider_value
end

--- Control label for the bonus points available
-- @element bonus_gui_control_pts_a
local bonus_gui_control_pts_a =
Gui.element{
    type = 'label',
    name = 'bonus_control_pts_a',
    caption = {'bonus.control-pts-a'},
    style = 'heading_1_label'
}:style{
    width = config.gui_display_width['half']
}

local bonus_gui_control_pts_a_count =
Gui.element{
    type = 'label',
    name = 'bonus_control_pts_a_count',
    caption = config.pts.base,
    style = 'heading_1_label'
}:style{
    width = config.gui_display_width['half']
}

--- Control label for the bonus points needed
-- @element bonus_gui_control_pts_n
local bonus_gui_control_pts_n =
Gui.element{
    type = 'label',
    name = 'bonus_control_pts_n',
    caption = {'bonus.control-pts-n'},
    style = 'heading_1_label'
}:style{
    width = config.gui_display_width['half']
}

local bonus_gui_control_pts_n_count =
Gui.element{
    type = 'label',
    name = 'bonus_control_pts_n_count',
    caption = '0',
    style = 'heading_1_label'
}:style{
    width =config.gui_display_width['half']
}

--- Control label for the bonus points remaining
-- @element bonus_gui_control_pts_r
local bonus_gui_control_pts_r =
Gui.element{
    type = 'label',
    name = 'bonus_control_pts_r',
    caption = {'bonus.control-pts-r'},
    style = 'heading_1_label'
}:style{
    width = config.gui_display_width['half']
}

local bonus_gui_control_pts_r_count =
Gui.element{
    type = 'label',
    name = 'bonus_control_pts_r_count',
    caption = '0',
    style = 'heading_1_label'
}:style{
    width = config.gui_display_width['half']
}

--- A button used for pts calculations
-- @element bonus_gui_control_refresh
local bonus_gui_control_reset =
Gui.element{
    type = 'button',
    name = Gui.unique_static_name,
    caption = {'bonus.control-reset'}
}:style{
    width = config.gui_display_width['half']
}:on_click(function(player, element, _)
    local frame = Gui.get_left_element(player, bonus_container)
    local disp = frame.container['bonus_st_2'].disp.table

    disp['bonus_display_cmms_slider'].slider_value = config.player_bonus['character_mining_speed_modifier'].value
    disp['bonus_display_crs_slider'].slider_value = config.player_bonus['character_running_speed_modifier'].value
    disp['bonus_display_ccs_slider'].slider_value = config.player_bonus['character_crafting_speed_modifier'].value
    disp['bonus_display_cisb_slider'].slider_value = config.player_bonus['character_inventory_slots_bonus'].value
    disp['bonus_display_chb_slider'].slider_value = config.player_bonus['character_health_bonus'].value
    disp['bonus_display_crdb_slider'].slider_value = config.player_bonus['character_reach_distance_bonus'].value

    disp['bonus_display_cmms_count'].slider_value = config.player_bonus['character_mining_speed_modifier'].value
    disp['bonus_display_crs_count'].slider_value = config.player_bonus['character_running_speed_modifier'].value
    disp['bonus_display_ccs_count'].slider_value = config.player_bonus['character_crafting_speed_modifier'].value
    disp['bonus_display_cisb_count'].slider_value = config.player_bonus['character_inventory_slots_bonus'].value
    disp['bonus_display_chb_count'].slider_value = config.player_bonus['character_health_bonus'].value
    disp['bonus_display_crdb_count'].slider_value = config.player_bonus['character_reach_distance_bonus'].value

    local r = bonus_gui_pts_needed(player)
    element.parent[bonus_gui_control_pts_n_count.name].caption = r
    element.parent[bonus_gui_control_pts_r_count.name].caption = tonumber(element.parent[bonus_gui_control_pts_a_count.name].caption) - r
end)

--- A button used for pts apply
-- @element bonus_gui_control_apply
local bonus_gui_control_apply =
Gui.element{
    type = 'button',
    name = Gui.unique_static_name,
    caption = {'bonus.control-apply'}
}:style{
    width = config.gui_display_width['half']
}:on_click(function(player, element, _)
    local n = bonus_gui_pts_needed(player)
    element.parent[bonus_gui_control_pts_n_count.name].caption = n
    local r = tonumber(element.parent[bonus_gui_control_pts_a_count.name].caption) - n
    element.parent[bonus_gui_control_pts_r_count.name].caption = r

    if r >= 0 then
        apply_bonus(player)
    end
end)

--- A vertical flow containing all the bonus control
-- @element bonus_control_set
local bonus_control_set =
Gui.element(function(_, parent, name)
    local bonus_set = parent.add{type='flow', direction='vertical', name=name}
    local disp = Gui.scroll_table(bonus_set, 360, 2, 'disp')

    bonus_gui_control_pts_a(disp)
    bonus_gui_control_pts_a_count(disp)

    bonus_gui_control_pts_n(disp)
    bonus_gui_control_pts_n_count(disp)

    bonus_gui_control_pts_r(disp)
    bonus_gui_control_pts_r_count(disp)

    bonus_gui_control_reset(disp)
    bonus_gui_control_apply(disp)

    return bonus_set
end)

--- Display group
-- @element bonus_gui_slider
local bonus_gui_slider =
Gui.element(function(_definition, parent, name, caption, tooltip, bonus)
    local label = parent.add{
        type = 'label',
        caption = caption,
        tooltip = tooltip,
        style = 'heading_1_label'
    }
    label.style.width = config.gui_display_width['label']

    local value = bonus.value

    if bonus.is_percentage then
        value = format_number(value * 100) .. ' %'

    else
        value = format_number(value)
    end

    local slider = parent.add{
        type = 'slider',
        name = name .. '_slider',
        value = bonus.value,
        maximum_value = bonus.max,
        value_step = bonus.scale,
        discrete_values = true,
        style = 'notched_slider',
        tags = {
            counter = name .. '_count',
            is_percentage = bonus.is_percentage
        }
    }
    slider.style.width = config.gui_display_width['slider']
    slider.style.horizontally_stretchable = true

    local count = parent.add{
        type = 'label',
        name = name .. '_count',
        caption = value,
        style = 'heading_1_label',
    }
    count.style.width = config.gui_display_width['count']

    return slider
end)
:on_value_changed(function(player, element, _event)
    if element.tags.is_percentage then
        element.parent[element.tags.counter].caption = format_number(element.slider_value * 100) .. ' %'

    else
        element.parent[element.tags.counter].caption = element.slider_value
    end

    local r = bonus_gui_pts_needed(player)
    local frame = Gui.get_left_element(player, bonus_container)
    local disp = frame.container['bonus_st_1'].disp.table
    disp[bonus_gui_control_pts_n_count.name].caption = r
    disp[bonus_gui_control_pts_r_count.name].caption = tonumber(disp[bonus_gui_control_pts_a_count.name].caption) - r
end)

--- A vertical flow containing all the bonus data
-- @element bonus_data_set
local bonus_data_set =
Gui.element(function(_, parent, name)
    local bonus_set = parent.add{type='flow', direction='vertical', name=name}
    local disp = Gui.scroll_table(bonus_set, 360, 3, 'disp')

    bonus_gui_slider(disp, 'bonus_display_cmms', {'bonus.display-cmms'}, {'bonus.display-cmms-tooltip'}, config.player_bonus['character_mining_speed_modifier'])
    bonus_gui_slider(disp, 'bonus_display_crs', {'bonus.display-crs'}, {'bonus.display-crs-tooltip'}, config.player_bonus['character_running_speed_modifier'])
    bonus_gui_slider(disp, 'bonus_display_ccs', {'bonus.display-ccs'}, {'bonus.display-ccs-tooltip'}, config.player_bonus['character_crafting_speed_modifier'])
    bonus_gui_slider(disp, 'bonus_display_cisb', {'bonus.display-cisb'}, {'bonus.display-cisb-tooltip'}, config.player_bonus['character_inventory_slots_bonus'])
    bonus_gui_slider(disp, 'bonus_display_chb', {'bonus.display-chb'}, {'bonus.display-chb-tooltip'}, config.player_bonus['character_health_bonus'])
    bonus_gui_slider(disp, 'bonus_display_crdb', {'bonus.display-crdb'}, {'bonus.display-crdb-tooltip'}, config.player_bonus['character_reach_distance_bonus'])

    return bonus_set
end)

--- The main container for the bonus gui
-- @element bonus_container
bonus_container =
Gui.element(function(definition, parent)
    local player = Gui.get_player_from_element(parent)
    local container = Gui.container(parent, definition.name, 320)

    bonus_control_set(container, 'bonus_st_1')
    bonus_data_set(container, 'bonus_st_2')

    local frame = Gui.get_left_element(player, bonus_container)
    local disp = frame.container['bonus_st_1'].disp.table
    local n = bonus_gui_pts_needed(player)
    disp[bonus_gui_control_pts_n_count.name].caption = n
    local r = tonumber(disp[bonus_gui_control_pts_a_count.name].caption) - n
    disp[bonus_gui_control_pts_r_count.name].caption = r

    apply_bonus(player)
    return container.parent
end)
:static_name(Gui.unique_static_name)
:add_to_left_flow()

--- Button on the top flow used to toggle the task list container
-- @element toggle_left_element
Gui.left_toolbar_button('item/exoskeleton-equipment', {'bonus.main-tooltip'}, bonus_container, function(player)
	return Roles.player_allowed(player, 'gui/bonus')
end)

Event.add(defines.events.on_player_created, function(event)
    if event.player_index ~= 1 then
        return
    end

    for k, v in pairs(config.force_bonus) do
        game.players[event.player_index].force[k] = v.value
    end

    for k, v in pairs(config.surface_bonus) do
        game.players[event.player_index].surface[k] = v.value
    end
end)

Event.add(Roles.events.on_role_assigned, function(event)
    apply_bonus(game.players[event.player_index])
end)

Event.add(Roles.events.on_role_unassigned, function(event)
    apply_bonus(game.players[event.player_index])
end)
