--- Sends alerts to discord once there is a bot set up to read the alerts.
-- @module ExpGamingBot.discordAlerts@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alias ThisModule

-- Module Require
local Sync = require('ExpGamingCore.Sync')
local Color = require('FactorioStdLib.Color')
local Game = require('FactorioStdLib.Game')

-- Module Define
local module_verbose = false
local ThisModule = {}

-- Event Handlers Define
script.on_event(defines.events.on_console_command,function(event)
    local command = event.command
    local args = {}
    if event.parameters then for word in event.parameters:gmatch('%S+') do table.insert(args,word) end end
    local data = {}
    data.title = string.gsub(command,'^%l',string.upper)
    data.by = event.player_index and game.players[event.player_index].name or '<server>'
    if data.by == '<server>' then return end
    if command == 'config' or command == 'banlist' then
        Sync.emit_embedded{
            title='Edit To '..data.title,
            color=Color.to_hex(defines.textcolor.bg),
            description='A player edited the '..command..'.',
            ['By:']=data.by,
            ['Edit:']=table.concat(args,' ',1)
        }
    else
        if command == 'ban' then
            data.colour = Color.to_hex(defines.textcolor.crit)
            data.reason = table.concat(args,' ',2)
        elseif command == 'kick' then
            data.colour = Color.to_hex(defines.textcolor.high)
            data.reason = table.concat(args,' ',2)
        elseif command == 'unban' then data.colour = Color.to_hex(defines.textcolor.low)
        elseif command == 'mute' then data.colour = Color.to_hex(defines.textcolor.med)
        elseif command == 'unmute' then data.colour = Color.to_hex(defines.textcolor.low)
        elseif command == 'promote' then data.colour = Color.to_hex(defines.textcolor.info)
        elseif command == 'demote' then data.colour = Color.to_hex(defines.textcolor.info)
        elseif command == 'purge' then data.colour = Color.to_hex(defines.textcolor.med)
        else return end
        data.username = args[1]
        if not Game.get_player(data.username) then return end
        if string.sub(command,-1) == 'e' then data.command = command..'d' else  data.command = command..'ed' end
        data.reason = data.reason and data.reason ~= '' and data.reason or 'No Reason Required'
        Sync.emit_embedded{
            title='Player '..data.title,
            color=data.colour,
            description='There was a player '..data.command..'.',
            ['Player:']='<<inline>>'..data.username,
            ['By:']='<<inline>>'..data.by,
            ['Reason:']=data.reason
        }
    end
end)

-- Module Return
return ThisModule