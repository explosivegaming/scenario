--- Adds a jail function to the admin set, require ExpGamingRole to work.
-- @module ExpGamingAdmin.Jail@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ThisModule 

-- Module Require
local Admin = require('ExpGamingAdmin.AdminLib@^4.0.0')
local AdminGui = require('ExpGamingAdmin.Gui@^4.0.0')
local Server = require('ExpGamingCore.Server@^4.0.0')
local Role = require('ExpGamingCore.Role@^4.0.0')
local Game = require('FactorioStdLib.Game@^0.8.0')
local Color -- FactorioStdLib.Color@^0.8.0
local Sync -- ExpGamingCore.Sync@^4.0.0

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Sync@^4.0.0'] then Sync = require('ExpGamingCore.Sync@^4.0.0') end
        if loaded_modules['FactorioStdLib.Color@^0.8.0'] then Sync = require('FactorioStdLib.Color@^0.8.0') end
    end
}

-- Function Define
AdminGui.add_button('jail','utility/clock',{'ExpGamingAdmin.tooltip-jail'},function(player,byPlayer)
    Admin.open(byPlayer,player,'Jail')
end)

function Admin.jail(player,by_player,reason)
    local player = Game.get_player(player)
    local by_player_name = Game.get_player(by_player) and Game.get_player(by_player).name or '<server>'
    local reason = Admin.create_reason(reason,by_player_name)
    if Sync then Sync.emit_embeded{
        title='Player Jail',
        color=Color.to_hex(defines.textcolor.med),
        description='There was a player jailed.',
        ['Player:']='<<inline>>'..player.name,
        ['By:']='<<inline>>'..by_player_name,
        ['Reason:']=reason
    } end
    Role.meta.last_jail = player.name
    Server.interface(Role.unassign,true,player,Role.get(player),by_player_name)
    Server.interface(Role.assign,true,player,'Jail',by_player_name)
end

Admin.add_action('Jail',Admin.jail)

-- Module Return
return ThisModule 