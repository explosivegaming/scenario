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
    -- mining
    -- crafting
    -- running
    -- build distance
    -- reach
    -- bot speed
    -- lab speed
    -- stack bonus
}

local advanced_settings = {
    -- hotbar count
    -- inventory size
    -- mining prog
    -- game speed
    -- force crc -function
    -- save game -function
    -- reset force -function
    -- reload effects -function
    -- kill bitters -function
    -- re chart map -function
}

local personal_settings = {
    -- craft speed
    -- mining speed
    -- running speed
    -- build distance
    -- reach distance
    -- quick bar count
    -- inventory slots
}

local _root_list = {basic_settings=basic_settings,advanced_settings=advanced_settings,personal_settings=personal_settings}

local function _get_data(root_frame)
    local object = root_frame.name
    local key = root_frame.setting_name.caption
    local data = _root_list[object] and _root_list[object][key]
    return data
end

local function _object_list(player) return {game=game,player=player,force=player.force} end

for name,group in pairs(_root_list) do
    for key,setting in pairs(group) do
        if key ~= '_loaded' and key ~= key then
            local _added = nil
            if setting.type == 'slider' then
                _added = Gui.inputs.add_slider('game-settings-'..setting.name,'horizontal',setting.min,setting.max,
                    function(player,root_frame) 
                        local data = _get_data(root_frame)
                        local objects = _object_list(player)
                        local object = objects[data.object]
                        return object[data.key] or nil
                    end,
                    function(player,value,percent,element)
                        local data = _get_data(element.parent)
                        local objects = _object_list(player)
                        local object = objects[data.object]
                        object[key] = value
                        element.parent.counter.caption = tostring(value)
                    end
                )
            elseif setting.type == 'function' then
                _added = Gui.add_check('game-settings-'..setting.name,true,nil,false,function(player,element)
                    local data = _get_data(element.parent)
                    local objects = _object_list(player)
                    local object = objects[data.object]
                    pcall(object[data.key],unpack(data.params))
                end)
            end
            setting._loaded = _added
            setting._group = name
        end
    end
end

local function _draw_setting(frame,setting)
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
        caption=settings.name,
        name='setting_name'
    }
    if setting.type == 'slider' then
        local slider = setting._loaded:draw(frame)
        frame.add{
            type='label',
            name='counter',
            caption=tostring(slider.value)
        }
    elseif setting.type == 'function' then
        setting._loaded:draw(frame)
    end
end

Gui.center.add{
    name='game-settings',
    caption='utility/no_building_material_icon',
    tooltip={'game-settings.tooltip'}
}:add_tab('basic',{'game-settings.basic-name'},{'game-settings.basic-name'},function(frame)
    for _,setting in pairs(basic_settings) do
        frame.add{
            type='label',
            caption={'game-settings.basic-message'}
        }
        _draw_setting(frame,setting)
    end
end):add_tab('advanced',{'game-settings.advanced-name'},{'game-settings.advanced-tooltip'},function(frame)
    for _,setting in pairs(advanced_settings) do
        frame.add{
            type='label',
            caption={'game-settings.advanced-message'}
        }
        _draw_setting(frame,setting)
    end
end):add_tab('personal',{'game-settings.personal-name'},{'game-settings.personal-tooltip'},function(frame)
    for _,setting in pairs(personal_settings) do
        frame.add{
            type='label',
            caption={'game-settings.personal-message'}
        }
        _draw_setting(frame,setting)
    end
end)