--- A gui for controlling game settings with sliders as well as some global commands.
-- @module GameSettingsGui@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

-- Module Require
local Server = require('ExpGamingCore.Server@^4.0.0')
local Gui = require('ExpGamingCore.Gui@^4.0.0')

-- Local Varibles
--{type='slider',object='',key='',name='',min=x,max=y}
--{type='function',object='',key='',name='',param={}}
local basic_settings = {
    {type='slider',object='force',key='manual_mining_speed_modifier',name='mining-speed',min=0,max=10},
    {type='slider',object='force',key='manual_crafting_speed_modifier',name='craft-speed',min=0,max=10},
    {type='slider',object='force',key='character_running_speed_modifier',name='running-speed',min=0,max=10},
    {type='slider',object='force',key='character_build_distance_bonus',name='build-distance',min=0,max=50},
    {type='slider',object='force',key='character_reach_distance_bonus',name='reach-distance',min=0,max=50},
    {type='slider',object='force',key='worker_robots_speed_modifier',name='bot-speed',min=0,max=10},
    {type='slider',object='force',key='laboratory_speed_modifier',name='lab-speed',min=0,max=10},
    {type='slider',object='force',key='stack_inserter_capacity_bonus',name='stack-bonus',min=1,max=30}
}

local advanced_settings = {
    {type='slider',object='force',key='quickbar_count',name='quickbar-count',min=1,max=5},
    {type='slider',object='force',key='character_inventory_slots_bonus',name='inventory-size',min=0,max=1000},
    {type='slider',object='force',key='mining_drill_productivity_bonus',name='mining-prod',min=0,max=10},
    {type='slider',object='game',key='speed',name='game-speed',min=0.01,max=5},
    {type='function',object='surface',key='clear_pollution',name='clear-pollution'},
    {type='function',object='game',key='server_save',name='save'},
    {type='function',object='force',key='reset_technology_effects',name='reload-effects'},
    {type='function',object='enemy',key='kill_all_units',name='kill-biters'},
    {type='function',object='force',key='rechart',name='reload-map'},
    {type='function',object='game',key='force_crc',name='crc'},
    {type='function',object='force',key='reset',name='reset-force'}
}

local personal_settings = {
    {type='slider',object='player',key='character_mining_speed_modifier',name='mining-speed',min=0,max=10},
    {type='slider',object='player',key='character_crafting_speed_modifier',name='craft-speed',min=0,max=10},
    {type='slider',object='player',key='character_running_speed_modifier',name='running-speed',min=0,max=10},
    {type='slider',object='player',key='character_build_distance_bonus',name='build-distance',min=0,max=50},
    {type='slider',object='player',key='character_reach_distance_bonus',name='reach-distance',min=0,max=50},
    {type='slider',object='player',key='character_inventory_slots_bonus',name='inventory-size',min=0,max=1000},
    {type='slider',object='player',key='quickbar_count_bonus',name='quickbar-count',min=0,max=5}
}

local _root_list = {basic_settings=basic_settings,advanced_settings=advanced_settings,personal_settings=personal_settings}

-- Module Define
local module_verbose = false
local ThisModule = {}

-- Function Define
local function _get_data(root_frame)
    local object = root_frame.name
    local key = root_frame.setting_name.caption
    for _,setting in pairs(_root_list[object]) do
        if key == setting.key then return setting end
    end
end

local function _object_list(player) return {game=game,player=player,force=player.force,enemy=game.forces['enemy'],surface=player.surface} end

