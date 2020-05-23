
local Event = require 'utils.event' --- @dep utils.event

local DatastoreManager = {}
local Datastores = {}
local Datastore = {}
local Data = {}
local copy = table.deep_copy

--- Save datastores in the global table
global.datastores = Data
Event.on_load(function()
    Data = global.datastores
    for tableName, datastore in pairs(Datastores) do
        datastore.data = Data[tableName]
    end
end)

----- Datastore Manager -----
-- @section datastoreManager

--- Metatable used on datastores
DatastoreManager.metatable = {
    __index = function(self, key) return rawget(self.children, key) or rawget(Datastore, key) end,
    __newidnex = function(_, _, _) error('Datastore can not be modified', 2) end,
    __call = function(self, ...) return self:get(...) end
}

--- Make a new datastore connection, if a connection already exists then it is returned
function DatastoreManager.connect(tableName, saveToDisk, autoSave, propagateChanges)
    if Datastores[tableName] then return Datastores[tableName] end
    if _LIFECYCLE ~= _STAGE.control then
        -- Only allow this function to be called during the control stage
        error('New datastore connection can not be created during runtime', 2)
    end

    local new_datastore = {
        name = tableName,
        table_name = tableName,
        auto_save = autoSave or false,
        save_to_disk = saveToDisk or false,
        propagate_changes = propagateChanges or false,
        serializer = false,
        parent = false,
        children = {},
        metadata = {},
        events = {},
        data = {}
    }

    Data[tableName] = new_datastore.data
    Datastores[tableName] = new_datastore
    return setmetatable(new_datastore, DatastoreManager.metatable)
end

--- Make a new datastore that stores its data inside of another one
function DatastoreManager.combine(datastore, subTableName)
    local new_datastore = DatastoreManager.connect(datastore.name..'.'..subTableName)
    datastore.children[subTableName] = new_datastore
    new_datastore.serializer = datastore.serializer
    new_datastore.auto_save = datastore.auto_save
    new_datastore.table_name = subTableName
    new_datastore.parent = datastore
    Data[new_datastore.name] = nil
    new_datastore.data = nil
    return new_datastore
end

--- Ingest the result from a request, this is used through a rcon interface to sync data
local function ingest_error(err) print('Datastore ingest error, Unable to parse json:', err) end
function DatastoreManager.ingest(action, tableName, key, valueJson)
    local datastore = assert(Datastores[tableName], 'Datastore ingest error, Datastore not found '..tostring(tableName))
    assert(type(action) == 'string', 'Datastore ingest error, Action is not a string got: '..type(action))
    assert(type(key) == 'string', 'Datastore ingest error, Key is not a string got: '..type(key))

    if action == 'remove' then
        datastore:raw_set(key)

    elseif action == 'message' then
        local success, value = xpcall(game.json_to_table, ingest_error, valueJson)
        if not success or value == nil then return end
        datastore:raise_event('on_message', key, value)

    elseif action == 'propagate' then
        local success, value = xpcall(game.json_to_table, ingest_error, valueJson)
        if not success or value == nil then return end
        value = datastore:raise_event('on_load', key, value)
        datastore:set(key, value)

    end

end

--- Debug, Use to get all datastores, or return debug info on a datastore
function DatastoreManager.debug(tableName)
    if not tableName then return Datastores end
    local datastore = assert(Datastores[tableName], 'Datastore not found '..tostring(tableName))
    return datastore:debug()
end

--- Commonly used serializer, returns the name of the object
function DatastoreManager.name_serializer(rawKey)
    return rawKey.name
end

----- Datastore -----
-- @section datastore

