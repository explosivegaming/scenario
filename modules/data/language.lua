--- Stores the language used to join the server
-- @data Language

local Event = require 'utils.event' ---@dep utils.event
local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data
local LocalLanguage = PlayerData.Settings:combine('LocalLanguage')
LocalLanguage:set_default("Unknown")

--- Creates translation request on_load of a player
LocalLanguage:on_load(function(player_name, language)
  local player = game.players[player_name]
  player.request_translation("language.local-language")
end)

--- Resolves translation request for language setting
Event.add(defines.events.on_string_translated, function(event)
  -- Check if the translation request was for language setting
  if event.localised_string ~= "language.local-language" then 
    return 
  end

  -- Check if the translation request was succesful
  if not event.translated then
    game.print("Could not detect your language settings")
    -- Raise error
    return
  end

  -- Change LocalLanguage value for the player to the recognized one
  local player = game.players[event.player_index]
  local language = {event.result}
  LocalLanguage:set(player, language)
end)