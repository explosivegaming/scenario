--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

--[[
    How to use groups:
name		The name that you can use to reference it.
disallow	If present then all ranks in this group will have this added to their disallow.
allow		If present then all ranks in this group will have this added to their allow.
highest     Assigned by the script to show the highest rank in this group.
lowest      Assigned by the script to show the lowest rank in this group.
How to add ranks:
Name		What will be used in the scripts and is often the best choice for display in text.
short_hand	What can be used when short on space but the rank still need to be displayed.
tag			The tag the player will gain when moved to the rank, it can be nil.
time		Used for auto-rank feature where you are moved to the rank after a certain play time in minutes.
colour		The RGB value that can be used to emphasise GUI elements based on rank.
power		Assigned by the script based on their index in ranks, you can insert new ranks between current ones.
group		Assigned by the script to show the group this rank is in.
disallow	A list containing input actions that the user can not perform.
allow		A list of custom commands and effects that that rank can use, all defined in the scripts.

For allow, add the allow as the key and the value as true
Example: test for 'server-interface' => allow['server-interface'] = true

For disallow, add to the list the end part of the input action
Example: defines.input_action.drop_item -> 'drop_item'
http://lua-api.factorio.com/latest/defines.html#defines.input_action
--]]

-- See ExpCore/ranks.lua for examples - you add your own and edit pre-made ones here.

Ranking._group:create{
    name='Donator',
    allow={},
    disallow={
        'set_allow_commands',
        'edit_permission_group',
        'delete_permission_group',
        'add_permission_group'
    }
}

local groups = Ranking._groups(true)

groups['Root']:edit('allow',false,{
    ['player-list']=true,
    ['readme']=true,
    ['rockets']=true,
    ['science']=true,
    ['tasklist']=true,
    ['rank-changer']=true,
    ['admin-commands']=true,
    ['warn']=true,
    ['temp-ban']=true,
    ['clear-warings']=true,
    ['clear-reports']=true,
    ['clear-all']=true,
    ['clear-inv']=true,
    ['announcements']=true,
    ['warp-list']=true,
    ['polls']=true,
    ['admin-items']=true,
    ['all-items']=true,
    ['repair']=true,
    ['global-chat']=true,
    ['set-home']=true,
    ['home']=true,
    ['return']=true,
})
groups['Admin']:edit('allow',false,{
    ['player-list']=true,
    ['readme']=true,
    ['rockets']=true,
    ['science']=true,
    ['tasklist']=true,
    ['rank-changer']=true,
    ['admin-commands']=true,
    ['warn']=true,
    ['temp-ban']=true,
    ['clear-warings']=true,
    ['clear-reports']=true,
    ['clear-all']=true,
    ['clear-inv']=true,
    ['announcements']=true,
    ['warp-list']=true,
    ['polls']=true,
    ['global-chat']=true,
    ['set-home']=true,
    ['home']=true,
    ['return']=true,
})
groups['Donator']:edit('allow',false,{
    ['player-list']=true,
    ['readme']=true,
    ['rockets']=true,
    ['science']=true,
    ['tasklist']=true,
    ['report']=true,
    ['warp-list']=true,
    ['polls']=true,
    ['global-chat']=true,
    ['set-home']=true,
    ['home']=true,
    ['return']=true,
})
groups['User']:edit('allow',false,{
    ['player-list']=true,
    ['readme']=true,
    ['rockets']=true,
    ['science']=true,
    ['tasklist']=true,
    ['report']=true,
    ['warp-list']=true,
    ['polls']=true
})
groups['Jail']:edit('allow',false,{
    
})



groups['Root']:add_rank{
    name='Owner',
    short_hand='Owner',
    tag='[Owner]',
    time=nil,
    colour={r=170,g=0,b=0},
    is_admin = true,
    is_spectator=true,
    base_afk_time=false
}
groups['Root']:add_rank{
    name='Community Manager',
    short_hand='Com Mngr',
    tag='[Com Mngr]',
    colour={r=150,g=68,b=161},
    is_admin = true,
    is_spectator=true,
    base_afk_time=false
}
groups['Root']:add_rank{
    name='Developer',
    short_hand='Dev',
    tag='[Dev]',
    colour={r=179,g=125,b=46},
    is_admin = true,
    is_spectator=true,
    base_afk_time=false
}

