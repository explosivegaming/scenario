--- Desction <get from json>
-- @module ExpGamingAdmin.Gui@4.0.0
-- @author <get from json>
-- @license <get from json>
-- @alais AdminGui 

-- Module Require
local Admin = require('ExpGamingAdmin.AdminLib@^4.0.0')
local Gui = require('ExpGamingCore.Gui@^4.0.0')
local Ranking = require('ExpGamingCore.Ranking@^4.0.0')
local Game = require('FactorioStdLib.Game@^0.8.0')
local playerInfo -- ExpGamingPlayer@^4.0.0

-- Module Define
local module_verbose = false
local AdminGui = {
    on_init=function()
        if loaded_modules['ExpGamingPlayer@^4.0.0'] then playerInfo = require('ExpGamingPlayer@^4.0.0')
        else playerInfo = function(player,frame)
            frame.add{
                type='label',
                caption={'ExpGamingAdmin.no-info-file'}
            }
        end end
        --code
    end,
    buttons={}
}

-- Function Define
function AdminGui.add_button(name,caption,tooltip,callback)
    AdminGui.buttons[name] = Gui.inputs.add{
        type='button',
        name='admin-gui-'..name,
        caption=caption,
        tooltip=tooltip
    }:on_event('click',function(event)
        local parent = event.element.parent
        pre_select_player = parent.player and parent.player.caption or nil
        callback(pre_select_player,event.player_index)
    end)
end

function AdminGui.draw(frame,filter_buttons)
    local frame = frame.add{
        type='flow',
        name='admin'
    }
    frame.add{
        type='label',
        caption='',
        name='player'
    }.style.visible = false
    local function format(btn)
        btn.style.height = 30
        btn.style.width = 30
    end
    for name,button in pairs(AdminGui.buttons) do
        if not filter_buttons or filter_buttons[name] then format(button:draw(frame)) end
    end
    return frame.player
end

-- Gui Define
local function _players(_player,root_frame,state)
    local players = {'Select Player'}
    local _players = state and game.players or game.connected_players
    for _,player in pairs(_players) do
        if player.name ~= _player.name then
            if Admin.is_banned and Admin.is_banned(player) then else
                table.insert(players,player.name)
            end
        end
    end
    return players
end

local online_check = Gui.inputs.add_checkbox('online-check-admin-commands',false,'Show Offline',false,function(player,element) 
    element.parent['player-drop-down-admin-commands'].items = _players(player,element.parent,true)
    element.parent['player-drop-down-admin-commands'].selected_index = 1
end,function(player,element)
    element.parent['player-drop-down-admin-commands'].items = _players(player,element.parent,false)
    element.parent['player-drop-down-admin-commands'].selected_index = 1
end)

local player_drop_down = Gui.inputs.add_drop_down('player-drop-down-admin-commands',_players,1,function(player,selected,items,element)
    element.parent.parent.player.caption = selected
    local player_info_flow = element.parent.parent.info_flow
    player_info_flow.clear()
    if selected == 'Select Player' then return
    else get_player_info(selected,player_info_flow,true) end
    local rank = Ranking.get_rank(player)
    local _rank = Ranking.get_rank(selected)
    if rank.power >= _rank.power then element.parent.warning.caption = {'ExpGamingAdmin.warning'}
    else element.parent.warning.caption = '' end
end)

local reason_input = Gui.inputs.add_text('reason-input-admin-commands',false,'Enter Reason',function(player,text,element)
    if string.len(text) < 20 or text == 'Enter Reason' then 
        element.parent.warning.caption = {'ExpGamingAdmin.short-reason'}
    else
        element.parent.warning.caption = ''
    end
end)

local action_drop_down = Gui.inputs.add_drop_down('action-drop-down-rank-change',{'Select Action',unpack(Admin.action_names)},1,function(player,selected,items,element)
    element.parent.parent.action.caption = selected
    if selected == 'Jail' or selected == 'Kick' or selected == 'Ban' or selected == 'Temp Ban' then
        element.parent['reason-input-admin-commands'].style.visible = true
    else
        element.parent['reason-input-admin-commands'].style.visible = false
    end
end)

