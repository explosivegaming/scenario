local Role = require('ExpGamingCore.Role@^4.0.0')

script.on_event(defines.events.on_role_change,self.update)

return function()
    local rtn = {}
    for _,role_name in pairs(Role.order) do
        local role = Role.get(role_name)
        table.insert(rtn,{role.colour,role.short_hand,role:get_players(true),role.not_reportable})
    end
    return rtn
end