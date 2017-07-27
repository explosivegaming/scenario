--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Tp All Command',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='When some thing big happens and everyone should be present',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
define_command('tp-all','Bring all players to one player',{'player'},'Admin',function(player,event,args)
    if player == '<server>' then
        local tp_player = game.players[args[1]]
        if not tp_player then print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
        for _,p in pairs(game.connected_players) do 
			local pos = game.surfaces[tp_player.surface.name].find_non_colliding_position("player", tp_player.position, 32, 1) 
			if p ~= tp_player then p.teleport(pos) end
		end
    else
        local tp_player = game.players[args[1]]
        if not tp_player then player.print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
        for _,p in pairs(game.connected_players) do 
			local pos = game.surfaces[tp_player.surface.name].find_non_colliding_position("player", tp_player.position, 32, 1) 
			if p ~= tp_player then p.teleport(pos) end
		end
    end
end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits