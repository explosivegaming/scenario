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
        name='auto-message',
        timeout=54000, -- 3240000 = 15 hours dont make the mistake i did, 54000 is 15 minutes
        reopen=true,
        data={
            high_rank= 'Owner',
            low_rank= 'Regular',
            low={
                {'auto-message.join-us'},
                {'auto-message.discord'},
                {'auto-message.website'},
                {'auto-message.custom-commands'},
                {'auto-message.read-readme'}
            }
        }
    }:on_event('timeout',function(self)
        local data = self.data
        if not data.high_rank or not data.low_rank
        or not data.low then self.reopen = false return end
        local _high = Ranking.get_rank(data.high_rank)
        local _low = Ranking.get_rank(data.low_rank)
        Ranking.print(_high,{'auto-message.players-online',#game.connected_players},nil,true)
        Ranking.print(_high,{'auto-message.map-time',tick_to_display_format(game.tick)},nil,true)
        --[[for _,line in pairs(data.low) do
            Ranking.print(_low,line,nil,true)
        end]]
        self.reopen = true
    end):on_event('error',function(self,err)
        discord_emit{
            title='Auto Message Error',
            color=Color.to_hex(defines.text_color.bg),
            description='Auto Message Error - Closed Thread',
            Error=err
        }
        self.reopen = false
        self:close()
    end):open()
end)