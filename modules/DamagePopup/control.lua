--- When a entibty is damaged y a player it will show how much damage you've dealth, When a player gets attacked by a entity it will popup the player's health in color.
-- @module DamagePopup@4.0.0
-- @author badgamernl
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais DamagePopup 

-- Module Require
local Color = require('FactorioStdLib.Color@^0.8.0')

local DamagePopup = {}

Event.register(defines.events.on_entity_damaged, function(event)
  local entity = event.entity
  local cause = event.cause
  local damage = event.original_damage_amount
  local health = entity.health
  -- local pre_attack_health = health + damage -- Didn't use it after all, maybe usefull later

  local color = defines.textcolor.crit

  if entity.name == 'player' then
    if health > 100 then
      if health > 200 then
        color = defines.textcolor.low
      else
        color = defines.textcolor.med
      end
    end
    entity.surface.create_entity{
      name="flying-text",
      color=color,
      text=math.floor(health),
      position=entity.position
    }
  elseif cause and cause.name == 'player' then
    entity.surface.create_entity{
      name="flying-text",
      color=defines.textcolor.med,
      text='-'..math.floor(damage), -- cooldude2606 added floor for damage ammount
      position=entity.position
    }
  end
end)

return DamagePopup