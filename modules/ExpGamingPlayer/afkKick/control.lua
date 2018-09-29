--- A full ranking system for factorio.
-- @module ExpGamingPlayer.playerInfo
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Game = require('FactorioStdLib.Game')
local Gui = require('ExpGamingCore.Gui')
local Role -- hanndled on load
local Sync -- hanndled on load

function get_allowed_afk_time(player)
    local role
    if Role then role = Role.get_highest(player)
    else if player.admin then return else rank = Role.meta.default end end
    local count = #game.connected_players
    local base = role.index or false
    if not base then return false end
    return (10/base)*count
end

script.on_event(defines.events.on_tick,function(event)
    if (game.tick%3600) ~= 0 then return end
    for _,player in pairs(game.connected_players) do
        local afk = #game.connected_players < 3 and 10 or get_allowed_afk_time(player)
        if afk then
            if player.afk_time > afk*3600 then game.kick_player(player,'AFK For Too Long ('..math.floor(afk)..' Minutes)') end
        end
    end
end)

return {
    get_allowed_afk_time=get_allowed_afk_time,
    on_init=function(self)
        if loaded_modules['ExpGamingCore.Role'] then Role = require('ExpGamingCore.Role') end
        if loaded_modules['ExpGamingCore.Sync'] then Sync = require('ExpGamingCore.Sync') end
        if loaded_modules['ExpGamingCore.Server'] then require(module_path..'/src/server',Sync) end
    end
}