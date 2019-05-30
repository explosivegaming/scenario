--- Adds an easy way to store and watch for updates to a value
--[[
>>>> Basic Use
    At the most basic level this allows for the naming of locations to store in the global table, the second feature is that you are
    able to listen for updates of this value, which means that when ever the set function is called it will trigger the update callback.

    This may be useful when storing config values and when they get set you want to make sure it is taken care of, or maybe you want
    to have a value that you can trigger an update of from different places.

    -- this will register a new location called 'scenario.dificutly' and the start value is 'normal'
    -- note that setting a start value is optional and we could take nil to mean normal
    Store.register('scenario.dificutly',function(value)
        game.print('The scenario dificulty has be set to: '..value)
    end,'normal')

    -- this will return 'normal' as we have not set the value anywhere else
    Store.get('scenario.dificutly')

    -- this will set the value in the store to 'hard' and will trigger the update callback which will print a message to the game
    Store.set('scenario.dificutly','hard')

>>>> Using Children
    One limitation of store is that all lcoations must be registered to avoid desyncs, to get round this issue "children" can be used.
    When you set the value of a child it does not have its own update callback so rather the "partent" location which has been registerd
    will have its update value called with a second param of the name of that child.

    This may be useful when you want a value of each player or force and since you cant regisier every player at the start you must use
    the players name as the child name.

    -- this will register the lcoation 'scenario.score' where we plan to use force names as the child
    -- here we have not set a start value since it will be an empty location
    Store.register('scenario.score',function(value,child)
        game.print(child..' now has a score of '..value)
    end)

    -- this will return nil, but will not error as children dont need to be registerd
    Store.get_child('scenario.score','player')

    -- this will set 'player' to have a value of 10 for 'scenario.score' and trigger the game message print
    Store.set_child('scenario.score','player',10)

    -- this would be the same as Store.get however this will return an empty table rather than nil
    Store.get_children('scenario.score')

>>>> Using Sync
    There is the option to use Store.register_synced which is the same as Store.register however you can combine this with an external script
    which can read the output from 'script-output/log/store.log' and have it send rcon commands back to the game allowing for cross instance
    syncing of values.

    This may be useful when you want to have a value change effect multiple instances or even if you just want a database to store values so
    you can sync data between map resets.

    -- this example will register the location 'stastics.total-play-time' where we plan to use plan names as the child
    -- note that the location must be the same across instances
    Store.register_synced('stastics.total-play-time',function(value,child)
        game.print(child..' now has now played for '..value)
    end)

    -- use of set,get,set_child and get_chlid are all the same as non synced

>>>> Using a watch function
    Some times the value that you want is not some made up value that you have but rather a factorio value or something similar, in order to recive
    updates on these values (if the factorio api does not provide an event for it) you will need to add a watch function to update the store when the
    values changes. You will want to keep these watch functions small since they run every tick.

    -- this will register a location 'game.speed', note that the lcoation can be anything but we chose 'game.speed' to match what we are watching
    -- also note that we do not need a start value here since it will be set on the first tick, but you may want a start value to avoid a trigger of the callback
    Store.register('game.speed',function(value)
        game.print('The game speed has been set to: '..value)
    end)

    -- this will add the watch function to the lcoation, every tick the function is ran and the value returned in compeared to the stored value
    -- if the two values are different then the store is overriden and the update function is called
    Store.add_watch('game.speed',function()
        return game.speed
    end)

>>>> Alternative method
    Some people may prefer to use a varible rather than a string for formating reasons here is an example. Also for any times when
    there will be little external input Store.uid_location() can be used to generate non conflicting locations, use of register_synced will
    still require a name other wise there may be mirgration issuses.

    local store_game_speed = Store.uid_location()

    Store.register(store_game_speed,function(value)
        game.print('The game speed has been set to: '..value)
    end)

    Store.add_watch(store_game_speed,function()
        return game.speed
    end)

]]

local Global = require 'utils.global'
local Event = require 'utils.event'
local write_json = ext_require('expcore.common','write_json','table_keys')
local Token = require 'utils.token'

local Store = {
    data={},
    callbacks={},
    synced={},
    watchers={}
}
Global.register(Store.data,function(tbl)
    Store.data = tbl
end)

--- Check for if a lcoation is registered
-- @tparam string location the location to test for
-- @treturn boolean true if registered
function Store.is_registered(location)
    return not not Store.callbacks[location]
end

--- Returns a unqiue name that can be used for a store
-- @treturn string a unqiue name
function Store.uid_location()
    return tostring(Token.uid())
end

