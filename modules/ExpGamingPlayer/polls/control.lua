--- Adds a poll gui into the game for quick polls (default 90 seconds)
-- @module ExpGamingPlayer.polls@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

-- Module Require
local Server = require('ExpGamingCore.Server@^4.0.0')
local Gui = require('ExpGamingCore.Gui@^4.0.0')
local Role -- ExpGamingCore.Server@^4.0.0

-- Local Varibles
local poll_time_out = 90 -- In seconds

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Role@^4.0.0'] then Role = require('ExpGamingCore.Role@^4.0.0') end
    end
}

-- Global Define
local global = global{
    active={},
    old={}
}

-- Function Define
local function _poll_end(self)
    local uuid = self.data.poll_uuid
    local poll = global.active[uuid]
    if not poll then return end
    local highest = {nil,-1}
    local _votes = {}
    for index,answer in pairs(poll.answers) do
        local _result = poll.votes[index] or 0
        if _result > highest[2] then highest = {answer,_result} end
        _votes[answer] = _result
    end
    local uuid = poll.uuid
    poll.uuid = nil
    poll.votes = _votes
    poll.answers = nil
    poll.voted = nil
    table.insert(global.old,poll)
    global.active[uuid] = nil
    game.print({'polls.end',poll.question},defines.textcolor.info)
    game.print({'polls.winner',highest[1]},defines.textcolor.info)
end

local function _poll_data(question,answers)
    local poll = {
        uuid=Server.uuid(),
        question=question,
        answers=answers or {'None'},
        votes={},
        voted={}
    }
    Server.new_thread{
        data={poll_uuid=poll.uuid},
        timeout=poll_time_out*60
    }:on_event('timeout',_poll_end):open()
    -- This time out is known to cause desyncs and so I have moved it to a hard coded function
    global.active[poll.uuid]=poll
    return poll.uuid
end

local function draw_poll(frame)
    frame.clear()
    local index = tonumber(frame.parent.current_index.caption)
    local poll = global.old[index]
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
    for answer,votes in pairs(poll.votes) do
        frame.add{
            type='label',
            caption=answer..') '..votes
        }
    end
end

local function _opptions(player,root_frame)
    local opptions = {'Please Select An Opption'}
    local uuid = root_frame.name
    local poll = global.active[uuid]
    if not poll then return {'Invalid Poll'} end
    for _,answer in pairs(poll.answers) do
        table.insert(opptions,answer)
    end
    return opptions
end

local opption_drop_down = Gui.inputs.add_drop_down('opption-drop-down-polls',_opptions,1,function(player,selected,items,element)
    local uuid = element.parent.name
    local poll = global.active[uuid]
    if not poll then return end
    if poll.voted[player.index] and poll.voted[player.index] > 1 then
        local old_vote = poll.voted[player.index]
        poll.votes[old_vote-1] = poll.votes[old_vote-1] and poll.votes[old_vote-1]-1 or 0
    end
    if element.selected_index > 1 then
        poll.votes[element.selected_index-1] = poll.votes[element.selected_index-1] and poll.votes[element.selected_index-1]+1 or 1
    end
    poll.voted[player.index]=element.selected_index
    element.parent.answer.caption = 'Your Answer: '..selected
end)

local prev = Gui.inputs{
    type='button',
    name='prev-poll',
    caption='utility/hint_arrow_left'
}:on_event('click',function(event)
    local parent = event.element.parent
    local index = parent.parent.current_index.caption
    local _index = tonumber(index)-1
    if _index < 1 then _index = #global.old end
    parent.parent.current_index.caption = _index
    parent.parent.title.title.caption = 'Viewing Poll: '.._index
    draw_poll(parent.parent.poll_area)
end)

local next = Gui.inputs{
    type='button',
    name='next-poll',
    caption='utility/hint_arrow_right'
}:on_event('click',function(event)
    local parent = event.element.parent
    local index = parent.parent.current_index.caption
    local _index = tonumber(index)+1
    if _index > #global.old then _index = 1 end
    parent.parent.current_index.caption = _index
    parent.parent.title.title.caption = 'Viewing Poll: '.._index
    draw_poll(parent.parent.poll_area)
end)

