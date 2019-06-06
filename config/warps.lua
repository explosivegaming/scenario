return {
    time_limit = 60,
    minimum_distance = 25,
    warp_radius = 4,
    spawn_radius_scale = 5,
    default_icon = 'discharge-defense-equipment',
    user_can_edit_own_tasks = true,
    only_admins_can_edit = false,
    edit_warps_role_permision = 'gui/warp-list/edit',
    entities = {
        {'small-lamp',-3,-2},{'small-lamp',-3,2},{'small-lamp',3,-2},{'small-lamp',3,2},
        {'small-lamp',-2,-3},{'small-lamp',2,-3},{'small-lamp',-2,3},{'small-lamp',2,3},
        {'small-electric-pole',-3,-3},{'small-electric-pole',3,3},{'small-electric-pole',-3,3},{'small-electric-pole',3,-3}
    },
    base_tile = 'tutorial-grid',
    tiles = {
        {-3,-2},{-3,-1},{-3,0},{-3,1},{-3,2},{3,-2},{3,-1},{3,0},{3,1},{3,2},
        {-2,-3},{-1,-3},{0,-3},{1,-3},{2,-3},{-2,3},{-1,3},{0,3},{1,3},{2,3}
    }
}