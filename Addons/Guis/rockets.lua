--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local function _global(reset)
    global.addons = not reset and global.addons or {}
    global.addons.rockets = not reset and global.addons.rockets or {update=0,first=0,_last=0,last=0,fastest=0,milestones={m1=0,m2=0,m5=0,m10=0,m20=0,m50=0,m100=0,m200=0,m500=0,m1000=0,m1500=0,m2000=0}}
    return global.addons.rockets
end
Gui.left.add{
    name='rockets',
    caption='item/rocket-silo',
    tooltip={'rockets.tooltip'},
    draw=function(frame)
        frame.caption = {'rockets.name'}
        local player = Game.get_player(frame.player_index)
        local data = _global()
        local satellites = player.force.get_item_launched('satellite')
        local time = {'rockets.nan'}
        if satellites == 1 then time = tick_to_display_format(game.tick)
        elseif satellites > 1 then time = tick_to_display_format((game.tick-data.first)/satellites) end
        if satellites ~= data.update then
            data.update = satellites
            if data.first == 0 then data.first = game.tick end
            data._last = data.last
            data.last = game.tick
            if data.last-data._last < data.fastest or data.fastest == 0 then data.fastest = data.last-data._last end
        end
        frame.add{
            type='label',
            caption={'rockets.sent',satellites}
        }
        frame.add{
            type='label',
            caption={'rockets.first',tick_to_display_format(data.first)}
        }
        frame.add{
            type='label',
            caption={'rockets.last',tick_to_display_format(data.last-data._last)}
        }
        frame.add{
            type='label',
            caption={'rockets.time',time}
        }
        frame.add{
            type='label',
            caption={'rockets.fastest',tick_to_display_format(data.fastest)}
        }
        frame.add{
            type='label',
            caption={'rockets.milestones'},
            style='caption_label'
        }
        local milestones = frame.add{
            type='flow',
            direction='vertical'
        }
        for milestone,time in pairs(data.milestones) do
            local milestone = tonumber(milestone:match('%d+'))
            if time == 0 and satellites == milestone then
                data.milestones['m'..milestone] = data.last
                time = data.last
                Gui.left.open('rockets')
            end
            local _time = {'rockets.nan'}
            if time > 0 then _time = tick_to_display_format(time) end
            milestones.add{
                type='label',
                caption={'rockets.format',tostring(milestone),_time}
            }
            if time == 0 then break end
        end
    end,
    can_open=function(player) 
        if player.force.get_item_launched('satellite') > 0 then return true
        else return {'rockets.none'} end
    end
}

Event.register(defines.events.on_rocket_launched,function(event) Gui.left.update('rockets') end)
Sync.add_update('rockets',function()
    local _return = {}
    local data = _global()
    local satellites = game.forces.player.get_item_launched('satellite')
    local time = {'rockets.nan'}
    if satellites == 1 then time = tick_to_display_format(game.tick)
    elseif satellites > 1 then time = tick_to_display_format((game.tick-data.first)/satellites) end
    _return.total = satellites
    _return.first = Sync.tick_format(data.first)
    _return.last = Sync.tick_format(data.last-data._last)
    _return.time = Sync.tick_format(time)
    _return.fastest = Sync.tick_format(data.fastest)
    _return.milestones = {}
    for milestone,time in pairs(data.milestones) do
        _return.milestones[milestone] = Sync.tick_format(time)
    end
    return _return
end)