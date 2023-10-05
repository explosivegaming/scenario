---- module pd
-- @addon pd

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data
require 'modules.data.statistics'
local format_time = _C.format_time --- @dep expcore.common
local format_number = require('util').format_number --- @dep util

local pd_container
local label_width = {
    ['name'] = 135,
    ['count'] = 105,
    ['total'] = 480
}

local pd_data_play_time_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.Playtime'},
    tooltip = {'exp-statistics.Playtime-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_play_time_count =
Gui.element{
    type = 'label',
    caption = '00:00'
}:style{
    width = label_width['count']
}

local pd_data_afk_time_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.AfkTime'},
    tooltip = {'exp-statistics.AfkTime-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_afk_time_count =
Gui.element{
    type = 'label',
    caption = '00:00'
}:style{
    width = label_width['count']
}

local pd_data_maps_played_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.MapsPlayed'},
    tooltip = {'exp-statistics.MapsPlayed-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_maps_played_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_join_count_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.JoinCount'},
    tooltip = {'exp-statistics.JoinCount-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_join_count_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_chat_messages_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.ChatMessages'},
    tooltip = {'exp-statistics.ChatMessages-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_chat_messages_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_commands_used_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.CommandsUsed'},
    tooltip = {'exp-statistics.CommandsUsed-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_commands_used_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_rockets_launched_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.RocketsLaunched'},
    tooltip = {'exp-statistics.RocketsLaunched-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_rockets_launched_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_research_completed_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.ResearchCompleted'},
    tooltip = {'exp-statistics.ResearchCompleted-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_research_completed_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_machines_built_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.MachinesBuilt'},
    tooltip = {'exp-statistics.MachinesBuilt-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_machines_built_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_machines_removed_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.MachinesRemoved'},
    tooltip = {'exp-statistics.MachinesRemoved-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_machines_removed_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_tiles_built_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.TilesBuilt'},
    tooltip = {'exp-statistics.TilesBuilt-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_tiles_built_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_tiles_removed_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.TilesRemoved'},
    tooltip = {'exp-statistics.TilesRemoved-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_tiles_removed_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_trees_destroyed_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.TreesDestroyed'},
    tooltip = {'exp-statistics.TreesDestroyed-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_trees_destroyed_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_ore_mined_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.OreMined'},
    tooltip = {'exp-statistics.OreMined-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_ore_mined_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_items_crafted_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.ItemsCrafted'},
    tooltip = {'exp-statistics.ItemsCrafted-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_items_crafted_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_items_picked_up_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.ItemsPickedUp'},
    tooltip = {'exp-statistics.ItemsPickedUp-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_items_picked_up_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_kills_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.Kills'},
    tooltip = {'exp-statistics.Kills-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_kills_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_deaths_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.Deaths'},
    tooltip = {'exp-statistics.Deaths-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_deaths_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_damage_dealt_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.DamageDealt'},
    tooltip = {'exp-statistics.DamageDealt-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_damage_dealt_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_distance_travelled_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.DistanceTravelled'},
    tooltip = {'exp-statistics.DistanceTravelled-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_distance_travelled_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_capsules_used_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.CapsulesUsed'},
    tooltip = {'exp-statistics.CapsulesUsed-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_capsules_used_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_entity_repaired_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.EntityRepaired'},
    tooltip = {'exp-statistics.EntityRepaired-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_entity_repaired_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_deconstruction_planner_used_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.DeconstructionPlannerUsed'},
    tooltip = {'exp-statistics.DeconstructionPlannerUsed-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_deconstruction_planner_used_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_map_tags_made_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.MapTagsMade'},
    tooltip = {'exp-statistics.MapTagsMade-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_map_tags_made_count =
Gui.element{
    type = 'label',
    caption = '0'
}:style{
    width = label_width['count']
}

local pd_data_damage_death_ratio_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.DamageDeathRatio'},
    tooltip = {'exp-statistics.DamageDeathRatio-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_damage_death_ratio_count =
Gui.element{
    type = 'label',
    caption = '0.00'
}:style{
    width = label_width['count']
}

local pd_data_kill_death_ratio_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.KillDeathRatio'},
    tooltip = {'exp-statistics.KillDeathRatio-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_kill_death_ratio_count =
Gui.element{
    type = 'label',
    caption = '0.00'
}:style{
    width = label_width['count']
}

local pd_data_session_time_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.SessionTime'},
    tooltip = {'exp-statistics.SessionTime-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_session_time_count =
Gui.element{
    type = 'label',
    caption = '00:00'
}:style{
    width = label_width['count']
}

local pd_data_build_ratio_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.BuildRatio'},
    tooltip = {'exp-statistics.BuildRatio-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_build_ratio_count =
Gui.element{
    type = 'label',
    caption = '0.00'
}:style{
    width = label_width['count']
}

local pd_data_rocket_per_hour_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.RocketPerHour'},
    tooltip = {'exp-statistics.RocketPerHour-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_rocket_per_hour_count =
Gui.element{
    type = 'label',
    caption = '0.00'
}:style{
    width = label_width['count']
}

local pd_data_tree_kill_per_minute_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.TreeKillPerMinute'},
    tooltip = {'exp-statistics.TreeKillPerMinute-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_tree_kill_per_minute_count =
Gui.element{
    type = 'label',
    caption = '0.00'
}:style{
    width = label_width['count']
}

local pd_data_net_play_time_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.NetPlayTime'},
    tooltip = {'exp-statistics.NetPlayTime-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_net_play_time_count =
Gui.element{
    type = 'label',
    caption = '00:00'
}:style{
    width = label_width['count']
}

local pd_data_afk_time_ratio_name =
Gui.element{
    type = 'label',
    caption = {'exp-statistics.AFKTimeRatio'},
    tooltip = {'exp-statistics.AFKTimeRatio-tooltip'}
}:style{
    width = label_width['name']
}

local pd_data_afk_time_ratio_count =
Gui.element{
    type = 'label',
    caption = '0.00'
}:style{
    width = label_width['count']
}

local pd_data_set =
Gui.element(function(_, parent, name)
    local pd_data_set = parent.add{type='flow', direction='vertical', name=name}
    local disp = Gui.scroll_table(pd_data_set, label_width['total'], 4, 'disp')

    pd_data_play_time_name(disp)
    pd_data_play_time_count(disp)
    pd_data_afk_time_name(disp)
    pd_data_afk_time_count(disp)
    pd_data_maps_played_name(disp)
    pd_data_maps_played_count(disp)
    pd_data_join_count_name(disp)
    pd_data_join_count_count(disp)
    pd_data_chat_messages_name(disp)
    pd_data_chat_messages_count(disp)
    pd_data_commands_used_name(disp)
    pd_data_commands_used_count(disp)
    pd_data_rockets_launched_name(disp)
    pd_data_rockets_launched_count(disp)
    pd_data_research_completed_name(disp)
    pd_data_research_completed_count(disp)
    pd_data_machines_built_name(disp)
    pd_data_machines_built_count(disp)
    pd_data_machines_removed_name(disp)
    pd_data_machines_removed_count(disp)
    pd_data_tiles_built_name(disp)
    pd_data_tiles_built_count(disp)
    pd_data_tiles_removed_name(disp)
    pd_data_tiles_removed_count(disp)
    pd_data_trees_destroyed_name(disp)
    pd_data_trees_destroyed_count(disp)
    pd_data_ore_mined_name(disp)
    pd_data_ore_mined_count(disp)
    pd_data_items_crafted_name(disp)
    pd_data_items_crafted_count(disp)
    pd_data_items_picked_up_name(disp)
    pd_data_items_picked_up_count(disp)
    pd_data_kills_name(disp)
    pd_data_kills_count(disp)
    pd_data_deaths_name(disp)
    pd_data_deaths_count(disp)
    pd_data_damage_dealt_name(disp)
    pd_data_damage_dealt_count(disp)
    pd_data_distance_travelled_name(disp)
    pd_data_distance_travelled_count(disp)
    pd_data_capsules_used_name(disp)
    pd_data_capsules_used_count(disp)
    pd_data_entity_repaired_name(disp)
    pd_data_entity_repaired_count(disp)
    pd_data_deconstruction_planner_used_name(disp)
    pd_data_deconstruction_planner_used_count(disp)
    pd_data_map_tags_made_name(disp)
    pd_data_map_tags_made_count(disp)

    pd_data_damage_death_ratio_name(disp)
    pd_data_damage_death_ratio_count(disp)
    pd_data_kill_death_ratio_name(disp)
    pd_data_kill_death_ratio_count(disp)
    pd_data_session_time_name(disp)
    pd_data_session_time_count(disp)
    pd_data_build_ratio_name(disp)
    pd_data_build_ratio_count(disp)
    pd_data_rocket_per_hour_name(disp)
    pd_data_rocket_per_hour_count(disp)
    pd_data_tree_kill_per_minute_name(disp)
    pd_data_tree_kill_per_minute_count(disp)
    pd_data_net_play_time_name(disp)
    pd_data_net_play_time_count(disp)
    pd_data_afk_time_ratio_name(disp)
    pd_data_afk_time_ratio_count(disp)

    return pd_data_set
end)

local pd_username_player =
Gui.element(function(name, parent, player_list)
    return parent.add{
        name = name,
        type = 'drop-down',
        items = player_list,
        selected_index = #player_list > 0 and 1
    }
end)
:style{
    horizontally_stretchable = true
}

local pd_username_update =
Gui.element{
    type = 'button',
    caption = 'update'
}:style{
    width = 128
}:on_click(function(_, element, _)
    local player_name = game.players[element.parent[pd_username_player.name].selected_index]
    local data = PlayerData.Statistics
    local table = element.parent.parent.parent.parent['pd_st_2'].disp.table

    table[pd_data_play_time_count.name].caption = format_time((data['Playtime']:get(player_name) or 0) * 3600, {hours=true, minutes=true, seconds=false, time=true, string=true})
    table[pd_data_afk_time_count.name].caption = format_time((data['AfkTime']:get(player_name) or 0) * 3600, {hours=true, minutes=true, seconds=false, time=true, string=true})
    table[pd_data_maps_played_count.name].caption = format_number(data['MapsPlayed']:get(player_name) or 0)
    table[pd_data_join_count_count.name].caption = format_number(data['JoinCount']:get(player_name) or 0)
    table[pd_data_chat_messages_count.name].caption = format_number(data['ChatMessages']:get(player_name) or 0)
    table[pd_data_commands_used_count.name].caption = format_number(data['CommandsUsed']:get(player_name) or 0)
    table[pd_data_rockets_launched_count.name].caption = format_number(data['RocketsLaunched']:get(player_name) or 0)
    table[pd_data_research_completed_count.name].caption = format_number(data['ResearchCompleted']:get(player_name) or 0)
    table[pd_data_machines_built_count.name].caption = format_number(data['MachinesBuilt']:get(player_name) or 0)
    table[pd_data_machines_removed_count.name].caption = format_number(data['MachinesRemoved']:get(player_name) or 0)
    table[pd_data_tiles_built_count.name].caption = format_number(data['TilesBuilt']:get(player_name) or 0)
    table[pd_data_tiles_removed_count.name].caption = format_number(data['TilesRemoved']:get(player_name) or 0)
    table[pd_data_trees_destroyed_count.name].caption = format_number(data['TreesDestroyed']:get(player_name) or 0)
    table[pd_data_ore_mined_count.name].caption = format_number(data['OreMined']:get(player_name) or 0)
    table[pd_data_items_crafted_count.name].caption = format_number(data['ItemsCrafted']:get(player_name) or 0)
    table[pd_data_items_picked_up_count.name].caption = format_number(data['ItemsPickedUp']:get(player_name) or 0)
    table[pd_data_kills_count.name].caption = format_number(data['Kills']:get(player_name) or 0)
    table[pd_data_deaths_count.name].caption = format_number(data['Deaths']:get(player_name) or 0)
    table[pd_data_damage_dealt_count.name].caption = format_number(data['DamageDealt']:get(player_name) or 0)
    table[pd_data_distance_travelled_count.name].caption = format_number(data['DistanceTravelled']:get(player_name) or 0)
    table[pd_data_capsules_used_count.name].caption = format_number(data['CapsulesUsed']:get(player_name) or 0)
    table[pd_data_entity_repaired_count.name].caption = format_number(data['EntityRepaired']:get(player_name) or 0)
    table[pd_data_deconstruction_planner_used_count.name].caption = format_number(data['DeconstructionPlannerUsed']:get(player_name) or 0)
    table[pd_data_map_tags_made_count.name].caption = format_number(data['MapTagsMade']:get(player_name) or 0)

    table[pd_data_damage_death_ratio_count.name].caption = string.format('%.2f', (data['DamageDealt']:get(player_name) or 0) / (data['Deaths']:get(player_name) or 1))
    table[pd_data_kill_death_ratio_count.name].caption = string.format('%.2f', (data['Kills']:get(player_name) or 0) / (data['Deaths']:get(player_name) or 1))
    table[pd_data_session_time_count.name].caption = format_time((((data['Playtime']:get(player_name) or 0) - (data['AfkTime']:get(player_name) or 0)) * 3600) / (data['JoinCount']:get(player_name) or 1), {hours=true, minutes=true, seconds=false, time=true, string=true})
    table[pd_data_build_ratio_count.name].caption = string.format('%.2f', (data['MachinesBuilt']:get(player_name) or 0) / (data['MachinesRemoved']:get(player_name) or 1))
    table[pd_data_rocket_per_hour_count.name].caption = string.format('%.2f', (data['RocketsLaunched']:get(player_name) or 0) * 60 / (data['Playtime']:get(player_name) or 1))
    table[pd_data_tree_kill_per_minute_count.name].caption = string.format('%.2f', (data['TreesDestroyed']:get(player_name) or 0) / (data['Playtime']:get(player_name) or 1))
    table[pd_data_net_play_time_count.name].caption = format_time((((data['Playtime']:get(player_name) or 0) - (data['AfkTime']:get(player_name) or 0)) * 3600), {hours=true, minutes=true, seconds=false, time=true, string=true})
    table[pd_data_afk_time_ratio_count.name].caption = string.format('%.2f', (data['AfkTime']:get(player_name) or 0) * 100 / (data['Playtime']:get(player_name) or 1))
end)

local pd_username_set =
Gui.element(function(_, parent, name, player_list)
    local pd_username_set = parent.add{type='flow', direction='vertical', name=name}
    local disp = Gui.scroll_table(pd_username_set, label_width['total'], 2, 'disp')

    pd_username_player(disp, player_list)
    pd_username_update(disp)

    return pd_username_set
end)

pd_container =
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, label_width['total'])
    local player_list = {}

    for _, player in pairs(game.players) do
        table.insert(player_list, player.name)
    end

    pd_username_set(container, 'pd_st_1', player_list)
    pd_data_set(container, 'pd_st_2')

    local table = container['pd_st_2'].disp.table
    table[pd_username_player.name].width = 224

    return container.parent
end)
:add_to_left_flow()

Gui.left_toolbar_button('item/power-armor-mk2', 'Player Data GUI', pd_container, function(player)
	return Roles.player_allowed(player, 'gui/playerdata')
end)

local function gui_player_list_update()
    local player_list = {}

    for _, player in pairs(game.players) do
        table.insert(player_list, player.name)
    end

    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, pd_container)
        frame.container['pd_st_1'].disp.table[pd_username_player.name].items = player_list
    end
end

Event.add(defines.events.on_player_joined_game, gui_player_list_update)
Event.add(defines.events.on_player_left_game, gui_player_list_update)
