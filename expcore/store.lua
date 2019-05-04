--- A system which stores peristent data and makes it easy to sync updates between changes
local Global = require 'utils.global'
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
    if location.type == Store.types.game then
        Store.data[location.location] = sub_location
    elseif location.type ~= Store.types['local'] and location.type ~= Store.types.global then
        Store.data[location.location][sub_location] = value
    end
    location.update_callback(sub_location,value,...)
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
    if location.type == Store.types.game then
        return Store.data[location.location]
    elseif location.type ~= Store.types['local'] and location.type ~= Store.types.global then
        return Store.data[location.location][sub_location]
    end
end

return Store