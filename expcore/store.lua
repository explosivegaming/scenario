--- This module is for storing and watching values for updates, useful for config settings or limiting what can be changed
--[[
>>>> When to use this system
    This system is to be used when you want to store a value and watch when it is changed or watch any value for changes.
    Examples would include runtime config settings where something needs to change when the value is updated or when you have
    values entered in a gui and you want them to be persistent between players like a force modifer gui

>>>> What store type to use
    There are different types of store that can be used each is designed to be used in a certain situation:
    local - this store type doesnt actually store any data and it has its use in only triggering the setter function when you use
        the set function rather than watching for updates, this might be used as an interface between modules where when you change the
        local varible you dont want it to trigger but when an outside source uses set it will trigger the setter.
    player - this will use the sub_location as a player so each player will have they own entry in the store location, this can be used
        with player modifiers where even if set is not used the update will still be detected.
    force - this will use the sub_location as a force so each force will have its own entry in the store location, this can be used to store
        custom settings for a force where if a player uses a gui to edit the setting it will detect the update and call the setter where you
        can update the value on the gui for other players.
    surface - this will use the sub_location as a surface so each surface will have its own entry in the store location, this will have the
        same use case as force but for a surface rather than a force.
    game - this will store all a single value so any sub_location string can be used, this is the general case so you really can store what
        ever values you want to in this and watch for external updates, this would be used when its not a local varible for example if you are
        watching the number of online players.
    global - this will store all of its data in an external source indepentent of the lua code, this means that you can store data between
        maps and even instances, when the value is updated it will trigger an emit where some external code should send a message to the other
        connected instances to update they value. lcoal set -> emit update -> local setter -> remote set -> remote setter

>>>> Force mining speed example:
    For this will print a message when the force mining speed has been updated, we will use the force type since each force will have its own
    mining speed and our getter will just return the current minning speed of the force.

    Store.register('force.mining_speed','force',function(force)
        return force.manual_mining_speed_modifier
    end,function(force,value)
        force.manual_mining_speed_modifier = value
        game.print(force.name..' how has '..value..' mining speed')
    end)

    Note that because we used type force the getter and setter are passed the force which the current check/update effects; if we used player or surface
    the same would be true. However for local, game and global they are passed the sub_location string which allows you to store multiple things in the same
    location; however one limitation is that a sub_location is required even if you only plan to store one value.

    Store.set('force.mining_speed','player',2)
    game.forces.player.manual_mining_speed_modifier = 2

    The two cases above will have the effect of both setting the minning speed and outputing the update message. This can be quite useful when you start to
    indroduce custom settings or do more than just output that the value was updated.

    Store.get('force.mining_speed','player')

    In a similar way get can be used to get the current value that is stored, if no value is stored then the getter function is called to get the value, this
    function is more useful when you have custom settings since they would be no other way to access them.

>>>> Optimise the watching
    When you use player,force or surface you will be checking alot of values for updates for this reason you might want to limit which sub_locations are checked
    for updates because by default every player/force/surface is checked. You might also want to do this if you want a sub_location that is nil but still want to
    check for it being updated (because by deafult it only checks non nil sub_locations). To do both these things you will use Store.watch

    Store.watch('force.mining_speed','player')
    For our force example we dont care about the enemy or neutral force only the player force, so we tell it to watch player and these means that the values for
    the other forces are not be watched for updates (although Store.get and Store.set will still work). Store.watch will also accept a table of sub_locations in
    case you want more than one thing to be watch.

>>>> Functions:
    Store.register(location,store_type,getter,setter,no_error) --- Register a new location to store a value, the valu returned from getter will be watched for updates
    Store.set(location,sub_location,value) --- Sets the stored values at the location, will call the setter function
    Store.get(location,sub_location) --- Gets the value at the location, if the value is nil then the getter function is called
    Store.watch(location,sub_location,state) --- If used then only sub_locations marked to be watched will be watched for updates, this will also midigate the nil value problem
    Store.check(location,sub_location) --- Checks if the store value needs updating, and if true will update it calling the setter function
]]


local Global = require 'utils.global'
local Event = require 'utils.event'
local Game = require 'utils.game'
local Enum,write_json,table_keys = ext_require('expcore.common','enum','write_json','table_keys')

