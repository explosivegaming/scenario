local Gui = require 'expcore.gui'
local Roles = require 'expcore.roles'
local Store = require 'expcore.store'
local Game = require 'utils.game'
local Reports = require 'modules.addons.reports-control'
local Warnings = require 'modules.addons.warnings-control'
local Jail = require 'modules.addons.jail-control'
local format_chat_player_name = ext_require('expcore.common','format_chat_player_name')

local action_player_store = 'gui.left.player-list.action-player'
local action_name_store = 'gui.left.player-list.action-name'

local function tool_button_style(style)
    Gui.set_padding_style(style,-1,-1,-1,-1)
    style.height = 28
    style.width = 28
end

local function auth_lower_role(player,action_player_name)
    local player_highest = Roles.get_player_highest_role(player)
    local action_player_highest = Roles.get_player_highest_role(action_player_name)
    if player_highest.index < action_player_highest.index then
        return true
    end
end

local function get_action_player(player)
    local action_player_name = Store.get_child(action_player_store,player.name)
    local action_player = Game.get_player_from_any(action_player_name)
    local action_player_name_color = format_chat_player_name(action_player)
    return action_player,action_player_name_color
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
:set_tooltip{'player-list.goto-player'}
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    local action_player = get_action_player(player)
    teleport(player,action_player)
end)

local bring_player =
Gui.new_button()
:set_sprites('utility/import')
:set_tooltip{'player-list.bring-player'}
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    local action_player = get_action_player(player)
    teleport(action_player,player)
end)

local kill_player =
Gui.new_button()
:set_sprites('utility/too_far')
:set_tooltip{'player-list.kill-player'}
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
:set_tooltip{'player-list.report-player'}
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    Store.set_child(action_name_store,player.name,'command/report')
end)

local function report_player_callback(player,reason)
    local action_player,action_player_name_color = get_action_player(player)
    local by_player_name_color = format_chat_player_name(player)
    game.print{'expcom-report.non-admin',action_player_name_color,reason}
    Roles.print_to_roles_higher('Trainee',{'expcom-report.admin',action_player_name_color,by_player_name_color,reason})
    Reports.report_player(action_player,reason,player.name)
end

local warn_player =
Gui.new_button()
:set_sprites('utility/spawn_flag')
:set_tooltip{'player-list.warn-player'}
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    Store.set_child(action_name_store,player.name,'command/give-warning')
end)

local function warn_player_callback(player,reason)
    local action_player,action_player_name_color = get_action_player(player)
    local by_player_name_color = format_chat_player_name(player)
    game.print{'expcom-warnings.received',action_player_name_color,by_player_name_color,reason}
    Warnings.add_warnings(action_player,player.name)
end

local jail_player =
Gui.new_button()
:set_sprites('utility/item_editor_icon')
:set_tooltip{'player-list.jail-player'}
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    Store.set_child(action_name_store,player.name,'command/jail')
end)

local function jail_player_callback(player,reason)
    local action_player,action_player_name_color = get_action_player(player)
    local by_player_name_color = format_chat_player_name(player)
    game.print{'expcom-jail.give',action_player_name_color,by_player_name_color,reason}
    Jail.jail_player(action_player,player.name)
end

local temp_ban_player =
Gui.new_button()
:set_sprites('utility/clock')
:set_tooltip{'player-list.temp-ban-player'}
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    Store.set_child(action_name_store,player.name,'command/temp-ban')
end)

local function temp_ban_player_callback(player,reason)
    local action_player = get_action_player(player)
    Jail.temp_ban_player(action_player,player.name,reason)
end

local kick_player =
Gui.new_button()
:set_sprites('utility/warning_icon')
:set_tooltip{'player-list.kick-player'}
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    Store.set_child(action_name_store,player.name,'command/kick')
end)

local function kick_player_callback(player,reason)
    local action_player = get_action_player(player)
    game.kick_player(action_player,reason)
end

local ban_player =
Gui.new_button()
:set_sprites('utility/danger_icon')
:set_tooltip{'player-list.ban-player'}
:set_style('tool_button',tool_button_style)
:on_click(function(player,element)
    Store.set_child(action_name_store,player.name,'command/ban')
end)

local function ban_player_callback(player,reason)
    local action_player = get_action_player(player)
    game.ban_player(action_player,reason)
end

return {
    ['command/teleport'] = {
        auth=function(player,action_player_name)
            return player.name ~= action_player_name
        end,
        goto_player,
        bring_player
    },
    ['command/kill'] = {
        auth=function(player,action_player_name)
            if player.name == action_player_name then
                return true
            elseif Roles.player_allowed(player,'command/kill/always') then
                return auth_lower_role(player,action_player_name)
            end
        end,
        kill_player
    },
    ['command/report'] = {
        auth=function(player,action_player_name)
            if not Roles.player_allowed(player,'command/give-warning') then
                return not Roles.player_has_flag(action_player_name,'report-immune')
            end
        end,
        reason_callback=report_player_callback,
        report_player
    },
    ['command/give-warning'] = {
        auth=auth_lower_role,
        reason_callback=warn_player_callback,
        warn_player
    },
    ['command/jail'] = {
        auth=auth_lower_role,
        reason_callback=jail_player_callback,
        jail_player
    },
    ['command/temp-ban'] = {
        auth=auth_lower_role,
        reason_callback=temp_ban_player_callback,
        temp_ban_player
    },
    ['command/kick'] = {
        auth=auth_lower_role,
        reason_callback=kick_player_callback,
        kick_player
    },
    ['command/ban'] = {
        auth=auth_lower_role,
        reason_callback=ban_player_callback,
        ban_player
    }
}