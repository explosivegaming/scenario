-- config file for the tasks gui
return {
    any_user_can_add_new_task = true, -- when false only people with edit permission can make new reports
    user_can_edit_own_tasks = true, -- when false only people with edit permission can edit reports
    only_admins_can_edit = false, -- true will hide the edit and delete buttons from non (game) admins
    edit_tasks_role_permision = 'gui/task-list/edit' -- value used with custom permision system
}