for name,group in pairs(_root_list) do
    for key,setting in pairs(group) do
        local _added = nil
        if setting.type == 'slider' then
            _added = Gui.inputs.add_slider('game-settings-'..setting.name,'horizontal',setting.min,setting.max,
                function(player,root_frame) 
                    local data = _get_data(root_frame)
                    local objects = _object_list(player)
                    local object = objects[data.object]
                    return object[data.key] or 1
                end,
                function(player,value,percent,element)
                    local data = _get_data(element.parent)
                    local objects = _object_list(player)
                    local object = objects[data.object]
                    local _caption = string.format('%.2f',value); if value > 2 then _caption = string.format('%.2f',math.floor(value)) end
                    object[data.key] = tonumber(_caption)
                    element.parent.counter.caption = _caption
                end
            )
        elseif setting.type == 'function' then
            _added = Gui.inputs.add_checkbox('game-settings-'..setting.name,true,nil,false,function(player,element)
                local data = _get_data(element.parent.parent)
                local objects = _object_list(player)
                local object = objects[data.object]
                -- if key is a function it will run the function rather than attempt to get a function
                if is_type(data.key,'function') then pcall(data.key,object,unpack(data.params))
                else pcall(object[data.key],unpack(data.params)) end
                Server.new_thread{
                    timeout=60,
                    data=element
                }:on_event('timeout',function(self)
                    if self.data and self.data.valid then
                        element.parent.parent['game-settings-are-you-sure'].state = false
                        self.data.parent.style.visible = false
                        self.data.state = false
                    end
                end):open()
            end)
            if not setting.params then setting.params = {} end
        end
        setting._loaded = _added
        setting._group = name
    end
end

local are_you_sure = Gui.inputs.add_checkbox('game-settings-are-you-sure',true,nil,false,function(player,element)
    element.parent.sure.style.visible = true
    Server.new_thread{
        timeout=600,
        data=element
    }:on_event('timeout',function(self)
        if self.data and self.data.valid then
            self.data.state = false
            self.data.parent.sure.style.visible = false
        end
    end):open()
end)

local function _draw_setting(frame,setting)
    local frame = frame.add{type='flow'}
    local frame = frame.add{
        type='flow',
        name=setting._group
    }
    frame.add{
        type='label',
        caption={'GameSettingsGui.effect-'..setting.name},
        style='caption_label'
    }
    frame.add{
        type='label',
        caption=setting.key,
        name='setting_name'
    }.style.visible = false
    if setting.type == 'slider' then
        local slider = setting._loaded(frame)
        slider.style.width = 300
        local _caption = string.format('%.2f',slider.slider_value); if slider.slider_value > 2 then _caption = tostring(math.floor(slider.slider_value)) end
        frame.add{
            type='label',
            name='counter',
            caption=_caption
        }
    elseif setting.type == 'function' then
        are_you_sure(frame)
        local flow = frame.add{type='flow',name='sure'}
        flow.style.visible = false
        flow.add{
            type='label',
            caption={'GameSettingsGui.sure'},
            style='bold_red_label'
        }
        setting._loaded(flow)
    end
end

ThisModule.Gui = Gui.center{
    name='game-settings',
    caption='utility/no_building_material_icon',
    tooltip={'GameSettingsGui.tooltip'}
}:add_tab('basic',{'GameSettingsGui.basic-name'},{'GameSettingsGui.basic-name'},function(frame)
    frame.add{
        type='label',
        caption={'GameSettingsGui.basic-message'}
    }.style.single_line = false
    for _,setting in pairs(basic_settings) do
        _draw_setting(frame,setting)
    end
end):add_tab('advanced',{'GameSettingsGui.advanced-name'},{'GameSettingsGui.advanced-tooltip'},function(frame)
    frame.add{
        type='label',
        caption={'GameSettingsGui.advanced-message'}
    }.style.single_line = false
    for _,setting in pairs(advanced_settings) do
        _draw_setting(frame,setting)
    end
end):add_tab('personal',{'GameSettingsGui.personal-name'},{'GameSettingsGui.personal-tooltip'},function(frame)
    frame.add{
        type='label',
        caption={'GameSettingsGui.personal-message'}
    }.style.single_line = false
    for _,setting in pairs(personal_settings) do
        _draw_setting(frame,setting)
    end
end)

-- Module return
-- when called it will open the center gui for the player
return setmetatable(ThisModule,{__call=function(self,...) self.Gui(...) end})