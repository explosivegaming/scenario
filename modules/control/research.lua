local Event = require 'utils.event' --- @dep utils.event
 
local function research_notification(event)
    
    game.print{'[technology=' .. event.research.name .. '][color=255, 255, 255] Researched Complete - ' .. event.research.name .. '-' .. level .. '[/color]'}
end

Event.add(defines.events.on_research_finished, research_notification)