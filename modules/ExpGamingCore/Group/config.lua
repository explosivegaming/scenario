-- defines for groups
Group{
    name='_root',
    disallow={}
}

Group{
    name='_admin',
    disallow={
        'edit_permission_group',
        'delete_permission_group',
        'add_permission_group'
    }
}

Group{
    name='_member',
    disallow={
        'edit_permission_group',
        'delete_permission_group',
        'add_permission_group'
    }
}

Group{
    name='_guest',
    disallow={
        'edit_permission_group',
        'delete_permission_group',
        'add_permission_group'
    }
}