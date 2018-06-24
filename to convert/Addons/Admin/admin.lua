--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

Admin = Admin or {}

local function append_name(reason,name)
    local reason = reason or 'No Reason'
    if not string.find(string.lower(reason),string.lower(name)) then return reason..' - '..name
    else return reason end
end

local function open(player,pre_select_player,pre_select_action)
    if Admin.center then Gui.center.clear(player) Admin.center.open(player,pre_select_player,pre_select_action) end
end

function Admin.allowed(player)
    local player = Game.get_player(player)
    local lowest_admin_power = Ranking.get_group('Admin').lowest.power
    return lowest_admin_power >= Ranking.get_rank(player).power
end

function Admin.btn_flow(frame,buttons)
    local frame = frame.add{
        type='flow',
        name='admin'
    }
    frame.add{
        type='label',
        caption='',
        name='player'
    }.style.visible = false
    local function format(btn)
        btn.style.height = 30
        btn.style.width = 30
    end
    if not buttons or buttons.ban then format(Admin.ban_btn:draw(frame)) end
    if not buttons or buttons.kick then format(Admin.kick_btn:draw(frame)) end
    if not buttons or buttons.jail then format(Admin.jail_btn:draw(frame)) end
    if not buttons or buttons.go_to then format(Admin.go_to_btn:draw(frame)) end
    if not buttons or buttons.bring then format(Admin.bring_btn:draw(frame)) end
    return frame.player
end

function Admin.take_action(action,player,by_player,reason)
    if action == 'Ban' then Admin.ban(player,by_player,reason)
    elseif action == 'Temp Ban' and Admin.temp_ban then Admin.temp_ban(player,by_player,reason)
    elseif action == 'Kick' then Admin.kick(player,by_player,reason)
    elseif action == 'Jail' then Admin.jail(player,by_player,reason)
    elseif action == 'GoTo' then Admin.go_to(player,by_player)
    elseif action == 'Bring' then Admin.bring(player,by_player)
    end
end

local inventorys = {
    defines.inventory.player_main,
    defines.inventory.player_quickbar,
    defines.inventory.player_trash,
    defines.inventory.player_guns,
    defines.inventory.player_ammo,
    defines.inventory.player_armor,
    defines.inventory.player_armor
}

function Admin.move_item_to_spawn(item,surface,chests)
    local chests = chests or surface.find_entities_filtered{area={{-10,-10},{10,10}},name='iron-chest'} or {}
    local chest = nil
    while not chest or not chest.get_inventory(defines.inventory.chest).can_insert(item) do
        chest = table.remove(chests,1)
        if not chest then chest = surface.create_entity{
            name='iron-chest',
            position=surface.find_non_colliding_position('iron-chest',{0,0},32,1)
        } end
    end
    chest.get_inventory(defines.inventory.chest).insert(item)
    table.insert(chests,chest)
    return chests
end

function Admin.move_inventory(player)
    local player = Game.get_player(player)
    if not player then return end
    local chests = player.surface.find_entities_filtered{area={{-10,-10},{10,10}},name='iron-chest'} or {}
    for _,_inventory in pairs(inventorys) do
        local inventory = player.get_inventory(_inventory)
        if inventory then
            for item,count in pairs(inventory.get_contents()) do
                local item = {name=item,count=count}
                chests = Admin.move_item_to_spawn(item,player.surface,chests)
            end
            inventory.clear()
        end
    end
end

Admin.ban_btn = Gui.inputs.add{
    type='button',
    name='admin-ban',
    caption='utility/danger_icon',
    tooltip={'admin-commands.tooltip-ban'}
}:on_event('click',function(event)
    local parent = event.element.parent
    pre_select_player = parent.player and parent.player.caption or nil
    open(event.player_index,pre_select_player,'Ban')
end)

