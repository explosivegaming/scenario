local Global = require 'utils.global'
local Event = require 'utils.event'
local Game = require 'utils.game'
local Enum = ext_require('expcore.common','enum')

local Store = {
    data={},
    locations={},
    types = Enum{
        'local', -- data is not stored with any sub_location, updates caused only by set
        'player', -- data is stroed per player, updates caused by watch and set
        'force', -- data is stroed per force, updates caused by watch and set
        'surface', -- data is stroed per surface, updates caused by watch and set
        'game', -- data is stored with any sub_location, updates caused by watch and set
        'global' -- data is stored externaly with any sub_location, updates casued by watch, set and the external source
    }
}
Global.register(Store.data,function(tbl)
    Store.data = table
end)

local function get_sub_location_object(store_type,sub_location)
    if store_type == Store.types.player then
        sub_location = Game.get_player_from_any(sub_location)
        if not sub_location then return error('Invalid player for sub_location',3) end
        return sub_location
    elseif store_type == Store.types.force then
        sub_location = type(sub_location) == 'table' and type(sub_location.__self) == 'userdata' and sub_location or game.forces[sub_location]
        if not sub_location then return error('Invalid force for sub_location',3) end
        return sub_location
    elseif store_type == Store.types.surface then
        sub_location = type(sub_location) == 'table' and type(sub_location.__self) == 'userdata' and sub_location or game.surfaces[sub_location]
        if not sub_location then return error('Invalid surface for sub_location',3) end
        return sub_location
    end
end

local function set_global_location_value(location,sub_location,value)
    -- not yet impimented, this will emit to a file in some way to set the value in an external database
end

function Store.register(location,store_type,getter,setter,no_error)
    if not no_error and Store.locations[location] then
        return error('The location is already registed: '..location,2)
    end
    store_type = type(store_type) == 'string' and Store.types[store_type] or store_type
    Store.locations[location] = {
        location=location,
        store_type=store_type,
        getter=getter,
        setter=setter
    }
end

function Store.set(location,sub_location,value)
    if not Store.locations[location] then
        return error('The location is not registed: '..location)
    end
    location = Store.locations[location]
    local sub_location_object = get_sub_location_object(location.store_type,sub_location)
    if location.store_type ~= Store.types['local'] then
        if not Store.data[location.location] then Store.data[location.location] = {} end
        Store.data[location.location][sub_location] = value
    end
    if location.store_type == Store.types.global then
        set_global_location_value(location.location,value)
    end
    location.setter(sub_location_object or sub_location,value)
end

function Store.get(location,sub_location)
    if not Store.locations[location] then return end
    location = Store.locations[location]
    local sub_location_object = get_sub_location_object(location.store_type,sub_location)
    local rtn = Store.data[location.location][sub_location]
    if rtn == nil then rtn = location.getter(sub_location_object or sub_location) end
    return rtn
end

function Store.check(location,sub_location)
    if not Store.locations[location] then return false end
    location = Store.locations[location]
    local sub_location_object = get_sub_location_object(location.store_type,sub_location)
    local store,getter = Store.data[location.location][sub_location],location.getter(sub_location_object or sub_location)
    if store ~= getter then
        if not Store.data[location.location] then Store.data[location.location] = {} end
        Store.data[location.location][sub_location] = getter
        location.setter(sub_location_object or sub_location,getter)
        return true
    end
    return false
end

Event.on_nth_tick(60,function()
    for _,location in pairs(Store.locations) do
        if location.store_type ~= Store.types['local'] then
            if not Store.data[location.location] then Store.data[location.location] = {} end
            for sub_location,_ in pairs(Store.data[location.location]) do
                Store.check(location,sub_location)
            end
        end
    end
end)

return Store