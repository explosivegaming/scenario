--[[-- Control Module - Tasks
- Stores tasks for each force.
@control Tasks
@alias Tasks

@usage-- Making and then editing a new task
local task_id = Tasks.add_task(game.player.force.name, nil, game.player.name)

Tasks.update_task(task_id, 'We need more iron!', game.player.name)

]]

local Datastore = require 'expcore.datastore' --- @dep expcore.datastore
local Global = require 'utils.global' --- @dep utils.global

--- Stores all data for the warp gui
local TaskData = Datastore.connect('TaskData')
TaskData:set_serializer(function(raw_key) return raw_key.task_id end)

local Tasks = {}

-- Global lookup table for force name to task ids
local force_tasks = {_uid=1}
Global.register(force_tasks, function(tbl)
    force_tasks = tbl
end)

--- Setters.
-- functions used to created and alter tasks
-- @section setters

--[[-- Add a new task for a force, the task can be placed into a certain position for that force
@tparam string force_name the name of the force to add the task for
@tparam[opt] number task_number the order place to add the task to, appends to end if omited
@tparam[opt] string player_name the player who added this task, will cause them to be listed under editing
@tparam[opt] string task_message the message that is used for this task, if not given default is used
@treturn string the uid of the task which was created

@usage-- Adding a new task for your force
local task_id = Tasks.add_task(game.player.force.name, nil, game.player.name)

]]
function Tasks.add_task(force_name, task_number, player_name, task_message)
    -- Get a new task id
    local task_id = tostring(force_tasks._uid)
    task_message = task_message or 'New Task'
    force_tasks._uid = force_tasks._uid + 1

    -- Get the existing tasks for this force
    local tasks = force_tasks[force_name]
    if not tasks then
        force_tasks[force_name] = {}
        tasks = force_tasks[force_name]
    end

    -- Insert the task id into the forces tasks
    if task_number then
        table.insert(tasks, task_number, task_id)
    else
        table.insert(tasks, task_id)
    end

    -- Create the editing table
    local editing = {}
    if player_name then
        editing[player_name] = true
    end

    -- Add the new task to the store
    TaskData:set(task_id, {
        task_id = task_id,
        force_name = force_name,
        message = task_message,
        last_edit_name = player_name or '<server>',
        last_edit_time = game.tick,
        currently_editing = editing
    })

    return task_id
end

--[[-- Removes a task and any data that is linked with it
@tparam string task_id the uid of the task which you want to remove

@usage-- Removing a task
Tasks.remove_task(task_id)

]]
function Tasks.remove_task(task_id)
    local task = TaskData:get(task_id)
    local force_name = task.force_name
    table.remove_element(force_tasks[force_name], task_id)
    TaskData:remove(task_id)
end

--[[-- Update the message and last edited information for a task
@tparam string task_id the uid of the task that you want to update
@tparam string new_message the message that you want to have for the task
@tparam[opt='server'] string player_name the name of the player who made the edit

@usage-- Updating the message for on a task
Task.update_task(task_id, 'We need more iron!', game.player.name)

]]
function Tasks.update_task(task_id, new_message, player_name)
    TaskData:update(task_id, function(_, task)
        task.last_edit_name = player_name or '<server>'
        task.last_edit_time = game.tick
        task.message = new_message
    end)
end

--[[-- Set the editing state for a player, can be used as a warning or to display a text field
@tparam string task_id the uid of the task that you want to effect
@tparam string player_name the name of the player you want to set the state for
@tparam boolean state the new state to set editing to

@usage-- Setting your editing state to true
Tasks.set_editing(task_id, game.player.name, true)

]]
function Tasks.set_editing(task_id, player_name, state)
    TaskData:update(task_id, function(_, task)
        task.currently_editing[player_name] = state
    end)
end

--[[-- Adds an update handler for when a task is added, removed, or updated
@tparam function handler the handler which is called when a task is updated

@usage-- Add a game print when a task is updated
Tasks.on_update(function(task)
    game.print(task.force_name..' now has the task: '..task.message)
end)

]]
function Tasks.on_update(handler)
    TaskData:on_update(handler)
end

--- Getters.
-- function used to get information about tasks
-- @section getters

--[[-- Gets the task information that is linked with this id
@tparam string task_id the uid of the task you want to get
@treturn table the task information

@usage-- Getting task information outside of on_update
local task = Tasks.get_task(task_id)

]]
function Tasks.get_task(task_id)
    return TaskData:get(task_id)
end

--[[-- Gets all the task ids that a force has
@tparam string force_name the name of the force that you want the task ids for
@treturn table an array of all the task ids

@usage-- Getting the task ids for a force
local task_ids = Tasks.get_force_task_ids(game.player.force.name)

]]
function Tasks.get_force_task_ids(force_name)
    return force_tasks[force_name] or {}
end

--[[-- Gets the editing state for a player
@tparam string task_id the uid of the task you want to check
@tparam string player_name the name of the player that you want to check
@treturn boolean weather the player is currently editing this task

@usage-- Check if a player is editing a task or not
local editing = Tasks.get_editing(task_id, game.player.name)

]]
function Tasks.get_editing(task_id, player_name)
    local task = TaskData:get(task_id)
    return task.currently_editing[player_name]
end

-- Module Return
return Tasks