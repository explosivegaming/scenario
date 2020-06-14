--- This is the main config file for the role system; file includes defines for roles and role flags and default values
-- @config Roles

local Roles = require 'expcore.roles' --- @dep expcore.roles

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
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_allow_all()

Roles.new_role('Senior Administrator','SAdmin')
:set_permission_group('Admin')
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_parent('Administrator')
:allow{
    'command/interface',
    'command/debug',
    'command/toggle-cheat-mode'
}

Roles.new_role('Administrator','Admin')
:set_permission_group('Admin')
:set_custom_color{r=233,g=63,b=233}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_parent('Moderator')
:allow{
    'gui/warp-list/bypass-cooldown',
    'gui/warp-list/bypass-proximity',
    'command/connect-all',
}

Roles.new_role('Moderator','Mod')
:set_permission_group('Admin')
:set_custom_color{r=0,g=170,b=0}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_parent('Trainee')
:allow{
    'command/assign-role',
    'command/unassign-role',
    'command/repair',
    'command/kill/always',
    'command/clear-tag/always',
    'command/go-to-spawn/always',
    'command/clear-reports',
    'command/clear-warnings',
    'command/clear-temp-ban',
    'command/clear-inventory',
    'command/bonus',
    'command/home',
    'command/home-set',
    'command/home-get',
    'command/return',
    'command/connect-player',
    'gui/rocket-info/toggle-active',
    'gui/rocket-info/remote_launch',
    'fast-tree-decon',
}

Roles.new_role('Trainee','TrMod')
:set_permission_group('Admin')
:set_custom_color{r=0,g=170,b=0}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_parent('Veteran')
:allow{
    'command/admin-chat',
    'command/teleport',
    'command/bring',
    'command/goto',
    'command/temp-ban',
    'command/give-warning',
    'command/get-warnings',
    'command/get-reports',
    'command/jail',
    'command/unjail',
    'command/kick',
    'command/ban',
}

--- Trusted Roles
Roles.new_role('Board Member','Board')
:set_permission_group('Trusted')
:set_custom_color{r=247,g=246,b=54}
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_parent('Sponsor')
:allow{
    'command/goto',
    'command/repair',
}

Roles.new_role('Senior Backer','Backer')
:set_permission_group('Trusted')
:set_custom_color{r=238,g=172,b=44}
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_parent('Sponsor')
:allow{
}

Roles.new_role('Sponsor','Spon')
:set_permission_group('Trusted')
:set_custom_color{r=238,g=172,b=44}
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_parent('Supporter')
:allow{
    'gui/rocket-info/toggle-active',
    'gui/rocket-info/remote_launch',
    'command/bonus',
    'command/home',
    'command/home-set',
    'command/home-get',
    'command/return',
    'fast-tree-decon'
}

Roles.new_role('Supporter','Sup')
:set_permission_group('Trusted')
:set_custom_color{r=230,g=99,b=34}
:set_flag('is_spectator')
:set_parent('Veteran')
:allow{
    'command/jail',
    'command/unjail',
    'command/join-message'
}

Roles.new_role('Partner','Part')
:set_permission_group('Trusted')
:set_custom_color{r=140,g=120,b=200}
:set_flag('is_spectator')
:set_parent('Veteran')
:allow{
    'command/jail',
    'command/unjail'
}

Roles.new_role('Veteran','Vet')
:set_permission_group('Trusted')
:set_custom_color{r=140,g=120,b=200}
:set_parent('Member')
:allow{
    'command/chat-bot',
}
:set_auto_assign_condition(function(player)
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
    'gui/task-list/add',
    'gui/task-list/edit',
    'gui/warp-list/add',
    'gui/warp-list/edit',
    'command/save-quickbar'
}

Roles.new_role('Regular','Reg')
:set_permission_group('Standard')
:set_custom_color{r=79,g=155,b=163}
:set_parent('Guest')
:allow{
    'command/kill',
    'command/rainbow',
    'command/go-to-spawn',
    'command/me',
    'standard-decon'
}
:set_auto_assign_condition(function(player)
    if player.online_time > 3*216000 then
        return true
    end
end)

