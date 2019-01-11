--- Adds a better method of player starting items based on production levels.
-- @module AdvancedStartingItems@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alias ThisModule

-- Local Variables
local items = {
	['iron-plate']=function(player,made) if tick_to_min(game.tick) < 5 then return 8 else return (made*10)/math.pow(tick_to_min(game.tick),2) end end,
	['copper-plate']=function(player,made) if tick_to_min(game.tick) < 5 then return 0 else return (made*8)/math.pow(tick_to_min(game.tick),2) end end,
	['electronic-circuit']=function(player,made) if tick_to_min(game.tick) < 5 then return 0 else return (made*6)/math.pow(tick_to_min(game.tick),2) end end,
	['iron-gear-wheel']=function(player,made) if tick_to_min(game.tick) < 5 then return 0 else return (made*6)/math.pow(tick_to_min(game.tick),2) end end,
	['steel-plate']=function(player,made) if tick_to_min(game.tick) < 5 then return 0 else return(made*4)/math.pow(tick_to_min(game.tick),2) end end,
	['pistol']=function(player,made) if player.force.item_production_statistics.get_input_count('submachine-gun') > 5 then return 0 else return 1 end end,
	['submachine-gun']=function(player,made) if made > 5 then return 1 else return 0 end end,
	['firearm-magazine']=function(player,made) if player.force.item_production_statistics.get_input_count('piercing-rounds-magazine') > 100 then return 0 else return 10 end end,
	['piercing-rounds-magazine']=function(player,made) if made > 100 then return 10 else return 0 end end,
	['light-armor']=function(player,made) if made > 5 and player.force.item_production_statistics.get_input_count('heavy-armor') <= 5 then return 1 else return 0 end end,
	['heavy-armor']=function(player,made) if made > 5 then return 1 else return 0 end end,
	['burner-mining-drill']=function(player,made) if tick_to_min(game.tick) < 5 then return 4 else return 0 end end,
	['stone-furnace']=function(player,made) if tick_to_min(game.tick) < 5 then return 4 else return 0 end end,
	['iron-axe']=function(player,made) if made > 5 and player.force.item_production_statistics.get_input_count('steel-axe') <= 5 then return 1 else return 0 end end,
	['steel-axe']=function(player,made) if made > 5 then return 1 else return 0 end end
}

-- Module Define
local module_verbose = false
local ThisModule = {}

-- Event Handlers Define
script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    if event.player_index == 1 then
        player.force.friendly_fire = false
        game.map_settings.enemy_expansion.enabled = false
        player.force.chart(player.surface, {{player.position.x - 400, player.position.y - 400}, {player.position.x + 400, player.position.y + 400}})
    end
    for item,count in pairs(items) do
        if type(count) == 'function' then count = math.floor(count(player,player.force.item_production_statistics.get_input_count(item))) end
        if count > 0 then player.insert{name=item, count=count} end
    end
end)

-- Module Return
return ThisModule