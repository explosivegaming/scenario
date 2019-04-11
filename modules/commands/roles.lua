local Commands = require 'expcore.commands'
local Roles = require 'expcore.roles'
local Colours = require 'resources.color_presets'

Commands.new_command('assign-role','Assigns a role to a player')
:add_param('player',false,'player-role')
:add_param('role',false,'role')
:set_flag('admin-only',true)
:add_alias('rpromote','assign','role','add-role')
:register(function(player,action_player,role,raw)
    local player_highest = Roles.get_player_highest_role(player)
    if player_highest.index < role.index then
        Roles.assign_player(action_player,role,player.name)
    else
        return Commands.error{'exp-commands.roles-higher-role'}
    end
end)

Commands.new_command('unassign-role','Unassigns a role from a player')
:add_param('player',false,'player-role')
:add_param('role',false,'role')
:set_flag('admin-only',true)
:add_alias('rdemote','unassign','remove-role')
:register(function(player,action_player,role,raw)
    local player_highest = Roles.get_player_highest_role(player)
    if player_highest.index < role.index then
        Roles.unassign_player(action_player,role,player.name)
    else
        return Commands.error{'exp-commands.roles-higher-role'}
    end
end)

Commands.new_command('list-roles','Lists all roles in they correct order')
:add_param('player',true,'player')
:add_alias('lsroles','roles')
:register(function(player,action_player,raw)
    local roles = Roles.config.order
    local message = {'exp-commands.roles-list'}
    if action_player ~= '' then
        roles = Roles.get_player_roles(action_player)
    end
    for index,role in pairs(roles) do
        role = Roles.get_role_from_any(role)
        local colour = role.custom_color or Colours.white
        colour = string.format('%d,%d,%d',colour.r,colour.g,colour.b)
        if index == 1 then
            message = {'exp-commands.roles-list',colour,role.name}
            if action_player ~= '' then
                local player_colour = action_player.color
                player_colour = string.format('%d,%d,%d',player_colour.r*255,player_colour.g*255,player_colour.b*255)
                message = {'exp-commands.roles-list-player',player_colour,action_player.name,colour,role.name}
            end
        else
            message = {'exp-commands.roles-list-element',message,colour,role.name}
        end
    end
    return Commands.success(message)
end)