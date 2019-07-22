--[[-- Control Module - Tasks
    - Stores tasks for each force.
    @control Tasks
    @alias Tasks

    @usage
    -- import the module from the control modules
    local Tasks = require 'modules.control.tasks'

    -- To create a new task all you need is the name of the force you want to add the task to
    -- you can give a place to add it but this is optional
    Tasks.new_task('player')

    -- You can then update this task to what ever value that you want
    -- the task id is returned by new_task, or within an update handler
    -- if a player name is not given that it will assume '<server>'
    Tasks.update_task(task_id,'My number one task!','Cooldude2606')

    -- You can then remove the task and all data linked with it
    Tasks.remove_task(task_id)

    -- set_editing and is_editing may be used to block other or provide warnings
    -- none of this is enforced by this module and so you must do so in your own module
    Tasks.set_editing(task_id,'Cooldude2606',true)

]]

--- Allows storing of task ids
-- @dep expcore.store
local Store = require 'expcore.store'
--- Allows storing in the global table
-- @dep utils.global
local Global = require 'utils.global'
--- Allows non conflicting task ids
-- @dep utils.token
local Token = require 'utils.token'

local Tasks = {
    store = 'gui.left.task-list.tasks',
    handlers = {},
    details = {},
    forces = {}
}

local task_details = Tasks.details
local force_tasks = Tasks.forces
Global.register({
    task_details=task_details,
    force_tasks=force_tasks
},function(tbl)
    task_details = tbl.task_details
    force_tasks = tbl.force_tasks
end)

local task_store = Tasks.store
Store.register(task_store,function(value,task_id)
    local details = task_details[task_id]
    local force = game.forces[details.force]
    for _,handler in pairs(Tasks.handlers) do
        handler(force,task_id)
    end
end)

--- Setters.
-- functions used to created and alter tasks
-- @section setters

--- Adds a new handler for when a task is updated
-- @tparam function callback the callback which is ran when a task is updated
-- @treturn boolean true if the callback was added
function Tasks.add_handler(callback)
    if type(callback) == 'function' then
        table.insert(Tasks.handlers,callback)
        return true
    end
    return false
end

--- Adds a new task for a force, with option to place it in a certain order
-- @tparam string force_name the name of the force to add the task for
-- @tparam[opt] number task_number the order place to add the task to, adds to end if omited
-- @tparam[opt] string player_name when given this player will be added to the editing list
-- @treturn string the uid of the task which was created
function Tasks.new_task(force_name,task_number,player_name)
    local task_id = tostring(Token.uid())

    local tasks = force_tasks[force_name]
    if not tasks then
        force_tasks[force_name] = {}
        tasks = force_tasks[force_name]
    end

    if task_number then
        table.insert(tasks,task_number,task_id)
    else
        table.insert(tasks,task_id)
    end

    task_details[task_id] = {
        task_id=task_id,
        force=force_name,
        last_edit_player=player_name or '<server>',
        last_edit_time=game.tick,
        editing={}
    }

    if player_name then
        task_details[task_id].editing[player_name] = true
    end

    Store.set(task_store,task_id,'New Task')

    return task_id
end

--- Removes a task and all data linked with it
-- @tparam string task_id the uid of the task which you want to remove
function Tasks.remove_task(task_id)
    local details = task_details[task_id]
    local force = details.force
    Store.clear(task_store,task_id)
    task_details[task_id] = nil
    table.remove_element(force_tasks[force],task_id)
end

--- Updates a task message
-- @tparam string task_id the uid of the task that you want to update
-- @tparam string task the message that you want to change the task to
-- @tparam[opt='server'] string player_name the name of the player who made the edit
function Tasks.update_task(task_id,task,player_name)
    local details = task_details[task_id]
    details.last_edit_player = player_name or '<server>'
    details.last_edit_time = game.tick
    Store.set(task_store,task_id,task)
end

--- Sets a player to be editing this task, used with is_editing
-- @tparam string task_id the uid of the task that you want to editing for
-- @tparam string player_name the name of the player you want to set editing for
-- @tparam[opt] boolean state the new state to set editing to
function Tasks.set_editing(task_id,player_name,state)
    local details = task_details[task_id]
    details.editing[player_name] = state
end

--- Getters.
-- function used to get information about tasks
-- @section getters

--- Gets the task stored at this id
-- @tparam string task_id the uid of the task you want to get
-- @treturn string the task message that was stored here
function Tasks.get_task(task_id)
    return Store.get(task_store,task_id)
end

--- Gets the task details stored at this id
-- @tparam string task_id the uid of the task you want to get
-- @treturn table the task details that was stored here
function Tasks.get_details(task_id)
    return task_details[task_id]
end

--- Gets the task ids for a force
-- @tparam string force_name the name of the force that you want the ids for
-- @treturn table an array of all the task ids
function Tasks.get_force_tasks(force_name)
    return force_tasks[force_name] or {}
end

--- Gets if a player is currently editing this task
-- @tparam string task_id the uid of the task you want to check
-- @tparam string player_name the name of the player that you want to check
-- @treturn boolean weather the player is currently editing this task
function Tasks.is_editing(task_id,player_name)
    local details = task_details[task_id]
    return details.editing[player_name]
end

return Tasks