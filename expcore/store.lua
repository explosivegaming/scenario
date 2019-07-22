--- Adds an easy way to store and watch for updates to a value
--[[
>>>> Basic Use
    At the most basic level this allows for the naming of locations to store in the global table, the second feature is that you are
    able to listen for updates of this value, which means that when ever the set function is called it will trigger the update callback.

    This may be useful when storing config values and when they get set you want to make sure it is taken care of, or maybe you want
    to have a value that you can trigger an update of from different places.

    -- this will register a new location called 'scenario.difficulty'
    -- note that setting a start value is optional and we could take nil to mean normal
    Store.register('scenario.difficulty',function(value)
        game.print('The scenario difficulty has be set to: '..value)
    end)

    -- this will set the value in the store to 'hard' and will trigger the update callback which will print a message to the game
    Store.set('scenario.difficulty','hard')

    -- this will return 'hard'
    Store.get('scenario.difficulty')

>>>> Using Children
    One limitation of store is that all locations must be registered to avoid desyncs, to get round this issue "children" can be used.
    When you set the value of a child it does not have its own update callback so rather the "parent" location which has been registered
    will have its update value called with a second param of the name of that child.

    This may be useful when you want a value of each player or force and since you cant register every player at the start you must use
    the players name as the child name.

    -- this will register the location 'scenario.score' where we plan to use force names as the child
    Store.register('scenario.score',function(value,child)
        game.print(child..' now has a score of '..value)
    end)

    -- this will return nil, but will not error as children don't need to be registered
    Store.get('scenario.score','player')

    -- this will set 'player' to have a value of 10 for 'scenario.score' and trigger the game message print
    Store.set('scenario.score','player',10)

    -- this would be the similar to Store.get however this will return the names of all the children
    Store.get_children('scenario.score')

>>>> Using Sync
    There is the option to use synced values which is the same as a normal value however you can combine this with an external script
    which can read the output from 'script-output/log/store.log' and have it send rcon commands back to the game allowing for cross instance
    syncing of values.

    This may be useful when you want to have a value change effect multiple instances or even if you just want a database to store values so
    you can sync data between map resets.

    -- this example will register the location 'statistics.total-play-time' where we plan to use plan names as the child
    -- note that the location must be the same across instances
    Store.register('statistics.total-play-time',true,function(value,child)
        game.print(child..' now has now played for '..value)
    end)

    -- use of set and are all the same as non synced but you should include from_sync as true

>>>> Alternative method
    Some people may prefer to use a variable rather than a string for formating reasons here is an example. Also for any times when
    there will be little external input Store.uid_location() can be used to generate non conflicting locations, uid_location will also
    be used if you give a nil location.

    local store_game_speed =
    Store.register(function(value)
        game.print('The game speed has been set to: '..value)
    end)

]]

local Global = require 'utils.global' --- @dep utils.global
local Event = require 'utils.event' --- @dep utils.event
local table_keys,write_json = ext_require('expcore.common','table_keys','write_json') --- @dep expcore.common
local Token = require 'utils.token' --- @dep utils.token

local Store = {
    data={},
    registered={},
    synced={},
    callbacks={},
    events = {
        on_value_update=script.generate_event_name()
    }
}

Global.register(Store.data,function(tbl)
    Store.data = tbl
end)

local function error_not_table(value)
    if type(value) ~= 'table' then
        error('Location is not a table can not use child locations',3)
    end
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

--- Registers a new location with an update callback which is triggered when the value updates
-- @tparam[opt] string location string a unique that points to the data, string used rather than token to allow migration
-- @tparam[opt] boolean synced when true will output changes to a file so it can be synced
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
        return error('Location is already registered', 2)
    end

    Store.registered[location] = true
    Store.synced[location] = synced and true or nil
    Store.callbacks[location] = callback or nil

    return location
end

--- Gets the value stored at a location, this location must be registered
-- @tparam string location the location to get the data from
-- @tparam[opt] string child the child location if required
-- @tparam[opt=false] boolean allow_unregistered when true no error is returned if the location is not registered
-- @treturn any the data which was stored at the location
function Store.get(location,child,allow_unregistered)
    if not Store.callbacks[location] and not allow_unregistered then
        return error('Location is not registered', 2)
    end

    local data = Store.data[location]
    if child and data then
        error_not_table(data)
        return data[child]
    end

    return data
end

--- Sets the value at a location, this location must be registered
-- @tparam string location the location to set the data to
-- @tparam[opt] string child the child location if required
-- @tparam any value the new value to set at the location, value may be reverted if there is a watch callback, cant be nil
-- @tparam[opt] boolean from_sync set this true to avoid an output to the sync file
-- @treturn boolean true if it was successful
function Store.set(location,child,value,from_sync)
    if not Store.callbacks[location] then
        return error('Location is not registered', 2)
    end

    if child == nil or value == nil then
        value = child or value
        child = nil
    end

    local data = Store.data
    if child then
        data = data[location]
        if not data then
            data = {}
            Store.data[location] = data
        end
        error_not_table(data)
        data[child] = value
    else
        data[location] = value
    end

    script.raise_event(Store.events.on_value_update,{
        tick=game.tick,
        location=location,
        child=child,
        value=value,
        from_sync=from_sync
    })

    return true
end

--- Sets the value at a location to nil, this location must be registered
-- @tparam string location the location to set the data to
-- @tparam[opt] string child the child location if required
-- @tparam[opt] boolean from_sync set this true to avoid an output to the sync file
-- @treturn boolean true if it was successful
function Store.clear(location,child,from_sync)
    if not Store.callbacks[location] then
        return error('Location is not registered', 2)
    end

    local data = Store.data
    if child then
        data = data[location]
        if not data then return end
        error_not_table(data)
        data[child] = nil
    else
        data[location] = nil
    end

    script.raise_event(Store.events.on_value_update,{
        tick=game.tick,
        location=location,
        child=child,
        from_sync=from_sync
    })

    return true
end

--- Gets all non nil children at a location, children can be added and removed during runtime
-- this is similar to Store.get but will always return a table even if it is empty
-- @tparam string location the location to get the children of
-- @treturn table a table containing all the children names
function Store.get_children(location)
    local data = Store.get(location)
    return type(data) == 'table' and table_keys(data) or {}
end

-- Handles syncing
Event.add(Store.events.on_value_update,function(event)
    if Store.callbacks[event.location] then
        Store.callbacks[event.location](event.value,event.child)
    end

    if not event.from_sync and Store.synced[event.location] then
        write_json('log/store.log',{
            tick=event.tick,
            location=event.location,
            child=event.child,
            value=event.value,
        })
    end
end)

return Store