--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
-- we run an exturnle script which syncs this table with discord, only top ranks are filled in case of error
Event.register(Event.soft_init,function()
	global.preset_ranks = {
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
end)
-- returns this list, or just one rank if given
function ranking.get_player_rank_presets(rank)
	if rank then return global.preset_ranks[ranking.string_to_rank(rank).name] else return global.preset_ranks end
end


