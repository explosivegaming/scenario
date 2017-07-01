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
	description='The Ranks that players are given apon joining',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
local preset_ranks = {
	Owner={'badgamernl'},
	
	['Community Manager']={'arty714'},
	
	Developer={'Cooldude2606'},
	
	Admin={
	'eissturm',
	'PropangasEddy',
	'Smou'},
	
	Mod={
	'Alanore',
	'Aquaday',
	'cafeslacker',
	'CrashKonijn',
	'Drahc_pro',
	'FlipHalfling90',
	'freek16',
	'Hobbitkicker',
	'hud',
	'Koroto',
	'mark9064',
	'Matthias60',
	'MeDDish',
	'Mindxt20',
	'MottledPetrel',
	'Mr_Happy_212',
	'NextIdea',
	'Phoenix27833',
	'samy115',
	'Sand3r205',
	'scarbvis',
	'steentje77',
	'tophatgaming123',
	'VR29',
	'xenocyber'},
	
	Donator={
	'M74132',
	'Splicer'},
	
	Veteran={},
	
	Member={},
	
	Regular={},
	
	Guest={},
	
	Jail={}
}

Event.register(-1,function() global.preset_ranks = preset_ranks end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits