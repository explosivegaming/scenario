--- Adds three function to admin: tp, bring and go to, these all move the player
-- @module ExpGamingAdmin.Teleport@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alias ThisModule

-- Module Require
local Admin = require('ExpGamingAdmin')
local AdminGui = require('ExpGamingAdmin.Gui')
local Game = require('FactorioStdLib.Game')

-- Module Define
local module_verbose = false
local ThisModule = {}

-- Function Define
AdminGui.add_button('Go To','utility/export_slot',{'ExpGamingAdmin.tooltip-go-to'},function(player,byPlayer)
    Admin.go_to(player,byPlayer)
end)
AdminGui.add_button('Bring','utility/import_slot',{'ExpGamingAdmin.tooltip-bring'},function(player,byPlayer)
    Admin.bring(player,byPlayer)
end)

function Admin.tp(from_player, to_player)
    local _from_player = Game.get_player(from_player)
    local _to_player = Game.get_player(to_player)
    if not _from_player or not _to_player then return end
    _from_player.teleport(_to_player.surface.find_non_colliding_position('player',_to_player.position,32,1),_to_player.surface)
end

function Admin.go_to(player,by_player)
    Admin.tp(by_player, player)
end

function Admin.bring(player,by_player)
    Admin.tp(player, by_player)
end

Admin.add_action('Go To',Admin.go_to)
Admin.add_action('Bring',Admin.bring)

-- Module Return
return setmetatable(ThisModule,{__call=Admin.tp})