local Role = self
local RoleGlobal = RoleGlobal
local Sync = require('ExpGamingCore.Sync')
local Game = require('FactorioStdLib.Game')
local Color = require('FactorioStdLib.Color')

-- just to hard reset the role sync
function Sync.set_roles(...)
    Role.set_preassign(...)
end

-- used to assign the role if the player is online, or add to the the preassign
function Sync.assign_role(player_name,roles,by_player_name)
    if not game then return end
    local preassign = RoleGlobal.preassign
    local player_roles = preassign[player_name]
    if Game.get_player(player_name) then Role.assign(player_name,roles,by_player_name)
    else
        if not is_type(roles,'table') then roles = {roles} end
        if not player_roles then preassign[player_name] = roles return end
        for _,role_name in pairs(roles) do
            if not table.includes(player_roles,role_name) then table.insert(player_roles,role_name) end
        end
    end
end

-- used to unassign the role if the player is online, or removes the preassign
function Sync.unassign_role(player_name,roles,by_player_name)
    if not game then return end
    local preassign = RoleGlobal.preassign
    local player_roles = preassign[player_name]
    if Game.get_player(player_name) then Role.unassign(player_name,roles,by_player_name)
    else
        if not is_type(roles,'table') then roles = {roles} end
        if not player_roles then preassign[player_name] = nil return end
        for _,role_name in pairs(roles) do
            local index = table.index(player_roles,role_name)
            if index then table.remove(player_roles,index) end
        end
    end
end

Sync.add_update('roles',function()
    if not game then return {'Offline'} end
    local _rtn = {}
    for _,role in pairs(Role.roles) do
        local players = role:get_players()
        local _players = {}
        for k,player in pairs(players) do _players[k] = player.name end
        local online = role:get_players(true)
        local _online = {}
        for k,player in pairs(online) do _online[k] = player.name end
        _rtn[role.name] = {players=_players,online=_online,n_players=#_players,n_online=#_online}
    end
    return _rtn
end)

-- Adds a caption to the info gui that shows the rank given to the player
if Sync.add_to_gui then
    Sync.add_to_gui(function(player)
        local names = {}
        for _,role in pairs(Role.get(player)) do table.insert(names,role.name) end
        return 'You have been assigned the roles: '..table.concat(names,', ')
    end)
end

-- adds a discord emit for rank changing
script.on_event('on_role_change',function(event)
    local role = Role.get(event.role_name)
    local player = Game.get_player(event)
    local by_player = Game.get_player(event.by_player_index) or SERVER
    if role.is_jail and RoleGlobal.last_change[1] ~= player.index then
        Sync.emit_embedded{
            title='Player Jail',
            color=Color.to_hex(defines.textcolor.med),
            description='There was a player jailed.',
            ['Player:']='<<inline>>'..player.name,
            ['By:']='<<inline>>'..by_player.name,
            ['Reason:']='No Reason'
        }
    end
end)