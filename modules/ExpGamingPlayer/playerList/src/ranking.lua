local Role = require('ExpGamingCore.Role')

script.on_event(defines.events.on_role_change,self.update)

return function()
    local rtn = {}
    local default = {}
    for _,role_name in pairs(Role.order) do
        local role = Role.get(role_name,true)
        if role.is_default then default = {role.colour,role.short_hand,role:get_players(true),role.not_reportable} 
        else table.insert(rtn,{role.colour,role.short_hand,role:get_players(true),role.not_reportable}) end
    end
    table.insert(rtn,default)
    return rtn
end