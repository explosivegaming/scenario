--[[-- Control Module - Tasks
- Stores tasks for each force.
@control Tasks
@alias Tasks

@usage-- Making and then editing a new task
local task_id = Tasks.add_task(game.player.force.name,nil,game.player.name)

Tasks.update_task(task_id,'We need more iron!',game.player.name)

]]

local Store = require 'expcore.store' --- @dep expcore.store
local Global = require 'utils.global' --- @dep utils.global
local Token = require 'utils.token' --- @dep utils.token

local Tasks = {}

-- Global lookup table for force name to task ids
local force_tasks = {}
Global.register(force_tasks,function(tbl)
    force_tasks = tbl
end)

-- Task store is keyed by task id, value is a table
local task_store = Store.register()
Tasks.store = task_store

--- Setters.
-- functions used to created and alter tasks
-- @section setters

--[[-- Add a new task for a force, the task can be placed into a certain position for that force
@tparam string force_name the name of the force to add the task for
@tparam[opt] number task_number the order place to add the task to, appends to end if omited
@tparam[opt] string player_name the player who added this task, will cause them to be listed under editing
@treturn string the uid of the task which was created

@usage-- Adding a new task for your force
local task_id = Tasks.add_task(game.player.force.name,nil,game.player.name)

]]
function Tasks.add_task(force_name,task_number,player_name)
    -- Get a new task id
    local task_id = tostring(Token.uid())

    -- Get the existing tasks for this force
    local tasks = force_tasks[force_name]
    if not tasks then
        force_tasks[force_name] = {}
        tasks = force_tasks[force_name]
    end

    -- Insert the task id into the forces tasks
    if task_number then
        table.insert(tasks,task_number,task_id)
    else
        table.insert(tasks,task_id)
    end

    -- Create the editing table
    local editing = {}
    if player_name then
        editing[player_name] = true
    end

    -- Add the new task to the store
    Store.set(task_store,task_id,{
        task_id = task_id,
        force_name = force_name,
        message = 'New Task',
        last_edit_name = player_name or '<server>',
        last_edit_time = game.tick,
        curently_editing = editing
    })

    return task_id
end

--[[-- Removes a task and any data that is linked with it
@tparam string task_id the uid of the task which you want to remove

@usage-- Removing a task
Tasks.remove_task(task_id)

]]
function Tasks.remove_task(task_id)
    local task = Store.get(task_store,task_id)
    local force_name = task.force_name
    Store.clear(task_store,task_id)
    table.remove_element(force_tasks[force_name],task_id)
end

--[[-- Update the message and last edited information for a task
@tparam string task_id the uid of the task that you want to update
@tparam string new_message the message that you want to have for the task
@tparam[opt='server'] string player_name the name of the player who made the edit

@usage-- Updating the message for on a task
Task.update_task(task_id,'We need more iron!',game.player.name)

]]
function Tasks.update_task(task_id,new_message,player_name)
    Store.update(task_store,task_id,function(task)
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
Tasks.set_editing(task_id,game.player.name,true)

]]
function Tasks.set_editing(task_id,player_name,state)
    Store.update(task_store,task_id,function(task)
        task.curently_editing[player_name] = state
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
    Store.watch(task_store,handler)
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
    return Store.get(task_store,task_id)
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
local editing = Tasks.get_editing(task_id,game.player.name)

]]
function Tasks.get_editing(task_id,player_name)
    local task = Store.get(task_store,task_id)
    return task.curently_editing[player_name]
end

-- Module Return
return Tasks