--- This config controls what happens when a player dies mostly about map markers and item collection
-- allow_teleport_to_body_command and allow_collect_bodies_command can be over ridden if command_auth_runtime_disable is present
-- if not present then the commands will not be loaded into the game
return {
    allow_teleport_to_body_command=false, -- allows use of /return-to-body which teleports you to your last death
    allow_collect_bodies_command=false, -- allows use of /collect-body which returns all your items to you and removes the body
    use_chests_as_bodies=false, -- weather items should be moved into a chest when a player dies
    auto_collect_bodies=false, -- enables items being returned to the spawn point in chests upon death
    show_map_markers=true, -- shows markers on the map where bodies are
    include_time_of_death=true, -- weather to include the time of death on the map marker
    map_icon='' -- the icon that the map marker shows '' means no icon
}