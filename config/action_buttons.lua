local Gui = require 'expcore.gui'
local Roles = require 'expcore.roles'
local Store = require 'expcore.store'
local Game = require 'utils.game'
local Reports = require 'modules.addons.reports-control'
local Jail = require 'modules.addons.jail-control'

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

local function teleport(from_player,to_player)
    local surface = to_player.surface
    local position = surface.find_non_colliding_position('character',to_player.position,32,1)
    if not position then return false end -- return false if no new position
    if from_player.driving then from_player.driving = false end -- kicks a player out a vehicle if in one
    from_player.teleport(position,surface)
    return true
end

local goto_player =
Gui.new_button()
:set_sprites('utility/export')
:set_tooltip('Goto player')
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    local action_player = get_action_player(player)
    teleport(player,action_player)
end)

local bring_player =
Gui.new_button()
:set_sprites('utility/import')
:set_tooltip('Bring player')
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    local action_player = get_action_player(player)
    teleport(action_player,player)
end)

local kill_player =
Gui.new_button()
:set_sprites('utility/too_far')
:set_tooltip('Kill player')
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    local action_player = get_action_player(player)
    if action_player.character then
        action_player.character.die()
    end
end)

local report_player =
Gui.new_button()
:set_sprites('utility/spawn_flag')
:set_tooltip('Report player')
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    local action_player = get_action_player(player)
    Reports.report_player(action_player,reason,player.name)
end)

local jail_player =
Gui.new_button()
:set_sprites('utility/item_editor_icon')
:set_tooltip('Jail player')
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    local action_player = get_action_player(player)
    Jail.jail_player(action_player,player.name)
end)

local temp_ban_player =
Gui.new_button()
:set_sprites('utility/clock')
:set_tooltip('Temp ban player')
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    local action_player = get_action_player(player)
    Jail.temp_ban_player(action_player,player.name,reason)
end)

local kick_player =
Gui.new_button()
:set_sprites('utility/warning_icon')
:set_tooltip('Kick player')
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    local action_player = get_action_player(player)
    game.kick_player(action_player,reason)
end)

local ban_player =
Gui.new_button()
:set_sprites('utility/danger_icon')
:set_tooltip('Ban player')
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    local action_player = get_action_player(player)
    game.ban_player(action_player,reason)
end)

return {
    ['command/teleport'] = {
        goto_player,
        bring_player
    },
    ['command/kill/always'] = {
        auth=auth_lower_role,
        kill_player
    },
    ['command/report'] = {
        auth=auth_lower_role,
        report_player
    },
    ['command/jail'] = {
        auth=auth_lower_role,
        jail_player
    },
    ['command/temp-ban'] = {
        auth=auth_lower_role,
        temp_ban_player
    },
    ['command/kick'] = {
        auth=auth_lower_role,
        kick_player
    },
    ['command/ban'] = {
        auth=auth_lower_role,
        ban_player
    }
}