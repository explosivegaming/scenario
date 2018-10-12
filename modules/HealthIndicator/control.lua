--- In game text float to desplay health to other players.
-- @module HealthIndicator@1.0.1
-- @author Ps7cho (converted by Cooldude2606)
-- @license https://opensource.org/licenses/MIT
-- @alais ThisModule 

-- Module Require
local Game = require('FactorioStdLib.Game@^0.8.0')

-- Local Varibles
local green = 200 -- above this makes text green
local yellow = 100 -- above this makes text yellow

-- Module Define
local module_verbose = false
local ThisModule = {}

-- Global Define
local global = global()

-- Event Handlers Define
script.on_event(defines.events.on_entity_damaged, function(event)
	if event.entity.name ~= 'player' then return end
  	local player = Game.get_player(event.entity.player)
	if player.character then
		if player.character.health == nil then return end
		local index = player.index
		local health = math.ceil(player.character.health)
		if global[index] == nil then global[index] = health end
		if global[index] ~= health then
			if health < global[index] then
				local text = health..' (-'..math.floor(event.final_damage_amount)..')'
				if health > green then
					player.surface.create_entity{name="flying-text", color={b = 0.2, r= 0.1, g = 1, a = 0.8}, text=text, position= {player.position.x, player.position.y-2}}
				elseif health > yellow then
					player.surface.create_entity{name="flying-text", color={r = 1, g = 1, b = 0}, text=text, position= {player.position.x, player.position.y-2}}
				else
					player.surface.create_entity{name="flying-text", color={b = 0.1, r= 1, g = 0, a = 0.8}, text=text, position= {player.position.x, player.position.y-2}}
				end
			end
			global[index] = health
		end
    end
end)

-- Module Return
return ThisModule 