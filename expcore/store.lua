--[[-- Core Module - Store
- Used to store and watch for updates for values in the global table
@core Store
@alias Store

@usage-- Require the module and add a store with no keys
-- Store with no keys does not need a serializer
local Store = require 'expcore.store' --- @dep expcore.store
local scenario_diffculty = Store.register()

-- When the store is changed this function will trigger
Store.watch(scenario_diffculty,function(value)
    game.print('The scenario diffculty has been set to '..value)
end)

Store.set(scenario_diffculty,'hard') -- Set the value stored to 'hard'
Store.get(scenario_diffculty) -- Returns 'hard'
Store.update(scenario_diffculty,function(value) -- Will set value to 'normal' if no value is present
    return not value and 'normal'
end)

@usage-- Require the module and add a store with keys
-- Store with keys does not require a serializer but it can be helpful
local Store = require 'expcore.store' --- @dep expcore.store
local player_scores = Store.register(function(player) -- Use player name as the key
    return player.name
end)

-- When any key in the store is changed this function will trigger
Store.watch(player_scores,function(value,key,old_value)
    game.print(key..' now has a score of '..value)
end)

Store.set(player_scores,game.player,10) -- Set your score to 10
Store.get(scenario_diffculty,game.player) -- Returns 10
Store.update(scenario_diffculty,game.player,function(value) -- Add 1 to your score
    return value + 1
end)

]]

local Event = require 'utils.event' --- @dep utils.event

local Store = {
    --- The current highest uid that is being used, will not increase during runtime
    -- @field uid
    uid = 0,
    --- An array of the serializers that stores are using, key is store uids
    -- @table serializers
    serializers = {},
    --- An array of watchers that stores will trigger, key is store uids
    -- @table watchers
    watchers = {},
    --- An index used for debuging to find the file where different stores where registered
    -- @table file_paths
    file_paths = {}
}

-- All data is stored in global.data_store and is accessed here with data_store
local data_store = {}
global.data_store = data_store
Event.on_load(function()
    data_store = global.data_store
end)

--- Store Setup.
-- @section setup

--[[-- An error checking and serializing function for checking store uids and keys, note key is not required
@tparam number store the uid of the store that you want to check is valid
@tparam[opt] ?string|any key the key that you want to serialize or check is a string
@tparam[opt=1] number error_stack the position in the stack relative to the current function (1) to raise this error on
@treturn string if key is given and a serializer is registered, or key was already a string, then the key is returned

@usage-- Registering a new store and checking that it is valid
-- New store will use player names as the keys
local player_scores = Store.register(function(player)
    return player.name
end)

-- player_scores is a valid store and key will be your player name
local key = Store.validate(player_scores,game.player)

]]
function Store.validate(store,key,error_stack)
    error_stack = error_stack or 1

    if type(store) ~= 'number' then
        -- Store is not a number and so if not valid
        error('Store uid given is not a number; recived type '..type(store),error_stack+1)
    elseif store > Store.uid then
        -- Store is a number but it is out of range, ie larger than the current highest uid
        error('Store uid is out of range; recived '..tostring(store),error_stack+1)
    elseif key ~= nil and type(key) ~= 'string' and Store.serializers[store] == nil then
        -- Key is present but is not a string and there is no serializer registered
        error('Store key is not a string and no serializer has been registered; recived '..type(key),error_stack+1)
    elseif key ~= nil then
        -- Key is present and so it is serialized and returned
        local serializer = Store.serializers[store]
        if type(key) ~= 'string' then
            local success, serialized_key = pcall(serializer,key)

            if not success then
                -- Serializer casued an error while serializing the key
                error('Store watcher casued an error:\n\t'..key,error_stack+1)
            elseif type(serialized_key) ~= 'string' then
                -- Serializer was successful but failed to return a string value
                error('Store key serializer did not return a string; recived type '..type(key),error_stack+1)
            end

            return serialized_key
        end

        return key
    end

end

