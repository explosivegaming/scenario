--- Desction <get from json>
-- @module ExpGamingAdmin.Jail@4.0.0
-- @author <get from json>
-- @license <get from json>
-- @alais ThisModule 

-- Module Require
local Admin = require('ExpGamingAdmin.AdminLib@^4.0.0')
local AdminGui = require('ExpGamingAdmin.AdminGui@^4.0.0')
local Server = require('ExpGamingCore.Server@^4.0.0')
local Ranking = require('ExpGamingCore.Ranking@^4.0.0')
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
AdminGui.add_button('jail','utility/clock',{'ExpGamingAdmin@4-0-0.tooltip-jail'},function(player,byPlayer)
    Admin.open(byPlayer,player,'jail')
end)

function Admin.jail(player,by_player,reason)
    local player = Game.get_player(player)
    local by_player_name = Game.get_player(by_player) and Game.get_player(by_player).name or '<server>'
    local reason = Admin.create_reason(reason,by_player_name)
    if Sync then Sync.emit_embeded{
        title='Player Jail',
        color=Color.to_hex(defines.text_color.med),
        description='There was a player jailed.',
        ['Player:']='<<inline>>'..player.name,
        ['By:']='<<inline>>'..by_player_name,
        ['Reason:']=reason
    } end
    if Admin.move_inventory then Admin.move_inventory(player) end
    Ranking.meta.last_jail = player.name
    Server.interface(Ranking.give_rank,true,player,'Jail',by_player_name)
end

Admin.add_action('Jail',Admin.jail)

-- Module Return
return ThisModule 