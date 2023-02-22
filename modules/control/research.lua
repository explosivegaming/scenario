local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.research' --- @dep config.research

local function research_notification(event)
    game.print{'[technology=' .. event.research.name .. '][color=255, 255, 255] Researched Complete - ' .. event.research.name .. '-' .. level .. '[/color]'}
end

if config.enabled then
    Event.add(defines.events.on_research_finished, research_notification)
end