--[[-- Required to create new stores and register an serializer to a store, serializer not required
@tparam[opt] function serializer the function used to convert non string keys into strings to be used in the store
@treturn number the uid for the new store that you have created, use this as the first param to all other functions

@usage-- Creating a store with no serializer
local scenario_diffculty = Store.register()

@usage-- Creating a store which can take LuaPlayer
local player_scores = Store.register(function(player)
    return player.name
end)

]]
function Store.register(serializer)
    if _LIFECYCLE ~= _STAGE.control then
        -- Only allow this function to be called during the control stage
        error('Store can not be registered durring runtime', 2)
    end

    -- Increment the uid counter
    local uid = Store.uid + 1
    Store.uid = uid

    -- Register the serializer if given
    if serializer then
        Store.serializers[uid] = serializer
    end

    -- Add entry in the debug table
    local file_path = debug.getinfo(2, 'S').source:match('^.+/currently%-playing/(.+)$'):sub(1, -5)
    Store.file_paths[uid] = file_path

    -- Return the new uid
    return uid
end

--[[-- Register a watch function to a store that is called when the value in the store is changed, triggers for any key
@tparam number store the uid of the store that you want to watch for changes to
@tparam function watcher the function that will be called when there is a change to the store

@usage-- Printing the changed value to all players, no keys
-- Register the new store, we are not using keys so we dont need a serializer
local scenario_diffculty = Store.register()

-- Register the watcher so that when we change the value the message is printed
Store.watch(scenario_diffculty,function(value)
    game.print('The scenario diffculty has been set to '..value)
end)

-- Set a new value for the diffculty and see that it has printed to the game
Store.set(scenario_diffculty,'hard')

@usage-- Printing the changed value to all players, with keys
-- Register the new store, we are not using player names as the keys so it would be useful to accept LuaPlayer objects
local player_scores = Store.register(function(player)
    return player.name
end)

-- Register the watcher so that when we change the value the message is printed
Store.watch(player_scores,function(value,key,old_value)
    game.print(key..' now has a score of '..value)
end)

-- Set a new value for your score and see that it has printed to the game
Store.set(player_scores,game.player,10)

]]
function Store.watch(store,watcher)
    if _LIFECYCLE ~= _STAGE.control then
        -- Only allow this function to be called during the control stage
        error('Store watcher can not be registered durring runtime', 2)
    end

    Store.validate(store,nil,2)

    -- Add the watchers table if it does not exist
    local watchers = Store.watchers[store]
    if not watchers then
        watchers = {}
        Store.watchers[store] = watchers
    end

    -- Append the new watcher function
    watchers[#watchers+1] = watcher
end

--- Store Data Management.
-- @section data

--[[-- Used to retrive the current data that is stored, key is optional depending on if you are using them
@tparam number store the uid of the store that you want to get the value from
@tparam[opt] ?string|any key the key that you want to get the value of, must be a string unless you have a serializer
@treturn any the data that is stored

@usage-- Getting the value of a store with no keys
-- Register the new store, we are not using keys so we dont need a serializer
local scenario_diffculty = Store.register()

-- Get the current diffculty for the scenario
local diffculty = Store.get(scenario_diffculty)

@usage-- Getting the data from a store with keys
-- Register the new store, we are not using player names as the keys so it would be useful to accept LuaPlayer objects
local player_scores = Store.register(function(player)
    return player.name
end)

-- Get your current score
local my_score = Store.get(player_scores,game.player)

-- Get all scores
lcoal scores = Store.get(player_scores)

]]
function Store.get(store,key)
    key = Store.validate(store,key,2)

    -- Get the data from the data store
    local data = data_store[store]
    if key then
        if type(data) ~= 'table' then
            data_store[store] = {_value = data_store[store]}
            return nil
        else
            return data[key]
        end
    end

    -- Return all data if there is no key
    return data
end

--[[-- Used to clear the data in a store, will trigger any watchers, key is optional depending on if you are using them
@tparam number store the uid of the store that you want to clear
@tparam[opt] ?string|any key the key that you want to clear, must be a string unless you have a serializer

@usage-- Clear a store which does not use keys
-- Register the new store, we are not using keys so we dont need a serializer
local scenario_diffculty = Store.register()

-- Clear the scenario diffculty
Store.clear(scenario_diffculty)

@usage-- Clear data that is in a store with keys
-- Register the new store, we are not using player names as the keys so it would be useful to accept LuaPlayer objects
local player_scores = Store.register(function(player)
    return player.name
end)

-- Clear your score
Store.clear(player_scores,game.player)

-- Clear all scores
Store.clear(player_scores)

]]
function Store.clear(store,key)
    key = Store.validate(store,key,2)
    local old_value

    -- Check if there is a key being used
    if key then
        if type(data_store[store]) == 'table' then
            old_value = data_store[store][key]
            data_store[store][key] = nil
        end
    else
        old_value = data_store[store]
        data_store[store] = nil
    end

    -- Trigger any watch functions
    Store.raw_trigger(store,key,nil,old_value)
end

--[[-- Used to set the data in a store, will trigger any watchers, key is optional depending on if you are using them
@tparam number store the uid of the store that you want to set
@tparam[opt] ?string|any key the key that you want to set, must be a string unless you have a serializer
@tparam any value the value that you want to set

@usage-- Setting a store which does not use keys
-- Register the new store, we are not using keys so we dont need a serializer
local scenario_diffculty = Store.register()

-- Set the new scenario diffculty
Store.set(scenario_diffculty,'hard')

@usage-- Set data in a store with keys
-- Register the new store, we are not using player names as the keys so it would be useful to accept LuaPlayer objects
local player_scores = Store.register(function(player)
    return player.name
end)

-- Set your current score
Store.set(player_scores,game.player,10)

-- Set all scores, note this might not have much use
Store.set(player_scores,{
    [game.player.name] = 10,
    ['SomeOtherPlayer'] = 0
})

]]
function Store.set(store,key,value)
    -- Allow for key to be optional
    if value == nil then
        value = key
        key = nil
    end

    -- Check the store is valid
    key = Store.validate(store,key,2)
    local old_value

    -- If there is a key being used then the store must be a able
    if key then
        if type(data_store[store]) ~= 'table' then
            data_store[store] = {_value = data_store[store]}
        end
        old_value = data_store[store][key]
        data_store[store][key] = value
    else
        old_value = data_store[store]
        data_store[store] = value
    end

    -- Trigger any watchers
    Store.raw_trigger(store,key,value,old_value)
end

--[[-- Used to update the data in a store, use this with tables, will trigger any watchers, key is optional depending on if you are using them
@tparam number store the uid of the store that you want to update
@tparam[opt] ?string|any key the key that you want to update, must be a string unless you have a serializer
@tparam function updater the function which is called to make changes to the value, such as changing table keys, if a value is returned it will replace the current value in the store

@usage-- Incrementing a global score
-- Because we are only going to have one score so we will not need keys or a serializer
local game_score = Store.register()

-- Setting a default value
Store.set(game_score,0)

-- We now will update the game score by one, we return the value so that it is set as the new value in the store
Store.update(game_score,function(value)
    return value + 1
end)

@usage-- Updating keys in a table of data
-- Register the new store, we are not using player names as the keys so it would be useful to accept LuaPlayer objects
local player_data = Store.register(function(player)
    return player.name
end)

-- Setting a default value for your player, used to show the table structure
Store.set(player_data,game.player,{
    group = 'Admin',
    role = 'Owner',
    show_group_config = false
})

-- Updating the show_group_config key in your player data, note that it would be harder to call set every time
-- We do not need to return anything in this case as we are not replacing all the data
Store.update(player_data,game.player,function(data)
    data.show_group_config = not data.show_group_config
end)

]]
function Store.update(store,key,updater)
    -- Allow for key to be nil
    if updater == nil then
        updater = key
        key = nil
    end

    -- Check the store is valid
    key = Store.validate(store,key,2)
    local value, old_value

    -- If a key is used then the store must be a table
    if key then
        if type(data_store[store]) ~= 'table' then
            data_store[store] = {_value = data_store[store]}
        end

        -- Call the updater and if it returns a value then set this value
        local rtn = updater(data_store[store][key])
        if rtn then
            old_value = data_store[store][key]
            data_store[store][key] = rtn
        end
        value = data_store[store][key]

    else
        -- Call the updater and if it returns a value then set this value
        local rtn = updater(data_store[store])
        if rtn then
            old_value = data_store[store][key]
            data_store[store] = rtn
        end
        value = data_store[store]

    end

    -- Trigger any watchers
    Store.raw_trigger(store,key,value,old_value)
end

--[[-- Used to update all values that are in a store, similar to Store.update but acts on all keys at once, will trigger watchers for every key present
@tparam number store the uid of the store that you want to map
@tparam function updater the function that is called on every key in this store

@usage-- Updating keys in a table of data
-- Register the new store, we are not using player names as the keys so it would be useful to accept LuaPlayer objects
local player_data = Store.register(function(player)
    return player.name
end)

-- Setting a default value for your player, used to show the table structure
Store.set(player_data,game.player,{
    group = 'Admin',
    role = 'Owner',
    show_group_config = false
})

-- Updating the show_group_config key for all players, note that it would be harder to call set every time
-- We do not need to return anything in this case as we are not replacing all the data
-- We also have access to the current key being updated if needed
Store.map(player_data,function(data,key)
    data.show_group_config = not data.show_group_config
end)

]]
function Store.map(store,updater)
    Store.validate(store,nil,2)

    -- Get all that data in the store and check its a table
    local data = data_store[store]
    if type(data) ~= 'table' then
        return
    end

    -- Loop over all the keys and call the updater, setting value if returned, and calling watcher functions
    for key,value in pairs(data) do
        local rtn = updater(value,key)
        if rtn then
            data[key] = rtn
        end
        Store.raw_trigger(store,key,data[key],value)
    end
end

--[[-- Used to trigger watcher functions, this may be used to trigger them if you did not use Store.update or Store.set
@tparam number store the uid of the store that you want to trigger
@tparam[opt] ?string|any key the key that you want to trigger, must be a string unless you have a serializer
@usage-- Faking the update to a store
-- The type of store we use does not really matter for this as long as you pass it what you watchers are expecting
local scenario_diffculty = Store.register()

-- Trigger the watchers with a fake change of diffculty
Store.trigger(scenario_diffculty)

]]
function Store.trigger(store,key)
    key = Store.validate(store,key,2)

    -- Get the data from the data store
    local data = data_store[store]
    if key then
        data = data[key]
        Store.raw_trigger(store,key,data,data)
    else
        Store.raw_trigger(store,key,data,data)
    end
end

--[[-- Used to trigger watcher functions, the value and key are passed directly to the watchers regardless if the value is correct
@tparam number store the uid of the store that you want to trigger
@tparam[opt] ?string|any key the key that you want to trigger, must be a string unless you have a serializer
@tparam[opt] any value the new value that is at this key or store, passed directly to the watcher
@tparam[opt] any old_value the old value that was at this key or store often the same if value is a table, passed directly to the watcher

@usage-- Triggering a manule call of the watchers
-- The type of store we use does not really matter for this as long as you pass it what you watchers are expecting
local scenario_diffculty = Store.register()

-- Trigger the watchers with a fake change of diffculty
-- This is mostly used internally but it can be useful in other cases
Store.raw_trigger(scenario_diffculty,nil,'normal','normal')

]]
function Store.raw_trigger(store,key,value,old_value)
    key = Store.validate(store,key,2)

    -- Get the watchers and then loop over them
    local watchers = Store.watchers[store] or {}
    for _,watcher in pairs(watchers) do
        local success, err = pcall(watcher,value,key,old_value)
        if not success then
            error('Store watcher casued an error:\n\t'..err)
        end
    end
end

-- Module return
return Store