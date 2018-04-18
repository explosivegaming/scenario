--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local settings = {
    {key='character_mining_speed_modifier',scale=3},
    {key='character_crafting_speed_modifier',scale=3},
    {key='character_running_speed_modifier',scale=3},
    {key='character_build_distance_bonus',scale=20},
    {key='character_reach_distance_bonus',scale=20},
    {key='character_inventory_slots_bonus',scale=200}
}

local function _bonus(reset)
    global.addons = not reset and global.addons or {}
    global.addons.bonus = not reset and global.addons.bonus or {}
    return global.addons.bonus
end

commands.add_command('bonus', 'Set your player bonus (default is 20, guest has 0)', {'bonus'}, function(event,args)
    local player = Game.get_player(event)
    local bonus = tonumber(args.bonus)
    if not bonus or bonus < 0 or bonus > 50 then player_return{'commands.invalid-range',0,50} return commands.error end
    for _,setting in pairs(settings) do player[setting.key] = setting.scale*math.floor(bonus)*0.01 end
    _bonus()[player.index]=bonus
    player_return('Bonus set to: '..math.floor(bonus)..'%')
end)

Event.register(defines.events.rank_change,function(event)
    local player = Game.get_player(event)
    if event.new_rank:allowed('bonus') then
        for _,setting in pairs(settings) do player[setting.key] = setting.scale*0.2 end
        _bonus()[player.index]=20
    else
        for _,setting in pairs(settings) do player[setting.key] = 0 end
        _bonus()[player.index]=nil
    end
end)

Event.register(defines.events.on_player_respawned,function(event)
    local player = Game.get_player(event)
    local bonus = _bonus()[player.index]
    if bonus then
        for _,setting in pairs(settings) do player[setting.key] = setting.scale*math.floor(bonus)*0.01 end
    end
end)

Event.register(defines.events.on_player_died,function(event)
    local player = Game.get_player(event)
    if Ranking.get_rank(player):allowed('bonus-respawn') then
        player.ticks_to_respawn = 0
    end
end)