--- This file controls what will show in each section of the rocket info gui
return {
    stats = { --- The data that will show in the stats section
        show_stats=true, -- false will hide this section all together
        show_first_rocket = true, -- false will not show when the first rocket was launched
        show_last_rocket = true, -- false will not show when the last rocket was launched
        show_fastest_rocket = true, -- false will not show the time taken for the fastest rocket
        show_total_rockets = true, -- false will not show the total number of rockets launched
        show_game_avg = true, -- false will hide the avg across the entire map time
        rolling_avg = { -- each number will be one statistic; 5 means the avg time taken for the last 5 rockets
            5,10,25
        }
    },
    milestones = { -- each number will be one statistic; 5 means the time that the 5th rocket was launched
        show_milestones=true, -- false will hide this section all together
        1,2,5,
        10,20,50,
        100,200,500,
        1000,1500,2000,2500,
        3000,3500,4000,4500,
        5000
    },
    progress = { --- The data and buttons in the build progress section
        show_progress = true, -- false will hide this section altogether
        allow_zoom_to_map = true, -- false will disable the zoom to map feature
        allow_remote_launch = true, -- false removes the remote launch button for all players
        remote_launch_admins_only = false, -- true will remove the remote launch button for all non (game) admins
        remote_launch_role_permission = 'gui/rocket-info/remote_launch', -- value used by custom permission system to allow or disallow the button
        allow_toggle_active = true, -- false removes the remote toggle auto launch button for all players
        toggle_active_admins_only = false, -- true will remove the toggle auto launch button for all non (game) admins
        toggle_active_role_permission = 'gui/rocket-info/toggle-active' -- value used by custom permission system to allow or disallow the button
    }
}