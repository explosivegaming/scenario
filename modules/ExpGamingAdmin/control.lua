--- The base functions required to make the others work.
-- @module ExpGamingAdmin@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alias Admin

-- Module Require
local Game = require('FactorioStdLib.Game')
local Color = require('FactorioStdLib.Color')
local Role -- ExpGamingCore.Role@^4.0.0
local Sync -- ExpGamingCore.Sync@^4.0.0
local Server -- ExpGamingCore.Server@^4.0.0

-- Module Define
local module_verbose = false
local Admin = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Role'] then Role = require('ExpGamingCore.Role') end
        if loaded_modules['ExpGamingCore.Sync'] then Sync = require('ExpGamingCore.Sync') end
        if loaded_modules['ExpGamingCore.Server'] then 
            Server = require('ExpGamingCore.Server')
            Server.add_module_to_interface('Admin','ExpGamingAdmin') 
        end
    end,
    actions={},
    action_functions={},
    action_names={}
}

-- Global Define
local global = global{
    banned = {}
}

-- Function Define
function Admin.valid_players(player,by_player)
    player = Game.get_player(player)
    by_player = Game.get_player(by_player) or SERVER
    return player, by_player
end

function Admin.create_reason(reason,name)
    reason = reason or 'No Reason'
    if not string.find(string.lower(reason),string.lower(name)) then reason = reason..' - '..name end
    if Sync and Sync.info.date ~= '0000/00/00' and not string.find(string.lower(reason),Sync.info.date) then reason = reason..' - '..Sync.info.date end
    if not string.find(string.lower(reason),'appeal') then reason = reason..' - Vist www.explosivegaming.nl to appeal.' end
    return reason
end

function Admin.allowed(player)
    player = Game.get_player(player)
    if Role then
        return Role.allowed(player,'admin-commands')
    else return player.admin end
end

function Admin.set_banned(player,set)
    player = Game.get_player(player)
    if not player then return false end
    global.banned[player.name] = set
end

function Admin.is_banned(player,detail)
    player = Game.get_player(player)
    if not player then return false end
    local banned = global.banned[player.name]
    if banned == true then return true end
    if not banned then return false end
    if detail then return banned
    else return true end
end

function Admin.add_action(action,callback)
    verbose('Added admin action: '..action)
    Admin.actions[string.lower(action)] = table.insert(Admin.action_names,action)
    Admin.action_functions[string.lower(action)] = callback
end

function Admin.take_action(action,player,by_player,reason)
    if Admin.action_functions[string.lower(action)] then Admin.action_functions[string.lower(action)](player,by_player,reason) end
    if Admin[action] then Admin[action](player,by_player,reason) end
end

function Admin.clear_player(player,by_player)
    player, by_player = Admin.valid_players(player,by_player)
    if not player then return end
    if Server and Admin.is_banned(player,true) == true then Server.interface(game.unban_player,true,player) end
    if Admin.clear_warnings then Admin.clear_warnings(player,by_player,true) end
    if Admin.clear_reports then Admin.clear_reports(player,by_player,true) end
    if Server and Role.has_flag(player,'is_jail') then Server.interface(Role.revert,true,player,by_player,2) end
    if Sync then Sync.emit_embedded{
        title='Player Clear',
        color=Color.to_hex(defines.textcolor.low),
        description='A player had their reports and warnings cleared.',
        ['Player:']='<<inline>>'..player.name,
        ['By:']='<<inline>>'..by_player.name,
    } end
    Admin.set_banned(player,false)
end

-- Module Return
return Admin 