--- Guest/Default role
local default = Roles.new_role('Guest','')
:set_permission_group('Guest')
:set_custom_color{r=185,g=187,b=160}
:allow{
    'command/tag',
    'command/tag-clear',
    'command/search-help',
    'command/list-roles',
    'command/find-on-map',
    'command/report',
    'command/ratio',
    'command/server-ups',
    'command/save-data',
    'command/preference',
    'command/set-preference',
    'command/connect',
    'gui/player-list',
    'gui/rocket-info',
    'gui/science-info',
    'gui/task-list',
    'gui/warp-list',
    'gui/readme'
}

--- Jail role
Roles.new_role('Jail')
:set_permission_group('Restricted')
:set_custom_color{r=50,g=50,b=50}
:set_block_auto_promote(true)
:disallow(default.allowed)

--- System defaults which are required to be set
Roles.set_root('System')
Roles.set_default('Guest')

Roles.define_role_order{
    'System', -- Best to keep root at top
    'Senior Administrator',
    'Administrator',
    'Moderator',
    'Trainee',
    'Board Member',
    'Senior Backer',
    'Sponsor',
    'Supporter',
    'Partner',
    'Veteran',
    'Member',
    'Regular',
    'Jail',
    'Guest' -- Default must be last if you want to apply restrictions to other roles
}

Roles.override_player_roles{
    ["Cooldude2606"]={"Senior Administrator","Moderator","Senior Backer","Supporter"},
    ["arty714"]={"Senior Administrator","Senior Backer","Supporter"},
    ["Drahc_pro"]={"Administrator","Moderator","Veteran","Member"},
    ["mark9064"]={"Administrator","Moderator","Member"},
    ["aldldl"]={"Administrator","Moderator","Senior Backer","Sponsor","Supporter","Member"},

    ["ookl"]={"Moderator","Senior Backer","Sponsor","Supporter","Partner","Member"},
    ["hamsterbryan"]={"Moderator","Senior Backer","Supporter","Member"},
    ["M74132"]={"Moderator","Senior Backer","Sponsor","Supporter","Member"},
    ["LoicB"]={"Moderator","Senior Backer","Supporter","Veteran","Member"},
    ["UUBlueFire"]={"Moderator","Senior Backer","Supporter","Member"},

    ["thadius856"]={"Moderator","Supporter","Member"},
    ["XenoCyber"]={"Moderator","Supporter","Partner","Member"},
    ["cydes"]={"Moderator","Supporter","Member"},
    ["darklich14"]={"Moderator","Supporter","Member"},
    ["SilentLog"]={"Moderator","Supporter","Member"},
    ["freek18"]={"Moderator","Supporter","Member"},
    ["porelos"]={"Moderator","Supporter","Member"},

    ["7h3w1z4rd"]={"Moderator","Member"},
    ["Windbomb"]={"Moderator","Member"},
    ["Phoenix27833"]={"Moderator","Member"},
    ["banakeg"]={"Moderator","Member"},
    ["maplesyrup01"]={"Moderator","Member"},
    ["FlipHalfling90"]={"Moderator","Member"},
    ["Ruuyji"]={"Moderator","Member"},
    ["Gizan"]={"Moderator"},
    ["samy115"]={"Moderator","Member"},
    ["Hobbitkicker"]={"Moderator","Member"},
    ["facere"]={"Moderator","Member"},
    ["whoami32"]={"Moderator","Member"},
    ["NextIdea"]={"Moderator","Member"},
    ["mafisch3"]={"Moderator","Member"},
    ["Tcheko"]={"Moderator","Member"},
    ["AssemblyStorm"]={"Moderator","Veteran","Member"},
    ["connormkii"]={"Moderator","Veteran","Member"},
    ["Koroto"]={"Moderator","Veteran","Member"},
    ["scarbvis"]={"Moderator","Member"},
    ["CmonMate497"]={"Moderator","Member"}
}