--- Registers a new location with an update callback which is triggered when the value updates
-- @tparam string location string a unique that points to the data, string used rather than token to allow migration
-- @tparam function callback this callback will be called when the stored value is set to a new value
-- @tparam[opt] any start_value this value will be the inital value that is stored at this location
function Store.register(location,callback,start_value)
    if _LIFECYCLE ~= _STAGE.control then
        return error('Can only be called during the control stage', 2)
    end

    if Store.callbacks[location] then
        return error('Location is already registered', 2)
    end

    if type(callback) ~= 'function' then
        return error('Callback must be a function', 2)
    end

    Store.data[location] = start_value
    Store.callbacks[location] = callback

    return location
end

--- Registers a new cross server synced location with an update callback, and external script is required for cross server
-- @tparam string location string a unique that points to the data, string used rather than token to allow migration
-- @tparam function callback this callback will be called when the stored value is set to a new value
-- @tparam[opt] any start_value this value will be the inital value that is stored at this location
function Store.register_synced(location,callback,start_value)
    if _LIFECYCLE ~= _STAGE.control then
        return error('Can only be called during the control stage', 2)
    end

    if Store.callbacks[location] then
        return error('Location is already registered', 2)
    end

    if type(callback) ~= 'function' then
        return error('Callback must be a function', 2)
    end

    Store.data[location] = start_value
    Store.callbacks[location] = callback
    Store.synced[location] = true
end

--- Adds a function that will be checked every tick for a change in the returned value, when the value changes it will be saved in the store
-- @tparam string location the location where the data will be saved and compeared to, must already be a registered location
-- @tparam function callback this function will be called every tick to check for a change in value
function Store.add_watch(location,callback)
    if _LIFECYCLE ~= _STAGE.control then
        return error('Can only be called during the control stage', 2)
    end

    if Store.callbacks[location] then
        return error('Location is already being watched', 2)
    end

    if type(callback) ~= 'function' then
        return error('Callback must be a function', 2)
    end

    Store.watchers[location] = callback
end

--- Gets the value stored at a location, this location must be registered
-- @tparam string location the location to get the data from
-- @tparam[opt=false] boolean no_error when true no error is returned if the location is not registered
-- @treturn any the data which was stored at the location
function Store.get(location,no_error)
    if not Store.callbacks[location] and not no_error then
        return error('Location is not registered', 2)
    end

    return Store.data[location]
end

--- Sets the value at a location, this location must be registered, if server synced it will emit the change to file
-- @tparam string location the location to set the data to
-- @tparam any value the new value to set at the location, value may be reverted if there is a watch callback
-- @treturn boolean true if it was successful
function Store.set(location,value)
    if not Store.callbacks[location] then
        return error('Location is not registered', 2)
    end

    Store.data[location] = value
    Store.callbacks[location](value)

    if Store.synced[location] then
        write_json('log/store.log',{
            location=location,
            value=value
        })
    end

    return true
end

--- Gets all non nil children at a location, children can be added and removed during runtime
-- this is similar to Store.get but will always return a table even if it is empty
-- @tparam string location the location to get the children of
-- @treturn table a table containg all the children and they values
function Store.get_children(location)
    local store = Store.get(location)

    if type(store) ~= 'table' and store ~= nil then
        return error('Location has a non table value', 2)
    end

    return store or {}
end

--- Gets the value of the child to a location, children can be added and removed during runtime
-- @tparam string location the location of which the child is located
-- @tparam string child the child element to get the value of
-- @treturn any the value which was stored at that location
function Store.get_child(location,child)
    local store = Store.get(location)

    if type(store) ~= 'table' and store ~= nil then
        return error('Location has a non table value', 2)
    end

    return store and store[child]
end

--- Sets the value of the chlid to a location, children can be added and removed during runtime
-- when a child is set it will call the update handler of the parent allowing children be to added at runtime
-- this may be used when a player joins the game and the child is the players name
-- @tparam string location the location of which the child is located
-- @tparam string child the child element to set the value of
-- @tparam any value the value to set at this location
-- @treturn boolean true if it was successful
function Store.set_child(location,child,value)
    local store = Store.get(location)

    if type(store) ~= 'table' and store ~= nil then
        return error('Location has a non table value', 2)
    end

    if not store then
        Store.data[location] = {}
    end

    Store.data[location][child] = value
    Store.callbacks[location](value,child)

    if Store.synced[location] then
        write_json('log/store.log',{
            location=location,
            child=child,
            value=value
        })
    end

    return true
end

-- Event handler for the watcher callbacks
Event.add(defines.events.on_tick,function()
    local errors = {}

    for location,callback in pairs(Store.watchers) do
        local store_old = Store.data[location]
        local success,store_new = pcall(callback)

        if not success then
            table.insert(errors,store_new)
        else
            if type(store_old) ~= type(store_new)
            or type(store_old) == 'table' and not table.compare(store_new,store_new)
            or store_old ~= store_new then
                Store.data[location] = store_new
                Store.callbacks[location](store_new)
            end
        end
    end

    if #errors > 0 then
        error(table.concat(errors,'; '))
    end
end)

return Store