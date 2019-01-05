--- Adds a kick function to the admin function set.
-- @module ExpGamingAdmin.Kick@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ThisModule 

-- Module Require
local Admin = require('ExpGamingAdmin')
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
AdminGui.add_button('Kick','utility/warning_icon',{'ExpGamingAdmin.tooltip-kick'},function(player,byPlayer)
    Admin.open(byPlayer,player,'Kick')
end)

function Admin.kick(player,by_player,reason)
    local player = Game.get_player(player)
    local by_player_name = Game.get_player(by_player) and Game.get_player(by_player).name or '<server>'
    local reason = Admin.create_reason(reason,by_player_name)
    if Sync then Sync.emit_embeded{
        title='Player Kick',
        color=Color.to_hex(defines.textcolor.high),
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
return setmetatable(ThisModule,{__call=Admin.kick})