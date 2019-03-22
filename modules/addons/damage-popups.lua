--- Displays the amount of dmg that is done by players to entities
-- also shows player health when a player is attacked
local Game = require 'utils.game'
local Event = require 'utils.event'
local config = require 'config.popup_messages'

Event.add(defines.events.on_entity_damaged, function(event)
    local entity = event.entity
    local cause = event.cause
    local damage = event.original_damage_amount
    local health = entity.health
    local health_percentage = entity.get_health_ratio()
    local text_colour = {r=1-health_percentage,g=health_percentage,b=0}

    -- Checks if its a player and show player health is enabled
    if entity.name == 'player' and config.show_player_health then
        Game.print_player_floating_text(entity.index,{'damage-popup.player-health',health},text_colour)
    end

    -- Checks if the source was a player and the entity was not a player
    if entity.name ~= 'player' and cause and cause.name == 'player' and config.show_player_damage then
        Game.print_floating_text(entity.surface,entity.position,{'damage-popup.player-damage',damage},text_colour)
    end

end)