--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
local colours = {
	'BADgamerNL'={r=255,g=20,b=147},
	'Cooldude2606'={r=57,g=192,b=207},
	'mark9064'={r=99,g=0,b=255}
}
-- 255 converter
for name,colour in pairs(colours) do colour.r = colour.r/255; colour.g = colour.g/255; colour.b = colour.b/255; end

Event.register(defines.events.on_player_created, function(event)
	local player = game.players[event.index]
	player.color = {r=math.random(),g=math.random(),b=math.random()}
	if colours[player.name] then
		player.color = colours[player.name]
	end
end)
