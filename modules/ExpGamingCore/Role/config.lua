Role.add_flag('is_default') -- this must be included in atleast one role
Role.add_flag('is_root',function(player,state) player.character.destructible = not state end)
Role.add_flag('is_admin',function(player,state) player.admin = state end)
Role.add_flag('is_spectator',function(player,state) player.spectator = state end)
Role.add_flag('is_jail',function(player,state) player.character.active = not state end)

Role{
    name='Root',
    short_hand='Root',
    tag='[Root]',
    group='Root',
    colour={r=255,b=255,g=255},
    is_root=true,
    is_admin=true,
    is_spectator=true,
    is_default=true,
    allow={}
}

Role.order = {
    'Root'
}