function Admin.ban(player,by_player,reason)
    local player = Game.get_player(player)
    local by_player_name = Game.get_player(by_player) and Game.get_player(by_player).name or '<server>'
    local reason = append_name(reason,by_player_name)
    Sync.emit_embeded{
        title='Player Ban',
        color=Color.to_hex(defines.text_color.crit),
        description='There was a player banned.',
        ['Player:']='<<inline>>'..player.name,
        ['By:']='<<inline>>'..by_player_name,
        ['Reason:']=reason
    }
    Admin.move_inventory(player)
    Server.interface(game.ban_player,true,player,reason)
end

Admin.kick_btn = Gui.inputs.add{
    type='button',
    name='admin-kick',
    caption='utility/warning_icon',
    tooltip={'admin-commands.tooltip-kick'}
}:on_event('click',function(event)
    local parent = event.element.parent
    pre_select_player = parent.player and parent.player.caption or nil
    open(event.player_index,pre_select_player,'Kick')
end)

function Admin.kick(player,by_player,reason)
    local player = Game.get_player(player)
    local by_player_name = Game.get_player(by_player) and Game.get_player(by_player).name or '<server>'
    local reason = append_name(reason,by_player_name)
    Sync.emit_embeded{
        title='Player Kick',
        color=Color.to_hex(defines.text_color.high),
        description='There was a player kicked.',
        ['Player:']='<<inline>>'..player.name,
        ['By:']='<<inline>>'..by_player_name,
        ['Reason:']=reason
    }
    Admin.move_inventory(player)
    Server.interface(game.kick_player,true,player,reason)
end

Admin.jail_btn = Gui.inputs.add{
    type='button',
    name='admin-jail',
    caption='utility/clock',
    tooltip={'admin-commands.tooltip-jail'}
}:on_event('click',function(event)
    local parent = event.element.parent
    pre_select_player = parent.player and parent.player.caption or nil
    open(event.player_index,pre_select_player,'Jail')
end)

function Admin.jail(player,by_player,reason)
    local player = Game.get_player(player)
    local by_player_name = Game.get_player(by_player) and Game.get_player(by_player).name or '<server>'
    local reason = append_name(reason,by_player_name)
    Sync.emit_embeded{
        title='Player Jail',
        color=Color.to_hex(defines.text_color.med),
        description='There was a player jailed.',
        ['Player:']='<<inline>>'..player.name,
        ['By:']='<<inline>>'..by_player_name,
        ['Reason:']=reason
    }
    Admin.move_inventory(player)
    Ranking._presets().last_jail = player.name
    Server.interface(Ranking.give_rank,true,player,'Jail',by_player_name)
end

Admin.go_to_btn = Gui.inputs.add{
    type='button',
    name='admin-go-to',
    caption='utility/export_slot',
    tooltip={'admin-commands.tooltip-go-to'}
}:on_event('click',function(event)
    local parent = event.element.parent
    pre_select_player = parent.player and parent.player.caption or nil
    Admin.go_to(pre_select_player,event.player_index)
end)

function Admin.go_to(player,by_player)
    local player = Game.get_player(player)
    local _player = Game.get_player(by_player)
    _player.teleport(player.surface.find_non_colliding_position('player',player.position,32,1),player.surface)
end

Admin.bring_btn = Gui.inputs.add{
    type='button',
    name='admin-bring',
    caption='utility/import_slot',
    tooltip={'admin-commands.tooltip-bring'}
}:on_event('click',function(event)
    local parent = event.element.parent
    pre_select_player = parent.player and parent.player.caption or nil
    Admin.bring(pre_select_player,event.player_index)
end)

function Admin.bring(player,by_player)
    local player = Game.get_player(player)
    local _player = Game.get_player(by_player)
    if not player or not _player then return end
    player.teleport(_player.surface.find_non_colliding_position('player',_player.position,32,1),_player.surface)
end

function Admin.tp(from_playaer, to_player)
    local _from_player = Game.get_player(from_player)
    local _to_player = Game.get_player(to_player)
    
    if not _from_player or not _to_player then return end
    
    if Game.players[_from_player].health >= 0 then return end
    if Game.players[_to_player].health >= 0 then return end
    
    _from_player.teleport(_to_player.surface.find_non_colliding_position('player',_to_player.position,32,1),_to_player.surface)
end
