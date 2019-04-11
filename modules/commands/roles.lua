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
:add_alias('lroles','roles')
:register(function(player,action_player,raw)
    local roles = Roles.config.order
    if action_player then
        roles = Roles.get_player_roles(action_player)
    end
    local message = {'exp-commands.roles-list'}
    for _,role_name in pairs(roles) do
        local role = Roles.get_role_by_name(role_name)
        local colour = role.custom_color or Colours.white
        colour = string.format('%d,%d,%d',colour.r,colour.g,colour.b)
        message = {'exp-commands.roles-list-element',message,colour,role_name}
    end
    return Commands.success(message)
end)