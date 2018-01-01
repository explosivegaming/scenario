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
    global.addons.tasklist = not reset and global.addons.tasklist or {tasks={},_edit={}}
    return global.addons.tasklist
end

local edit = Gui.inputs.add{
    name='tasklist-edit',
    type='button',
    caption='utility/rename_icon_normal'
}:on_event('click',function(event)
    local text_flow = event.element.parent.parent.text_flow
    if text_flow.text.type == 'label' then
        _global()._edit[event.player_index]._editing[text_flow.parent.name]=true
        local text = text_flow.text.caption
        text_flow.clear()
        local _text = text_flow.add{
            name='text',
            type='textfield',
            text=text
        }
        _text.style.width = 100
        event.element.sprite = 'utility/enter'
    elseif text_flow.text.type == 'textfield' then
        local text = text_flow.text.text
        _global()._edit[event.player_index]._editing[text_flow.parent.name]=false
        _global()._edit[event.player_index]._tasks[text_flow.parent.name]=text
        text_flow.parent.parent.clear()
        _draw(text_flow.parent.parent)
    end
end)

local remove = Gui.inputs.add{
    name='tasklist-remove',
    type='button',
    caption='utility/remove'
}

local add = Gui.inputs.add{
    name='tasklist-add',
    type='button',
    caption='add'
}

local function _draw(frame)
    frame.caption = {'tasklist.name'}
    local data = _global()
    local player = Game.get_player(frame.player_index)
    local rank = Ranking.get_rank(player)
    for i,task in pairs(_tasks(player)) do
        local flow = frame.add{
            name=i-- use parent and children so there dont colidide with each other
            type='flow',
            direction='horizontal'
        }
        local text_flow = flow.add{
            name='text_flow',
            type='flow',
            direction='horizontal'
        }
        text_flow.add{
            name='text',
            type='label',
            caption=task
        }
        local button_flow = flow.add{
            type='flow',
            direction='horizontal'
        }
        if rank:allowed('edit-tasklist') then
            edit:draw(button_flow)
            remove:draw(button_flow)
            add:draw(button_flow)
        end
    end
    if rank:allowed('edit-tasklist') then
        if not data._edit[player.index] then data._edit[player.index] = {_edit=false,_tasks={},_editing={}} end
    end
end

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
        data._edit = false
        Gui.left.update('tasklist')
    elseif not data._edit and _edit then
        data.tasks = table.deepcopy(_global()._tasks)
        data._edit = true
    elseif _edit then return data._tasks
    else return _global().tasks
    end
end

Gui.left.add{
    name='tasklist',
    caption='utility/not_enough_repair_packs_icon',
    tooltip={'tasklist.tooltip'},
    draw=_draw,
    open_on_join=true
}