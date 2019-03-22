local Commands = require 'expcore.commands'
require 'config.command_parse_general'
require 'config.command_auth_admin'

local function teleport(from_player,to_player)
    local surface = to_player.surface
    local position = surface.find_non_colliding_position('player',to_player.position,32,1)
    if not position then return false end -- return false if no new position
    if from_player.driving then from_player.driving = false end -- kicks a player out a vehicle if in one
    from_player.teleport(position,surface)
    return true
end

Commands.new_command('teleport','Teleports a player to another player.')
:add_param('from_player',false,'player-alive') -- player that will be teleported, must be alive
:add_param('to_player',false,'player-online') -- player to teleport to, must be online (if dead goes to where they died)
:add_alias('tp')
:add_tag('admin_only',true)
:register(function(player,from_player,to_player,raw)
    if from_player.index == to_player.index then
        -- return if attempting to teleport to self
        return Commands.error{'exp-commands.tp-to-self'}
    end
    if not teleport(from_player,to_player) then
        -- return if the teleport failed
        return Commands.error{'exp-commands.tp-no-position-found'}
    end
end)

Commands.new_command('bring','Teleports a player to you.')
:add_param('player',false,'player-alive') -- player that will be teleported, must be alive
:add_tag('admin_only',true)
:register(function(player,from_player,raw)
    if from_player.index == player.index then
        -- return if attempting to teleport to self
        return Commands.error{'exp-commands.tp-to-self'}
    end
    if not teleport(from_player,player) then
        -- return if the teleport failed
        return Commands.error{'exp-commands.tp-no-position-found'}
    end
end)

Commands.new_command('goto','Teleports you to a player.')
:add_param('player',false,'player-online') -- player to teleport to, must be online (if dead goes to where they died)
:add_alias('tp-me','tpme')
:add_tag('admin_only',true)
:register(function(player,to_player,raw)
    if to_player.index == player.index then
        -- return if attempting to teleport to self
        return Commands.error{'exp-commands.tp-to-self'}
    end
    if not teleport(player,to_player) then
        -- return if the teleport failed
        return Commands.error{'exp-commands.tp-no-position-found'}
    end
end)