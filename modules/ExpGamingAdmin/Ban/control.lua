--- Adds a custom ban function to the admin command set.
-- @module ExpGamingAdmin.Ban@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ThisModule 

-- Module Require
local Admin = require('ExpGamingAdmin.AdminLib')
local AdminGui = require('ExpGamingAdmin.Gui')
local Server = require('ExpGamingCore.Server')
local Game = require('FactorioStdLib.Game')
local Color -- FactorioStdLib.Color@^0.8.0
local Sync -- ExpGamingCore.Sync@^4.0.0

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Sync'] then Sync = require('ExpGamingCore.Sync') end
        if loaded_modules['FactorioStdLib.Color'] then Color = require('FactorioStdLib.Color') end
    end
}

-- Function Define
AdminGui.add_button('Ban','utility/danger_icon',{'ExpGamingAdmin.tooltip-ban'},function(player,byPlayer)
    Admin.open(byPlayer,player,'Ban')
end)

function Admin.ban(player,by_player,reason)
    local player = Game.get_player(player)
    local by_player_name = Game.get_player(by_player) and Game.get_player(by_player).name or '<server>'
    local reason = Admin.create_reason(reason,by_player_name)
    Admin.set_banned(player,true)
    if Sync then Sync.emit_embeded{
        title='Player Ban',
        color=Color.to_hex(defines.textcolor.crit),
        description='There was a player banned.',
        ['Player:']='<<inline>>'..player.name,
        ['By:']='<<inline>>'..by_player_name,
        ['Reason:']=reason
    } end
    if Admin.move_inventory then Admin.move_inventory(player) end
    Server.interface(game.ban_player,true,player,reason)
end

Admin.add_action('Ban',Admin.ban)

-- Module Return
return ThisModule 