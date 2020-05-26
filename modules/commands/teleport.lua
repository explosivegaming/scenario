--[[-- Commands Module - Teleport
    - Adds a command that allows players to teleport to other players
    @commands Teleport
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

local function teleport(from_player, to_player)
    local surface = to_player.surface
    local position = surface.find_non_colliding_position('character', to_player.position, 32, 1)
    if not position then return false end -- return false if no new position
    if from_player.driving then from_player.driving = false end -- kicks a player out a vehicle if in one
    from_player.teleport(position, surface)
    return true
end

--- Teleports a player to another player.
-- @command teleport
-- @tparam LuaPlayer from_player the player that will be teleported, must be alive
-- @tparam LuaPlayer to_player the player to teleport to, must be online (if dead goes to where they died)
Commands.new_command('teleport', 'Teleports a player to another player.')
:add_param('from_player', false, 'player-alive')
:add_param('to_player', false, 'player-online')
:add_alias('tp')
:set_flag('admin_only')
:register(function(_, from_player, to_player)
    if from_player.index == to_player.index then
        -- return if attempting to teleport to self
        return Commands.error{'expcom-tp.to-self'}
    end
    if not teleport(from_player, to_player) then
        -- return if the teleport failed
        return Commands.error{'expcom-tp.no-position-found'}
    end
end)

--- Teleports a player to you.
-- @command bring
-- @tparam LuaPlayer player the player that will be teleported, must be alive
Commands.new_command('bring', 'Teleports a player to you.')
:add_param('player', false, 'player-alive')
:set_flag('admin_only')
:register(function(player, from_player)
    if from_player.index == player.index then
        -- return if attempting to teleport to self
        return Commands.error{'expcom-tp.to-self'}
    end
    if not teleport(from_player, player) then
        -- return if the teleport failed
        return Commands.error{'expcom-tp.no-position-found'}
    end
end)

--- Teleports you to a player.
-- @command goto
-- @tparam LuaPlayer player the player to teleport to, must be online (if dead goes to where they died)
Commands.new_command('goto', 'Teleports you to a player.')
:add_param('player', false, 'player-online')
:add_alias('tp-me', 'tpme')
:set_flag('admin_only')
:register(function(player, to_player)
    if to_player.index == player.index then
        -- return if attempting to teleport to self
        return Commands.error{'expcom-tp.to-self'}
    end
    if not teleport(player, to_player) then
        -- return if the teleport failed
        return Commands.error{'expcom-tp.no-position-found'}
    end
end)