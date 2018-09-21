--- A full ranking system for factorio.
-- @module ExpGamingCommands.bonus@^4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local global = global{}
local Game = require('FactorioStdLib.Game@^0.8.0')

-- these are the settings which are changed with scale being as +100%
local settings = {
    character_mining_speed_modifier=3,
    character_crafting_speed_modifier=3,
    character_running_speed_modifier=3,
    character_build_distance_bonus=20,
    character_reach_distance_bonus=20,
    character_inventory_slots_bonus=200
}

--- Allows a player to set there bonus
-- @command bonus
-- @param bonus the amount of bonus there will get
commands.add_command('bonus', 'Set your player bonus (default is 20, guest has 0)', {
    ['bonus'] = {true,'number-range-int',-1,50} -- -1 < math.floor(bonus) <= 50
}, function(event,args)
    local player = Game.get_player(event)
    local bonus = args.bonus
    for key,setting in pairs(settings) do player[key] = setting*math.floor(bonus)*0.01 end
    global[player.index]=bonus
    player_return('Bonus set to: '..math.floor(bonus)..'%')
end).default_admin_only = true

script.on_event(defines.events.on_player_respawned,function(event)
    local player = Game.get_player(event)
    local bonus = global[player.index]
    if bonus then
        for _,setting in pairs(settings) do player[key] = setting*math.floor(bonus)*0.01 end
    end
end)

-- overided by ExpGamingCore.Ranking if present
script.on_event(defines.events.on_pre_player_died,function(event)
    local player = Game.get_player(event)
    if player.admin then
        player.ticks_to_respawn = 120
        -- manually dispatch death event because it is not fired when ticks_to_respawn is set pre death
        Event.dispatch{
            name=defines.events.on_player_died,
            tick=event.tick,
            player_index=event.player_index,
            cause = event.cause
        }
    end
end)

return {
    on_init= function(self)
        if loaded_modules['ExpGamingCore.Ranking@^4.0.0'] then
            local Ranking = require('ExpGamingCore.Ranking@^4.0.0')
            -- instant respawn
            script.on_event(defines.events.on_pre_player_died,function(event)
                local player = Game.get_player(event)
                if Ranking.get_rank(player):allowed('bonus-respawn') then
                    player.ticks_to_respawn = 120
                    -- manually dispatch death event because it is not fired when ticks_to_respawn is set pre death
                    Event.dispatch{
                        name=defines.events.on_player_died,
                        tick=event.tick,
                        player_index=event.player_index,
                        cause = event.cause
                    }
                end
            end)
            -- either clears or adds default when rank changed
            script.on_event(defines.events.rank_change,function(event)
                local player = Game.get_player(event)
                if event.new_rank:allowed('bonus') then
                    for _,setting in pairs(settings) do player[key] = setting*0.2 end
                    global[player.index]=20
                else
                    for _,setting in pairs(settings) do player[key] = 0 end
                    global[player.index]=nil
                end
            end)
        end
    end
}