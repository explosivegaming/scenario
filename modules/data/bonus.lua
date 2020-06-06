--[[-- Commands Module - Bonus
    - Adds a command that allows players to have increased stats
    @data Bonus
]]

local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.bonuses' --- @dep config.bonuses
local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

--- Stores the bonus for the player
local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data
local PlayerBonus = PlayerData.Settings:combine('Bonus')
PlayerBonus:set_default(0)
PlayerBonus:set_metadata{
    permission = 'command/bonus',
    stringify = function(value)
        if not value or value == 0 then return 'None set' end
        return (value*100)..'%'
    end
}

--- Apply a bonus amount to a player
local function apply_bonus(player, amount)
    if not amount then return end
    for bonus, min_max in pairs(config) do
        local increase = min_max[2]*amount
        player[bonus] = min_max[1]+increase
    end
end

--- When store is updated apply new bonus to the player
PlayerBonus:on_update(function(player_name, player_bonus)
    apply_bonus(game.players[player_name], player_bonus or 0)
end)

--- Changes the amount of bonus you receive
-- @command bonus
-- @tparam number amount range 0-50 the percent increase for your bonus
Commands.new_command('bonus', 'Changes the amount of bonus you receive')
:add_param('amount', 'integer-range', 0,50)
:register(function(player, amount)
    local percent = amount/100
    PlayerBonus:set(player, percent)
    Commands.print{'expcom-bonus.set', amount}
    Commands.print({'expcom-bonus.wip'}, 'orange')
end)

--- When a player respawns re-apply bonus
Event.add(defines.events.on_player_respawned, function(event)
    local player = game.players[event.player_index]
    apply_bonus(player, PlayerBonus:get(player))
end)

--- When a player dies allow them to have instant respawn
Event.add(defines.events.on_player_died, function(event)
    local player = game.players[event.player_index]
    if Roles.player_has_flag(player, 'instance-respawn') then
        player.ticks_to_respawn = 120
    end
end)

--- Remove bonus if a player no longer has access to the command
local function role_update(event)
    local player = game.players[event.player_index]
    if not Roles.player_allowed(player, 'command/bonus') then
        PlayerBonus:remove(player)
    end
end

Event.add(Roles.events.on_role_assigned, role_update)
Event.add(Roles.events.on_role_unassigned, role_update)