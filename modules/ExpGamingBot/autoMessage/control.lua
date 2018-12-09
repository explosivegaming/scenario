--- Prints a message every 15 minutes to chat.
-- @module ExpGamingBot.autoMessage
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ThisModule 

-- Module Require
local Server = require('ExpGamingCore.Server')
local Game = require('FactorioStdLib.Game')
local Role -- ExpGamingCore.Role@4.0.0
local Sync -- ExpGamingCore.Sync@4.0.0

-- Local Varibles

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Role'] then Role = require('ExpGamingCore.Role') end
        if loaded_modules['ExpGamingCore.Sync'] then Sync = require('ExpGamingCore.Sync') end
    end,
    on_post=function()
        --code
    end
}

-- Event Handlers Define
script.on_init(function(event)
    Server.new_thread{
        name='auto-message',
        timeout=54000, -- 3240000 = 15 hours dont make the mistake i did, 54000 is 15 minutes
        reopen=true,
        data={
            high_role= 'Owner',
            low_role= 'Regular',
            low={
                {'ExpGamingBot-autoMessage.join-us'},
                {'ExpGamingBot-autoMessage.discord'},
                {'ExpGamingBot-autoMessage.website'},
                {'ExpGamingBot-autoMessage.custom-commands'},
                {'ExpGamingBot-autoMessage.read-readme'}
            }
        }
    }:on_event('timeout',function(self)
        local data = self.data
        if not data.high_role or not data.low_role
        or not data.low then self.reopen = false return end
        game.print{'ExpGamingBot-autoMessage.message',{'ExpGamingBot-autoMessage.players-online',#game.connected_players}}
        game.print{'ExpGamingBot-autoMessage.message',{'ExpGamingBot-autoMessage.map-time',tick_to_display_format(game.tick)}}
        self.reopen = true
    end):on_event(defines.events.on_player_joined_game,function(self,event)
        local player = Game.get_player(event)
        if not player then return end
        local data = self.data
        if not data.high_role or not data.low_role
        or not data.low then self.reopen = false return end
        -- idk but this stoped working for no appent reason so i added more checks for nil values  
        if Role and Role.get_highest(player).index <= Role.get(data.low_role).index or player.admin then return end
        for _,message in pairs(data.low) do
            player_return({'ExpGamingBot-autoMessage.message',message},nil,player)
        end
    end):on_event('error',function(self,err)
        if Sync then Sync.emit_embeded{
            title='Auto Message Error',
            color=Color.to_hex(defines.textcolor.bg),
            description='Auto Message Error - Closed Thread',
            Error=err
        } end
        self.reopen = false
        self:close()
    end):open()
end)

-- Module Return
return ThisModule 