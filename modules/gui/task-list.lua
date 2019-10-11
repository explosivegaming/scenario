--[[-- Gui Module - Task List
    - Adds a task list to the game which players can add remove and edit items on
    @gui Task-List
    @alias task_list
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Event = require 'utils.event' --- @dep utils.event
local Roles = require 'expcore.roles' --- @dep expcore.roles
local config = require 'config.tasks' --- @dep config.tasks
local format_time,table_keys = ext_require('expcore.common','format_time','table_keys') --- @dep expcore.common
local Tasks = require 'modules.control.tasks' --- @dep modules.control.tasks

--- If a player is allowed to use the edit buttons
local function player_allowed_edit(player,task)
    if task then
        if config.user_can_edit_own_tasks and task.last_edit_player == player.name then
            return true
        end
    else
        if config.any_user_can_add_new_task then
            return true
        end
    end

    if config.only_admins_can_edit and not player.admin then
        return false
    end

    if config.edit_tasks_role_permission and not Roles.player_allowed(player,config.edit_tasks_role_permission) then
        return false
    end

    return true
end

--- Button in the header to add a new task
-- @element add_new_task
local add_new_task =
Gui.new_button()
:set_sprites('utility/add')
:set_tooltip{'task-list.add-tooltip'}
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.height = 20
    style.width = 20
end)
:on_click(function(player,element)
    Tasks.add_task(player.force.name,nil,player.name)
end)

--- Used to save changes to a task
-- @element confirm_edit
local confirm_edit =
Gui.new_button()
:set_sprites('utility/downloaded')
:set_tooltip{'task-list.confirm-tooltip'}
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.height = 20
    style.width = 20
end)
:on_click(function(player,element)
    local task_id = element.parent.name
    local new_message = element.parent.task.text
    Tasks.set_editing(task_id,player.name)
    Tasks.update_task(task_id,new_message,player.name)
end)

--- Used to cancel any changes you made to a task
-- @element cancel_edit
local cancel_edit =
Gui.new_button()
:set_sprites('utility/close_black')
:set_tooltip{'task-list.cancel-tooltip'}
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.height = 20
    style.width = 20
end)
:on_click(function(player,element)
    local task_id = element.parent.name
    Tasks.set_editing(task_id,player.name)
end)

--- Removes the task from the list
-- @element discard_task
local discard_task =
Gui.new_button()
:set_sprites('utility/trash')
:set_tooltip{'task-list.discard-tooltip'}
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.height = 20
    style.width = 20
end)
:on_click(function(player,element)
    local task_id = element.parent.name
    Tasks.remove_task(task_id)
end)

--- Opens edit mode for the task
-- @element edit_task
local edit_task =
Gui.new_button()
:set_sprites('utility/rename_icon_normal')
:set_tooltip{'task-list.edit-tooltip-none'}
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.height = 20
    style.width = 20
end)
:on_click(function(player,element)
    local task_id = element.parent.name
    Tasks.set_editing(task_id,player.name,true)
end)

