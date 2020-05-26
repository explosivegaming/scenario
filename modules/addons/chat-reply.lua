--- Adds auto replies to chat messages; aswell as chat commands
-- @addon Chat-Reply

local Event = require 'utils.event' --- @dep utils.event
local Game = require 'utils.game' --- @dep utils.game
local Roles = require 'expcore.roles' --- @dep expcore.roles
local config = require 'config.chat_reply' --- @dep config.chat_reply

Event.add(defines.events.on_console_chat, function(event)
    local player_index = event.player_index
    if not player_index or player_index < 1 then return end
    local player = Game.get_player_by_index(player_index)
    local message = event.message:lower():gsub("%s+", "")
    local allowed = true
    if config.command_admin_only and not player.admin then allowed = false end
    if config.command_permission and not Roles.player_allowed(player, config.command_permission) then allowed = false end

    local prefix = config.command_prefix
    for key_word, reply in pairs(config.messages) do
        if message:find(key_word) then
            if type(reply) == 'function' then
                reply = reply(player)
            end

            if message:find(prefix..key_word) then
                if allowed then
                    game.print{'chat-bot.reply', reply}
                else
                    player.print{'chat-bot.disallow'}
                end
            elseif not allowed then
                player.print{'chat-bot.reply', reply}
            end
        end
    end

    if not allowed then return end

    for key_word, reply in pairs(config.commands) do
        if message:find(prefix..key_word) then
            if type(reply) == 'function' then
                reply = reply(player)

                if reply then
                    game.print{'chat-bot.reply', reply}
                end

            else
                game.print{'chat-bot.reply', reply}
            end

        end
    end
end)