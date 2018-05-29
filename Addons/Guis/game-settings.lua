--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

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

local function _get_data(root_frame)
    local object = root_frame.name
    local key = root_frame.setting_name.caption
    for _,setting in pairs(_root_list[object]) do
        if key == setting.key then return setting end
    end
end

local function _object_list(player) return {game=game,player=player,force=player.force,enemy=game.forces['enemy']} end

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
                pcall(object[data.key],unpack(data.params))
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
        caption={'game-settings.effect-'..setting.name},
        style='caption_label'
    }
    frame.add{
        type='label',
        caption=setting.key,
        name='setting_name'
    }.style.visible = false
    if setting.type == 'slider' then
        local slider = setting._loaded:draw(frame)
        slider.style.width = 300
        local _caption = string.format('%.2f',slider.slider_value); if slider.slider_value > 2 then _caption = tostring(math.floor(slider.slider_value)) end
        frame.add{
            type='label',
            name='counter',
            caption=_caption
        }
    elseif setting.type == 'function' then
        are_you_sure:draw(frame)
        local flow = frame.add{type='flow',name='sure'}
        flow.style.visible = false
        flow.add{
            type='label',
            caption={'game-settings.sure'},
            style='bold_red_label'
        }
        setting._loaded:draw(flow)
    end
end

Gui.center.add{
    name='game-settings',
    caption='utility/no_building_material_icon',
    tooltip={'game-settings.tooltip'}
}:add_tab('basic',{'game-settings.basic-name'},{'game-settings.basic-name'},function(frame)
    frame.add{
        type='label',
        caption={'game-settings.basic-message'}
    }.style.single_line = false
    for _,setting in pairs(basic_settings) do
        _draw_setting(frame,setting)
    end
end):add_tab('advanced',{'game-settings.advanced-name'},{'game-settings.advanced-tooltip'},function(frame)
    frame.add{
        type='label',
        caption={'game-settings.advanced-message'}
    }.style.single_line = false
    for _,setting in pairs(advanced_settings) do
        _draw_setting(frame,setting)
    end
end):add_tab('personal',{'game-settings.personal-name'},{'game-settings.personal-tooltip'},function(frame)
    frame.add{
        type='label',
        caption={'game-settings.personal-message'}
    }.style.single_line = false
    for _,setting in pairs(personal_settings) do
        _draw_setting(frame,setting)
    end
end)