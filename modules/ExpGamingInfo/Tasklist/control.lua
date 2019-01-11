--- Adds a task list gui which acts like a bulletin board for the current tasks
-- @module ExpGamingInfo.Tasklist
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alias ThisModule

-- Module Require
local Gui = require('ExpGamingCore.Gui')
local Role = require('ExpGamingCore.Role')
local Game = require('FactorioStdLib.Game')

-- Module Define
local module_verbose = false
local ThisModule = {}

-- Global Define
local global = global{
    tasks={},
    _edit={},
    _base={
        _edit=false,
        _tasks={},
        _editing={}
    }
}

-- Function Define
local edit = Gui.inputs{
    name='tasklist-edit',
    type='button',
    caption='utility/rename_icon_normal'
}:on_event('click',function(event)
    local text_flow = event.element.parent.parent.text_flow
    local data = global._edit[event.player_index]
    if not data._edit then data._tasks = table.deepcopy(global.tasks) end
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
    local element = edit(frame)
    element.style.height = 20
    element.style.width = 20
    local text_flow = element.parent.parent.text_flow
    local data = global._edit[frame.player_index]
    data._tasks[text_flow.parent.name]=text
    if data._editing[tonumber(text_flow.parent.name)] then
        element.style.height = 30
        element.style.width = 30
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

local remove = Gui.inputs{
    name='tasklist-remove',
    type='button',
    caption='utility/remove'
}:on_event('click',function(event)
    local frame = event.element.parent.parent
    local data = global._edit[event.player_index]
    if data._edit then
        table.remove(data._tasks,tonumber(frame.name))
        table.remove(data._editing,tonumber(frame.name))
    else
        table.remove(global.tasks,tonumber(frame.name))
        Gui.left.update('tasklist')
    end
    Gui.left.update('tasklist',event.player_index)
end)

local add = Gui.inputs{
    name='tasklist-add',
    type='button',
    caption='utility/add'
}:on_event('click',function(event)
    local frame = event.element.parent.parent
    local data = global._edit[event.player_index]
    if data._edit then
        table.insert(data._tasks,tonumber(frame.name)+1,'New Value')
        table.insert(data._editing,tonumber(frame.name)+1,true)
    else
        data._tasks = table.deepcopy(global.tasks)
        table.insert(data._tasks,tonumber(frame.name)+1,'New Value')
        table.insert(data._editing,tonumber(frame.name)+1,true)
    end
    Gui.left.update('tasklist',event.player_index)
end)

local function _tasks(player)
    player = Game.get_player(player)
    local data = global._edit[player.index]
    if not data then return global.tasks end
    local editing = false
    for _,v in pairs(data._editing) do
        if v == true then
            editing = true
            break
        end
    end
    if data._edit and not editing then
        global.tasks = table.deepcopy(data._tasks)
        global._edit[player.index] = table.deepcopy(global._base)
        Gui.left.update('tasklist')
        return global.tasks
    elseif not data._edit and editing then
        data._edit = true
        for key,_ in pairs(data._tasks) do if not data._editing[key] then data._editing[key] = false end end
        return data._tasks
    elseif editing then return data._tasks
    else return global.tasks
    end
end

ThisModule.Gui = Gui.left{
    name='tasklist',
    caption='utility/not_enough_repair_packs_icon',
    tooltip={'ExpGamingInfo-Tasklist.tooltip'},
    draw=function(self,frame)
        frame.caption = ''
        local title = frame.add{
            type='flow',
            direction='horizontal'
        }
        title.add{
            type='label',
            caption={'ExpGamingInfo-Tasklist.name'},
            style='caption_label'
        }
        local player = Game.get_player(frame.player_index)
        local allowed = Role.allowed(player,'edit-tasklist')
        if allowed then
            if not global._edit[player.index] then global._edit[player.index] = table.deepcopy(global._base) end
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
            if allowed then
                _edit(button_flow)
                if global._edit[player.index]._editing[i] then
                    local element = remove(button_flow)
                    element.style.height = 30
                    element.style.width = 30
                    local _element = add(button_flow)
                    _element.style.height = 30
                    _element.style.width = 30
                end
            end
        end
        if allowed then
            local flow = title.add{
                name=#_tasks(player),
                type='flow',
                direction='horizontal'
            }
            local button_flow = flow.add{
                type='flow',
                direction='horizontal'
            }
            local element = add(button_flow)
            element.style.height = 20
            element.style.width = 20
        end
        if #_tasks(player) == 0 and not allowed then frame.style.visible = false end
    end,
    can_open=function(player)
        if Role.allowed(player,'edit-tasklist') or #global.tasks > 0 then return true
        else return {'ExpGamingInfo-Tasklist.none'} end
    end,
    open_on_join=true
}

-- Module return
-- when called it will toggle the gui for that player, if no player then it will update the gui
return setmetatable(ThisModule,{__call=function(self,...) self.Gui(...) end})