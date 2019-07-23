--- This file contains all the different settings for the warp system and gui
-- @config Warps

return {
    recharge_time = 60, --- @setting recharge_time The amount of time in seconds that the player must wait between warps, acts as a balance
    update_smoothing = 10, --- @setting update_smoothing Higher is better, the amount of smoothing applied to recharge timer and other gui updates, max is 60
    minimum_distance = 100, --- @setting minimum_distance The minimum distance that must be between warp points, creating new ones is blocked when too close
    activation_range = 4, --- @setting activation_range The distance the player must be to a warp in order to use the warp gui, gui can still be viewed but not used
    spawn_activation_range = 20, --- @setting spawn_activation_range A second activation range which is used for the forces spawn point
    default_icon = 'discharge-defense-equipment', --- @setting default_icon The default icon which is used by warps; must be an item name
    user_can_edit_own_warps = false, --- @setting user_can_edit_own_warps When true the user can always edit warps which they created regardless of other settings
    any_user_can_add_new_warp = false, --- @setting any_user_can_add_new_warp When true any user is able to create new warps, however editing may still be restricted
    only_admins_can_edit = false, --- @setting only_admins_can_edit When true only admins can edit warps
    edit_warps_role_permission = 'gui/warp-list/edit', --- @setting edit_warps_role_permission Role permission used by the role system to allow editing warps
    bypass_warp_limits_permission = 'gui/warp-list/no-limit', --- @setting bypass_warp_limits_permission Role permission used by the role system to allow bypassing the time and distance restrictions
    entities = { --- @setting entities The entities which are created for warps
        {'small-lamp',-3,-2},{'small-lamp',-3,2},{'small-lamp',3,-2},{'small-lamp',3,2},
        {'small-lamp',-2,-3},{'small-lamp',2,-3},{'small-lamp',-2,3},{'small-lamp',2,3},
        {'small-electric-pole',-3,-3},{'small-electric-pole',3,3},{'small-electric-pole',-3,3},{'small-electric-pole',3,-3}
    },
    base_tile = 'tutorial-grid', --- @setting base_tile The tile which is used for the warps
    tiles = { --- @setting tiles The tiles which are created for warps
        {-3,-2},{-3,-1},{-3,0},{-3,1},{-3,2},{3,-2},{3,-1},{3,0},{3,1},{3,2},
        {-2,-3},{-1,-3},{0,-3},{1,-3},{2,-3},{-2,3},{-1,3},{0,3},{1,3},{2,3}
    }
}