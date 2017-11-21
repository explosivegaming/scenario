--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
--Please Only Edit Below This Line-----------------------------------------------------------
How to use groups:
name		the name that you can use to refence it.
colour		if present then all ranks in this group will have this colour.
disallow	if present then all ranks in this group will have this added to their disallow.
allow		if present then all ranks in this group will have this added to their allow.
highest_rank is asigned by the script to show the highest rank in this group.
lowest_rank is asigned by the script to show the lowest rank in this group.
How to add ranks:
Name		is what will be used in the scripts and is often the best choice for display in text.
short_hand	is what can be used when short on space but the rank still need to be displayed.
tag			is the tag the player will gain when moved to the rank, it can be nil.
time		is used for auto-rank feature where you are moved to the rank after a certain play time in minutes.
colour		is the RGB value that can be used to emphasise GUI elements based on rank.
power		is not in the list below as it is auto-defined by index but allows comparison between ranks.
group		is the groups that this rank is apart of can be nil, group allow and disallow are non-inheritable.
disallow	is a list containing input actions that the user can not perform.
allow		is a list of custom commands and effects that that rank can use, all defined in the sctips.
For disallow, add to the list the end part of the input action
Example: defines.input_action.drop_item -> 'drop_item'
http://lua-api.factorio.com/latest/defines.html#defines.input_action
--]]
local ranks = {
	--these are asigned during the rank set up
	highest_timed_rank=nil,
	lowest_timed_rank=nil,
	number_of_ranks=0,
	groups={
		--note dont remove these groups but you may add more
		--all but the management group is used to indentiy ranks by the script
		{name='Management',
		allow={'cheat-mode','debug'}
		},

		{name='Moderation',
		disallow={
			'set_allow_commands',
			'edit_permission_group',
			'delete_permission_group',
			'add_permission_group'},
		allow={
			'temp-ban',
			'rank_changer',
			'clear-reports',
			'limitless_tags',
			'map-changes'}
		},

		{name='User',
		allow={
			'kill',
			'tag',
			'report',
			'task_list',
			'science_list',
			'rocket_list',
			'player_list',
			'readme',
			'rules_tab',
			'chat_tab',
			'commands_tab',
			'players_tab',
			'info',
			'links_tab',
			'servers_tab',
			'warp-points'}
		},

		{name='Jail',
		disallow={
			'open_character_gui',
			'begin_mining',
			'start_walking',
			'player_leave_game',
			'rotate_entity',
			'reverse_rotate_entity',
			'select_gun',
			'open_technology_gui',
			'start_research',
			'open_blueprint_library_gui',
			'open_trains_gui',
			'open_train_station_gui',
			'use_item',
			'build_item'}
		}
	},
	ranks={
		{name='Owner',
		short_hand='Owner',
		tag='[Owner]',
		time=nil,
		colour={r=170,g=0,b=0},
		group='Management',
		disallow={},
		allow={}},
		
		{name='Community Manager',
		short_hand='Com Mngr',
		tag='[Com Mngr]',
		time=nil,
		colour={r=150,g=68,b=161},
		group='Management',
		disallow={},
		allow={}},
		
		{name='Developer',
		short_hand='Dev',
		tag='[Dev]',
		time=nil,
		colour={r=179,g=125,b=46},
		group='Management',
		disallow={},
		allow={'cheat-mode'}
		},
		
		{name='Admin',
		short_hand='Admin',
		tag='[Admin]',
		time=nil,
		colour={r=233,g=63,b=233},
		group='Moderation',
		disallow={},
		allow={
			'server-interface',
			'tp-all',
			'announcement',
			'admin',
			'force_modifiers_tab',
			'player_modifiers_tab',
			'adv_repair',
			'free-warp'}
		},
		
		{name='Mod',
		short_hand='Mod',
		tag='[Mod]',
		time=nil,
		colour={r=0,g=170,b=0},
		group='Moderation',
		disallow={'server_command'},
		allow={}
		},
		
		{name='Donator',
		short_hand='P2W',
		tag='[P2W]',
		time=nil,
		colour={r=233,g=63,b=233},
		group='User',
		disallow={},
		allow={
			'tp',
			'repair',
			'tree_remover',
			'report_protection'}
		},
		
		{name='Veteran',
		short_hand='Vet',
		tag='[Veteran]',
		time=600,
		colour={r=140,g=120,b=200},
		group='User',
		disallow={},
		allow={}},
		
		{name='Member',
		short_hand='Mem',
		tag='[Member]',
		time=nil,
		colour={r=24,g=172,b=188},
		group='User',
		disallow={},
		allow={'trusted_reporter','warp-point'}},
		
		{name='Regular',
		short_hand='Reg',
		tag='[Regular]',
		time=180,
		colour={r=24,g=172,b=188},
		group='User',
		disallow={
			'set_auto_launch_rocket',
			'change_programmable_speaker_alert_parameters',
			'drop_item'},
		allow={'decon','edit_tasks'}
		},
		
		{name='Guest',
		short_hand='',
		tag='',
		time=nil,
		colour={r=255,g=159,b=27},
		group='User',
		disallow={
			'build_terrain',
			'remove_cables',
			'launch_rocket',
			'reset_assembling_machine',
			'cancel_research'},
		allow={}
		},
		
		{name='Jail',
		short_hand='Jail',
		tag='[Jail]',
		time=nil,
		colour={r=50,g=50,b=50},
		group='Jail',
		disallow={},
		allow={}
		}
	}
}
-- rank table setup
-- group setup
for n,rank in pairs(ranks.ranks) do
	local group = nil; for _,g in pairs(ranks.groups) do if g.name == rank.group then group = g break end end
	if group and not group.highest_rank then group.highest_rank=rank end
	if group then group.lowest_rank=rank end
	if group and group.colour then rank.colour = group.colour end
end
-- group to rank setup
for n,group in pairs(ranks.groups) do
	if group.allow and group.lowest_rank then
		for _,allow in pairs(group.allow) do table.insert(group.lowest_rank.allow,allow) end
	end
	if group.disallow and group.highest_rank then
		for _,disallow in pairs(group.disallow) do table.insert(group.highest_rank.disallow,disallow) end
	end
end
-- rank setup
for n,rank in pairs(ranks.ranks) do
	rank.power = n
	if ranks.ranks[n-1] then
		for _,disallow in pairs(ranks.ranks[n-1].disallow) do
			table.insert(rank.disallow,disallow)
		end
	end
	if rank.time and not ranks.highest_timed_rank then ranks.highest_timed_rank=rank end
	if rank.time then ranks.lowest_timed_rank=rank end
	ranks.number_of_ranks=ranks.number_of_ranks+1
end

for n = #ranks.ranks, 1, -1 do
    local rank = ranks.ranks[n]
    if ranks.ranks[n+1] then
		for _,allow in pairs(ranks.ranks[n+1].allow) do
			table.insert(rank.allow,allow)
		end
	end
end
-- returns a list off all the ranks, return only one part if given
local function get_ranks(part)
	local to_return = {}
	if part then 
		for _,rank in pairs(global.exp_core.ranks.ranks) do table.insert(to_return,rank[part]) end
	else to_return = global.exp_core.ranks.ranks end
	return to_return
end
-- returns a list off all the groups, return only one part if given
local function get_rank_groups(part)
	local to_return = {}
	if part then 
		for _,group in pairs(global.exp_core.ranks.groups) do table.insert(to_return,group[part]) end
	else to_return = global.exp_core.ranks.groups end
	return to_return
end
-- Move the ranks to the global array
Event.register(Event.soft_init,function() global.exp_core.ranks = ranks end)

return {get_ranks, get_rank_groups}