local Store = {
    data={},
    watching={},
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
Global.register({Store.data,Store.watching},function(tbl)
    Store.data = tbl[1]
    Store.watching = tbl[2]
end)

--- Returns a factorio object for the sub_location
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

--- Returns three common parts that are used
local function get_location_parts(location,sub_location)
    location = Store.locations[location]
    local sub_location_object = get_sub_location_object(location.store_type,sub_location)
    sub_location = sub_location_object and sub_location_object.name or sub_location
    return location, sub_location, sub_location_object
end

--- Emits an event to the external store that a value was updated
local function set_global_location_value(location,sub_location,value)
    write_json('log/store.log',{
        location=location,
        sub_location=sub_location,
        value=value
    })
end

--- Register a new location to store a value, the valu returned from getter will be watched for updates
-- @tparam location string the location path for the data must be unqiue
-- @tparam store_type string the type of store this is, see Store.types
-- @tparam getter function will be called to get the value for the store, the value is watched for updates
-- @tparam setter function when the store value changes the setter will be called
-- @tparam[opt=false] no_error boolean when true will skip check for location already registered
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

--- Sets the stored values at the location, will call the setter function
-- @tparam location string the location to be updated, must be registed
-- @tparam sub_location string sub_location to set, either string,player,force or surface depending on store type
-- @tparam value any the value to set at the location
function Store.set(location,sub_location,value)
    if not Store.locations[location] then
        return error('The location is not registed: '..location)
    end
    local location, sub_location, sub_location_object = get_location_parts(location,sub_location)
    if location.store_type ~= Store.types['local'] then
        if not Store.data[location.location] then Store.data[location.location] = {} end
        Store.data[location.location][sub_location] = value
    end
    if location.store_type == Store.types.global then
        set_global_location_value(location.location,value)
    end
    location.setter(sub_location_object or sub_location,value)
    return true
end

--- Gets the value at the location, if the value is nil then the getter function is called
-- @tparam location string the location to be returned, must be registed
-- @tparam sub_location string sub_location to get, either string,player,force or surface depending on store type
-- @treturn any the value that was at this location
function Store.get(location,sub_location)
    if not Store.locations[location] then return end
    local location, sub_location, sub_location_object = get_location_parts(location,sub_location)
    local rtn = Store.data[location.location][sub_location]
    if rtn == nil or Store.watching[location.location] and not Store.watching[location.location][sub_location] then
        rtn = location.getter(sub_location_object or sub_location)
    end
    return rtn
end

--- If used then only sub_locations marked to be watched will be watched for updates, this will also midigate the nil value problem
-- @tparam location string the location to be returned, must be registed
-- @tparam sub_location string sub_location to watch, either string,player,force or surface depending on store type, can be a table of sub_locations
-- @tparam[opt=true] state boolean when true it will be marked to be watched, when false it will be removed
function Store.watch(location,sub_location,state)
    if not Store.locations[location] then
        return error('The location is not registed: '..location)
    end
    if type(sub_location) ~= 'table' or type(sub_location.__self) == 'userdata' then
        sub_location = {sub_location}
    end
    for _,v in pairs(sub_location) do
        if not Store.watching[location] then Store.watching[location] = {} end
        if state == false then Store.watching[location][v] = nil
        else Store.watching[location][v] = true end
    end
    if #table_keys(Store.watching[location]) == 0 then Store.watching[location] = nil end
end

--- Checks if the store value needs updating, and if true will update it calling the setter function
-- @tparam location string the location to be check, must be registed
-- @tparam sub_location string sub_location to check, either string,player,force or surface depending on store type
-- @treturn boolean if the value was updated and setter function called
function Store.check(location,sub_location)
    if not Store.locations[location] then return false end
    location = Store.locations[location]
    local sub_location_object = get_sub_location_object(location.store_type,sub_location)
    sub_location = sub_location_object and sub_location_object.name or sub_location
    local store,getter = Store.data[location.location][sub_location],location.getter(sub_location_object or sub_location)
    if store ~= getter then
        if not Store.data[location.location] then Store.data[location.location] = {} end
        Store.data[location.location][sub_location] = getter
        location.setter(sub_location_object or sub_location,getter)
        return true
    end
    return false
end

--- Checks once per second for changes to the store values
Event.on_nth_tick(60,function()
    local types = {}
    for _,location in pairs(Store.locations) do
        if location.store_type ~= Store.types['local'] then
            if not types[location.store_type] then types[location.store_type] = {} end
            table.insert(types[location.store_type],location)
        end
    end
    for store_type,locations in pairs(types) do
        local keys
        if store_type == Store.types.player then keys = game.players
        elseif store_type == Store.types.force then keys = game.forces
        elseif store_type == Store.types.surface then keys = game.surfaces
        end
        if keys then
            for _,sub_location in pairs(keys) do
                for _,location in pairs(locations) do
                    if not Store.watching[location.location] or Store.watching[location.location][sub_location.name] then
                        if not Store.data[location.location] then Store.data[location.location] = {} end
                        Store.check(location.location,sub_location)
                    end
                end
            end
        else
            for _,location in pairs(locations) do
                if not Store.data[location.location] then Store.data[location.location] = {} end
                if Store.watching[location.location] then keys = Store.watching[location.location]
                else keys = table_keys(Store.data[location.location]) end
                for _,sub_location in pairs(keys) do
                    Store.check(location.location,sub_location)
                end
            end
        end
    end
end)

return Store