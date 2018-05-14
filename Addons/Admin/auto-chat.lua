--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

-- white spaces removed and made into lower
-- these messages are sent only to the player
local messages = {
    ['discord']={'chat-bot.discord'},
    ['expgaming']={'chat-bot.website'},
    ['website']={'chat-bot.website'},
    ['command']={'chat-bot.custom-commands'},
    ['commands']={'chat-bot.custom-commands'},
    ['softmod']={'chat-bot.softmod'},
    ['script']={'chat-bot.softmod'},
    ['link']={'chat-bot.links'},
    ['links']={'chat-bot.links'},
    ['loop']={'chat-bot.loops'},
    ['loops']={'chat-bot.loops'},
    ['roundabout']={'chat-bot.loops'},
    ['roundabouts']={'chat-bot.loops'},
    ['afk']=function(_player) local max=_player for _,player in pairs(game.connected_players) do if max.afk_time < player.afk_time then max=player end end return {'chat-bot.afk',max.name,tick_to_display_format(max.afk_time)} end
}

-- white spaces removed and made into lower
-- these are global chat commands that can be used
-- comands start with ! (all messages are also commands)
local command_syntax = '!'
local commands = {
    ['online']=function(player) return {'chat-bot.players-online',#game.connected_players} end,
    ['playtime']=function(player) return {'chat-bot.map-time',tick_to_display_format(game.tick)} end,
    ['players']=function(player) return {'chat-bot.players',#game.players} end,
    ['dev']={'chat-bot.not-real-dev'},
    ['blame']=function(player) local names = {'Cooldude2606','arty714','badgamernl',player.name} return {'chat-bot.blame',names[math.random(#names)]} end,
    ['readme']={'chat-bot.read-readme'},
    ['magic']={'chat-bot.magic'},
    ['aids']={'chat-bot.aids'},
    ['riot']={'chat-bot.riot'},
    ['lenny']={'chat-bot.lenny'},
    ['orderpizza']=function(player) Server.new_thread{
        timeout=math.floor(180*(math.random()+0.5)),data={player.name,0}, reopen=true
    }:on_event('timeout',function(self)
        if self.data[2]==0 then game.print{'chat-bot.message',{'chat-bot.order-pizza-2',self.data[1]}}                     
        elseif self.data[2]==1 then game.print{'chat-bot.message',{'chat-bot.order-pizza-3',self.data[1]}} self.reopen = false
        end
        self.data[2]=self.data[2]+1
    end):open() return {'chat-bot.order-pizza-1'} end,
    ['maketea']=function(player) Server.new_thread{
        timeout=math.floor(180*(math.random()+0.5)),data=player.name
    }:on_event('timeout',function(self)
        if self.data then game.print{'chat-bot.message',{'chat-bot.make-tea-2',self.data}} end
    end):open() return {'chat-bot.make-tea-1'} end
}

Event.register(defines.events.on_console_chat,function(event)
    local player = Game.get_player(event)
    if not player then return end
    local player_message = event.message:lower():gsub("%s+", "")
    local allowed = Ranking.get_rank(player):allowed('global-chat')
    for to_find,message in pairs(messages) do
        if player_message:match(command_syntax..to_find) then
            if allowed then
                if is_type(message,'function') then message=message(player) end
                game.print{'chat-bot.message',message}
            else player_return({'chat-bot.rank-error'},nil,player) end
        elseif player_message:match(to_find) then
            if is_type(message,'function') then message=message(player) end
            player_return({'chat-bot.message',message},nil,player)
        end
    end
    for to_find,message in pairs(commands) do
        if player_message:match(command_syntax..to_find) then
            if allowed then
                if is_type(message,'function') then message=message(player) end
                game.print{'chat-bot.message',message}
            else player_return({'chat-bot.rank-error'},nil,player) end
        end
    end
end)
