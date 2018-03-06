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

local function _damage(reset)
    global.addons = not reset and global.addons or {}
    global.addons.damage = not reset and global.addons.damage or {}
    return global.addons.damage
end

Event.register(defines.events.on_entity_damaged,function(event)
    if event.force == nil or event.force ~= event.entity.force then return end
    if event.cause == nil or event.cause.name ~= 'player' then return end
    local player = Game.get_player(event.cause.player)
    if Ranking.get_rank(player):allowed('base-damage') then return end
    if not _damage()[player.index] then _damage()[player.index] = {0,0} end
    _damage()[player.index][1] = _damage()[player.index][1]+event.final_damage_amount
    if _damage()[player.index][2] < event.tick-300 then
        _damage()[player.index][2] = event.tick
        player_return({'base-damage.used'},defines.text_color.med,player)
        Admin.give_warning(player,'<server>','Damaged something inside the base. Total Delt: '.._damage()[player.index][1],4)
    end
end)

Event.register(defines.events.on_player_ammo_inventory_changed,function(event)
    local player = Game.get_player(event)
    if Ranking.get_rank(player):allowed('nuke') then return end
    local found = player.remove_item({name='atomic-bomb',count=1000})
    if not _damage()[player.index] then _damage()[player.index] = {0,0} end
    if found > 0 then
        Admin.move_item_to_spawn({name='atomic-bomb',count=found},player.surface)
        player_return({'base-damage.nuke'},defines.text_color.med,player)
        if _damage()[player.index][2] < event.tick-300 then
            _damage()[player.index][2] = event.tick
            Admin.give_warning(player,'<server>','Nukes are not allowed for your rank.',4)
        end
    end
end)