--- Allows syncing with an outside server and info panle.
-- @submodule ExpGamingCore.Sync
-- @alias Sync
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

--- This file will be loaded when ExpGamingCore.Role is present
-- @function _comment

local Game = require('FactorioStdLib.Game')
local Color = require('FactorioStdLib.Color')
local Role = require('ExpGamingCore.Role')

--- Used as a redirect to Role._base_preset that will set the rank given to a player apon joining
-- @usage Sync.set_roles{player_name=rank_name,...}
function Sync.set_roles(...)
    Role._base_preset(...)
end

--- Used to get the number of players in each rank and currently online
-- @usage Sync.count_roles()
-- @treturn table contains the ranks and the players in that rank
function Sync.count_roles()
    if not game then return {'Offline'} end
    local _roles = {}
    for name,role in pairs(Role.roles) do
        local players = role:get_players()
        for k,player in pairs(players) do players[k] = player.name end
        local online = role:get_players(true)
        for k,player in pairs(online) do online[k] = player.name end
        _roles[role.name] = {players=players,online=online,n_players=#players,n_online=#online}
    end
    return _roles
end

-- Adds a caption to the info gui that shows the rank given to the player
if Sync.add_to_gui then
    Sync.add_to_gui(function(player,frame)
        local names = {}
        for _,role in pairs(Role.get(player)) do table.insert(names,role.name) end
        return 'You have been assigned the roles: '..table.concat(names,', ')
    end)
end

-- adds a discord emit for rank chaning
script.on_event('on_role_change',function(event)
    local role = Role.get(event.role_name)
    local player = Game.get_player(event)
    local by_player = Game.get_player(event.by_player_index) or SERVER
    local global = global['ExpGamingCore.Role^4.0.0']
    if role.is_jail == 'Jail' and global.last_change[1] ~= player.index then
        Sync.emit_embeded{
            title='Player Jail',
            color=Color.to_hex(defines.textcolor.med),
            description='There was a player jailed.',
            ['Player:']='<<inline>>'..player.name,
            ['By:']='<<inline>>'..by_player.name,
            ['Reason:']='No Reason'
        }
    end
end)