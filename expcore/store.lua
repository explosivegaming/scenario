--- A system which stores peristent data and makes it easy to sync updates between changes

--[[
>>>> What the system is for
    This module is made so that data can be saved easily in global and have data be synced for the player, force or game.
    This means that when the value is updated the callback will be rasied with object which it effects eg when set to force
    type each force will have a stored value and when it changes the force and the new value will be passed to the update callback
    the same can be done for a surface or players. In a sence this is just an easy way to keep data that can be updated at any time
    and not have confilcts with other data; for example force settings changed in a gui.

>>>> How to register a location
    Every location that is used must be registed with an update_callback which will be called when the value is updated, to do this you
    must use Store.register_location and pass a string that referses to the location (must be unqiue) for example 'settings.force' might be
    the location where you store custom settings for a force and 'settings.force.manual_mining_speed_modifier' will be a value for the mining speed.
    Note: these are not connected directly to the objects you need your own way to update the stored value.

    Continuing with this example you would want to have the store_type as 'force' which will mean that sub_location will refer to different
    force names, this way each force will have its own store of data all at the same location. The store_type has two speaial cases: local and
    game (global not yet impimented) where 'local' will not store any data and acts as a reditrect to update_callback and can be used when you
    dont want any persitent data but still have mutiple places where the value will be updated from. 'game' will have only a single stored value
    and is because of this will not have a sub_location.

    Finaly the update_callback is the method which you should use to watch for updates to the value from any source, for all types (apart from the
    2 speaial types listed above) the first param will be the object that it conceners ie the player, force or surface and the second param will be
    the new value that is set. For game and local there is no sub_location and so there is no object that is passed so the first param is the value
    that was set. Note that they may be more args after these which were passed from the set_location call these are for your own use.

    Example:

    Store.register_location('settings.force.manual_mining_speed_modifier','force',function(force,value)
        force.manual_mining_speed_modifier = value
    end)

>>>> When should I use a getter
    Some types of data (such as the mining speed for a force) lend them selfs nicely to using a getter function, where unless a value was set then
    the getter function will be used to get the value for get_location. This is basicly a way to have a default value for the store when no calls
    have been made to set a value.

    Note that using a getter function does not mean the store will listen for updates for the returned value of this function.

    Example:

    Store.register_getter('settings.force.manual_mining_speed_modifier',function(force)
        return force.manual_mining_speed_modifier
    end)

>>>> Getting and setting values
    Once a location is registered you can use the get and set location functions this will allow new values to be set at a location and to retive the current
    or default (via getter if present).

    Example:

    Store.set_location('settings.force.manual_mining_speed_modifier',game.player.force,5)

    Store.get_location('settings.force.manual_mining_speed_modifier',game.player.force)

>>>> Functions:
    Store.register_location(location,store_type,update_callback) --- Registers a new store location
    Store.register_getter(location,get_callback) --- Registers an optional getter funtion that will return a value when the stored value is nil
    Store.set_location(location,sub_location,value,...) --- Sets a new value for a location, will trigger the update callback
    Store.get_location(location,sub_location,allow_invalid_location) --- Gets the value for a location
]]

local Global = require 'utils.global'
local Game = require 'utils.game'
local Enum = ext_require('expcore.common','enum')

local Store = {
    data = {},
    locations = {},
    types = Enum{
        'local', -- no persistent data, only triggers update_callback
        'player', -- each player has they own sub_location
        'force', -- each force has its own sub_location
        'surface', -- each surface has its own sub_location
        'game', -- the entrie game has a single store of data
        'global' -- not yet impimented, data will sync between all servers
    }
}
Global.register(Store.data,function(tbl)
    Store.data = tbl
end)

local function get_sub_location(type,sub_location,value)
    if location.type == Store.types['local'] then
        return nil,sub_location
    elseif location.type == Store.types.player then
        sub_location = Game.get_player_from_any(sub_location)
        if not sub_location then return error('Invalid player for sub_location',3) end
        return sub_location,value
    elseif location.type == Store.types.force then
        sub_location = type(sub_location) == 'table' and type(sub_location.__self) == 'userdata' and sub_location or game.forces[sub_location]
        if not sub_location then return error('Invalid force for sub_location',3) end
        return sub_location,value
    elseif location.type == Store.types.surface then
        sub_location = type(sub_location) == 'table' and type(sub_location.__self) == 'userdata' and sub_location or game.surfaces[sub_location]
        if not sub_location then return error('Invalid surface for sub_location',3) end
        return sub_location,value
    elseif location.type == Store.types.game then
        return nil,sub_location
    elseif location.type == Store.types.glboal then
        return nil,sub_location
    end
end

--- Registers a new store location
-- @tparam location string a unique location string that will hold the data
-- @tparam type string see Store.types
-- @tparam update_callback function the function which will be called with the new value that is set
function Store.register_location(location,store_type,update_callback)
    if Store.locations[location] then
        store_type = Store.locations[location]
        store_type = type(store_type) == 'number' and Store.types(store_type) or store_type
        return error('The location is already registed: '..location..' and is type: '..store_type,2)
    end
    if not Store.type[type] then
        return error('Attempted to set invlid type: '..type..' for location: '..location,2)
    end
    store_type = type(store_type) == 'string' and Store.types(store_type) or store_type
    Store.locations[location] = {
        location=location,
        type=store_type,
        update_callback=update_callback
    }
    if store_type ~= Store.types['local'] and store_type ~= Store.types.global then
        Store.data[location] = {}
    end
end

--- Registers an optional getter funtion that will return a value when the stored value is nil
-- @tparam location string the location to set the data at, must be registed
-- @tparam get_callback function the function that will be called to return the value
function Store.register_getter(location,get_callback)
    if not Store.locations[location] then
        return error('Invalid store location: '..location,2)
    end
    location = Store.locations[location]
    location.get_callback = get_callback
end

--- Sets a new value for a location, will trigger the update callback
-- @tparam location string the location to set the data at, must be registed
-- @tparam[opt] sub_location string a second location value that can be a player's name force name etc
-- @tparam value any the value to be stored, passed via sublocation if sub_location is not required
-- @tparam[opt] ... any any more values that you want to pass to the update callback
function Store.set_location(location,sub_location,value,...)
    if not Store.locations[location] then
        return error('Invalid store location: '..location,2)
    end
    location = Store.locations[location]
    local _sub_location,_value = get_sub_location(type,sub_location,value)
    if _sub_location then
        Store.data[location][_sub_location] = _value
        location.update_callback(_sub_location,_value,...)
    else
        Store.data[location] = _value
        location.update_callback(_value,...)
    end
end

--- Gets the value for a location
-- @tparam location string the location to set the data at, must be registed
-- @tparam[opt] sub_location string a second location value that can be a player's name force name etc
-- @tparam[opt=false] allow_invalid_location boolean when true will not error when location is invalid
-- @treturn any the value found at that location
function Store.get_location(location,sub_location,allow_invalid_location)
    if not Store.locations[location] then
        return not allow_invalid_location and error('Invalid store location: '..location,2) or nil
    end
    location = Store.locations[location]
    local rtn
    if location.type == Store.types.game then
        rtn = Store.data[location.location]
    elseif location.type ~= Store.types['local'] and location.type ~= Store.types.global then
        rtn = Store.data[location.location][sub_location]
    end
    if rtn == nil and location.get_callback then
        sub_location = get_sub_location(location.type,sub_location)
        rtn = location.get_callback(sub_location)
    end
    return rtn
end

return Store