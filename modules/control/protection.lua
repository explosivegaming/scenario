--[[-- Control Module - Protection
    - Controls protected entities
    @control Protection
    @alias Protection
]]

local Global = require 'utils.global' --- @dep utils.global
local Event = require 'utils.event' --- @dep utils.event
local EntityProtection = {}

----- Global Variables -----
--- Variables stored in the global table

local protected_entities = {} -- All entities which are protected
local protected_areas = {} -- All areas which are protected
local repeats = {} -- Stores repeat removals by players

Global.register({
    protected_entities = protected_entities,
    protected_areas = protected_areas,
    repeats = repeats
}, function(tbl)
    protected_entities = tbl.protected_entities
    protected_areas = tbl.protected_areas
    repeats = tbl.repeats
end)

----- Local Functions -----
--- Functions used internally to search and add to the protected array


----- Public Functions -----
--- Functions used to add and remove protected entities

--- Add an entity to the protected list
function EntityProtection.add_entity(entity)

end

--- Remove an entity from the protected list
function EntityProtection.remove_entity(entity)

end

--- Add an area to the protected list
function EntityProtection.add_area(area)

end

--- Remove an area from the protected list
function EntityProtection.remove_area(area)

end

----- Events -----
--- All events registered by this module

Event.add(defines.events.on_player_mined_item, function(event)
    
end)

return EntityProtection