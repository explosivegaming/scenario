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
    sprite22 = { height = 22, width = 22, padding = -2 },
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
:style(Styles.sprite22)
:on_click(function(player, _,_)
    Tasks.add_task(player.force.name, player.name)
end)

--- Editing state for a task, contrins a text field and the two edit buttons
-- @element task_editing
local task_textfield =
Gui.element(function(event_trigger, parent, task)
    -- Draw the element
    local element =
    parent.add{
        name = event_trigger,
        type = 'textfield',
        text = task.message,
        clear_and_focus_on_right_click = true
    }

    -- Return the element
    return element
end)
:style{
    -- Needed fields to make it squashable and strechable.
    minimal_width = 10,
    maximal_width = 300,
    horizontally_squashable = "on",
    horizontally_stretchable = "on",
    -- Other styling
    height = 22,
    padding = -2,
    left_margin = 2,
    right_margin = 2,
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
Gui.element(function(event_trigger, parent, task)
    local last_edit_name = task.last_edit_name
    local last_edit_time = task.last_edit_time
    -- Draw the element
    return parent.add{
        name = event_trigger,
        type = 'label',
        caption = task.message,
        tooltip = {'task-list.last-edit', last_edit_name, format_time(last_edit_time)}
    }
end)
:style{
    single_line = false,
    vertically_stretchable = true,
    horizontally_stretchable = true
}

--- Button displayed next to tasks which the user is can edit, used to start editing a task
-- @element edit_task_button
local edit_task_button =
Gui.element{
    type = 'sprite-button',
    sprite = 'utility/rename_icon_normal',
    tooltip = {'task-list.edit-tooltip-none'},
    style = 'shortcut_bar_button'
}
:style(Styles.sprite22)
:on_click(function(player, element, _)
    local task_id = element.parent.caption
    Tasks.set_editing(task_id, player.name, true)
end)

--- Button displayed next to tasks which the user is can edit, used to remove a task from the list
-- @element remove_task_button
local remove_task_button =
Gui.element{
    type = 'sprite-button',
    sprite = 'utility/trash',
    tooltip = {'task-list.discard-tooltip'},
    style = 'shortcut_bar_button_red'
}
:style(Styles.sprite22)
:on_click(function(_, element, _)
    local task_id = element.parent.caption
    Tasks.remove_task(task_id)
end)

-- Removes the three elements that are added as part of the task base
local function remove_task_base(parent, task_id)
    Gui.destroy_if_valid(parent['count-'..task_id])
    Gui.destroy_if_valid(parent['name-'..task_id])
    Gui.destroy_if_valid(parent['button-'..task_id])
end

--- Button displayed next to tasks which the user is currently editing, used to save changes
-- @element confirm_edit_button
local confirm_edit_button =
Gui.element{
    type = 'sprite-button',
    sprite = 'utility/confirm_slot',
    tooltip = {'task-list.confirm-tooltip'},
    style = 'shortcut_bar_button_green'
}
:style(Styles.sprite22)
:on_click(function(player, element, _)
    local task_id = element.parent.caption
    local new_message = element.parent.parent['name-'..task_id][task_textfield.name].text
    Tasks.set_editing(task_id, player.name)
    Tasks.update_task(task_id, new_message, player.name)
end)

--- Button displayed next to tasks which the user is currently editing, used to cancel changes
-- @element cancel_edit_button
local cancel_edit_button =
Gui.element{
    type = 'sprite-button',
    sprite = 'utility/close_black',
    tooltip = {'task-list.cancel-tooltip'},
    style = 'shortcut_bar_button_red'
}
:style(Styles.sprite22)
:on_click(function(player, element, _)
    local task_id = element.parent.caption
    Tasks.set_editing(task_id, player.name)
end)

--- Set of three elements which make up each row of the task table
-- @element add_task_elements
local add_task_elements =
Gui.element(function(_, parent, task)
    -- Add the task number label
    local task_number = parent.add{
        name = 'count-'..task.task_id,
        type = 'label',
        caption = '#)'
    }
    task_number.style.padding = 0
    task_number.style.font = 'default-semibold'

    -- Add name flow this will contain the task label and textbox
    local task_flow = parent.add{
        name = 'name-'..task.task_id,
        type = 'flow',
        caption = task.task_id,
    }
    task_flow.style.padding = 0

    -- Add the label and textfield of the task
    task_label(task_flow, task)
    task_textfield(task_flow, task)

    -- Add button flow this will contain buttons to manage this specific task
    local button_flow = parent.add{
        name = 'button-'..task.task_id,
        type = 'flow',
        caption = task.task_id,
    }
    button_flow.style.padding = 0

    -- Add both edit state buttons
    cancel_edit_button(button_flow)
    confirm_edit_button(button_flow)
    edit_task_button(button_flow)
    remove_task_button(button_flow)

    -- Return the task flow as the main element
    return { task_flow, button_flow }
end)

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
    if not task_table['name-'..task_id] then
        add_task_elements(task_table, task)
    end
    local count_flow = task_table['count-'..task_id]
    local name_flow = task_table['name-'..task_id]
    local button_flow = task_table['button-'..task_id]
    task_table.parent.no_tasks.visible = false
    count_flow.caption = task_number..')'

    -- Create local references to the elements for this task
    local label_element = name_flow[task_label.name]
    local textfield_element = name_flow[task_textfield.name]

    local cancel_edit_element = button_flow[cancel_edit_button.name]
    local confirm_edit_element = button_flow[confirm_edit_button.name]

    local edit_task_element = button_flow[edit_task_button.name]
    local remove_task_element = button_flow[remove_task_button.name]

    -- Hide the edit button if the player is not allowed to edit the task
    local player_allowed_edit = check_player_permissions(player, task)
    local players_editing = table.get_keys(task.currently_editing)
    edit_task_element.visible = player_allowed_edit
    remove_task_element.visible = player_allowed_edit

    if #players_editing > 0 then
        edit_task_element.hovered_sprite = 'utility/warning_icon'
        edit_task_element.tooltip = {'task-list.edit-tooltip', table.concat(players_editing, ', ')}
    else
        edit_task_element.hovered_sprite = edit_task_element.sprite
        edit_task_element.tooltip = {'task-list.edit-tooltip-none'}
    end

    -- Check if the player is editing the task
    local player_is_editing = task.currently_editing[player.name]

    if player_is_editing then
        -- Set the name elements visibility
        label_element.visible = false
        textfield_element.visible = true
        textfield_element.focus()
        task_table.parent.scroll_to_element(textfield_element, 'top-third')

        -- Set the edit buttons
        cancel_edit_element.visible = true
        confirm_edit_element.visible = true
        -- Set the task buttons
        edit_task_element.visible = false
        remove_task_element.visible = false
    else
        -- Set the name elements visibility
        label_element.visible = true
        label_element.caption = task.message
        local last_edit_name = task.last_edit_name
        local last_edit_time = task.last_edit_time
        label_element.tooltip = {'task-list.last-edit', last_edit_name, format_time(last_edit_time)}
        textfield_element.visible = false
        textfield_element.focus()
        task_table.parent.scroll_to_element(textfield_element, 'top-third')

        -- Set the edit buttons
        cancel_edit_element.visible = false
        confirm_edit_element.visible = false
        -- Set the task buttons
        edit_task_element.visible = true and player_allowed_edit
        remove_task_element.visible = true and player_allowed_edit
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
    local container = Gui.container(parent, event_trigger, 268)

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
    -- Set the scroll panel to always show the scrollbar (not doing this will result in a changing gui size)
    scroll_table.parent.vertical_scroll_policy = 'always'
    scroll_table.draw_horizontal_lines = true
    scroll_table.vertical_centering = false

    -- Change the style of the scroll table
    local scroll_table_style = scroll_table.style
    scroll_table_style.top_cell_padding = 2
    scroll_table_style.bottom_cell_padding = 4

    -- Draw the no tasks label
    local no_tasks_label =
    scroll_table.parent.add{
        name = 'no_tasks',
        type = 'label',
        caption = {'task-list.no-tasks'}
    }

    -- Change the style of the no tasks label
    local no_tasks_style = no_tasks_label.style
    no_tasks_style.padding = {4, 4}
    no_tasks_style.single_line = true
    no_tasks_style.horizontally_stretchable = true

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