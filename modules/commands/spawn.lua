--[[-- Commands Module - Spawn
    - Adds a command that allows players to teleport to their spawn point
    @commands Spawn
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local Roles = require 'expcore.roles' --- @dep expcore.roles

local function teleport(player)
    local surface = player.surface
    local spawn = player.force.get_spawn_position(surface)
    local position = surface.find_non_colliding_position('character', spawn, 32, 1)
    if not position then return false end
    if player.driving then player.driving = false end -- kicks a player out a vehicle if in one
    player.teleport(position, surface)
    return true
end

--- Teleport to spawn
-- @command go-to-spawn
-- @tparam[opt=self] LuaPlayer player the player to teleport to their spawn point
Commands.new_command('go-to-spawn', 'Teleport to spawn')
:add_param('player', true, 'player-role-alive')
:set_defaults{
    player=function(player)
        if player.connected and player.character and player.character.health > 0 then
            return player
        end
    end
}
:add_alias('spawn', 'tp-spawn')
:register(function(player, action_player)
    if not action_player then
        return Commands.error{'expcom-spawn.unavailable'}
    elseif action_player == player then
        if not teleport(player) then
            return Commands.error{'expcom-spawn.unavailable'}
        end
    elseif Roles.player_allowed(player, 'command/go-to-spawn/always') then
        if not teleport(action_player) then
            return Commands.error{'expcom-spawn.unavailable'}
        end
    else
        return Commands.error{'expcore-commands.unauthorized'}
    end
end)