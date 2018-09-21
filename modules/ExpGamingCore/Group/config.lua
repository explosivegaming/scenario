-- defines for groups
Group{
    name='Root',
    disallow={}
}

Group{
    name='Admin',
    disallow={
        'edit_permission_group',
        'delete_permission_group',
        'add_permission_group'
    }
}

Group{
    name='Member',
    disallow={
        'edit_permission_group',
        'delete_permission_group',
        'add_permission_group'
    }
}

Group{
    name='Guest',
    disallow={
        'edit_permission_group',
        'delete_permission_group',
        'add_permission_group'
    }
}