--- Debug, Get the debug info for this datastore
function Datastore:debug()
    local debug_info = {}

    if self.parent then
        debug_info.parent = self.parent.name
    else
        debug_info.settings = { auto_save = self.auto_save, save_to_disk = self.save_to_disk, propagate_changes = self.propagate_changes, serializer = not not self.serializer }
    end

    local children = {}
    for name in pairs(self.children) do children[#children+1] = name end
    if #children > 0 then debug_info.children = children end

    local events = {}
    for name, handlers in pairs(self.events) do events[name] = #handlers end
    if next(events) then debug_info.events = events end

    if next(self.metadata) then debug_info.metadata = self.metadata end
    debug_info.data = self:get_all()

    return debug_info
end

--- Internal, Get data following combine logic
function Datastore:raw_get(key, fromChild)
    local data = self.data
    if self.parent then
        data = self.parent:raw_get(key, true)
        key  = self.table_name
    end
    local value = data[key]
    if value ~= nil then return value end
    if fromChild then value = {} end
    data[key] = value
    return value
end

--- Internal, Set data following combine logic
function Datastore:raw_set(key, value)
    if self.parent then
        local data = self.parent:raw_get(key, true)
        data[self.table_name] = value
    else
        self.data[key] = value
    end
end

--- Internal, Return the serialized key
local function serialize_error(err) error('An error ocurred in a datastore serializer: '..err) end
function Datastore:serialize(rawKey)
    if type(rawKey) == 'string' then return rawKey end
    assert(self.serializer, 'Datastore does not have a serializer and received non string key')
    local success, key = xpcall(self.serializer, serialize_error, rawKey)
    return success and key or nil
end

--- Internal, Writes an event to the output file to be saved and/or propagated
function Datastore:write_action(action, key, value)
    local data = {action, self.name, '"'..key..'"'}
    if value ~= nil then
        data[4] = type(value) == 'table' and '"'..game.table_to_json(value)..'"' or '"'..tostring(value)..'"'
    end
    game.write_file('datastore.pipe', table.concat(data, ' ')..'\n', true, 0)
end

--- Set a callback that will be used to serialize keys which aren't strings
function Datastore:set_serializer(callback)
    assert(type(callback) == 'function', 'Callback must be a function')
    self.serializer = callback
end

--- Set metadata tags on this datastore which can be accessed by other scripts
function Datastore:set_metadata(tags)
    local metadata = self.metadata
    for key, value in pairs(tags) do
        metadata[key] = value
    end
end

--- Create a new datastore which is stores its data inside of this datastore
Datastore.combine = DatastoreManager.combine

--- Request a value from an external source, will trigger on_load when data is received
function Datastore:request(key)
    if self.parent then return self.parent:request(key) end
    key = self:serialize(key)
    self:write_action('request', key)
end

--- Save a value to an external source, will trigger on_save before data is saved, save_to_disk must be set to true
function Datastore:save(key)
    if self.parent then self.parent:save(key) end
    if not self.save_to_disk then return end
    key = self:serialize(key)
    local value  = self:raise_event('on_save', key, copy(self:raw_get(key)))
    local action = self.propagate_changes and 'propagate' or 'save'
    self:write_action(action, key, value)
end

--- Save a value to an external source and remove locally, will trigger on_unload then on_save, save_to_disk is not required for on_unload
function Datastore:unload(key)
    if self.parent then return self.parent:unload(key) end
    key = self:serialize(key)
    self:raise_event('on_unload', key, copy(self:raw_get(key)))
    self:save(key)
    self:raw_set(key)
end

--- Use to send a message over the connection, works regardless of saveToDisk and propagateChanges
function Datastore:message(key, message)
    key = self:serialize(key)
    self:write_action('message', key, message)
end

--- Remove a value locally and on the external source, works regardless of propagateChanges
function Datastore:remove(key)
    key = self:serialize(key)
    self:raw_set(key)
    self:write_action('remove', key)
    if self.parent and self.parent.auto_save then return self.parent:save(key) end
end

--- Get a value from local storage, option to have a default value
function Datastore:get(key, default)
    key = self:serialize(key)
    local value = self:raw_get(key)
    if value ~= nil then return value end
    return copy(default)
end

--- Set a value in local storage, will trigger on_update then on_save, save_to_disk and auto_save is required for on_save
function Datastore:set(key, value)
    key = self:serialize(key)
    self:raw_set(key, value)
    self:raise_event('on_update', key, value)
    if self.auto_save then self:save(key) end
    return value
end

--- Increment the value in local storage, only works for number values, will trigger on_update then on_save, save_to_disk and auto_save is required for on_save
function Datastore:increment(key, delta)
    key = self:serialize(key)
    local value = self:raw_get(key) or 0
    return Datastore:set(key, value + (delta or 1))
end

--- Use a function to update the value locally, will trigger on_update then on_save, save_to_disk and auto_save is required for on_save
local function update_error(err) error('An error ocurred in datastore update: '..err, 2) end
function Datastore:update(key, callback)
    key = self:serialize(key)
    local value = self:raw_get(key)
    local success, new_value = xpcall(callback, update_error, key, value)
    if success and new_value ~= nil then
        self:set(key, new_value)
    else
        self:raise_event('on_update', key, value)
        if self.auto_save then self:save(key) end
    end
end

--- Internal, Used to filter elements from a table
local function filter_error(err) print('An error ocurred in a datastore filter:', err) end
local function filter(tbl, callback)
    if not callback then return tbl end
    local rtn = {}
    for key, value in pairs(tbl) do
        local success, add = xpcall(callback, filter_error, key, value)
        if success and add then rtn[key] = value end
    end
    return rtn
end

--- Get all keys in this datastore, optional filter callback
function Datastore:get_all(callback)
    if not self.parent then
        return filter(self.data, callback)
    else
        local data, table_name = {}, self.table_name
        for key, value in pairs(self.parent:get_all()) do
            data[key] = value[table_name]
        end
        return filter(data, callback)
    end
end

--- Save all the keys in the datastore, optional filter callback
function Datastore:save_all(callback)
    local data = self:get_all(callback)
    for key in pairs(data) do self:save(key) end
end

--- Unload all the keys in the datastore, optional filter callback
function Datastore:unload_all(callback)
    local data = self:get_all(callback)
    for key in pairs(data) do self:unload(key) end
end

----- Events -----
-- @section events

--- Internal, Raise an event on this datastore
local function event_error(err) print('An error ocurred in a datastore event handler:', err) end
function Datastore:raise_event(event_name, key, value, source)
    -- Raise the event for the children of this datastore
    if source ~= 'child' then
        for table_name, child in pairs(self.children) do
            value[table_name] = child:raise_event(event_name, key, value[table_name], 'parent')
        end
    end

    -- Raise the event for this datastore
    local handlers = self.events[event_name]
    if handlers then
        for _, handler in ipairs(handlers) do
            local success, new_value = xpcall(handler, event_error, key, value)
            if success and new_value ~= nil then value = new_value end
        end
    end

    -- Raise the event for the parent of this datastore
    if source ~= 'parent' and self.parent then
        self.parent:raise_event(event_name, key, self.parent:raw_get(key), 'child')
    end
    return value
end

--- Internal, Returns a function which will add a callback to an event
local function event_factory(event_name)
    return function(self, callback)
        assert(type(callback) == 'function', 'Handler must be a function')
        local handlers = self.events[event_name]
        if not handlers then
            self.events[event_name] = { callback }
        else
            handlers[#handlers+1] = callback
        end
    end
end

--- Register a callback that triggers when data is loaded from an external source, returned value is saved locally
Datastore.on_load = event_factory('on_load')

--- Register a callback that triggers before data is saved, returned value is saved externally
Datastore.on_save = event_factory('on_save')

--- Register a callback that triggers before data is unloaded, returned value is ignored
Datastore.on_unload = event_factory('on_unload')

--- Register a callback that triggers when a message is received, returned value is ignored
Datastore.on_message = event_factory('on_message')

--- Register a callback that triggers any time a value is changed, returned value is ignored
Datastore.on_update = event_factory('on_update')

----- Module Return -----
return DatastoreManager