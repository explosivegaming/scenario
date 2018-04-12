--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local get_player_info = get_player_info or function(player,frame)
    frame.add{
        type='label',
        caption={'rank-changer.no-info-file'}
    }
end

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

local online_check = Gui.inputs.add_checkbox('online-check-rank-change',false,'Show Offline',false,function(player,element) 
    element.parent['player-drop-down-rank-change'].items = _players(player,element.parent,true)
    element.parent['player-drop-down-rank-change'].selected_index = 1
end,function(player,element)
    element.parent['player-drop-down-rank-change'].items = _players(player,element.parent,false)
    element.parent['player-drop-down-rank-change'].selected_index = 1
end)

local player_drop_down = Gui.inputs.add_drop_down('player-drop-down-rank-change',_players,1,function(player,selected,items,element)
    element.parent.parent.player.caption = selected
    local player_info_flow = element.parent.parent.info_flow
    player_info_flow.clear()
    if selected == 'Select Player' then return
    else get_player_info(selected,player_info_flow,true) end
    local rank = Ranking.get_rank(player)
    local _rank = Ranking.get_rank(selected)
    if rank.power >= _rank.power then element.parent.warning.caption = {'rank-changer.warning'}
    else element.parent.warning.caption = '' end
end)

local function _ranks(player)
    local ranks = {'Select Rank'}
    local _rank = Ranking.get_rank(player)
    for _,rank in pairs(Ranking._ranks()) do
        if rank.power > _rank.power then
            table.insert(ranks,rank.name)
        end
    end
    return ranks
end

local rank_drop_down = Gui.inputs.add_drop_down('rank-drop-down-rank-change',_ranks,1,function(player,selected,items,element)
    element.parent.parent.rank.caption = selected
end)

local set_rank = Gui.inputs.add{
    type='button',
    name='rank-change-set',
    caption={'rank-changer.set-rank'}
}:on_event('click',function(event)
    local dropdowns = event.element.parent
    local rank = Ranking.get_rank(event.player_index)
    local _rank = Ranking.get_rank(dropdowns.parent.rank.caption)
    local _player = Game.get_player(dropdowns.parent.player.caption)
    if not _player or not _rank then dropdowns.warning.caption = {'rank-changer.invalid'} return end
    local __rank = Ranking.get_rank(_player)
    if rank.power >= __rank.power then dropdowns.warning.caption = {'rank-changer.rank-high'} return end
    Ranking.give_rank(_player,_rank,event)
    Gui.center.clear(event)
end)

Gui.center.add{
    name='rank-changer',
    caption='utility/circuit_network_panel',
    tooltip={'rank-changer.tooltip'},
    draw=function(self,frame)
        frame.caption={'rank-changer.name'}
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
        player_info_flow.style.height = 200
        player_info_flow.style.width = 200
        local label = dropdowns.add{
            type='label',
            caption={'rank-changer.message'}
        }
        label.style.single_line = false
        label.style.width = 200
        online_check:draw(dropdowns)
        player_drop_down:draw(dropdowns)
        rank_drop_down:draw(dropdowns)
        local label = dropdowns.add{
            name='warning',
            type='label',
            caption='',
            style='bold_red_label'
        }
        label.style.single_line = false
        label.style.width = 200
        set_rank:draw(dropdowns)
        frame.add{
            name='player',
            type='label',
            caption='///'
        }.style.visible = false
        frame.add{
            name='rank',
            type='label',
            caption='///'
        }.style.visible = false
    end
}