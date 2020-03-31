--[[-- Commands Module - Roles
    - Adds a commands that allow interaction with the role system
    @commands Roles
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Colours = require 'utils.color_presets' --- @dep utils.color_presets
local format_chat_player_name, format_chat_colour_localized = _C.format_chat_player_name, _C.format_chat_colour_localized

--- Assigns a role to a player
-- @command assign-role
-- @tparam LuaPlayer player the player to assign the role to
-- @tparam string role the name of the role to assign to the player, supports auto complete after enter
Commands.new_command('assign-role','Assigns a role to a player')
:add_param('player',false,'player-role')
:add_param('role',false,'role')
:set_flag('admin-only')
:add_alias('rpromote','assign','role','add-role')
:register(function(player,action_player,role,raw)
    local player_highest = Roles.get_player_highest_role(player)
    if player_highest.index < role.index then
        Roles.assign_player(action_player,role,player.name)
    else
        return Commands.error{'expcom-roles.higher-role'}
    end
end)

--- Unassigns a role from a player
-- @command unassign-role
-- @tparam LuaPlayer player the player to unassign the role from
-- @tparam string role the name of the role to unassign from the player, supports auto complete after enter
Commands.new_command('unassign-role','Unassigns a role from a player')
:add_param('player',false,'player-role')
:add_param('role',false,'role')
:set_flag('admin-only')
:add_alias('rdemote','unassign','rerole','remove-role')
:register(function(player,action_player,role,raw)
    local player_highest = Roles.get_player_highest_role(player)
    if player_highest.index < role.index then
        Roles.unassign_player(action_player,role,player.name)
    else
        return Commands.error{'expcom-roles.higher-role'}
    end
end)

--- Lists all roles in they correct order
-- @command list-roles
-- @tparam[opt=all] LuaPlayer player list only the roles which this player has
Commands.new_command('list-roles','Lists all roles in they correct order')
:add_param('player',true,'player')
:add_alias('lsroles','roles')
:register(function(player,action_player,raw)
    local roles = Roles.config.order
    local message = {'expcom-roles.list'}
    if action_player then
        roles = Roles.get_player_roles(action_player)
    end
    for index,role in pairs(roles) do
        role = Roles.get_role_from_any(role)
        local colour = role.custom_color or Colours.white
        local role_name = format_chat_colour_localized(role.name,colour)
        if index == 1 then
            message = {'expcom-roles.list',role_name}
            if action_player then
                local player_name_colour = format_chat_player_name(action_player)
                message = {'expcom-roles.list-player',player_name_colour,role_name}
            end
        else
            message = {'expcom-roles.list-element',message,role_name}
        end
    end
    return Commands.success(message)
end)