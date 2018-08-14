--- Sends messages in chat in resposce to other messages
-- @module ExpGamingBot.autoChat
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Server = require('ExpGamingCore.Server')
local Game = require('FactorioStdLib.Game')
local Ranking
local Sync

script.on_init(function(event)
    Server.new_thread{
        name='auto-message',
        timeout=54000, -- 3240000 = 15 hours dont make the mistake i did, 54000 is 15 minutes
        reopen=true,
        data={
            high_rank= 'Owner',
            low_rank= 'Regular',
            low={
                {'chat-bot.join-us'},
                {'chat-bot.discord'},
                {'chat-bot.website'},
                {'chat-bot.custom-commands'},
                {'chat-bot.read-readme'}
            }
        }
    }:on_event('timeout',function(self)
        local data = self.data
        if not data.high_rank or not data.low_rank
        or not data.low then self.reopen = false return end
        game.print{'chat-bot.message',{'chat-bot.players-online',#game.connected_players}}
        game.print{'chat-bot.message',{'chat-bot.map-time',tick_to_display_format(game.tick)}}
        self.reopen = true
    end):on_event(defines.events.on_player_joined_game,function(self,event)
        local player = Game.get_player(event)
        if not player then return end
        local data = self.data
        if not data.high_rank or not data.low_rank
        or not data.low then self.reopen = false return end
        -- idk but this stoped working for no appent reason so i added more checks for nil values
        if Ranking and Ranking.get_rank(player).power <= Ranking.get_rank(data.low_rank).power or player.admin then return end
        for _,message in pairs(data.low) do
            player_return({'chat-bot.message',message},nil,player)
        end
    end):on_event('error',function(self,err)
        if Sync then Sync.emit_embeded{
            title='Auto Message Error',
            color=Color.to_hex(defines.text_color.bg),
            description='Auto Message Error - Closed Thread',
            Error=err
        } end
        self.reopen = false
        self:close()
    end):open()
end)

return {
    on_init = function(self) 
        if loaded_modules['ExpGamingCore.Ranking'] then Ranking = require('ExpGamingCore.Ranking') end
        if loaded_modules['ExpGamingCore.Sync'] then Sync = require('ExpGamingCore.Sync') end
    end
}