--[[ Generates each task, handles both view and edit mode
    element
    > count-"task_id"
    >> label
    > "task_id"
    >> task
    >> cancel_edit (edit mode)
    >> confirm_edit (edit mode)
    > edit-"task_id"
    >> edit_task
    >> discard_task
]]
local function generate_task(player,element,task_id)
    local task = Tasks.get_task(task_id)
    local task_ids = Tasks.get_force_task_ids(player.force.name)
    local task_number = table.index_of(task_ids, task_id)

    if not task then
        -- task is nil so remove it from the list
        element.parent.no_tasks.visible = #task_ids == 1
        Gui.destroy_if_valid(element['count-'..task_id])
        Gui.destroy_if_valid(element['edit-'..task_id])
        Gui.destroy_if_valid(element[task_id])

    else
        local message = task.message
        local editing = task.curently_editing[player.name]
        local last_edit_name = task.last_edit_name
        local last_edit_time = task.last_edit_time

        element.parent.no_tasks.visible = false
        -- if it is not already present then add it now
        local task_area = element[task_id]
        if not task_area then
            -- label to show the task number
            element.add{
                name='count-'..task_id,
                type='label',
                caption=task_number..')'
            }

            -- area which stores the task and buttons
            task_area =
            element.add{
                name=task_id,
                type='flow',
            }
            Gui.set_padding(task_area)

            -- if the player can edit then it adds the edit and delete button
            local flow = Gui.create_alignment(element,'edit-'..task_id)
            local sub_flow = flow.add{type='flow',name=task_id}

            edit_task(sub_flow)
            discard_task(sub_flow)

        end

        -- update the number indexes and the current editing players
        element['count-'..task_id].caption = task_number..')'

        local edit_area = element['edit-'..task_id][task_id]
        local players = table_keys(task.editing)
        local allowed = player_allowed_edit(player,task)

        edit_area.visible = allowed

        if #players > 0 then
            edit_area[edit_task.name].tooltip = {'task-list.edit-tooltip',table.concat(players,', ')}
        else
            edit_area[edit_task.name].tooltip = {'task-list.edit-tooltip-none'}
        end

        -- draws/updates the task area
        local element_type = task_area.task and task_area.task.type or nil
        if not editing and element_type == 'label' then
            -- update the label already present
            task_area.task.caption = message
            task_area.task.tooltip = {'task-list.last-edit',last_edit_name,format_time(last_edit_time)}

        elseif not editing then
            -- create the label, view mode
            if edit_area then
                edit_area[edit_task.name].enabled = true
            end

            task_area.clear()

            local label =
            task_area.add{
                name='task',
                type='label',
                caption=message,
                tooltip={'task-list.last-edit',last_edit_name,format_time(last_edit_time)}
            }
            label.style.single_line = false
            label.style.maximal_width = 150

        elseif editing and element_type ~= 'textfield' then
            -- create the text field, edit mode, update it omitted as value is being edited
            if edit_area then
                edit_area[edit_task.name].enabled = false
            end

            task_area.clear()

            local entry =
            task_area.add{
                name='task',
                type='textfield',
                text=message
            }
            entry.style.maximal_width = 150
            entry.style.height = 20

            cancel_edit(task_area)
            confirm_edit(task_area)

        end

    end

end

--[[ generates the main gui structure
    element
    > container
    >> header
    >>> right aligned add_new_task
    >> scroll
    >>> no_tasks
    >>> table
]]
local function generate_container(player,element)
    Gui.set_padding(element,2,2,2,2)
    element.style.minimal_width = 200

    -- main container which contains the other elements
    local container =
    element.add{
        name='container',
        type='frame',
        direction='vertical',
        style='window_content_frame_packed'
    }
    Gui.set_padding(container)
    container.style.vertically_stretchable = false

    -- main header for the gui
    local header_area = Gui.create_header(
        container,
        {'task-list.main-caption'},
        {'task-list.sub-tooltip'},
        true
    )

    --- Right aligned button to toggle the section
    if player_allowed_edit(player) then
        add_new_task(header_area)
    end

    -- table that stores all the data
    local flow_table = Gui.create_scroll_table(container,3,185)
    flow_table.draw_horizontal_lines = true
    flow_table.vertical_centering = false
    flow_table.style.top_cell_padding = 3
    flow_table.style.bottom_cell_padding = 3

    -- message to say that you have no tasks
    local non_made =
    flow_table.parent.add{
        name='no_tasks',
        type='label',
        caption={'task-list.no-tasks'}
    }
    non_made.style.width = 200
    non_made.style.single_line = false

    return flow_table
end

--- Registers the task list
-- @element task_list
local task_list =
Gui.new_left_frame('gui/task-list')
:set_sprites('utility/not_enough_repair_packs_icon')
:set_direction('vertical')
:set_tooltip{'task-list.main-tooltip'}
:set_open_by_default()
:on_creation(function(player,element)
    local data_table = generate_container(player,element)
    local task_ids = Tasks.get_force_task_ids(player.force.name)

    for _,task_id in pairs(task_ids) do
        generate_task(player,data_table,task_id)
    end
end)
:on_update(function(player,element)
    local data_table = element.container.scroll.table
    local task_ids = Tasks.get_force_task_ids(player.force.name)

    for _,task_id in pairs(task_ids) do
        generate_task(player,data_table,task_id)
    end
end)

--- When a new task is added it will udpate the task list for everyone on that force
Tasks.on_update(function(task,task_id)
    local players
    if task then
        local force = game.forces[task.force_name]
        players = force.players
    else
        players = game.connected_players
    end

    for _,player in pairs(players) do
        local frame = task_list:get_frame(player)
        local element = frame.container.scroll.table
        generate_task(player,element,task_id)
    end
end)

--- Makes sure the right buttons are present when roles change
Event.add(Roles.events.on_role_assigned,task_list 'redraw')
Event.add(Roles.events.on_role_unassigned,task_list 'redraw')

return task_list