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

commands.add_command('bonus', 'Set your player bonus (default is 20, guest has 0)', {'bonus'}, function(event,args)
    local player = Game.get_player(event)
    local bonus = tonumber(args.bonus)
    if not bonus or bonus < 0 or bonus > 50 then player_return{'commands.invalid-range',0,50} return commands.error end
    for _,setting in pairs(settings) do player[setting.key] = setting.scale*math.floor(bonus)*0.01 end
    player_return('Bonus set to: '..math.floor(bonus)..'%')
end)

Event.register(defines.events.rank_change,function(event)
    local player = Game.get_player(event)
    if event.new_rank:allowed('bonus') then
        for _,setting in pairs(settings) do player[setting.key] = setting.scale*0.2 end
    else
        for _,setting in pairs(settings) do player[setting.key] = 0 end
    end
end)