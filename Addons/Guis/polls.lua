--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local poll_time_out = 90 -- this is in seconds

local function _polls(reset)
    global.addons = not reset and global.addons or {}
    global.addons.polls = not reset and global.addons.polls or {active={},old={}}
    return global.addons.polls
end

local function _poll_end(uuid)
    local poll = _polls().active[poll.uuid]
    if not poll then return end
    for index,answer in pairs(poll.answers) do
        local _result = #poll.votes[index] or 0
        poll.votes[index] = _result
    end
    local uuid = poll.uuid
    poll.uuid = nil
    poll.answers = nil
    poll.voted = nil
    table.insert(_polls().old,poll)
    _polls().active[uuid] = nil
end

local function _poll_data(question,answers)
    local poll = {
        uuid=Server.new_uuid(),
        question=question,
        answers=answers or {'None'},
        votes={},
        voted={}
    }
    Server.new_thread{
        data={poll_uuid=poll.uuid},
        timeout=poll_time_out*60
    }:on_event('timeout',function(self)
        local uuid = self.data.poll_uuid
        _poll_end(uuid)
    end)
    _polls().active[poll.uuid]=poll
    return poll.uuid
end

local function _opptions(player,root_frame)
    local opptions = {'Please Select An Opption'}
    local uuid = root_frame.name
    local poll = _polls().active[uuid]
    if not poll then return {'Invalid Poll'} end
    for _,answer in pairs(poll.answers) do
        table.insert(opptions,answer)
    end
    return opptions
end

local opption_drop_down = Gui.inputs.add_drop_down('opption-drop-down-polls',_opptions,1,function(player,selected,items,element)
    local uuid = element.parent.name
    local poll = _polls().active[uuid]
    if not poll then return end
    if poll.voted[player.index] and poll.voted[player.index] > 1 then
        local old_vote = poll.voted[player.index]
        poll.votes[old_vote] = poll.votes[old_vote]-1
    end
    if element.selected_index > 1 then
        poll.votes[element.selected_index-1] = poll.votes[element.selected_index-1] + 1
    end
    poll.voted[player.index]=element.selected_index
    element.parent.answer.caption = 'Your Answer: '..selected
end)

local prev = Gui.inputs.add{
    type='button',
    name='prev-poll',
    caption='utility/hint_arrow_right'
}:on_event('click',function(event)
    local parent = event.element.parent
    local index = parent.parent.current_index.caption
    local _index = tonumber(index)-1
    if _index < 1 then _index = #_polls().old end
    parent.parent.current_index.caption = _index
    draw_poll(parent.parent.poll_area)
end)

local next = Gui.inputs.add{
    type='button',
    name='next-poll',
    caption='utility/hint_arrow_left'
}:on_event('click',function(event)
    local parent = event.element.parent
    local index = parent.parent.current_index.caption
    local _index = tonumber(index)+1
    if _index > #_polls().old then _index = 1 end
    parent.parent.current_index.caption = _index
    draw_poll(parent.parent.poll_area)
end)

-- this function from redmew, would take too much to make a better one
local function poll_assembler(frame)
	frame.clear()
	local frame_table = frame.add { type = 'table', name = 'table_poll_assembler', column_count = 2 }
	frame_table.add { type = 'label', caption = 'Question:' }
	frame_table.add { type = 'textfield', name = 'textfield_question', text = '' }
	frame_table.add { type = 'label', caption = 'Answer #1:' }
	frame_table.add { type = 'textfield', name = 'textfield_answer_1', text = '' }
	frame_table.add { type = 'label', caption = 'Answer #2:' }
	frame_table.add { type = 'textfield', name = 'textfield_answer_2', text = '' }
	frame_table.add { type = 'label', caption = 'Answer #3:' }
	frame_table.add { type = 'textfield', name = 'textfield_answer_3', text = '' }
	frame_table.add { type = 'label', caption = '' }
end

local create_poll = Gui.inputs.add{
    type='button',
    name='create-poll',
    caption='utility/add'
}:on_event('click',function(event)
    local parent = event.element.parent
    if event.element.caption == 'utility/enter' then
        local inputs = parent.pool_area.table_poll_assembler
        local uuid = _poll_data(inputs.textfield_question,{
            inputs.textfield_answer_1,
            inputs.textfield_answer_2,
            inputs.textfield_answer_3
        })
        Gui.popup.open('polls',{uuid=uuid})
    else
        event.element.caption = 'utility/enter'
        poll_assembler(parent.parent.poll_area)
    end
end)

local function draw_poll(frame)
    frame.clear()
    local index = frame.parent.current_index.caption
    local poll = _polls().old[index]
    if not poll then
        frame.add{
            type='label',
            caption={'polls.no-poll'}
        }
        return
    end
    frame.add{
        type='label',
        caption='Question: '..poll.question
    }
    for answer,votes in pairs(poll.answers) do
        frame.add{
            type='label',
            caption=answer..') '..votes
        }
    end
end

Gui.popup.add{
    name='polls',
    caption={'polls.name'},
    draw=function(frame,data)
        frame.style.right_padding = 5
        frame.style.bottom_padding = 5
        local uuid = data.uuid
        local poll = _polls().active[uuid]
        if not poll then return end
        local flow = frame.add{
            type='flow',
            name=uuid,
            direction='vertical'
        }
        flow.add{type='label',caption='Question: '..poll.question}
        flow.add{type='label',name='answer',caption='Your Answer: None'}
        opption_drop_down:draw(flow)
        flow.add{type='lable',caption={'polls.auto-update'}}.style.font_size = 8
    end
}:add_left{
    caption='utility/item_editor_icon',
    tooltip={'polls.tooltip'},
    draw=function(frame)
        frame.add{
            type='lable',
            name='current_index',
            cpation=1
        }.style.visible = false
        local title = frame.add{
            type='flow',
            name='title'
        }
        local btn = prev:draw(title)
        btn.style.width = 30
        btn.style.height = 30
        title.add{
            type='label',
            caption='Viewing Poll: 1',
            style='caption_label'
        }
        local btn = next:draw(title)
        btn.style.width = 30
        btn.style.height = 30
        if Ranking.get_rank(frame.player_index):allowed('create-poll') then
            local btn = create_poll:draw(title)
            btn.style.width = 30
            btn.style.height = 30
        end
        local flow = frame.add{
            type='flow',
            name='poll_area',
            direction='vertical'
        }
        draw_poll(flow)
    end
}