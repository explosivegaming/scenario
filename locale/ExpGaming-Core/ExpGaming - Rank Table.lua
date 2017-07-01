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
Rank Powers:
0: root
1: no restrictions - management ranks
2: unable to use scripting commands - must be with sudo()
3: able to jail people - must use /promote to be able to ban
4: highest user power
5: people who are trusted
6: default power level
7: full restrictions

For disallow add to the list the end part of the input action
Example: defines.input_action.drop_item -> 'drop_item'
http://lua-api.factorio.com/latest/defines.html#defines.input_action
--]]
local ranks = {
	{name='Owner',
	shortHand='Owner',
	tag='[Owner]',
	power=0,
	time=nil,
	colour={r=170,g=0,b=0},
	disallow={}},
	
	{name='Community Manager',
	shortHand='Com Mngr',
	tag='[Com Mngr]',
	power=1,
	time=nil,
	colour={r=150,g=68,b=161},
	disallow={}},
	
	{name='Developer',
	shortHand='Dev',
	tag='[Dev]',
	power=1,
	time=nil,
	colour={r=179,g=125,b=46},
	disallow={}},
	
	{name='Admin',
	shortHand='Admin',
	tag='[Admin]',
	power=2,
	time=nil,
	colour={r=233,g=63,b=233},
	disallow={
		'set_allow_commands',
		'edit_permission_group',
		'delete_permission_group',
		'add_permission_group'}
	},
	
	{name='Mod',
	shortHand='Mod',
	tag='[Mod]',
	power=3,
	time=nil,
	colour={r=0,g=170,b=0},
	disallow={
		'server_command'}
	},
	
	{name='Donator',
	shortHand='P2W',
	tag='[P2W]',
	power=4,
	time=nil,
	colour={r=233,g=63,b=233},
	disallow={}},
	
	{name='Veteran',
	shortHand='Vet',
	tag='[Veteran]',
	power=4,
	time=600,
	colour={r=140,g=120,b=200},
	disallow={}},
	
	{name='Member',
	shortHand='Mem',
	tag='[Member]',
	power=5,
	time=nil,
	colour={r=24,g=172,b=188},
	disallow={}},
	
	{name='Regular',
	shortHand='Reg',
	tag='[Regular]',
	power=5,
	time=180,
	colour={r=24,g=172,b=188},
	disallow={
		'set_auto_launch_rocket',
		'change_programmable_speaker_alert_parameters',
		'reset_assembling_machine',
		'drop_item'}
	},
	
	{name='Guest',
	shortHand='',
	tag='[Guest]',
	power=6,
	time=nil,
	colour={r=255,g=159,b=27},
	disallow={
		'build_terrain',
		'remove_cables',
		'launch_rocket',
		'cancel_research'}
	},
	
	{name='Jail',
	shortHand='Jail',
	tag='[Jail]',
	power=7,
	time=nil,
	colour={r=50,g=50,b=50},
	disallow={
		'open_character_gui',
		'begin_mining',
		'start_walking',
		'player_leave_game'}
	}
}
-- This For Loop cauess the disallows of each rank to be feed into the one below its self
for n,rank in pairs(ranks) do
	if ranks[n-1] then
		for _,disallow in pairs(ranks[n-1].disallow) do
			table.insert(rank.disallow,disallow)
		end
	end
end
-- Moves The Ranks to the global array
Event.register(-1,function() global.ranks = ranks end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits, ranks