--- A full ranking system for factorio.
-- @module ExpGamingPlayer.afkKick@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Game = require('FactorioStdLib.Game')
local Role -- ExpGamingCore.Role@^4.0.0
local Sync -- ExpGamingCore.Sync@^4.0.0

local function get_allowed_afk_time(player)
    local player = Game.get_player(player)
    local role = Role and Role.get_highest(player) or {index=1,allow_afk_kick=not player.admin}
    local player_count = #game.connected_players
    local role_count = Role and Role.meta.count or 1
    local role_index = role.allow_afk_kick and role.index or false
    if not base then return false end
    return (role_count/role_index)*count
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
        if loaded_modules['ExpGamingCore.Role'] then Role = require('ExpGamingCore.Role') end
        if loaded_modules['ExpGamingCore.Sync'] then Sync = require('ExpGamingCore.Sync') end
        if loaded_modules['ExpGamingCore.Server'] then require(module_path..'/src/server',{Sync=Sync,self=self}) end
    end
},{__call=function(self,...) return self.get_allowed_afk_time(...) end})