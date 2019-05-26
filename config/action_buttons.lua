local Gui = require 'expcore.gui'
local Roles = require 'expcore.roles'
local Store = require 'expcore.store'
local Game = require 'utils.game'

local action_player_store = 'gui.left.player-list.action-player'

local function tool_button_style(style)
    Gui.set_padding_style(style,-1,-1,-1,-1)
    style.height = 28
    style.width = 28
end

local function auth_lower_role(player,action_player)
    local player_highest = Roles.get_player_highest_role(player)
    local action_player_highest = Roles.get_player_highest_role(action_player)
    if player_highest.index < action_player_highest.index then
        return true
    end
end

local function get_action_player(player)
    local action_player_name = Store.get_child(action_player_store,player.name)
    local action_player = Game.get_player_from_any(action_player_name)
    return action_player
end

local report_player =
Gui.new_button()
:set_sprites('utility/warning')
:set_tooltip('Report player')
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    local action_player = get_action_player(player)
end)

return {
    ['command/report'] = {
        auth=auth_lower_role,
        report_player
    }
}