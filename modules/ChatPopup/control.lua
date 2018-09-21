--- Creates flying text above player when they send a message.
-- @module ChatPopup@4.0.0
-- @author badgamernl
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ChatPopup 

-- Module Require
local Game = require('FactorioStdLib.Game@^0.8.0')
local Color = require('FactorioStdLib.Color@^0.8.0')

local ChatPopup = {}

function ChatPopup.sendFlyingText(player, text)
	local _player = Game.get_player(player)
	if not _player then return end
	-- Split long text in chunks
	local chunkSize = 40
	local chunks = {}
	for i=1, #text, chunkSize do
		chunks[#chunks+1] = text:sub(i,i+chunkSize - 1)
	end
  -- Itterate over text chunks and create them as floating text centered above the player
  -- Disabled false centering because of not being able to disable scaling: (1 / 7.9 * #value)
	for i,value in ipairs(chunks) do
		_player.surface.create_entity{
			name="flying-text",
			color=_player.chat_color,
			text=value,
			position={_player.position.x, _player.position.y-(2 - (1 * i))}
		}
	end
end

Event.register(defines.events.on_console_chat, function(event)
  local player = game.players[event.player_index]
  if not player then return end
  if not event.message then return end
  
  -- Send message player send to player itself
  local message = player.name .. ': ' .. event.message
  ChatPopup.sendFlyingText(player, message)

  -- parse message for players and if it includes player, send him a notification that he has been mentioned in the chat
  local player_message = event.message:lower():gsub("%s+", "")

  for i,_player in ipairs(game.connected_players) do
    if _player.index ~= player.index then
      if player_message:match(_player.name:lower()) then
        ChatPopup.sendFlyingText(_player, 'You\'ve been mentioned by: ' ..player.name .. ' in chat!')
      end
    end
  end
  
end)

return ChatPopup