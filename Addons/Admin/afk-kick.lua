--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

Event.register(-1,function(event)
    Server.new_thread{
        name='afk-kick',
    }:on_event('tick',function(self)
        if (game.tick%3600) ~= 0 then return end
        for _,player in pairs(game.connected_players) do
            local afk = Ranking.get_rank(player).max_afk_time or false
            if afk then
                if player.afk_time > afk*3600 then game.kick_player(player,'AFK For Too Long ('..afk..' Minutes)') end
            end
        end
    end):on_event('error',function(self,err)
        discord_emit{
            title='Auto Kick Error',
            color=Color.to_hex(defines.text_color.bg),
            description='Auto Kick Error - Closed Thread',
            Error=err
        }
        self:close()
    end):open()
end)
