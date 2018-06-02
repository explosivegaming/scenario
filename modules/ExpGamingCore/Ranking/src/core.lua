--[[
    How to use groups:
name		the name that you can use to refence it.
disallow	if present then all ranks in this group will have this added to their disallow.
allow		if present then all ranks in this group will have this added to their allow.
highest     is asigned by the script to show the highest rank in this group.
lowest      is asigned by the script to show the lowest rank in this group.
How to add ranks:
Name		is what will be used in the scripts and is often the best choice for display in text.
short_hand	is what can be used when short on space but the rank still need to be displayed.
tag			is the tag the player will gain when moved to the rank, it can be nil.
time		is used for auto-rank feature where you are moved to the rank after a certain play time in minutes.
colour		is the RGB value that can be used to emphasise GUI elements based on rank.
power		is asigned by the script based on their index in ranks, you can insert new ranks between current ones, lower is better
group		is asigned by the script to show the group this rank is in
disallow	is a list containing input actions that the user can not perform.
allow		is a list of custom commands and effects that that rank can use, all defined in the sctips.

For allow, add the allow as the key and the value as true
Example: test for 'server-interface' => allow['server-interface'] = true

For disallow, add to the list the end part of the input action
Example: defines.input_action.drop_item -> 'drop_item'
http://lua-api.factorio.com/latest/defines.html#defines.input_action
--]]

-- If you wish to add more groups please use src/config or add during your own module
-- If you wish to add to these rank groups use src/config or add during your own module
-- But groups do not inherite from each other
-- DO NOT REMOVE ANY OF THESE GROUPS!!!

local root = Ranking._group:create{
    name='Root',
    allow={
        ['interface'] = true
    },
    disallow={}
}
local admin = Ranking._group:create{
    name='Admin',
    parent='Root',
    allow={},
    disallow={
        'edit_permission_group',
        'delete_permission_group',
        'add_permission_group'
    }
}
local user = Ranking._group:create{
    name='User',
    parent='Admin',
    allow={},
    disallow={}
}
local jail = Ranking._group:create{
    name='Jail',
    parent='User',
    allow={},
    disallow={
        'open_character_gui',
        'begin_mining',
        'start_walking',
        'player_leave_game',
        'open_blueprint_library_gui',
        'build_item',
        'use_item',
        'select_item',
        'rotate_entity',
        'open_train_gui',
        'open_train_station_gui',
        'open_gui',
        'open_item',
        'deconstruct',
        'build_rail',
        'cancel_research',
        'start_research',
        'set_train_stopped',
        'select_gun',
        'open_technology_gui',
        'open_trains_gui',
        'edit_custom_tag',
        'craft',
        'setup_assembling_machine',
    }
}

-- If you wish to add more ranks please use src/config or add during your own module
-- If you wish to add to these rank use src/config or add during your own module
root:add_rank{
    name='Root',
    short_hand='Root',
    tag='[Root]',
    colour=defines.color.white,
    is_root=true,
    is_admin=true,
    is_spectator=true,
    base_afk_time=false
}

admin:add_rank{
    name='Admin',
    short_hand='Admin',
    tag='[Admin]',
    parent='Root',
    colour={r=233,g=63,b=233},
    is_admin=true,
    is_spectator=true,
    base_afk_time=false
}

user:add_rank{
    name='Member',
    short_hand='Mem',
    tag='[Member]',
    parent='Admin',
    colour={r=24,g=172,b=188},
    disallow={
        'set_auto_launch_rocket',
        'change_programmable_speaker_alert_parameters',
        'drop_item'
    },
    base_afk_time=60
}
user:add_rank{
    name='Guest',
    short_hand='',
    tag='',
    parent='Member',
    colour={r=255,g=159,b=27},
    is_default=true,
    disallow={
        'build_terrain',
        'remove_cables',
        'launch_rocket',
        'reset_assembling_machine',
        'cancel_research'
    },
    base_afk_time=10
}

jail:add_rank{
    name='Jail',
    short_hand='Jail',
    tag='[Jail]',
    parent='Guest',
    colour={r=50,g=50,b=50},
    disallow={},
    base_afk_time=false
}