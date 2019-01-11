--- Assigns random colours to players (larger range than default) and allows predefined colours for users.
-- @module PlayerAutoColor@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alias ThisModule

-- Module Require
local Color = require('FactorioStdLib.Color')

-- Module Define
local module_verbose = false
local ThisModule = {}

-- Global Define
local global = global{
	BADgamerNL={r=255,g=20,b=147},
	arty714={r=150,g=68,b=161},
	Cooldude2606={r=57,g=192,b=207},
	mark9064={r=99,g=0,b=255},
	eissturm={r=25,g=25,b=112},
	Sakama={r=20,g=213,b=80},
	Sakama={r=20,g=213,b=80},
	freek18={r=50,g=0,b=255},
	aldldl={r=0,g=131,b=255},
	NAD4X4={r=135,g=206,b=250},
	cydes={r=82,g=249,b=155},
	UUBlueFire={r=0,g=204,b=255}
}

-- Event Handlers Define
script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
	local colours = table.keys(defines.color)
	player.color = defines.color.black
	while player.color.r == defines.color.black.r and player.color.g == defines.color.black.g and player.color.b == defines.color.black.b 
	or player.color.r == defines.color.white.r and player.color.g == defines.color.white.g and player.color.b == defines.color.white.b  do
		player.color = defines.color[colours[math.random(#colours)]]
		if global[player.name] then
			local c = global[player.name]
			player.color = Color.from_rgb(c.r,c.g,c.b)
		end
	end
	player.chat_color = player.color
end)

-- Module Return
return ThisModule