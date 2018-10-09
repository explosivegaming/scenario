--- A full ranking system for factorio.
-- @module ExpGamingPlayer.afkKick@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Game = require('FactorioStdLib.Game@^0.8.0')
local Gui = require('ExpGamingCore.Gui@^4.0.0')
local Role -- ExpGamingCore.Role@^4.0.0
local Sync -- ExpGamingCore.Sync@^4.0.0

local function get_allowed_afk_time(player)
    local role
    if Role then role = Role.get_highest(player)
    else if player.admin then return else role = Role.meta.default end end
    local count = #game.connected_players
    local base = role.index or false
    if not base then return false end
    return (Role.meta.count/base)*count
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

return setmetatable({
    get_allowed_afk_time=get_allowed_afk_time,
    on_init=function(self)
        if loaded_modules['ExpGamingCore.Role@^4.0.0'] then Role = require('ExpGamingCore.Role@^4.0.0') end
        if loaded_modules['ExpGamingCore.Sync@^4.0.0'] then Sync = require('ExpGamingCore.Sync@^4.0.0') end
        if loaded_modules['ExpGamingCore.Server@^4.0.0'] then require(module_path..'/src/server',Sync,self) end
    end
},{__call=function(self,...) self.get_allowed_afk_time(...) end})