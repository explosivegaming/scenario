
local Event = require 'utils.event' --- @dep utils.event

local DatastoreManager = {}
local Datastores = {}
local Datastore = {}

--- Save datastores in the global table
global.datastores = Datastores
Event.on_load(function()
    Datastores = global.datastores
end)

----- Datastore Manager -----

--- Make a new datastore
function DatastoreManager.connect(tableName, saveToDisk, propagateChanges)

end

--- Make a new datastore that is contained within another
function DatastoreManager.combine(datastore, subTableName)

end

--- Ingest the result from a request
function DatastoreManager.ingest(action, tableName, key, valueJson)

end

--- Commonly used serializer, returns the objects name
function DatastoreManager.name_serializer(rawKey)

end

----- Datastore -----

--- Request a value from an external source
function Datastore:request(key)

end

--- Save a value to an external source
function Datastore:save(key)

end

--- Save a value to an external source and remove locally
function Datastore:unload(key)

end

--- Remove a value locally and on the external source
function Datastore:remove(key)

end

--- Get a value from local storage
function Datastore:get(key, default)

end

--- Set a value in local storage
function Datastore:set(key, value)

end

--- Increment the value in local storage, only works for number values
function Datastore:increment(key, delta)

end

--- Use a callback function to update the value locally
function Datastore:update(key, callback)

end

--- Use to send a message over the connection, works regardless of saveToDisk and propagateChanges
function Datastore:message(key, message)

end

--- Get all keys in the datastore, optional filter callback
function Datastore:get_all(callback)

end

--- Save all the keys in the datastore, optional filter callback
function Datastore:save_all(callback)

end

--- Unload all the keys in the datastore, optional filter callback
function Datastore:unload_all(callback)

end

--- Set a callback that will be used to serialize keys which aren't strings
function Datastore:set_serializer(callback)

end

----- Events -----

--- Register a callback that triggers only when data is received
function Datastore:on_received(callback)

end

--- Register a callback that triggers before data is saved
function Datastore:on_save(callback)

end

--- Register a callback that triggers before data is unloaded
function Datastore:on_unload(callback)

end

--- Register a callback that triggers when a message is received
function Datastore:on_message(callback)

end

--- Register a callback that triggers any time a value is changed
function Datastore:on_update(callback)

end

----- Module Return -----
return DatastoreManager