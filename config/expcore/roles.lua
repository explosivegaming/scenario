--- This is the main config file for the role system; file includes defines for roles and role flags and default values
-- @config Roles

local Roles = require 'expcore.roles' --- @dep expcore.roles
local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data
local Statistics = PlayerData.Statistics

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
:set_permission_group('Default', true)
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instant-respawn')
:set_allow_all()

Roles.new_role('Senior Administrator','SAdmin')
:set_permission_group('Admin')
:set_custom_color{r=233,g=63,b=233}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instant-respawn')
:set_parent('Administrator')
:set_allow_all()

Roles.new_role('Administrator','Admin')
:set_permission_group('Admin')
:set_custom_color{r=233,g=63,b=233}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instant-respawn')
:set_parent('Senior Moderator')
:allow{
    'command/connect-all',
	'command/collectdata',
    'command/interface',
    'command/debug',
    'command/toggle-cheat-mode',
    'command/toggle-all-research',
    'command/connect-player'
}

Roles.new_role('Senior Moderator','SMod')
:set_permission_group('Admin')
:set_custom_color{r=0,g=209,b=102}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instant-respawn')
:set_parent('Moderator')
:allow{
}

Roles.new_role('Moderator','Mod')
:set_permission_group('Admin')
:set_custom_color{r=0,g=209,b=102}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instant-respawn')
:set_parent('Trainee')
:set_allow_all()
:allow{
}

Roles.new_role('Trainee','TrMod')
:set_permission_group('Admin')
:set_custom_color{r=0,g=209,b=102}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_parent('Board Member')
:allow{
    'gui/warp-list/bypass-proximity',
    'command/assign-role',
    'command/unassign-role',
    'command/admin-chat',
    'command/admin-marker',
    'command/teleport',
    'command/bring',
    'command/give-warning',
    'command/get-warnings',
    'command/get-reports',
    'command/clear-reports',
    'command/clear-warnings',
    'command/clear-inventory',
    'command/kick',
    'command/ban',
    'command/follow',
    'command/search',
    'command/search-amount',
    'command/search-recent',
    'command/search-online',
    'command/bot-queue-get',
    'command/bot-queue-set',
    'command/pol-off',
    'command/pol-clr',
    'command/kill/always',
    'command/clear-tag/always',
    'command/go-to-spawn/always',
    'command/protect-entity',
    'command/protect-area'
}

--- Trusted Roles
Roles.new_role('Board Member','Board')
:set_permission_group('Trusted')
:set_custom_color{r=247,g=246,b=54}
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instant-respawn')
:set_parent('Sponsor')
:allow{
    'gui/warp-list/bypass-cooldown',
    'command/goto',
    'command/repair',
    'command/spectate',
    'command/follow',
    'command/player-data-json'
}

Roles.new_role('Senior Backer','Backer')
:set_permission_group('Trusted')
:set_custom_color{r=238,g=172,b=44}
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instant-respawn')
:set_parent('Sponsor')
:allow{
}

Roles.new_role('Sponsor','Spon')
:set_permission_group('Trusted')
:set_custom_color{r=238,g=172,b=44}
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instant-respawn')
:set_parent('Supporter')
:allow{
    'bonus-2',
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
    'gui/rocket-info/toggle-active',
    'gui/rocket-info/remote_launch',
    'command/tag-color',
    'command/jail',
    'command/unjail',
    'command/join-message',
    'command/join-message-clear',
    'command/last-location'
}

Roles.new_role('Partner','Part')
:set_permission_group('Trusted')
:set_custom_color{r=140,g=142,b=200}
:set_flag('is_spectator')
:set_parent('Veteran')
:allow{
    'gui/rocket-info/toggle-active',
    'gui/rocket-info/remote_launch',
    'command/tag-color',
    'command/jail',
    'command/unjail',
    'command/join-message',
    'command/join-message-clear',
    'bonus-2',
    'command/last-location',
    'command/home',
    'command/home-set',
    'command/home-get',
    'command/return',
    'command/goto',
    'command/repair',
    'command/spectate',
    'command/follow',
    'fast-tree-decon'
}

Roles.new_role('Senior Member','SMem')
:set_permission_group('Trusted')
:set_custom_color{r=0,g=153,b=225}
:set_flag('is_spectator')
:set_parent('Veteran')
:allow{
}

local hours6, hours250 = 6*216000, 250*60
Roles.new_role('Veteran','Vet')
:set_permission_group('Trusted')
:set_custom_color{r=0,g=153,b=225}
:set_parent('Member')
:allow{
}
:set_auto_assign_condition(function(player)
    if player.online_time >= hours6 then
        return true
    else
        local stats = Statistics:get(player, {})
        local playTime, afkTime, mapCount = stats.Playtime or 0, stats.AfkTime or 0, stats.MapsPlayed or 0
        return playTime - afkTime >= hours250 and mapCount >= 25
    end
end)

