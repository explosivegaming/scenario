--- Config file for the tasks gui
-- @config Tasks

return {
    any_user_can_add_new_task = true, --- @setting any_user_can_add_new_task when false only people with edit permission can make new reports
    user_can_edit_own_tasks = true, --- @setting user_can_edit_own_tasks when false only people with edit permission can edit reports
    only_admins_can_edit = false, --- @setting only_admins_can_edit true will hide the edit and delete buttons from non (game) admins
    edit_tasks_role_permission = 'gui/task-list/edit' --- @setting edit_tasks_role_permission value used with custom permission system
}