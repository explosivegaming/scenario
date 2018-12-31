--- Adds a science count gui to the game that shows toatal made and per minute
-- @module ExpGamingInfo.Science
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ThisModule 

-- Module Require
local Gui = require('ExpGamingCore.Gui')
local Game = require('FactorioStdLib.Game')

-- Local Varibles
local science_packs = {
    'science-pack-1',
    'science-pack-2',
    'science-pack-3',
    'military-science-pack',
    'production-science-pack',
    'high-tech-science-pack',
    'space-science-pack'
}

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Sync^4.0.0'] then require(module_path..'/src/sync') end
    end
}

-- Global Define
local global = global{
    _base={
        update=0,
        _update=0,
        made={0,0,0,0,0,0,0},
        _made={0,0,0,0,0,0,0}
    }
}

-- Function Define
ThisModule.Gui = Gui.left{
    name='science',
    caption='item/lab',
    tooltip={'ExpGamingInfo-Science.tooltip'},
    draw=function(self,frame)
        local player = Game.get_player(frame.player_index)
        if not global[player.force.name] then
            verbose('Added Science Global for: '..player.force.name)
            global[player.force.name] = table.deepcopy(global._base)
        end
        force_data = global[player.force.name]
        frame.caption = {'ExpGamingInfo-Science.name'}
        frame.add{
            type='label',
            caption={'ExpGamingInfo-Science.total'},
            style='caption_label'
        }
        local totals = frame.add{
            type='flow',
            direction='vertical'
        }
        frame.add{
            type='label',
            caption={'ExpGamingInfo-Science.time'},
            style='caption_label'
        }
        local times = frame.add{
            type='flow',
            direction='vertical'
        }
        if force_data.update < game.tick-100 then
            force_data._update = force_data.update
            force_data._made = table.deepcopy(force_data.made)
            for i,name in pairs(science_packs) do
                force_data.made[i] = player.force.item_production_statistics.get_input_count(name)
            end
            force_data.update = game.tick
        end
        for i,name in pairs(science_packs) do
            local made = force_data.made[i]
            if made > 0 then
                totals.add{
                    type='label',
                    caption={'ExpGamingInfo-Science.format',{'ExpGamingInfo-Science.'..name},made}
                }
                local _made = string.format('%.2f',(made-force_data._made[i])/((force_data.update-force_data._update)/(3600*game.speed)))
                times.add{
                    type='label',
                    caption={'ExpGamingInfo-Science.format',{'ExpGamingInfo-Science.'..name},_made}
                }
            end
        end
    end,
    can_open=function(player)
        if player.force.item_production_statistics.get_input_count('science-pack-1') > 0 then return true
        else return {'ExpGamingInfo-Science.none'} end
    end
}

-- Event Define
script.on_event(defines.events.on_research_finished,function(event) Gui.left.update('science') end)

-- Module Return
-- when called will toogle the gui for that player, if no player it will update the gui
return setmetatable(ThisModule,{_call=function(self,...) self.Gui(...) end})