local poll_question_input = Gui.inputs.add_text('poll-question-input',true,'Question',function(player,text,element)
    local options = element.parent.options
    if not options.question then options.add{type='label',name='question',caption=''}
    else options.question.caption = text end
end)

local _self_referace_poll_option_input = nil
local poll_option_input = Gui.inputs.add_text('poll-option-input',true,'Enter Option',function(player,text,element)
    local options = element.parent.parent.parent.options
    if not options[element.parent.name] then options.add{type='label',name=element.parent.name,caption=text} 
    else options[element.parent.name].caption = text end
    if options.last.caption == element.parent.name then
        options.last.caption = tonumber(options.last.caption)+1
        _self_referace_poll_option_input(element.parent.parent.add{type='flow',name=options.last.caption}).style.minimal_width = 200
    end
end)
_self_referace_poll_option_input = poll_option_input

local function poll_assembler(frame)
    frame.clear()
    local options = frame.add{type='flow',name='options'}
    options.style.visible = false
    options.add{type='label',name='last',caption='2'}
    poll_question_input(frame).style.minimal_width = 200
    local flow = frame.add{type='flow',direction='vertical'}
    poll_option_input(flow.add{type='flow',name='1'}).style.minimal_width = 200
    poll_option_input(flow.add{type='flow',name='2'}).style.minimal_width = 200
end

local create_poll = Gui.inputs{
    type='button',
    name='create-poll',
    caption='utility/add'
}:on_event('click',function(event)
    local parent = event.element.parent
    if event.element.sprite == 'utility/enter' then
        local inputs = parent.parent.poll_area.options
        if not inputs then
            event.element.sprite = 'utility/add'
            draw_poll(parent.parent.poll_area)
            return
        end
        local options = {}
        for _,option in pairs(inputs.children) do
            if option.name ~= 'question' and option.name ~= 'last' then 
                if option.caption ~= 'Enter Option' and option.caption ~= '' then table.insert(options,option.caption) end
            end
        end
        if not inputs.question or #options == 0 then 
            event.element.sprite = 'utility/add'
            draw_poll(parent.parent.poll_area)
            return
        end
        local uuid = _poll_data(inputs.question.caption,options)
        Gui.popup.open('polls',{uuid=uuid})
        event.element.sprite = 'utility/add'
        draw_poll(parent.parent.poll_area)
    else
        event.element.sprite = 'utility/enter'
        poll_assembler(parent.parent.poll_area)
    end
end)

ThisModule.Gui = Gui.popup{
    name='polls',
    caption={'polls.name'},
    draw=function(frame,data)
        frame.style.right_padding = 5
        frame.style.bottom_padding = 5
        local uuid = data.uuid
        local poll = global.active[uuid]
        if not poll then return end
        local flow = frame.add{
            type='flow',
            name=uuid,
            direction='vertical'
        }
        flow.add{type='label',caption={'polls.time-left',poll_time_out}}
        flow.add{type='label',caption='Question: '..poll.question}
        flow.add{type='label',name='answer',caption='Your Answer: None'}
        opption_drop_down:draw(flow)
    end
}:add_left{
    caption='utility/item_editor_icon',
    tooltip={'polls.tooltip'},
    draw=function(frame)
        frame.caption={'polls.name'}
        frame.add{
            type='label',
            name='current_index',
            caption=1
        }.style.visible = false
        local title = frame.add{
            type='flow',
            name='title'
        }
        local btn = prev:draw(title)
        btn.style.width = 20
        btn.style.height = 20
        title.add{
            type='label',
            name='title',
            caption='Viewing Poll: 1',
            style='caption_label'
        }
        local btn = next:draw(title)
        btn.style.width = 20
        btn.style.height = 20
        if Role and Role.allowed(frame.player_index,'create-poll') or player.admin then
            local btn = create_poll:draw(title)
            btn.style.width = 20
            btn.style.height = 20
        end
        local flow = frame.add{
            type='flow',
            name='poll_area',
            direction='vertical'
        }
        draw_poll(flow)
    end,
    can_open=function(player)
        if #global.old > 0 then return true
        elseif Role and Role.allowed(player,'create-poll') or player.admin then return true
        else return {'polls.no-poll'} end
    end
}
-- Event Handlers Define

-- Module Return
-- when called it will toogle the left gui for this player
return setmetatable(ThisModule,{__call=function(self,...) self.Gui(...) end})