-- not_luadoc=true
local temp_ban = require('ExpGamingAdmin.TempBan')
return function repairDisallow(player,entity)
    player_return('You have repaired: '..entity.name..' this item is not allowed.',defines.text_color.crit,player)
    temp_ban(player,'<server>','Attempt To Repair A Banned Item')
    entity.destroy()
end