--- This file contains all the different settings for the warp system and gui
return {
    recharge_time = 60, -- The amount of time in seconds that the player must wait between warps, acts as a balance
    update_smoothing = 10, -- Higher is better, the amount of smothing applied to recharge timer and other gui updates, max is 60
    minimum_distance = 100, -- The minimum distance that must be between warp points, creating new ones is blocked when too close
    activation_range = 4, -- The distance the player must be to a warp in order to use the warp gui, gui can still be viewd but not used
    spawn_activation_range = 20, -- A second activation range which is used for the forces spawn point
    default_icon = 'discharge-defense-equipment', -- The deafult icon which is used by warps; must be an item name
    user_can_edit_own_warps = false, -- When true the user can always edit warps which they created regaudless of other settings
    any_user_can_add_new_warp = false, -- When true any user is able to create new warps, however editing may still be restricted
    only_admins_can_edit = false, -- When true only admins can edit warps
    edit_warps_role_permision = 'gui/warp-list/edit', -- Role permission used by the role system to allow editing warps
    bypass_warp_limits_permision = 'gui/warp-list/no-limit', -- Role permission used by the role system to allow bypassing the time and distance restrctions
    entities = { -- The entites which are created for warps
        {'small-lamp',-3,-2},{'small-lamp',-3,2},{'small-lamp',3,-2},{'small-lamp',3,2},
        {'small-lamp',-2,-3},{'small-lamp',2,-3},{'small-lamp',-2,3},{'small-lamp',2,3},
        {'small-electric-pole',-3,-3},{'small-electric-pole',3,3},{'small-electric-pole',-3,3},{'small-electric-pole',3,-3}
    },
    base_tile = 'tutorial-grid', -- The tile which is used for the warps
    tiles = { -- The tiles which are created for warps
        {-3,-2},{-3,-1},{-3,0},{-3,1},{-3,2},{3,-2},{3,-1},{3,0},{3,1},{3,2},
        {-2,-3},{-1,-3},{0,-3},{1,-3},{2,-3},{-2,3},{-1,3},{0,3},{1,3},{2,3}
    }
}