Role.add_flag('is_default') -- this must be included in atleast one role
Role.add_flag('is_root',function(player,state) if player.character then player.character.destructible = not state end end) -- not required but setting true will allow everythin for that role
Role.add_flag('is_antiroot',function(player,state) if player.character then player.character.destructible = not state end end) -- not required but setting true will disallow everythin for that role
Role.add_flag('is_admin',function(player,state) player.admin = state end) -- highly recomented but not required
Role.add_flag('is_spectator',function(player,state) player.spectator = state end)
Role.add_flag('is_jail',function(player,state) if player.character then player.character.active = not state end end)
Role.add_flag('allow_afk_kick')
Role.add_flag('is_donator')
Role.add_flag('is_timed')
Role.add_flag('is_varified')
Role.add_flag('not_reportable')

-- Root
Role{
    name='Root',
    short_hand='Root',
    tag='[Root]',
    group='Root',
    colour={r=255,b=255,g=255},
    is_root=true,
    is_admin=true,
    is_spectator=true,
    not_reportable=true,
    allow={}
}
Role{
    name='Community Manager',
    short_hand='Com Mngr',
    tag='[Com Mngr]',
    group='Root',
    colour={r=150,g=68,b=161},
    is_admin=true,
    is_spectator=true,
    is_donator=true,
    not_reportable=true,
    allow={}
}
Role{
    name='Developer',
    short_hand='Dev',
    tag='[Dev]',
    group='Root',
    colour={r=179,g=125,b=46},
    is_admin=true,
    is_spectator=true,
    is_donator=true,
    not_reportable=true,
    allow={
        ['interface']=true,
        ['cheat-mode']=true
    }
}

-- Admin
Role{
    name='Administrator',
    short_hand='Admin',
    tag='[Admin]',
    group='Admin',
    colour={r=233,g=63,b=233},
    is_admin=true,
    is_spectator=true,
    not_reportable=true,
    allow={
        ['game-settings']=true,
        ['always-warp']=true,
        ['admin-items']=true
    }
}
Role{
    name='Moderator',
    short_hand='Mod',
    tag='[Mod]',
    group='Admin',
    colour={r=0,g=170,b=0},
    is_admin=true,
    is_spectator=true,
    not_reportable=true,
    allow={
        ['set-home']=true,
        ['home']=true,
        ['return']=true,
        ['announcements']=true,
        ['rank-changer']=true,
    }
}
Role{
    name='Trainee',
    short_hand='TrMod',
    tag='[TrMod]',
    group='Admin',
    colour={r=0,g=196,b=137},
    is_spectator=true,
    not_reportable=true,
    allow={
        ['go-to']=true,
        ['bring']=true,
        ['set-home']=false,
        ['home']=false,
        ['return']=false,
        ['bonus']=false,
        ['admin-commands']=true,
        ['warn']=true,
        ['temp-ban']=true,
        ['clear-warnings']=true,
        ['clear-reports']=true,
        ['clear-all']=true,
        ['clear-inv']=true,
    }
}

-- High Member
Role{
    name='Sponsor',
    short_hand='Spon',
    tag='[Sponsor]',
    group='HiMember',
    colour={r=247,g=246,b=54},
    is_spectator=true,
    is_donator=true,
    allow={}
}
Role{
    name='Pay to Win',
    short_hand='P2W',
    tag='[P2W]',
    group='HiMember',
    colour={r=238,g=172,b=44},
    is_donator=true,
    allow={
        ['jail']=true,
        ['unjail']=true,
        ['bonus']=true,
        ['bonus-respawn']=true
    }
}
Role{
    name='Donator',
    short_hand='Don',
    tag='[Donator]',
    group='HiMember',
    colour={r=230,g=99,b=34},
    is_donator=true,
    allow_afk_kick=true,
    allow={
        ['set-home']=true,
        ['home']=true,
        ['return']=true,
    }
}
Role{
    name='Partner',
    short_hand='Part',
    tag='[Partner]',
    group='HiMember',
    colour={r=140,g=120,b=200},
    allow_afk_kick=true,
    allow={
        ['global-chat']=true,
    }
}
Role{
    name='Veteran',
    short_hand='Vet',
    tag='[Veteran]',
    group='HiMember',
    colour={r=140,g=120,b=200},
    is_timed=true,
    is_varified=true,
    allow_afk_kick=true,
    time=600, -- 10 hours
    allow={
        ['tree-decon']=true,
        ['create-poll']=true,
        ['repair']=true
    }
}

-- Member
Role{
    name='Member',
    short_hand='Mem',
    tag='[Member]',
    group='Member',
    colour={r=24,g=172,b=188},
    is_varified=true,
    allow_afk_kick=true,
    allow={
        ['edit-tasklist']=true,
        ['make-warp']=true,
        ['nuke']=true,
        ['varified']=true
    }
}
Role{
    name='Regular',
    short_hand='Reg',
    tag='[Regular]',
    group='Member',
    colour={r=79,g=155,b=163},
    allow_afk_kick=true,
    is_timed=true,
    time=180, -- 3 hours
    allow={
        ['kill']=true,
        ['decon']=true,
        ['capsules']=true
    }
}

-- Guest
Role{
    name='Guest',
    short_hand='',
    tag='',
    group='User',
    colour={r=185,g=187,b=160},
    allow_afk_kick=true,
    is_default=true,
    allow={
        ['player-list']=true,
        ['readme']=true,
        ['rockets']=true,
        ['science']=true,
        ['tasklist']=true,
        ['report']=true,
        ['warp-list']=true,
        ['polls']=true,
        ['tag']=true,
        ['tag-clear']=true,
        ['report']=true
    }
}

-- Jail
Role{
    name='Jail',
    short_hand='Jail',
    tag='[Jail]',
    group='Jail',
    colour={r=50,g=50,b=50},
    is_jail=true,
    is_antiroot=true,
    allow={}
}

Role.order = {
    'Root',
    'Community Manager',
    'Developer',
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

Role.set_preassign{
    ["cooldude2606"]={"Developer","Admin","Mod"},
    ["aldldl"]={"Sponsor","Admin","Donator","Sponsor","Member","Mod"},
    ["arty714"]={"Admin","Community Manager","Member","Mod"},
    ["drahc_pro"]={"Admin","Member","Mod"},
    ["mark9064"]={"Admin","Member","Mod"}
}