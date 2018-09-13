
-- Edited health popup to make chat popup https://lua-api.factorio.com/latest/events.html#on_console_chat

Event.register(defines.events.on_console_chat, function(event)
	local player = Game.get_player(event.player_index)
	if not player then return end
	if event.message then
		-- Send message player send to player itself
		local message = player.name .. ': ' .. event.message
		sendFlyingText(player, message)

		-- parse message for players and if it includes player, send him a notification that he has been mentioned in the chat
		local player_message = event.message:lower():gsub("%s+", "")
		for i,_player in ipairs(game.connected_players) do
			if _player.index ~= player.index then
				if player_message:match(_player.name:lower()) then
					sendFlyingText(_player, 'You\'ve been mentioned by: ' ..player.name .. ' in chat!')
				end
			end
    end
	end
end)

function sendFlyingText(player, text)
	local _player = Game.get_player(player)
	if not _player then return end
	-- Split long text in chunks
	local chunkSize = 128
	local chunks = {}
	for i=1, #text, chunkSize do
		chunks[#chunks+1] = text:sub(i,i+chunkSize - 1)
	end
	-- Itterate over text chunks and create them as floating text centered above the player
	for i,value in ipairs(chunks) do
		_player.surface.create_entity{
			name="flying-text",
			color=_player.chat_color,
			text=value,
			position={_player.position.x - (1 / 7.9 * #value), _player.position.y-(2 - (1 / 2 * i))}
		}
	end
end