--- Standard User Roles
Roles.new_role('Member','Mem')
:set_permission_group('Standard')
:set_custom_color{r=0,g=153,b=225}
:set_flag("deconlog-bypass")
:set_parent('Regular')
:allow{
    'gui/task-list/add',
    'gui/task-list/edit',
    'gui/warp-list/add',
    'gui/warp-list/edit',
    'command/save-quickbar',
    'command/bonus',
    'bonus-1',
    'vlayer-2',
    'personal-logistic',
    'command/manual-train',
    'command/chat-bot',
}

local hours2, hours15 = 2*216000, 15*60
Roles.new_role('Regular','Reg')
:set_permission_group('Standard')
:set_custom_color{r=0,g=153,b=225}
:set_parent('Guest')
:allow{
    'command/kill',
    'command/rainbow',
    'command/go-to-spawn',
    'command/me',
    'standard-decon',
    'bypass-entity-protection',
	'bypass-nukeprotect'
}
:set_auto_assign_condition(function(player)
    if player.online_time >= hours2 then
        return true
    else
        local stats = Statistics:get(player, {})
        local playTime, afkTime, mapCount = stats.Playtime or 0, stats.AfkTime or 0, stats.MapsPlayed or 0
        return playTime - afkTime >= hours15 and mapCount >= 5
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
    'gui/readme',
    'vlayer-1',
}

--- Jail role
Roles.new_role('Jail')
:set_permission_group('Restricted')
:set_custom_color{r=185,g=187,b=160}
:set_block_auto_assign(true)
:set_flag("defer_role_changes")
:disallow(default.allowed)

--- System defaults which are required to be set
Roles.set_root('System')
Roles.set_default('Guest')

Roles.define_role_order{
    'System', -- Best to keep root at top
    'Senior Administrator',
    'Administrator',
    'Senior Moderator',
    'Moderator',
    'Trainee',
    'Board Member',
    'Senior Backer',
    'Sponsor',
    'Supporter',
    'Partner',
    'Veteran',
    'Senior Member',
    'Member',
    'Regular',
    'Jail',
    'Guest' -- Default must be last if you want to apply restrictions to other roles
}

Roles.override_player_roles{
    ["PHIDIAS0303"]={"Senior Administrator", "Moderator", "Board Member", "Member"},

    ["aldldl"]={"Moderator","Member"},
    ["arty714"]={"Moderator", "Member"},
    ["Cooldude2606"]={"Moderator", "Member"},
    ["Drahc_pro"]={"Moderator", "Member"},
    ["mark9064"]={"Moderator","Member"},

    ["7h3w1z4rd"]={"Moderator","Member"},
    ["FlipHalfling90"]={"Moderator","Member"},
    ["hamsterbryan"]={"Moderator","Member"},
    ["HunterOfGames"]={"Moderator","Member"},
    ["NextIdea"]={"Moderator","Member"},
    ["TheKernel32"]={"Moderator","Member"},
    ["TheKernel64"]={"Moderator","Member"},
    ["tovernaar123"]={"Moderator","Member"},
    ["UUBlueFire"]={"Moderator","Member"},

    ["AssemblyStorm"]={"Moderator", "Member"},
    ["banakeg"]={"Moderator","Member"},
    ["CmonMate497"]={"Moderator","Member"},
    ["connormkii"]={"Moderator", "Member"},
    ["cydes"]={"Moderator","Member"},
    ["darklich14"]={"Moderator","Member"},
    ["facere"]={"Moderator","Member"},
    ["freek18"]={"Moderator","Member"},
    ["Gizan"]={"Moderator","Member"},
    ["Hobbitkicker"]={"Moderator","Member"},
    ["Koroto"]={"Moderator", "Member"},
    ["LoicB"]={"Moderator","Member"},
    ["M74132"]={"Moderator","Member"},
    ["mafisch3"]={"Moderator","Member"},
    ["maplesyrup01"]={"Moderator","Member"},
    ["ookl"]={"Moderator","Member"},
    ["Phoenix27833"]={"Moderator","Member"},
    ["porelos"]={"Moderator","Member"},
    ["Ruuyji"]={"Moderator","Member"},
    ["samy115"]={"Moderator","Member"},
    ["SilentLog"]={"Moderator","Member"},
    ["Tcheko"]={"Moderator","Member"},
    ["thadius856"]={"Moderator","Member"},
    ["whoami32"]={"Moderator","Member"},
    ["Windbomb"]={"Moderator","Member"},
    ["XenoCyber"]={"Moderator","Member"}
}
