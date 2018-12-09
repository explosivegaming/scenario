local Sync = require('ExpGamingCore.Sync')
local global = global['ExpGamingInfo.Rockets']

Sync.add_update('rockets',function()
    local _return = {}
    local satellites = game.forces.player.get_item_launched('satellite')
    local time = {'rockets.nan'}
    if satellites == 1 then time = tick_to_display_format(game.tick)
    elseif satellites > 1 then time = tick_to_display_format((game.tick-global.first)/satellites) end
    _return.total = satellites
    _return.first = Sync.tick_format(global.first)
    _return.last = Sync.tick_format(global.last-global._last)
    _return.time = Sync.tick_format(time)
    _return.fastest = Sync.tick_format(global.fastest)
    _return.milestones = {}
    for milestone,time in pairs(global.milestones) do
        _return.milestones[milestone] = Sync.tick_format(time)
    end
    return _return
end)