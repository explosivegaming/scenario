--[[-- Core Module - Store
    - Adds an easy way to store and watch for updates to a value
    @core Store
    @alias Store

    @usage
-- The data store module is designed to be an alterative way to store data in the global table
-- each piece of data is stored at a location and optional key of that location
-- it is recomented that you use a local varible to store the location
local scenario_difficuly = Store.uid_location()
local team_scores = 'team-scores'

-- Setting and getting data is then as simple as
-- note that when storing a table you must use Store.update
Store.set(scenario_difficuly,'Hard')
Store.set(team_scores,game.player.force.name,20)

Store.get(scenario_difficuly) -- returns 'Hard'
Store.get(team_scores,game.player.force.name) -- returns 20

Store.update(team_scores,game.player.force.name,function(value,key)
    return value + 10 -- add 10 to the score
end)

-- The reason for using stores over global is the abilty to watch for updates
-- for stores to work you must register them, often at the end of the file
Store.register(scenario_difficuly,function(value)
    game.print('Scenario difficulty has been set to: '..value)
end)

Store.register(team_scores,function(value,key)
    game.print('Team '..key..' now has a score of '..value)
end)

-- This can be very powerful when working with data that can be changed for a number of locations
-- with this module you can enable any location to output its changes to a file
-- say we wanted team scores to be synced across servers or between saves
-- although you will need to set up a method of storing the data outside the game
Store.register(team_scores,true,function(value,key)
    game.print('Team '..key..' now has a score of '..value)
end)

]]

local Global = require 'utils.global' --- @dep utils.global
local Event = require 'utils.event' --- @dep utils.event
local table_keys,write_json,get_file_path = ext_require('expcore.common','table_keys','write_json','get_file_path') --- @dep expcore.common
local Token = require 'utils.token' --- @dep utils.token

local Store = {
    registered={},
    synced={},
    callbacks={},
    events = {
        on_value_changed=script.generate_event_name()
    }
}

local store_data = {}
Global.register(Store.data,function(tbl)
    store_data = tbl
end)

local function error_not_table(value)
    if type(value) ~= 'table' then
        error('Location is not a table can not use key locations',3)
    end
end

--- Registers a new location with an update callback which is triggered when the value updates
-- @tparam[opt] string location string a unique that points to the data, string used rather than token to allow migration
-- @tparam[opt=false] boolean synced when true will output changes to a file so it can be synced
-- @tparam[opt] function callback when given the callback will be automatically registered to the update of the value
-- @treturn string the location that is being used
function Store.register(location,synced,callback)
    if _LIFECYCLE ~= _STAGE.control then
        return error('Can only be called during the control stage', 2)
    end

    if type(location) ~= 'string' then
        callback = synced
        synced = location
    end

    if type(synced) ~= 'boolean' then
        callback = synced
    end

    location = type(location) == 'string' and location or Store.uid_location()

    if Store.registered[location] then
        return error('Location '..location..' is already registered by '..Store.registered[location], 2)
    end

    Store.registered[location] = get_file_path(1)
    Store.synced[location] = synced and true or nil
    Store.callbacks[location] = callback or nil

    return location
end

--- Gets the value stored at a location, this location must be registered
-- @tparam string location the location to get the data from
-- @tparam[opt] string key the key location if used
-- @treturn any the data which was stored at the location
function Store.get(location,key)
    if not Store.registered[location] then
        return error('Location is not registered', 2)
    end

    local data = store_data[location]
    if key and data then
        error_not_table(data)
        return data[key]
    end

    return data
end

--- Sets the value at a location, this location must be registered
-- @tparam string location the location to set the data to
-- @tparam[opt] string key the key location if used
-- @tparam any value the new value to set at the location, value may be reverted if there is a watch callback, cant be nil
-- @tparam[opt=false] boolean from_sync set this true to avoid an output to the sync file
-- @treturn boolean true if it was successful
function Store.set(location,key,value,from_sync)
    if not Store.callbacks[location] then
        return error('Location is not registered', 2)
    end

    if key == nil or value == nil then
        value = key or value
        key = nil
    end

    if key then
        local data = store_data[location]
        if not data then
            data = {}
            store_data[location] = data
        end
        error_not_table(data)
        data[key] = value
    else
        store_data[location] = value
    end

    script.raise_event(Store.events.on_value_changed,{
        tick=game.tick,
        location=location,
        key=key,
        value=value,
        from_sync=from_sync or false
    })

    return true
end

--- Allows for updating a value based on the current value; only valid way to change tables in a store
-- @tparam string location the location to set the data to
-- @tparam[opt] string key the key location if required
-- @tparam[opt] function update_callback the function called to update the value stored, rtn value to set new value
function Store.update(location,key,update_callback,...)
    local value = Store.get(location,key)

    local arg1
    if type(key) == 'function' then
        arg1 = update_callback
        update_callback = key
        key = nil
    end

    local rtn
    if update_callback and type(update_callback) == 'function' then
        rtn = update_callback(value,key,arg1,...)
    end

    if rtn then
        Store.set(location,key,rtn)
    else
        script.raise_event(Store.events.on_value_changed,{
            tick=game.tick,
            location=location,
            key=key,
            value=value,
            from_sync=false
        })
    end

end

--- Allows for updating all values at a location based on the current value; only valid way to change tables in a store
-- @tparam string location the location to set the data to
-- @tparam[opt] function update_callback the function called to update the value stored
function Store.update_all(location,update_callback,...)
    local data = Store.get(location)

    error_not_table(data)

    for key,value in pairs(data) do
        local rtn
        if update_callback and type(update_callback) == 'function' then
            rtn = update_callback(value,key,...)
        end

        if rtn then
            Store.set(location,key,rtn)
        else
            script.raise_event(Store.events.on_value_changed,{
                tick=game.tick,
                location=location,
                key=key,
                value=value,
                from_sync=false
            })
        end
    end

end

--- Sets the value at a location to nil, this location must be registered
-- @tparam string location the location to set the data to
-- @tparam[opt] string key the key location if used
-- @tparam[opt=false] boolean from_sync set this true to avoid an output to the sync file
-- @treturn boolean true if it was successful
function Store.clear(location,key,from_sync)
    if not Store.callbacks[location] then
        return error('Location is not registered', 2)
    end

    if key then
        local data = store_data[location]
        if not data then return end
        error_not_table(data)
        data[key] = nil
    else
        store_data[location] = nil
    end

    script.raise_event(Store.events.on_value_changed,{
        tick=game.tick,
        location=location,
        key=key,
        from_sync=from_sync or false
    })

    return true
end

--- Gets all non nil keys at a location, keys can be added and removed during runtime
-- this is similar to Store.get but will always return a table even if it is empty
-- @tparam string location the location to get the keys of
-- @treturn table a table containing all the keys names
function Store.get_keys(location)
    local data = Store.get(location)
    return type(data) == 'table' and table_keys(data) or {}
end

--- Check for if a location is registered
-- @tparam string location the location to test for
-- @treturn boolean true if registered
function Store.is_registered(location)
    return Store.registered[location]
end

--- Returns a unique name that can be used for a store
-- @treturn string a unique name
function Store.uid_location()
    return tostring(Token.uid())
end

-- Handles syncing
Event.add(Store.events.on_value_changed,function(event)
    if Store.callbacks[event.location] then
        Store.callbacks[event.location](event.value,event.key)
    end

    if not event.from_sync and Store.synced[event.location] then
        write_json('log/store.log',{
            tick=event.tick,
            location=event.location,
            key=event.key,
            value=event.value,
        })
    end
end)

return Store