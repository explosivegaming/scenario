--- This file defines the different triggers for the chat bot
local format_time = ext_require('expcore.common','format_time')
return {
    allow_command_prefix_for_messages = true, -- when true any message trigger will print to all player when prefixed
    messages = { -- will trigger when ever the word is said
        ['discord']={'info.discord'},
        ['expgaming']={'info.website'},
        ['website']={'info.website'},
        ['wiki']={'info.wiki'},
        ['status']={'info.status'},
        ['github']={'info.github'},
        ['command']={'info.custom-commands'},
        ['commands']={'info.custom-commands'},
        ['softmod']={'info.softmod'},
        ['script']={'info.softmod'},
        ['loop']={'chat-bot.loops'},
        ['loops']={'chat-bot.loops'},
        ['rhd']={'chat-bot.lhd'},
        ['lhd']={'chat-bot.lhd'},
        ['roundabout']={'chat-bot.loops'},
        ['roundabouts']={'chat-bot.loops'},
        ['redmew']={'chat-bot.redmew'},
        ['afk']=function(player)
            local max=player
            for _,next_player in pairs(game.connected_players) do
                if max.afk_time < next_player.afk_time then
                    max=next_player
                end
            end
            return {'chat-bot.afk',max.name,format_time(max.afk_time,{minutes=true,seconds=true,long=true})}
        end,
        ['players']=function()
            return {'chat-bot.players',#game.players}
        end,
        ['online']=function()
            return {'chat-bot.players-online',#game.connected_players}
        end,
        ['time']=function()
            return {'chat-bot.map-time',format_time(game.tick,{days=true,hours=true,minutes=true,seconds=true,long=true})}
        end,
    },
    command_admin_only = false, -- when true will only allow chat commands for admins
    command_permission = 'command/chat-bot', -- the permission used to allow command prefixes
    command_prefix = '!', -- prefix used for commands below and to print to all players (if enabled above)
    commands = { -- will trigger only when command prefix is given
        ['dev']={'chat-bot.not-real-dev'},
        ['blame']=function(player)
            local names = {'Cooldude2606','arty714','badgamernl',player.name}
            for _,next_player in pairs(game.connected_players) do
                names[#names + 1] = next_player.name
            end
            return {'chat-bot.blame',table.get_random_dictionary_entry(names)}
        end,
        ['magic']={'chat-bot.magic'},
        ['aids']={'chat-bot.aids'},
        ['riot']={'chat-bot.riot'},
        ['lenny']={'chat-bot.lenny'},
        ['hodor']=function()
            local options = {'?','.','!','!!!'}
            return {'chat-bot.hodor',table.get_random_dictionary_entry(options)}
        end,
        ['evolution']=function()
            return {'chat-bot.current-evolution',string.format('%.2f',game.forces['enemy'].evolution_factor)}
        end,
    }
}