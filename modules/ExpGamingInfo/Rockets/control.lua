--- Adds a rocket count gui to the game that shows milestones and average rocket time
-- @module ExpGamingInfo.Rockets
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alias ThisModule

-- Module Require
local Gui = require('ExpGamingCore.Gui')
local Game = require('FactorioStdLib.Game')

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Sync^4.0.0'] then require(module_path..'/src/sync') end
    end
}

-- Global Define
local global = {
    update=0,
    first=0,
    _last=0,
    last=0,
    fastest=0,
    milestones={m1=0,m2=0,m5=0,m10=0,m20=0,m50=0,m100=0,m200=0,m500=0,m1000=0,m2000=0,m5000=0}
}
Global.register(global,function(tbl) global = tbl end)

-- Function Define
ThisModule.Gui = Gui.left{
    name='rockets',
    caption='item/rocket-silo',
    tooltip={'ExpGamingInfo-Rockets.tooltip'},
    draw=function(self,frame)
        frame.caption = {'ExpGamingInfo-Rockets.name'}
        local player = Game.get_player(frame.player_index)
        local satellites = player.force.get_item_launched('satellite')
        local time = {'ExpGamingInfo-Rockets.nan'}
        if satellites == 1 then time = tick_to_display_format(game.tick)
        elseif satellites > 1 then time = tick_to_display_format((game.tick-global.first)/satellites) end
        if satellites ~= global.update then
            global.update = satellites
            if global.first == 0 then global.first = game.tick end
            global._last = global.last
            global.last = game.tick
            if global.last-global._last < global.fastest or global.fastest == 0 then global.fastest = global.last-global._last end
        end
        frame.add{
            type='label',
            caption={'ExpGamingInfo-Rockets.sent',satellites}
        }
        frame.add{
            type='label',
            caption={'ExpGamingInfo-Rockets.first',tick_to_display_format(global.first)}
        }
        frame.add{
            type='label',
            caption={'ExpGamingInfo-Rockets.last',tick_to_display_format(global.last-global._last)}
        }
        frame.add{
            type='label',
            caption={'ExpGamingInfo-Rockets.time',time}
        }
        frame.add{
            type='label',
            caption={'ExpGamingInfo-Rockets.fastest',tick_to_display_format(global.fastest)}
        }
        frame.add{
            type='label',
            caption={'ExpGamingInfo-Rockets.milestones'},
            style='caption_label'
        }
        local milestones = frame.add{
            type='flow',
            direction='vertical'
        }
        for milestone,next_time in pairs(global.milestones) do
            milestone = tonumber(milestone:match('%d+'))
            if next_time == 0 and satellites == milestone then
                global.milestones['m'..milestone] = global.last
                next_time = global.last
                Gui.left.open('rockets')
            end
            local _time = {'ExpGamingInfo-Rockets.nan'}
            if next_time > 0 then _time = tick_to_display_format(next_time) end
            milestones.add{
                type='label',
                caption={'ExpGamingInfo-Rockets.format',tostring(milestone),_time}
            }
            if next_time == 0 then break end
        end
    end,
    can_open=function(player) 
        if player.force.get_item_launched('satellite') > 0 then return true
        else return {'ExpGamingInfo-Rockets.none'} end
    end
}

-- Event Define
Event.add(defines.events.on_rocket_launched,function(event) Gui.left.update('rockets') end)

-- Module Return
-- when called will toggle the gui for that player, updates gui if no player given
return setmetatable(ThisModule,{__call=function(self,...) self.Gui(...) end})