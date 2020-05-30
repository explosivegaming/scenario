--- A list of all tracked statistics and the events which trigger them
-- @config Statistics

local e = defines.events -- order as per lua api as it was easier just to go down the list
return {
    Playtime = true, --- @setting Playtime If playtime is tracked for a player, play time measured in minutes
    AfkTime = true, --- @setting AfkTime If afk time is tracked for a player, play time measured in minutes, afk is once a player does nothing for 5 minutes
    DistanceTraveled = true, --- @setting DistanceTraveled If distance traveled is checked, only counts if not afk
    MachinesRemoved = true, --- @setting MachinesRemoved If removed machines are tracked, includes marked for decon and player mined entity
    TreesDestroyed = true, --- @setting OreMined If ore mined is tracked for a player, includes marked for decon and player mined entity but only trees
    OreMined = true, --- @setting OreMined If ore mined is tracked for a player, includes player mined entity but only ore
    DamageDealt = true, --- @setting DamageDealt If damage dealt is tracked for a player, includes any damage to entities not on the same force or neutral
    Kills = true, --- @setting Kills If kills are tracked for a player, includes all kills not on same force or neutral
    RocketsLaunched = true, --- @setting RocketsLaunched If the number of rockets launched should be tracked, done for all players on the force
    ResearchCompleted = true, --- @setting ResearchCompleted If the number of researches completed should be tracked, done for all players on the force
    counters = { --- @setting counters Simple statistics that just go up by one each time an event happens
        MachinesBuilt = e.on_built_entity,
        MapTagsMade = e.on_chart_tag_added,
        ChatMessages = e.on_console_chat,
        CommandsUsed = e.on_console_command,
        ItemsPickedUp = e.on_picked_up_item,
        TilesBuilt = e.on_player_built_tile,
        ItemsCrafted = e.on_player_crafted_item,
        MapsPlayed = e.on_player_created,
        DeconstructionPlanerUsed = e.on_player_deconstructed_area,
        Deaths = e.on_player_died,
        JoinCount = e.on_player_joined_game,
        TilesRemoved = e.on_player_mined_tile,
        CapsulesUsed = e.on_player_used_capsule
    }
}