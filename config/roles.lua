--- This is the main config file for the role system; file includes defines for roles and role flags and default values
local Roles = require 'expcore.roles'

-- Use these to adjust for ticks ie game.tick < 5*minutes
local seconds, minutes, hours = 60, 3600, 216000

--[[
    -- cant use a factory as it has upvalues ;-;
    local function playtime(time_required)
        return function(player)
            if player.online_time > time_required then
                return true
            end
        end
    end
]]

--- Role flags that will run when a player changes roles
Roles.define_flag_trigger('is_admin',function(player,state)
    player.admin = state
end)
Roles.define_flag_trigger('is_spectator',function(player,state)
    player.spectator = state
end)
Roles.define_flag_trigger('is_jail',function(player,state)
    if player.character then
        player.character.active = not state
    end
end)

--- Admin Roles
Roles.new_role('System','SYS')
:set_permission_group('Admin')
:set_flag('is_admin')
:set_flag('is_spectator')
:set_allow_all()

Roles.new_role('Senior Administrator','SAdmin')
:set_permission_group('Admin')
:set_flag('is_admin')
:set_flag('is_spectator')
:set_parent('Administrator')
:allow{
    'command/interface',
    'command/toggle-cheat-mode'
}

Roles.new_role('Administrator','Admin')
:set_permission_group('Admin')
:set_custom_color{r=233,g=63,b=233}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_parent('Moderator')
:allow{
}

Roles.new_role('Moderator','Mod')
:set_permission_group('Admin')
:set_custom_color{r=0,g=170,b=0}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_parent('Trainee')
:allow{
    'command/assign-role',
    'command/unassign-role'
}

Roles.new_role('Trainee','TrMod')
:set_permission_group('Admin')
:set_custom_color{r=0,g=170,b=0}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_parent('Donator')
:allow{
    'command/admin-chat',
    'command/teleport',
    'command/bring',
    'command/goto',
    'command/kill/always',
    'command/tag-clear/always',
}

--- Trusted Roles
Roles.new_role('Sponsor','Spon')
:set_permission_group('Trusted')
:set_custom_color{r=247,g=246,b=54}
:set_flag('is_spectator')
:set_parent('Pay to Win')
:allow{
}

Roles.new_role('Pay to Win','P2W')
:set_permission_group('Trusted')
:set_custom_color{r=238,g=172,b=44}
:set_flag('is_spectator')
:set_parent('Donator')
:allow{
}

Roles.new_role('Donator','Don')
:set_permission_group('Trusted')
:set_custom_color{r=230,g=99,b=34}
:set_flag('is_spectator')
:set_parent('Veteran')
:allow{
}

Roles.new_role('Partner','Part')
:set_permission_group('Trusted')
:set_custom_color{r=140,g=120,b=200}
:set_flag('is_spectator')
:set_parent('Veteran')
:allow{
}

Roles.new_role('Veteran','Vet')
:set_permission_group('Trusted')
:set_custom_color{r=140,g=120,b=200}
:set_parent('Member')
:allow{
}
:set_auto_promote_condition(function(player)
    if player.online_time > 10*216000 then
        return true
    end
end)

--- Standard User Roles
Roles.new_role('Member','Mem')
:set_permission_group('Standard')
:set_custom_color{r=24,g=172,b=188}
:set_parent('Regular')
:allow{
}

Roles.new_role('Regular','Reg')
:set_permission_group('Standard')
:set_custom_color{r=79,g=155,b=163}
:set_parent('Guest')
:allow{
    'command/kill'
}
:set_auto_promote_condition(function(player)
    if player.online_time > 3*216000 then
        return true
    end
end)

--- Guest/Default role
Roles.new_role('Guest','')
:set_permission_group('Guest')
:set_custom_color{r=185,g=187,b=160}
:allow{
    'command/me',
    'command/tag',
    'command/tag-clear',
    'command/chelp',
    'command/list-roles',
    'command/rainbow'
}

--- Jail role
Roles.new_role('Jail')
:set_permission_group('Restricted')
:set_custom_color{r=50,g=50,b=50}
:set_block_auto_promote(true)
:allow{
}

--- System defaults which are required to be set
Roles.set_root('System')
Roles.set_default('Guest')

Roles.define_role_order{
    'System',
    'Senior Administrator',
    'Administrator',
    'Moderator',
    'Trainee',
    'Sponsor',
    'Pay to Win',
    'Donator',
    'Partner',
    'Veteran',
    'Member',
    'Regular',
    'Guest',
    'Jail'
}

Roles.override_player_roles{
    Cooldude2606={'Senior Administrator','Administrator','Moderator','Member'},
    arty714={'Senior Administrator','Administrator','Moderator','Member'},
    mark9064={'Administrator','Moderator','Member'},
    Drahc_pro={'Administrator','Moderator','Member'},
    aldldl={'Sponsor','Administrator','Moderator','Member'},
}