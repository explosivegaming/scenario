--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='ExpGaming - Rank Preset Table',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='The ranks that players are given upon joining',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
-- we run an exturnle script which syncs this table with discord, only top ranks are filled in case of error
local preset_ranks = {
	Owner={'badgamernl'},
	
	['Community Manager']={'arty714'},
	
	Developer={'Cooldude2606'},
	
	Admin={
	'eissturm',
	'PropangasEddy',
	'mark9064',
	'Smou'},
	
	Mod={},
	
	Donator={},
	
	Veteran={},
	
	Member={},
	
	Regular={},
	
	Guest={},
	
	Jail={}
}
-- returns this list, or just one rank if given
function get_rank_presets(rank)
	if rank then return global.preset_ranks[rank] else return global.preset_ranks end
end
Event.register(-1,function() global.preset_ranks = preset_ranks end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits
