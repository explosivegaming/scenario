--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Rank Changer',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Allows players to set the ranks of those below them.',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
ExpGui.add_frame.center('rank_changer','Edit Ranks','Allows you to edit players ranks','Mod',{},function(player,frame)
	
end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits