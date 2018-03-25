
-- made by cooldude - we are lazy and we want to always have the same colour, also uses std lib to auto assign random colours

local default_colours = {
	BADgamerNL={r=255,g=20,b=147},
	arty714={r=150,g=68,b=161},
	Cooldude2606={r=57,g=192,b=207},
	mark9064={r=99,g=0,b=255},
	eissturm={r=25,g=25,b=112}
}

Event.register(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
	local colours = table.keys(defines.color)
	player.color = defines.color.black
	while player.color.r == defines.color.black.r and player.color.g == defines.color.black.g and player.color.b == defines.color.black.b do
		player.color = defines.color[colours[math.random(#colours)]]
		if default_colours[player.name] then
			local c = default_colours[player.name]
			player.color = Color.from_rgb(c.r,c.g,c.b)
		end
	end
	player.chat_color = player.color
end)
