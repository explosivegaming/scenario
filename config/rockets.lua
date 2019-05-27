--- This file controls what will show in each section of the rocket info gui
-- each function will be given the player and must return the value to show and a tooltip, nil will not show the stat
local Global = require 'utils.global'
local Event = require 'utils.event'

return {
    stats = {
        show_stats=true,
        show_first_rocket = true,
        show_last_rocket = true,
        show_fastest_rocket = true,
        show_total_rockets = true,
        show_game_avg = true,
        rolling_avg = {
            5,10,25
        }
    },
    milestones = {
        show_milestones=true,
        1,2,5,
        10,20,50,
        100,200,500,
        1000,1500,2000,2500,
        3000,3500,4000,4500,
        5000
    },
    progress = {
        show_progress = true,
        allow_zoom_to_map = true,
        allow_remote_launch = true,
        remote_launch_admins_only = false,
        remote_launch_role_permision = 'gui/rocket-info/remote_launch',
        allow_toggle_active = true,
        toggle_active_admins_only = false,
        toggle_active_role_permision = 'gui/rocket-info/toggle-active'
    }
}