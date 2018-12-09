-- not_luadoc=true
local temp_ban = require('ExpGamingAdmin.AdminLib').temp_ban
return function(player,entity)
    player_return('You have repaired: '..entity.name..' this item is not allowed.',defines.textcolor.crit,player)
    temp_ban(player,'<server>','Attempt To Repair A Banned Item')
    entity.destroy()
end