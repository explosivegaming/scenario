
local Event = require 'utils.event' --- @dep utils.event

local DatastoreManager = {}
local Datastores = {}
local Datastore = {}

--- Save datastores in the global table
global.datastores = Datastores
Event.on_load(function()
    Datastores = global.datastores
    for _, datastore in pairs(Datastores) do
        setmetatable(datastore, DatastoreManager.metatable)
    end
end)

----- Datastore Manager -----
-- @section datastoreManager

--- Metatable used on datastores
DatastoreManager.metatable = {
    __newidnex = function(_, _, _) error('Datastore can not be modified', 2) end,
    __call = function(self, ...) return self:get(...) end,
    __index = Datastore
}

--- Make a new datastore
function DatastoreManager.connect(tableName, saveToDisk, autoSave, propagateChanges)
    if Datastores[tableName] then return Datastores[tableName] end

    local new_datastore = {
        name = tableName,
        auto_save = autoSave or false,
        save_to_disk = saveToDisk or false,
        propagate_changes = propagateChanges or false,
        serializer = false,
        combined = false,
        events = {},
        data = {}
    }

    Datastores[tableName] = new_datastore
    return setmetatable(new_datastore, DatastoreManager.metatable)
end

--- Make a new datastore that is contained within another
function DatastoreManager.combine(datastore, subTableName)
    local new_datastore = DatastoreManager.connect(subTableName)
    new_datastore.serializer = datastore.serializer
    new_datastore.auto_save = datastore.auto_save
    new_datastore.combined = datastore
    return new_datastore
end

--- Ingest the result from a request
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
        value = datastore:raise_event('on_received', key, value)
        datastore:set(key, value)

    end

end

--- Commonly used serializer, returns the objects name
function DatastoreManager.name_serializer(rawKey)
    return rawKey.name
end

----- Datastore -----
-- @section datastore

--- Internal, Get the data following combine logic
function Datastore:raw_get(key, isTable)
    if self.combined then
        local data = self.combined:raw_get(key, true)
        if data[self.name] == nil and isTable then
            data[self.name] = {}
        end
        return data[self.name]
    else
        if self.data[key] == nil and isTable then
            self.data[key] = {}
        end
        return self.data[key]
    end
end

--- Internal, Set the data following combine logic
function Datastore:raw_set(key, value)
    if self.combined then
        local data = self.combined:raw_get(key, true)
        data[self.name] = value
    else
        self.data[key] = value
    end
end

--- Internal, return the serialized key
local function serialize_error(err) error('An error ocurred in a datastore serializer: '..err) end
function Datastore:serialize(rawKey)
    if type(rawKey) == 'string' then return rawKey end
    assert(self.serializer, 'Datastore does not have a serializer and received non string key')
    local success, key = xpcall(self.serializer, serialize_error, rawKey)
    return success and key or nil
end

--- Internal, writes an event to the output file to be saved and/or propagated
function Datastore:write_action(action, key, value)
    local data = {action, self.name, '"'..key..'"'}
    if value ~= nil then
        data[4] = type(value) == 'table' and '"'..game.table_to_json(value)..'"' or '"'..tostring(value)..'"'
    end
    game.write_file('datastore.pipe', table.concat(data, ' ')..'\n', true, 0)
end

--- Request a value from an external source
function Datastore:request(key)
    if self.combined then return self.combined:request(key) end
    key = self:serialize(key)
    self:write_action('request', key)
end

--- Save a value to an external source
function Datastore:save(key)
    if self.combined then return self.combined:save(key) end
    if not self.save_to_disk then return end
    key = self:serialize(key)
    local value = self:raw_get(key)
    value = self:raise_event('on_save', key, value)
    local action = self.propagateChanges and 'propagate' or 'save'
    self:write_action(action, key, value)
end

--- Save a value to an external source and remove locally
function Datastore:unload(key)
    if self.combined then return self.combined:unload(key) end
    key = self:serialize(key)
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
    if self.combined and self.combined.auto_save then return self.combined:save(key) end
end

--- Get a value from local storage
function Datastore:get(key, default)
    key = self:serialize(key)
    local value = self:raw_get(key)
    if value ~= nil then return value end
    return table.deep_copy(default)
end

--- Set a value in local storage
function Datastore:set(key, value)
    key = self:serialize(key)
    self:raw_set(key, value)
    self:raise_event('on_update', key, value)
    if self.auto_save then self:save(key) end
    return value
end

--- Increment the value in local storage, only works for number values
function Datastore:increment(key, delta)
    key = self:serialize(key)
    local value = self:raw_get(key) or 0
    return Datastore:set(key, value + (delta or 1))
end

--- Use a callback function to update the value locally
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

--- Used to filter elements from a table
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

--- Get all keys in the datastore, optional filter callback
function Datastore:get_all(callback)
    if not self.combined then
        return filter(self.data, callback)
    else
        local name = self.name
        local data = self.combined:get_all()
        for key, value in pairs(data) do
            data[key] = value[name]
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

--- Set a callback that will be used to serialize keys which aren't strings
function Datastore:set_serializer(callback)
    assert(type(callback) == 'function', 'Callback must be a function')
    self.serializer = callback
end

----- Events -----
-- @section events

--- Raise a custom event on this datastore
local function event_error(err) print('An error ocurred in a datastore event handler:', err) end
function Datastore:raise_event(event_name, key, value)
    local handlers = self.events[event_name]
    if not handlers then return value end
    for _, handler in ipairs(handlers) do
        local success, new_value = xpcall(handler, event_error, key, value)
        if success and new_value ~= nil then value = new_value end
    end
    return value
end

--- Returns a function which will add a callback to an event
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

--- Register a callback that triggers only when data is received
Datastore.on_received = event_factory('on_received')

--- Register a callback that triggers before data is saved
Datastore.on_save = event_factory('on_save')

--- Register a callback that triggers before data is unloaded
Datastore.on_unload = event_factory('on_unload')

--- Register a callback that triggers when a message is received
Datastore.on_message = event_factory('on_message')

--- Register a callback that triggers any time a value is changed
Datastore.on_update = event_factory('on_update')

----- Module Return -----
return DatastoreManager