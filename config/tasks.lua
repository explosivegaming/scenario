--- Config file for the tasks gui
-- @config Tasks

return {
    -- values can be all, admin, expcore.roles, none
    allow_add_task = 'all', --- @setting allow_add_task dictates who is allowed to add new tasks; values: all, admin, expcore.roles, none
    expcore_roles_add_permission = 'gui/task-list/add', --- @setting expcore_roles_add_permission if expcore.roles is used then this is the required permission
    -- values can be all, admin, expcore.roles, none
    allow_edit_task = 'expcore.roles', --- @setting allow_edit_task dictates who is allowed to edit existing tasks; values: all, admin, expcore.roles, none
    expcore_roles_edit_permission = 'gui/task-list/edit', --- @setting expcore_roles_edit_permission if expcore.roles is used then this is the required permission
    user_can_edit_own_tasks = true --- @settings if true then the user who made the task can edit it regardless of the allow_edit_task setting
}