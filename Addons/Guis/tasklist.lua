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
    global.addons.tasklist = not reset and global.addons.tasklist or {tasks={},_edit={},_base={_edit=false,_tasks={},_editing={}}}
    return global.addons.tasklist
end

local edit = Gui.inputs.add{
    name='tasklist-edit',
    type='button',
    caption='utility/rename_icon_normal'
}:on_event('click',function(event)
    local text_flow = event.element.parent.parent.text_flow
    local data = _global()._edit[event.player_index]
    if not data._edit then data._tasks = table.deepcopy(_global().tasks) end
    if text_flow.input.type == 'label' then
        data._editing[tonumber(text_flow.parent.name)]=true
        Gui.left.update('tasklist',event.player_index)
    elseif text_flow.input.type == 'textfield' then
        local text = text_flow.input.text
        data._editing[tonumber(text_flow.parent.name)]=false
        data._tasks[tonumber(text_flow.parent.name)]=text
        Gui.left.update('tasklist',event.player_index)
    end
end)

local function _edit(frame)
    local element = edit:draw(frame)
    local text_flow = element.parent.parent.text_flow
    local data = _global()._edit[frame.player_index]
        data._tasks[text_flow.parent.name]=text
        if data._editing[tonumber(text_flow.parent.name)] then
        local text = text_flow.input.caption
        text_flow.clear()
        local _text = text_flow.add{
            name='input',
            type='textfield',
            text=text
        }
        _text.style.width = 200
        element.sprite = 'utility/enter'
    end
end

local remove = Gui.inputs.add{
    name='tasklist-remove',
    type='button',
    caption='utility/remove'
}:on_event('click',function(event)
    local frame = event.element.parent.parent
    local data = _global()._edit[event.player_index]
    if data._edit then
        table.remove(data._tasks,tonumber(frame.name))
        table.remove(data._editing,tonumber(frame.name))
    else
        table.remove(_global().tasks,tonumber(frame.name))
    end
    Gui.left.update('tasklist',event.player_index)
end)

local add = Gui.inputs.add{
    name='tasklist-add',
    type='button',
    caption='utility/add'
}:on_event('click',function(event)
    local frame = event.element.parent.parent
    local data = _global()._edit[event.player_index]
    if data._edit then
        table.insert(data._tasks,tonumber(frame.name)+1,'New Value')
        table.insert(data._editing,tonumber(frame.name)+1,true)
    else
        data._tasks = table.deepcopy(_global().tasks)
        table.insert(data._tasks,tonumber(frame.name)+1,'New Value')
        table.insert(data._editing,tonumber(frame.name)+1,true)
    end
    Gui.left.update('tasklist',event.player_index)
end)

local function _tasks(player)
    local player = Game.get_player(player)
    local data = _global()._edit[player.index]
    if not data then return _global().tasks end
    local _edit = false
    for _,v in pairs(data._editing) do
        if v == true then
            _edit = true
            break
        end
    end
    if data._edit and not _edit then
        _global().tasks = table.deepcopy(data._tasks)
        _global()._edit[player.index] = table.deepcopy(_global()._base)
        Gui.left.update('tasklist')
        return _global().tasks
    elseif not data._edit and _edit then
        data._edit = true
        return data._tasks
    elseif _edit then return data._tasks
    else return _global().tasks
    end
end

Gui.left.add{
    name='tasklist',
    caption='utility/not_enough_repair_packs_icon',
    tooltip={'tasklist.tooltip'},
    draw=function(frame)
        frame.caption = {'tasklist.name'}
        local data = _global()
        local player = Game.get_player(frame.player_index)
        local rank = Ranking.get_rank(player)
        if rank:allowed('edit-tasklist') then
            if not data._edit[player.index] then data._edit[player.index] = table.deepcopy(data._base) end
        end
        for i,task in pairs(_tasks(player)) do
            local flow = frame.add{
                name=i,
                type='flow',
                direction='horizontal'
            }
            local text_flow = flow.add{
                name='text_flow',
                type='flow',
                direction='horizontal'
            }
            text_flow.add{
                name='input',
                type='label',
                caption=task
            }
            local button_flow = flow.add{
                type='flow',
                direction='horizontal'
            }
            if rank:allowed('edit-tasklist') then
                _edit(button_flow)
                remove:draw(button_flow)
                add:draw(button_flow)
            end
        end
        if #_tasks(player) == 0 then
            local flow = frame.add{
                name=0,
                type='flow',
                direction='horizontal'
            }
            local button_flow = flow.add{
                type='flow',
                direction='horizontal'
            }
            add:draw(button_flow)
        end
    end,
    can_open=function(player)
        local rank = Ranking.get_rank(player)
        if rank:allowed('edit-tasklist') or #_global().tasks > 0 then return true
        else return {'tasklist.none'} end
    end,
    open_on_join=true
}