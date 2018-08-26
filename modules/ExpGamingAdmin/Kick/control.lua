--- Desction <get from json>
-- @module ExpGamingAdmin.Kick@4.0.0
-- @author <get from json>
-- @license <get from json>
-- @alais ThisModule 

-- Module Require
local Admin = require('ExpGamingAdmin.AdminLib@^4.0.0')
local AdminGui = require('ExpGamingAdmin.AdminGui@^4.0.0')
local Server = require('ExpGamingCore.Server@^4.0.0')
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
AdminGui.add_button('kick','utility/warning_icon',{'ExpGamingAdmin@4-0-0.tooltip-kick'},function(player,byPlayer)
    Admin.open(byPlayer,player,'kick')
end)

function Admin.kick(player,by_player,reason)
    local player = Game.get_player(player)
    local by_player_name = Game.get_player(by_player) and Game.get_player(by_player).name or '<server>'
    local reason = Admin.create_reason(reason,by_player_name)
    if Sync then Sync.emit_embeded{
        title='Player Kick',
        color=Color.to_hex(defines.text_color.high),
        description='There was a player kicked.',
        ['Player:']='<<inline>>'..player.name,
        ['By:']='<<inline>>'..by_player_name,
        ['Reason:']=reason
    } end
    if Admin.move_inventory then Admin.move_inventory(player) end
    Server.interface(game.kick_player,true,player,reason)
end

Admin.add_action('Kick',Admin.kick)

-- Module Return
return ThisModule 