groups['Admin']:add_rank{
    name='Mod',
    short_hand='Mod',
    tag='[Mod]',
    colour={r=0,g=170,b=0},
    disallow={
        'server_command'
    },
    is_admin = true,
    is_spectator=true,
    base_afk_time=false
}
groups['Admin']:add_rank{
    name='Trainee',
    short_hand='TrMod',
    tag='[Trainee]',
    colour={r=0,g=196,b=137},
    disallow={
        'server_command'
    },
    is_spectator=true,
    base_afk_time=false
}

groups['Donator']:add_rank{
    name='Sponsor',
    short_hand='Spon',
    tag='[Sponsor]',
    colour={r=247,g=246,b=54},
    power=8,
    is_spectator=true,
    base_afk_time=false
}
groups['Donator']:add_rank{
    name='Pay to Win',
    short_hand='P2W',
    tag='[P2W]',
    colour={r=238,g=172,b=44},
    is_spectator=true,
    base_afk_time=160
}
groups['Donator']:add_rank{
    name='Donator',
    short_hand='Don',
    tag='[Donator]',
    colour={r=230,g=99,b=34},
    is_spectator=true,
    base_afk_time=120
}

groups['User']:add_rank{
    name='Partner',
    short_hand='Part',
    tag='[Partner]',
    power=0,
    colour={r=140,g=120,b=200},
    base_afk_time=120
}
groups['User']:add_rank{
    name='Veteran',
    short_hand='Vet',
    tag='[Veteran]',
    time=600,
    power=1,
    colour={r=26,g=118,b=156},
    base_afk_time=60
}
groups['User']:add_rank{
    name='Regular',
    short_hand='Reg',
    tag='[Regular]',
    time=180,
    colour={r=79,g=155,b=163},
    power=3,
    base_afk_time=30
}

local ranks = Ranking._ranks(true)

ranks['Developer']:edit('allow',false,{
    ['cheat-mode']=true
})

ranks['Admin']:edit('allow',false,{
    ['game-settings']=true,
    ['always-warp']=true,
    ['admin-items']=true
})
ranks['Mod']:edit('allow',false,{
    ['go-to']=true,
    ['bring']=true,
    ['no-report']=true
})
ranks['Trainee']:edit('allow',false,{
    ['go-to']=true,
    ['bring']=true,
    ['no-report']=true
})

ranks['Sponsor']:edit('allow',false,{
    ['jail']=true,
    ['unjail']=true,
    ['bonus']=true,
    ['bonus-respawn']=true
})
ranks['Pay to Win']:edit('allow',false,{
    ['jail']=true,
    ['unjail']=true,
    ['bonus']=true,
    ['bonus-respawn']=true
})
ranks['Donator']:edit('allow',false,{

})

ranks['Partner']:edit('allow',false,{

})
ranks['Veteran']:edit('allow',false,{
    ['tree-decon']=true,
    ['create-poll']=true,
    ['repair']=true
})
ranks['Member']:edit('allow',false,{
    ['edit-tasklist']=true,
    ['make-warp']=true,
    ['nuke']=true,
    ['base-damage']=true,
    ['varified']=true
})
ranks['Regular']:edit('allow',false,{
    ['kill']=true,
    ['decon']=true,
    ['capsules']=true
})
ranks['Guest']:edit('allow',false,{
    ['tag']=true,
    ['tag-clear']=true,
    ['report']=true
})

Ranking._base_preset{
    ['badgamernl']='Owner',
    ['arty714']='Community Manager',
    ['cooldude2606']='Developer',
    ['mark9064']='Admin',
    ['propangaseddy']='Admin',
    ['aldldl']='Admin'
}
