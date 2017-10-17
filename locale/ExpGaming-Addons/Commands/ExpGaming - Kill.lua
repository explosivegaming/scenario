--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Kill Command',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='For when ever you need to kill some one',
	factorio_version='0.15.23',
	show=true
	}}

--Please Only Edit Below This Line-----------------------------------------------------------
define_command('kill','Used to kill a player, you can always kill your self!',{'player'},function(player,event,args)
    if player == '<server>' then
        local kill_player = game.players[args[1]]
        if not kill_player then print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
        if kill_player.connected then else print('Invaild Player, player is not online') return end
        if kill_player.character then kill_player.character.die() else print('Invaild Player, their are already dead') return  end
    else
        local kill_player = game.players[args[1]]
        if not kill_player then player.print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
        if kill_player == player or ranking.get_player_rank(player).power < ranking.get_player_rank(kill_player).power and ranking.get_player_rank(player).power <= string_to_rank_group('Moderation').lowest_rank.power then
            if kill_player.connected then else player.print('Invaild Player, player is not online') return end
            if kill_player.character then kill_player.character.die() else player.print('Invaild Player, their are already dead') return end
        else player.print('401 - Unauthorized: Access is denied due to invalid credentials') end
    end
end)

