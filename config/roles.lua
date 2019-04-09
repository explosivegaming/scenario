local Roles = require 'expcore.roles'

-- Use these to adjust for ticks ie game.tick < 5*minutes
local seconds, minutes, hours = 60, 3600, 216000

local function playtime(time_required)
    return function(player)
        if player.online_time > time_required then
            return true
        end
    end
end

Roles.define_flag_trigger('admin',function(player,state)
    player.admin = state
end)

Roles.new_role('Server','SYS')
:set_allow_all(true)
:set_flag('admin',true)

Roles.new_role('Senior Admin','SAdmin')
:set_flag('admin',true)
:set_parent('Admin')
:set_permission_group('Admin')
:set_custom_color('blue')
:allow{
    'interface'
}

Roles.new_role('Admin','Admin')
:set_flag('admin',true)
:set_parent('Regular')
:set_permission_group('Admin')
:allow{
    'tp'
}

Roles.new_role('Regular','Reg')
:set_auto_promote_condition(playtime(5*minutes))
:set_parent('Guest')
:set_custom_tag('Reg')
:set_permission_group('Trusted')

Roles.new_role('Guest','')
:set_permission_group('Standard')

Roles.set_root('Server')
Roles.set_default('Guest')

Roles.define_role_order{
    'Server',
    'Senior Admin',
    'Regular',
    'Guest'
}

Roles.override_player_roles{
    Cooldude2606={'Server','Senior Admin'}
}