--[[-- Commands Module - Bonus
    - Adds a command that allows players to have increased stats
    @data Bonus
]]

local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.bonus' --- @dep config.bonuses
local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

-- Stores the bonus for the player
local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data
local PlayerBonus = PlayerData.Settings:combine('Bonus')
PlayerBonus:set_default(0)
PlayerBonus:set_metadata{
    permission = 'command/bonus',
    stringify = function(value)
        if not value or value == 0 then
            return 'None set'
        end

        return value
    end
}

--- Apply a bonus to a player
local function apply_bonus(player, stage_)
    if not player.character then
        return 
    end

    if stage_ >= 2 then
        if not Roles.player_allowed(player, "bonus-2") then
            stage_ = 0
        end
    elseif stage_ == 1 then
        if not Roles.player_allowed(player, "bonus-1") then
            stage_ = 0
        end
    end

    for k, v in pairs(config) do
        player[config[k].name] = config[k].stage['1'] * stage_
    end
end

--- When store is updated apply new bonus to the player
PlayerBonus:on_update(function(player_name, player_bonus)
    apply_bonus(game.players[player_name], player_bonus or 0)
end)

--- Changes the amount of bonus you receive
-- @command bonus
-- @tparam number amount range 0-10 the increase for your bonus
Commands.new_command('bonus', 'Changes the amount of bonus you receive')
:add_param('amount', 'integer-range', 0, 10)
:register(function(player, amount)
    PlayerBonus:set(player, amount)
    Commands.print{'expcom-bonus.set', amount}
end)

--- When a player respawns re-apply bonus
Event.add(defines.events.on_player_respawned, function(event)
    local player = game.players[event.player_index]
    PlayerBonus:set(player)
end)

--- When a player dies allow them to have instant respawn
Event.add(defines.events.on_player_died, function(event)
    local player = game.players[event.player_index]

    if Roles.player_has_flag(player, 'instant-respawn') then
        player.ticks_to_respawn = 120
    end
end)

--- Remove bonus if a player no longer has access to the command
local function role_update(event)
    local player = game.players[event.player_index]

    -- if not (Roles.player_allowed(player, 'bonus-2') or Roles.player_allowed(player, 'bonus-1')) then
    apply_bonus(player)
end

Event.add(defines.events.on_player_created, role_update)
Event.add(defines.events.on_player_joined_game, role_update)
Event.add(Roles.events.on_role_assigned, role_update)
Event.add(Roles.events.on_role_unassigned, role_update)