local take_action = Gui.inputs.add{
    type='button',
    name='admin-commands-take',
    caption={'ExpGamingAdmin.take-action'}
}:on_event('click',function(event)
    local dropdowns = event.element.parent
    local rank = Ranking.get_rank(event.player_index)
    local _action= dropdowns.parent.action.caption ~= 'Select Action' and dropdowns.parent.action.caption or nil
    local _player = Game.get_player(dropdowns.parent.player.caption)
    if not _player or not _action then dropdowns.warning.caption = {'ExpGamingAdmin.invalid'} return end
    local _rank = Ranking.get_rank(_player)
    if rank.power >= _rank.power then dropdowns.warning.caption = {'ExpGamingAdmin.rank-high'} return end
    local _reason = dropdowns['reason-input-admin-commands'] and dropdowns['reason-input-admin-commands'].text
    if (_action == 'Jail' or _action == 'Kick' or _action == 'Ban' or _action == 'Temp Ban') and (_reason == 'Enter Reason' or string.len(_reason) < 20) then return end
    Admin.take_action(_action,_player,event.player_index,_reason)
    Gui.center.clear(event)
end)

Admin.center = Gui.center.add{
    name='admin-commands',
    caption='utility/danger_icon',
    tooltip={'ExpGamingAdmin.tooltip'},
    open=function(event,pre_select_player,pre_select_action)
        local _player = Game.get_player(pre_select_player)
        local player = Game.get_player(event)
        local _center = Gui._get_data('center')['admin-commands']
        local center_flow = Gui.center.get_flow(player)
        if center_flow[_center.name] then Gui.center.clear(player) return end
        local center_frame = center_flow.add{
            name=_center.name,
            type='frame',
            direction='vertical',
            style=mod_gui.frame_style
        }
        -- only edit i made was passing diffrent arguments to the draw function, try to avoid this
        local success, err = pcall(_center.draw,center_frame,_player,pre_select_action)
        if not success then error(err) end
        player.opened=center_frame
    end,
    draw=function(frame,pre_select_player,pre_select_action)
        frame.caption={'ExpGamingAdmin.name'}
        local frame = frame.add{
            type='flow',
            direction='horizontal'
        }
        local dropdowns = frame.add{
            type='flow',
            direction='vertical'
        }
        local player_info_flow = frame.add{
            name='info_flow',
            type='flow',
            direction='vertical'
        }
        player_info_flow.style.height = 280
        player_info_flow.style.width = 200
        local label = dropdowns.add{
            type='label',
            caption={'ExpGamingAdmin.message'}
        }
        label.style.single_line = false
        label.style.width = 200
        online_check:draw(dropdowns)
        local _drop = player_drop_down:draw(dropdowns)
        if pre_select_player then Gui.set_dropdown_index(_drop,pre_select_player.name) end
        local _drop = action_drop_down:draw(dropdowns)
        Gui.set_dropdown_index(_drop,pre_select_action)
        local _text =  reason_input:draw(dropdowns)
        if pre_select_action == 'Jail' or pre_select_action == 'Kick' or pre_select_action == 'Ban' then 
            _text.style.visible = true else _text.style.visible = false 
        end
        if pre_select_player then get_player_info(pre_select_player,player_info_flow,true) end
        _text.style.width = 200
        local label = dropdowns.add{
            name='warning',
            type='label',
            caption='',
            style='bold_red_label'
        }
        label.style.single_line = false
        label.style.width = 200
        take_action:draw(dropdowns)
        local _caption = pre_select_player and pre_select_player.name or ''
        frame.add{
            name='player',
            type='label',
            caption=_caption
        }.style.visible = false
        local _caption = pre_select_action or ''
        frame.add{
            name='action',
            type='label',
            caption=_caption
        }.style.visible = false
    end
}

-- Module Return
return AdminGui 