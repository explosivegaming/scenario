--- This is the main config file for the role system; file includes defines for roles and role flags and default values
-- @config Roles

local Roles = require 'expcore.roles' --- @dep expcore.roles

-- Use these to adjust for ticks ie game.tick < 5*minutes
local seconds, minutes, hours = 60, 3600, 216000

--[[
    -- cant use a factory as it has up values ;-;
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
    'gui/warp-list/no-limit',
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
    'gui/rocket-info/toggle-active',
    'gui/rocket-info/remote_launch',
}

Roles.new_role('Trainee','TrMod')
:set_permission_group('Admin')
:set_custom_color{r=0,g=170,b=0}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_parent('Donator')
:allow{
    'command/admin-chat',
    'command/teleport',
    'command/bring',
    'command/goto',
    'command/temp-ban',
    'command/give-warning',
    'command/get-warnings',
    'command/get-reports',
    'command/kick',
    'command/ban',
}

--- Trusted Roles
Roles.new_role('Sponsor','Spon')
:set_permission_group('Trusted')
:set_custom_color{r=247,g=246,b=54}
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_parent('Pay to Win')
:allow{
}

Roles.new_role('Pay to Win','P2W')
:set_permission_group('Trusted')
:set_custom_color{r=238,g=172,b=44}
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_parent('Donator')
:allow{
    'gui/rocket-info/toggle-active',
    'gui/rocket-info/remote_launch',
    'command/bonus',
    'command/home',
    'command/home-set',
    'command/home-get',
    'command/return',
}

Roles.new_role('Donator','Don')
:set_permission_group('Trusted')
:set_custom_color{r=230,g=99,b=34}
:set_flag('is_spectator')
:set_parent('Veteran')
:allow{
    'command/jail',
    'command/unjail'
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
    'gui/task-list/edit',
    'gui/warp-list/edit'
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
}
:set_auto_promote_condition(function(player)
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
    'command/chelp',
    'command/list-roles',
    'command/find-on-map',
    'command/report',
    'command/ratio',
    'gui/player-list',
    'gui/rocket-info',
    'gui/science-info',
    'gui/task-list',
    'gui/warp-list',
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
    'Sponsor',
    'Pay to Win',
    'Donator',
    'Partner',
    'Veteran',
    'Member',
    'Regular',
    'Jail',
    'Guest' -- Default must be last if you want to apply restrictions to other roles
}

Roles.override_player_roles{
    Cooldude2606={'Senior Administrator','Administrator','Moderator','Member'},
    arty714={'Senior Administrator','Administrator','Moderator','Member'},
    mark9064={'Administrator','Moderator','Member'},
    Drahc_pro={'Administrator','Moderator','Member'},
    aldldl={'Sponsor','Administrator','Moderator','Member'},
    LoicB={'Sponsor','Trainee','Member'},
    ookl={'Sponsor','Moderator','Member'},
    cydes={'Pay to Win','Moderator','Member'},
    darklich14={'Pay to Win','Moderator','Member'},
    porelos={'Pay to Win','Moderator','Member'},
    SilentLog={'Pay to Win','Moderator','Member'},
    UUBlueFire={'Pay to Win','Moderator','Member'},
    XenoCyber={'Pay to Win','Moderator','Member'},
    Chromaddict={'Donator','Moderator','Member'},
    eissturm={'Donator','Moderator','Member'},
    freek18={'Donator','Moderator','Member'},
    M74132={'Donator','Moderator','Member'},
    thadius856={'Donator','Moderator','Member'},
    ['7h3w1z4rd']={'Moderator','Member'},
    AssemblyStorm={'Moderator','Member'},
    bombershark={'Moderator','Member'},
    CmonMate497={'Moderator','Member'},
    facere={'Moderator','Member'},
    FlipHalfling90={'Moderator','Member'},
    Gizan={'Pay to Win','Moderator','Member'},
    Hobbitkicker={'Moderator','Member'},
    jessi_gaming={'Trainee','Member'},
    Koroto={'Moderator','Member'},
    mafisch3={'Moderator','Member'},
    maplesyrup01={'Moderator','Member'},
    NextIdea={'Moderator','Member'},
    Phoenix27833={'Moderator','Member'},
    Rezz={'Moderator','Member'},
    Ruuyji={'Moderator','Member'},
    samy115={'Moderator','Member'},
    scarbvis={'Moderator','Member'},
    Tcheko={'Moderator','Member'},
    WhomstThouAmMe={'Moderator','Member'},
    Windbomb={'Moderator','Member'},
    tovernaar123={'Member'},
}
