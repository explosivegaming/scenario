--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Tp Command',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Teleport players to each other, ON DUTIY ONLY!',
	factorio_version='0.15.23',
	show=true
	}}

--Please Only Edit Below This Line-----------------------------------------------------------
define_command('tp','Teleport players to each other, ON DUTIY ONLY!',{'player','to_player'},function(player,event,args)
    if player == '<server>' then
        local p1 = game.players[args[1]] if p1 then else print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
	    local p2 = game.players[args[2]] if p2 then else print('Invaild Player Name,'..args[2]..', try using tab key to auto-complete the name') return end 
        if p1 == p2 then print('Invaild Players, must be two diffrent players') return end
		if p1.connected and p2.connected then else print('Invaild Players, one/both of players is not online') return end
		p1.teleport(game.surfaces[p2.surface.name].find_non_colliding_position("player", p2.position, 32, 1))
    else
        local p1 = game.players[args[1]] if p1 then else player.print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
		local p2 = game.players[args[2]] if p2 then else player.print('Invaild Player Name,'..args[2]..', try using tab key to auto-complete the name') return end
        if p1 == p2 then  player.print('Invaild Players, must be two diffrent players') return end
		if p1.connected and p2.connected then else player.print('Invaild Player, player is not online') return end
		if ranking.get_player_rank(player).power > ranking.get_player_rank(p1).power then player.print('401 - Unauthorized: Access is denied due to invalid credentials') return end
		p1.teleport(game.surfaces[p2.surface.name].find_non_colliding_position("player", p2.position, 32, 1))
    end
end)

