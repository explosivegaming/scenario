--[[-- Commands Module - Bonus
    - Adds a command that allows players to have increased stats
    @commands Bonus
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local Game = require 'utils.game' --- @dep utils.game
local Store = require 'expcore.store' --- @dep expcore.store
local config = require 'config.bonuses' --- @dep config.bonuses
require 'config.expcore.command_general_parse'

-- Store bonus percentages keyed by player name
local bonus_store = Store.register(function(player)
    return player.name
end)

-- Apply a bonus amount to a player
local function apply_bonus(player,amount)
    if not amount then return end
    for bonus,min_max in pairs(config) do
        local increase = min_max[2]*amount
        player[bonus] = min_max[1]+increase
    end
end

--- Changes the amount of bonus you receive
-- @command bonus
-- @tparam number amount range 0-50 the percent increase for your bonus
Commands.new_command('bonus','Changes the amount of bonus you receive')
:add_param('amount','integer-range',0,50)
:register(function(player,amount)
    local percent = amount/100
    Store.set(bonus_store,player,percent)
    Commands.print{'expcom-bonus.set',amount}
    Commands.print({'expcom-bonus.wip'},'orange')
end)

-- When store is updated apply new bonus to the player
Store.watch(bonus_store,function(value,category)
    local player = Game.get_player_from_any(category)
    apply_bonus(player,value)
end)

-- When a player respawns re-apply bonus
Event.add(defines.events.on_player_respawned,function(event)
    local player = Game.get_player_by_index(event.player_index)
    local value = Store.get(bonus_store,player)
    apply_bonus(player,value)
end)

-- When a player dies allow them to have instant respawn
Event.add(defines.events.on_player_died,function(event)
    local player = Game.get_player_by_index(event.player_index)
    if Roles.player_has_flag(player,'instance-respawn') then
        player.ticks_to_respawn = 120
    end
end)

-- Remove bonus if a player no longer has access to the command
local function role_update(event)
    local player = Game.get_player_by_index(event.player_index)
    if not Roles.player_allowed(player,'command/bonus') then
        Store.clear(bonus_store,player)
    end
end

Event.add(Roles.events.on_role_assigned,role_update)
Event.add(Roles.events.on_role_unassigned,role_update)

return bonus_store