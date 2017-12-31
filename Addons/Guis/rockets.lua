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
    global.addons.rockets = not reset and global.addons.rockets or {first=0,last=0,milestones={m1=0,m2=0,m5=0,m10=0,m20=0,m50=0,m100=0,m200=0,m500=0}}
    return global.addons.rockets
end
Gui.left.add{
    name='rockets',
    caption='item/rocket-silo',
    tooltip={'rockets.tooltip'},
    draw=function(frame)
        frame.caption = {'rocket-gui.name'}
        local data = _global()
        local satellites = player.force.get_item_launched('satellite')
        local time = {'rockets.nan'}
        if satellites == 1 then time = tick_to_display_format(game.tick) data.first = game.tick data.last = game.tick
        elseif satellites > 1 then tick_to_display_format((game.tick-data.first)/satellites) data.last = game.tick end
        frame.add{
            type='label',
            caption={'rockets.sent',satellites}
        }
        frame.add{
            type='label',
            caption={'rockets.first',tick_to_display_format(data.fist)}
        }
        frame.add{
            type='label',
            caption={'rockets.last',tick_to_display_format(data.last)}
        }
        frame.add{
            type='label',
            caption={'rockets.time',time}
        }
        frame.add{
            type='label',
            caption={'rockets.milestones'},
            style='caption_label'
        }
        local milestones = {
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
                caption={'rockets.format',tostring(milestone),time}
            }
        end
    end,
    can_open=function(player) return player.force.get_item_launched('satellite') > 0 end
}

Event.register(defines.events.on_rocket_launched,function(event) Gui.left.update('rockets') end)