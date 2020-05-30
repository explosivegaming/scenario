--[[-- Gui Module - Task List
    - Adds a task list to the game which players can add, remove and edit items on
    @gui Task-List
    @alias task_list
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Event = require 'utils.event' --- @dep utils.event
local Roles = require 'expcore.roles' --- @dep expcore.roles
local config = require 'config.gui.tasks' --- @dep config.gui.tasks
local Tasks = require 'modules.control.tasks' --- @dep modules.control.tasks
local format_time = _C.format_time --- @dep expcore.common

-- Styles used for sprite buttons
local Styles = {
    sprite20 = Gui.sprite_style(20),
    sprite22 = Gui.sprite_style(20, nil, { right_margin = -3 })
}

--- If a player is allowed to use the edit buttons
local function check_player_permissions(player, task)
    if task then
        -- When a task is given check if the player can edit it
        local allow_edit_task = config.allow_edit_task

        -- Check if the player being the last to edit will override existing permisisons
        if config.user_can_edit_own_tasks and task.last_edit_name == player.name then
            return true
        end

        -- Check player has permisison based on value in the config
        if allow_edit_task == 'all' then
            return true
        elseif allow_edit_task == 'admin' then
            return player.admin
        elseif allow_edit_task == 'expcore.roles' then
            return Roles.player_allowed(player, config.expcore_roles_allow_edit_task)
        end

        -- Return false as all other condidtions have not been met
        return false
    else
        -- When a task is not given check if the player can add a new task
        local allow_add_task = config.allow_add_task

        -- Check player has permisison based on value in the config
        if allow_add_task == 'all' then
            return true
        elseif allow_add_task == 'admin' then
            return player.admin
        elseif allow_add_task == 'expcore.roles' then
            return Roles.player_allowed(player, config.expcore_roles_allow_add_task)
        end

        -- Return false as all other condidtions have not been met
        return false
    end
end

--- Button displayed in the ehader bar, used to add a new task
-- @element add_new_task
local add_new_task =
Gui.element{
    type = 'sprite-button',
    sprite = 'utility/add',
    tooltip = {'task-list.add-tooltip'},
    style = 'tool_button'
}
:style(Styles.sprite20)
:on_click(function(player, _,_)
    Tasks.add_task(player.force.name, nil, player.name)
end)

--- Button displayed next to tasks which the user is can edit, used to start editing a task
-- @element edit_task
local edit_task =
Gui.element{
    type = 'sprite-button',
    sprite = 'utility/rename_icon_normal',
    tooltip = {'task-list.edit-tooltip-none'},
    style = 'tool_button'
}
:style(Styles.sprite20)
:on_click(function(player, element, _)
    local task_id = element.parent.name:sub(6)
    Tasks.set_editing(task_id, player.name, true)
end)

--- Button displayed next to tasks which the user is can edit, used to delete a task from the list
-- @element discard_task
local discard_task =
Gui.element{
    type = 'sprite-button',
    sprite = 'utility/trash',
    tooltip = {'task-list.discard-tooltip'},
    style = 'tool_button'
}
:style(Styles.sprite20)
:on_click(function(_, element, _)
    local task_id = element.parent.name:sub(6)
    Tasks.remove_task(task_id)
end)

--- Set of three elements which make up each row of the task table
-- @element add_task_base
local add_task_base =
Gui.element(function(_, parent, task_id)
    -- Add the task number label
    local task_number = parent.add{
        name = 'count-'..task_id,
        type = 'label',
        caption = '0)'
    }
    task_number.style.left_margin = 1

    -- Add a flow which will contain the task message and edit buttons
    local task_flow = parent.add{ name = task_id, type = 'flow', }
    task_flow.style.padding = 0

    -- Add the two edit buttons outside the task flow
    local edit_flow = Gui.alignment(parent, 'edit-'..task_id)
    edit_task(edit_flow)
    discard_task(edit_flow)

    -- Return the task flow as the main element
    return task_flow
end)

-- Removes the three elements that are added as part of the task base
local function remove_task_base(parent, task_id)
    Gui.destroy_if_valid(parent['count-'..task_id])
    Gui.destroy_if_valid(parent['edit-'..task_id])
    Gui.destroy_if_valid(parent[task_id])
end

--- Button displayed next to tasks which the user is currently editing, used to save changes
-- @element confirm_edit
local task_editing
local confirm_edit =
Gui.element{
    type = 'sprite-button',
    sprite = 'utility/confirm_slot',
    tooltip = {'task-list.confirm-tooltip'},
    style = 'shortcut_bar_button_green'
}
:style(Styles.sprite22)
:on_click(function(player, element, _)
    local task_id = element.parent.name
    local new_message = element.parent[task_editing.name].text
    Tasks.set_editing(task_id, player.name)
    Tasks.update_task(task_id, new_message, player.name)
end)

--- Button displayed next to tasks which the user is currently editing, used to discard changes
-- @element cancel_edit
local cancel_edit =
Gui.element{
    type = 'sprite-button',
    sprite = 'utility/close_black',
    tooltip = {'task-list.cancel-tooltip'},
    style = 'shortcut_bar_button_red'
}
:style(Styles.sprite22)
:on_click(function(player, element, _)
    local task_id = element.parent.name
    Tasks.set_editing(task_id, player.name)
end)

--- Editing state for a task, contrins a text field and the two edit buttons
-- @element task_editing
task_editing =
Gui.element(function(event_trigger, parent, task)
    local message = task.message

    -- Draw the element
    local element =
    parent.add{
        name = event_trigger,
        type = 'textfield',
        text = message,
        clear_and_focus_on_right_click = true
    }

    -- Add the edit buttons
    cancel_edit(parent)
    confirm_edit(parent)

    -- Return the element
    return element
end)
:style{
    maximal_width = 110,
    height = 20
}
:on_confirmed(function(player, element, _)
    local task_id = element.parent.name
    local new_message = element.text
    Tasks.set_editing(task_id, player.name)
    Tasks.update_task(task_id, new_message, player.name)
end)

--- Default state for a task, contains only a label with the task message
-- @element task_label
local task_label =
Gui.element(function(_, parent, task)
    local message = task.message
    local last_edit_name = task.last_edit_name
    local last_edit_time = task.last_edit_time
    -- Draw the element
    return parent.add{
        name = task_editing.name,
        type = 'label',
        caption = message,
        tooltip = {'task-list.last-edit', last_edit_name, format_time(last_edit_time)}
    }
end)
:style{
    single_line = false,
    maximal_width = 150
}

--- Updates a task for a player
local function update_task(player, task_table, task_id)
    local task = Tasks.get_task(task_id)
    local task_ids = Tasks.get_force_task_ids(player.force.name)
    local task_number = table.get_index(task_ids, task_id)

    -- Task no longer exists so should be removed from the list
    if not task then
        task_table.parent.no_tasks.visible = #task_ids == 0
        remove_task_base(task_table, task_id)
        return
    end

    -- Get the task flow for this task
    local task_flow = task_table[task_id] or add_task_base(task_table, task_id)
    task_table.parent.no_tasks.visible = false
    task_table['count-'..task_id].caption = task_number..')'

    -- Update the edit flow
    local edit_flow = task_table['edit-'..task_id]
    local player_allowed_edit = check_player_permissions(player, task)
    local players_editing = table.get_keys(task.currently_editing)
    local edit_task_element = edit_flow[edit_task.name]
    local discard_task_element = edit_flow[discard_task.name]

    edit_task_element.visible = player_allowed_edit
    discard_task_element.visible = player_allowed_edit
    if #players_editing > 0 then
        edit_task_element.hovered_sprite = 'utility/warning_icon'
        edit_task_element.tooltip = {'task-list.edit-tooltip', table.concat(players_editing, ', ')}
    else
        edit_task_element.hovered_sprite = edit_task_element.sprite
        edit_task_element.tooltip = {'task-list.edit-tooltip-none'}
    end

    -- Check if the player is was editing and/or currently editing
    local task_entry = task_flow[task_editing.name] or task_label(task_flow, task)
    local player_was_editing = task_entry.type == 'textfield'
    local player_is_editing = task.currently_editing[player.name]

    -- Update the task flow
    if not player_was_editing and not player_is_editing then
        -- Update the task message label
        local message = task.message
        local last_edit_name = task.last_edit_name
        local last_edit_time = task.last_edit_time
        task_entry.caption = message
        task_entry.tooltip = {'task-list.last-edit', last_edit_name, format_time(last_edit_time)}

    elseif player_was_editing and not player_is_editing then
        -- Player was editing but is no longer, remove text field and add label
        edit_task_element.enabled = true
        task_flow.clear()
        task_label(task_flow, task)

    elseif not player_was_editing and player_is_editing then
        -- Player was not editing but now is, remove label and add text field
        edit_task_element.enabled = false
        task_flow.clear()
        task_editing(task_flow, task).focus()
        task_table.parent.scroll_to_element(task_flow, 'top-third')

    end
end

-- Update all the tasks for a player
local function update_all_tasks(player, scroll_table)
    local task_ids = Tasks.get_force_task_ids(player.force.name)
    if #task_ids > 0 then
        for _, task_id in ipairs(task_ids) do
            update_task(player, scroll_table, task_id)
        end
    end
end

--- Main task list container for the left flow
-- @element task_list_container
local task_list_container =
Gui.element(function(event_trigger, parent)
    -- Draw the internal container
    local container = Gui.container(parent, event_trigger, 200)

    -- Draw the header
    local header = Gui.header(
        container,
        {'task-list.main-caption'},
        {'task-list.sub-tooltip'},
        true
    )

    -- Draw the new task button
    local player = Gui.get_player_from_element(parent)
    local add_new_task_element = add_new_task(header)
    add_new_task_element.visible = check_player_permissions(player)

    -- Draw the scroll table for the tasks
    local scroll_table = Gui.scroll_table(container, 190, 3)
    scroll_table.draw_horizontal_lines = true
    scroll_table.vertical_centering = false

    -- Change the style of the scroll table
    local scroll_table_style = scroll_table.style
    scroll_table_style.top_cell_padding = 3
    scroll_table_style.bottom_cell_padding = 3

    -- Draw the no tasks label
    local no_tasks_label =
    scroll_table.parent.add{
        name = 'no_tasks',
        type = 'label',
        caption = {'task-list.no-tasks'}
    }

    -- Change the style of the no tasks label
    local no_tasks_style = no_tasks_label.style
    no_tasks_style.padding = {2, 4}
    no_tasks_style.single_line = false
    no_tasks_style.width = 200

    -- Add any existing tasks
    local task_ids = Tasks.get_force_task_ids(player.force.name)
    if #task_ids > 0 then
        no_tasks_label.visible = false
        for _, task_id in ipairs(task_ids) do
            update_task(player, scroll_table, task_id)
        end
    end

    -- Return the exteral container
    return container.parent
end)
:add_to_left_flow(function(player)
    local task_ids = Tasks.get_force_task_ids(player.force.name)
    return #task_ids > 0
end)

--- Button on the top flow used to toggle the task list container
-- @element toggle_left_element
Gui.left_toolbar_button('utility/not_enough_repair_packs_icon', {'task-list.main-tooltip'}, task_list_container, function(player)
    return Roles.player_allowed(player, 'gui/task-list')
end)

--- When a new task is added it will update the task list for everyone on that force
Tasks.on_update(function(task_id, task, old_task)
    -- Get the force to update, task is nil when removed
    local force
    if task then
        force = game.forces[task.force_name]
    else
        force = game.forces[old_task.force_name]
    end

    -- Update the task for all the players on the force
    local task_ids = Tasks.get_force_task_ids(force.name)
    for _, player in pairs(force.connected_players) do
        local frame = Gui.get_left_element(player, task_list_container)
        local scroll_table = frame.container.scroll.table

        -- Update the task that was changed
        update_task(player, scroll_table, task_id)

        -- Update the numbering of the other tasks if the task was removed
        if not task then
            for task_number, next_task_id in pairs(task_ids) do
                scroll_table['count-'..next_task_id].caption = task_number..')'
            end
        end
    end

end)

--- Update the tasks when the player joins
Event.add(defines.events.on_player_joined_game, function(event)
    local player = game.players[event.player_index]
    local frame = Gui.get_left_element(player, task_list_container)
    local scroll_table = frame.container.scroll.table
    update_all_tasks(player, scroll_table)
end)

--- Makes sure the right buttons are present when roles change
local function role_update_event(event)
    local player = game.players[event.player_index]
    local container = Gui.get_left_element(player, task_list_container).container

    -- Update the tasks, incase the user can now edit them
    local scroll_table = container.scroll.table
    update_all_tasks(player, scroll_table)

    -- Update the new task button incase the user can now add them
    local add_new_task_element = container.header.alignment[add_new_task.name]
    add_new_task_element.visible = check_player_permissions(player)
end

Event.add(Roles.events.on_role_assigned, role_update_event)
Event.add(Roles.events.on_role_unassigned, role_update_event)