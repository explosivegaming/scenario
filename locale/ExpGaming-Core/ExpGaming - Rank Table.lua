--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='ExpGaming - Ranks Table',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Table holding the ranks used',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
--[[
How to add ranks:
Name		is what will be used in the scripts and is often the best choice for display in text.
short_hand	is what can be used when short on space but the rank still need to be displayed.
tag			is the tag the player will gain when moved to the rank, it can be nil.
time		is used for auto-rank feature where you are moved to the rank after a certain play time in minutes.
colour		is the RGB value that can be used to emphasise GUI elements based on rank.
power		is not in the list below as it is auto-defined by index but allows comparison between ranks.
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
	ranks={
		{name='Owner',
		short_hand='Owner',
		tag='[Owner]',
		time=nil,
		colour={r=170,g=0,b=0},
		disallow={},
		allow={}},
		
		{name='Community Manager',
		short_hand='Com Mngr',
		tag='[Com Mngr]',
		time=nil,
		colour={r=150,g=68,b=161},
		disallow={},
		allow={}},
		
		{name='Developer',
		short_hand='Dev',
		tag='[Dev]',
		time=nil,
		colour={r=179,g=125,b=46},
		disallow={},
		allow={'cheat-mode'}
		},
		
		{name='Admin',
		short_hand='Admin',
		tag='[Admin]',
		time=nil,
		colour={r=233,g=63,b=233},
		disallow={
			'set_allow_commands',
			'edit_permission_group',
			'delete_permission_group',
			'add_permission_group'},
		allow={
			'server-interface',
			'tp-all',
			'announcement',
			'admin',
			'force_modifiers_tab',
			'player_modifiers_tab'}
		},
		
		{name='Mod',
		short_hand='Mod',
		tag='[Mod]',
		time=nil,
		colour={r=0,g=170,b=0},
		disallow={
			'server_command'},
		allow={
			'temp-ban',
			'rank_changer'}
		},
		
		{name='Donator',
		short_hand='P2W',
		tag='[P2W]',
		time=nil,
		colour={r=233,g=63,b=233},
		disallow={},
		allow={
			'tp',
			'repair',
			'tree_remover'}
		},
		
		{name='Veteran',
		short_hand='Vet',
		tag='[Veteran]',
		time=600,
		colour={r=140,g=120,b=200},
		disallow={},
		allow={'edit_tasks'}},
		
		{name='Member',
		short_hand='Mem',
		tag='[Member]',
		time=nil,
		colour={r=24,g=172,b=188},
		disallow={},
		allow={}},
		
		{name='Regular',
		short_hand='Reg',
		tag='[Regular]',
		time=180,
		colour={r=24,g=172,b=188},
		disallow={
			'set_auto_launch_rocket',
			'change_programmable_speaker_alert_parameters',
			'drop_item'},
		allow={'decon'}
		},
		
		{name='Guest',
		short_hand='',
		tag='[Guest]',
		time=nil,
		colour={r=255,g=159,b=27},
		disallow={
			'build_terrain',
			'remove_cables',
			'launch_rocket',
			'reset_assembling_machine',
			'cancel_research'},
		allow={
			'kill',
			'tag',
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
			'credit_tab'}
		},
		
		{name='Jail',
		short_hand='Jail',
		tag='[Jail]',
		time=nil,
		colour={r=50,g=50,b=50},
		disallow={
			'open_character_gui',
			'begin_mining',
			'start_walking',
			'player_leave_game'},
		allow={}
		}
	}
}
-- rank table setup
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
    rank = ranks.ranks[n]
    if ranks.ranks[n+1] then
		for _,allow in pairs(ranks.ranks[n+1].allow) do
			table.insert(rank.allow,allow)
		end
	end
end
-- returns a list off all the ranks, return only one part if given
function get_ranks(part)
	local to_return = {}
	if part then 
		for _,rank in pairs(global.ranks.ranks) do table.insert(to_return,rank[part]) end
	else to_return = global.ranks.ranks end
	return to_return
end
-- Move the ranks to the global array
Event.register(-1,function() global.ranks = ranks end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits