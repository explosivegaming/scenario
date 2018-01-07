--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

-- alot of this is copied from redmew - but it has been reworked to use the ExpCore
-- https://github.com/Valansch/RedMew/blob/develop/nuke_control.lua

local const = 8 -- this is how many entites must be found in order to give a warning
-- false means that it cant be used
local capsules = {
    ['artillery-targeting-remote']=false,
    ['cliff-explosives']=true,
    ['cluster-grenade']=false,
    ['defender-capsule']=true,
    ['destroyer-capsule']=true,
    ['discharge-defense-remote']=true,
    ['distractor-capsule']=true,
    ['grenade']=false,
    ['poison-capsule']=false,
    ['raw-fish']=true,
    ['slowdown-capsule']=true,
}

Event.register(defines.events.on_player_used_capsule,function(event)
    local player = Game.get_player(event)
    local item = event.item
    if capsules[item.name] or Ranking.get_rank(player):allowed('capsules') then return end
    local x,y = event.position.x, event.position.y
    local player_entities = player.surface.count_entities_filtered{
        force=player.force,
        area={{x-5,y-5},{x+5,y+5}}
    }
    if player_entities < const then return end
    player_return({'capsules.used',item.name},defines.text_color.med,player)
    Admin.give_warning(player,'<server>','Using '..item.name..' inside the base.',4)
end)

Event.register(defines.events.on_player_ammo_inventory_changed,function(event)
    local player = Game.get_player(event)
    if Ranking.get_rank(player):allowed('nuke') then return end
    local found = player.remove_item({name='atomic-bomb',count=1000})
    if found > 0 then
        Admin.move_item_to_spawn({name='atomic-bomb',count=found},player.surface)
        player_return({'capsules.nuke'},defines.text_color.med,player)
        Admin.give_warning(player,'<server>','Nukes are not allowed for your rank.',4)
    end
end)