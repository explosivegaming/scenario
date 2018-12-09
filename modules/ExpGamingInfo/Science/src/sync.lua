local Sync = require('ExpGamingCore.Sync')
local data = global['ExpGamingInfo.Science']

Sync.add_update('science',function()
    local _return = {}
    for force_name,global in pairs(data) do
        if force_name ~= '_base' then
            _return[force_name] = {totals={},times={}}
            for i,name in pairs(science_packs) do
                local made = global.made[i]
                _return[force_name].totals[name] = made
                local _made = string.format('%.2f',(made-global._made[i])/((global.update-global._update)/(3600*game.speed)))
                _return[force_name].times[name] = _made
            end
        end
    end
    return _return
end)