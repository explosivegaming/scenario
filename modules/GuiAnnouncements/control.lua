--- Creates a gui for making and reciving announcements
-- @module GuiAnnouncements@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ThisModule 

-- maybe make this not require Role and have it optinal

-- Module Require
local Game = require('FactorioStdLib.Game@^0.8.0')
local Gui = require('ExpGamingCore.Gui@^4.0.0')
local Role = require('ExpGamingCore.Role@^4.0.0')

-- Module Define
local module_verbose = false
local ThisModule = {}

-- Function Define
local function _roles(player)
    local roles = {'Select Rank'}
    local _role = Role.get_highest(player)
    for index,role_name in pairs(Role.order) do
        if index >= _role.index then
            table.insert(ranks,role_name)
        end
    end
    return ranks
end

local role_drop_down = Gui.inputs.add_drop_down('rank-drop-down-annoncements',_roles,1,function(player,selected,items,element)
    element.parent.role.caption = selected
    if selected == 'Select Rank' then element.parent['send-annoncement'].style.visible = false
    else element.parent['send-annoncement'].style.visible = true end
end)

local send_popup = Gui.inputs{
    type='button',
    name='send-annoncement',
    caption='utility/export_slot'
}:on_event('click',function(event)
    local player = Game.get_player(event)
    local role = Role.get_highest(player)
    local _role = Role.get(event.element.parent.role.caption); if not _role then return end
    local sent_by = {'announcements.sent-by',player.name,role.name}
    local role_name = _role.name..'s'; if rank_name == Role.meta.default.name..'s' then rank_name = 'Everyone' end
    local sent_to = {'announcements.sent-to',rank_name}
    local message = event.element.parent.parent.message.text
    for index,_role_name in pairs(Role.order) do
        if index <= _role.index then
            Gui.popup.open('announcements',{sent_by=sent_by,sent_to=sent_to,message=message},Role.get(_role_name):get_players(true))
            event.element.parent.parent.message.text = ''
        end
    end
end)

ThisModule.Gui = Gui.popup{
    name='announcements',
    caption={'announcements.name'},
    draw=function(frame,data)
        frame.style.right_padding = 5
        frame.style.bottom_padding = 5
        frame.add{type='label',caption=data.sent_by,style='caption_label'}
        frame.add{type='label',caption=data.sent_to,style='caption_label'}
        local text_box = frame.add{type='text-box'}
        text_box.text = data.message
        text_box.style.width = 400
        text_box.read_only = true
		text_box.word_wrap = true
		text_box.selectable = true
    end
}:add_left{
    caption='item/programmable-speaker',
    tooltip={'announcements.tooltip'},
    draw=function(frame)
        frame.caption = {'announcements.name'}
        local frame = frame.add{
            type='flow',
            direction='vertical'
        }
        local text_box = frame.add{
            type='text-box',
            name='message'
        }
        text_box.style.width = 400
        text_box.style.minimal_height = 100
        text_box.read_only = false
		text_box.word_wrap = true
		text_box.selectable = true
        local flow = frame.add{type='flow'}
        flow.add{
            type='label',
            caption={'announcements.select-rank'}
        }
        rank_drop_down:draw(flow)
        local btn = send_popup:draw(flow)
        btn.style.visible = false
        btn.style.height = 25
        btn.style.width = 25
        flow.add{
            type='label',
            name='rank',
            caption=''
        }.style.visible = false
    end
}

-- Module return
-- when called it will open the center gui for the player
return setmetatable(ThisModule,{__call=function(self,...) self.Gui(...) end})