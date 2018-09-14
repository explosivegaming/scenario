--- Sends messages in chat in resposce to other messages
-- @module ExpGamingBot.autoChat
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ThisModule 

-- Module Require
local Game = require('FactorioStdLib.Game@^0.8.0')
local Ranking -- ExpGamingCore.Ranking@^4.0.0

-- Local Varibles
-- lots of these are jokes, but some have uses

-- white spaces removed and made into lower
-- these messages are sent only to the player
local messages = {
    ['discord']={'ExpGamingBot-autoChat.discord'},
    ['expgaming']={'ExpGamingBot-autoChat.website'},
    ['website']={'ExpGamingBot-autoChat.website'},
    ['command']={'ExpGamingBot-autoChat.custom-commands'},
    ['commands']={'ExpGamingBot-autoChat.custom-commands'},
    ['softmod']={'ExpGamingBot-autoChat.softmod'},
    ['script']={'ExpGamingBot-autoChat.softmod'},
    ['link']={'ExpGamingBot-autoChat.links'},
    ['links']={'ExpGamingBot-autoChat.links'},
    ['loop']={'ExpGamingBot-autoChat.loops'},
    ['loops']={'ExpGamingBot-autoChat.loops'},
    ['rhd']={'ExpGamingBot-autoChat.lhd'},
    ['roundabout']={'ExpGamingBot-autoChat.loops'},
    ['roundabouts']={'ExpGamingBot-autoChat.loops'},
    ['redmew']={'ExpGamingBot-autoChat.redmew'},
    ['afk']=function(_player) local max=_player for _,player in pairs(game.connected_players) do if max.afk_time < player.afk_time then max=player end end return {'ExpGamingBot-autoChat.afk',max.name,tick_to_display_format(max.afk_time)} end
}
-- white spaces removed and made into lower
-- these are global chat commands that can be used
-- comands start with ! (all messages are also commands)
local command_syntax = '!'
local commands = {
    ['online']=function(player) return {'ExpGamingBot-autoChat.players-online',#game.connected_players} end,
    ['playtime']=function(player) return {'ExpGamingBot-autoChat.map-time',tick_to_display_format(game.tick)} end,
    ['players']=function(player) return {'ExpGamingBot-autoChat.players',#game.players} end,
    ['dev']={'ExpGamingBot-autoChat.not-real-dev'},
    ['blame']=function(player) local names = {'Cooldude2606','arty714','badgamernl',player.name} return {'ExpGamingBot-autoChat.blame',names[math.random(#names)]} end,
    ['readme']={'ExpGamingBot-autoChat.read-readme'},
    ['magic']={'ExpGamingBot-autoChat.magic'},
    ['aids']={'ExpGamingBot-autoChat.aids'},
    ['riot']={'ExpGamingBot-autoChat.riot'},
    ['lenny']={'ExpGamingBot-autoChat.lenny'},
    ['wiki']={'ExpGamingBot-autoChat.wiki'},
    ['evolution']=function(player) return {'ExpGamingBot-autoChat.current-evolution',string.format('%.2f',game.forces['enemy'].evolution_factor)} end,
    --Jokes about food and drink
    ['whattoeat']={'ExpGamingBot-autoChat.food'},
    ['makepopcorn']=function(player) Server.new_thread{
        timeout=math.floor(180*(math.random()+0.5)),data=player.name
    }:on_event('timeout',function(self)
        if self.data then game.print{'ExpGamingBot-autoChat.message',{'ExpGamingBot-autoChat.get-popcorn-2',self.data}} end
    end):open() return {'ExpGamingBot-autoChat.get-popcorn-1'} end,    
    ['orderpizza']=function(player) Server.new_thread{
        timeout=math.floor(180*(math.random()+0.5)),data={player.name,0}, reopen=true
    }:on_event('timeout',function(self)
        if self.data[2]==0 then game.print{'ExpGamingBot-autoChat.message',{'ExpGamingBot-autoChat.order-pizza-2',self.data[1]}}                
        elseif self.data[2]==1 then game.print{'ExpGamingBot-autoChat.message',{'ExpGamingBot-autoChat.order-pizza-3',self.data[1]}} self.reopen = false
        end
        self.data[2]=self.data[2]+1
    end):open() return {'ExpGamingBot-autoChat.order-pizza-1'} end,
    ['passsomesnaps']=function(player) Server.new_thread{
        timeout=math.floor(180*(math.random()+0.5)),data={player.name,0}, reopen=true
    }:on_event('timeout',function(self)
        if self.data[2]==0 then game.print{'ExpGamingBot-autoChat.message',{'ExpGamingBot-autoChat.get-snaps-2',self.data[1]}}                
        elseif self.data[2]==1 then game.print{'ExpGamingBot-autoChat.message',{'ExpGamingBot-autoChat.get-snaps-3',self.data[1]}} self.reopen = false
        end
        self.data[2]=self.data[2]+1
    end):open() return {'ExpGamingBot-autoChat.get-snaps-1'} end,
    ['makecocktail']=function(player) Server.new_thread{
        timeout=math.floor(180*(math.random()+0.5)),data={player.name,0}, reopen=true
    }:on_event('timeout',function(self)
        if self.data[2]==0 then game.print{'ExpGamingBot-autoChat.message',{'ExpGamingBot-autoChat.get-cocktail-2',self.data[1]}}                
        elseif self.data[2]==1 then game.print{'ExpGamingBot-autoChat.message',{'ExpGamingBot-autoChat.get-cocktail-3',self.data[1]}} self.reopen = false
        end
        self.data[2]=self.data[2]+1
    end):open() return {'ExpGamingBot-autoChat.get-cocktail-1'} end,
    ['makecoffee']=function(player) Server.new_thread{
        timeout=math.floor(180*(math.random()+0.5)),data=player.name
    }:on_event('timeout',function(self)
        if self.data then game.print{'ExpGamingBot-autoChat.message',{'ExpGamingBot-autoChat.make-coffee-2',self.data}} end
    end):open() return {'ExpGamingBot-autoChat.make-coffee-1'} end,
    ['orderpizza']=function(player) Server.new_thread{
        timeout=math.floor(180*(math.random()+0.5)),data={player.name,0}, reopen=true
    }:on_event('timeout',function(self)
        if self.data[2]==0 then game.print{'ExpGamingBot-autoChat.message',{'ExpGamingBot-autoChat.order-pizza-2',self.data[1]}}                     
        elseif self.data[2]==1 then game.print{'ExpGamingBot-autoChat.message',{'ExpGamingBot-autoChat.order-pizza-3',self.data[1]}} self.reopen = false
        end
        self.data[2]=self.data[2] + 1
    end):open() return {'ExpGamingBot-autoChat.order-pizza-1'} end,
    ['maketea']=function(player) Server.new_thread{
        timeout=math.floor(180*(math.random()+0.5)),data=player.name
    }:on_event('timeout',function(self)
        if self.data then game.print{'ExpGamingBot-autoChat.message',{'ExpGamingBot-autoChat.make-tea-2',self.data}} end
    end):open() return {'ExpGamingBot-autoChat.make-tea-1'} end,
    ['meadplease']=function(player) Server.new_thread{
        timeout=math.floor(180*(math.random()+0.5)),data=player.name
    }:on_event('timeout',function(self)
        if self.data then game.print{'ExpGamingBot-autoChat.message',{'ExpGamingBot-autoChat.get-mead-2',self.data}} end
    end):open() return {'ExpGamingBot-autoChat.get-mead-1'} end,
    ['passabeer']=function(player) Server.new_thread{
        timeout=math.floor(180*(math.random()+0.5)),data=player.name
    }:on_event('timeout',function(self)
        if self.data then game.print{'ExpGamingBot-autoChat.message',{'ExpGamingBot-autoChat.get-beer-2',self.data}} end
    end):open() return {'ExpGamingBot-autoChat.get-beer-1'} end
}

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Ranking@^4.0.0'] then Ranking = require('ExpGamingCore.Ranking@^4.0.0') end
    end
}

-- Event Handlers Define
script.on_event(defines.events.on_console_chat,function(event)
    local player = Game.get_player(event)
    if not player then return end
    local player_message = event.message:lower():gsub("%s+", "")
    local allowed = Ranking and Ranking.get_rank(player):allowed('global-chat') or player.admin
    for to_find,message in pairs(messages) do
        if player_message:match(command_syntax..to_find) then
            if allowed then
                if is_type(message,'function') then message=message(player) end
                game.print{'ExpGamingBot-autoChat.message',message}
            else player_return({'ExpGamingBot-autoChat.rank-error'},nil,player) end
        elseif player_message:match(to_find) then
            if is_type(message,'function') then message=message(player) end
            player_return({'ExpGamingBot-autoChat.message',message},nil,player)
        end
    end
    for to_find,message in pairs(commands) do
        if player_message:match(command_syntax..to_find) then
            if allowed then
                if is_type(message,'function') then message=message(player) end
                game.print{'ExpGamingBot-autoChat.message',message}
            else player_return({'ExpGamingBot-autoChat.rank-error'},nil,player) end
        end
    end
end)

-- Module Return
return ThisModule 