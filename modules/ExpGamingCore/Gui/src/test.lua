--- Used to test all gui elements and parts can be used in game via Gui.test()
-- @module ExpGamingCore.Gui.Test
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

--- This is a submodule of ExpGamingCore.Gui but for ldoc reasons it is under its own module
-- @function _comment

local Gui = require('ExpGamingCore.Gui')
local mod_gui = require("mod-gui")

local gui_tset_close = Gui.inputs.add{
    name='gui-test-close',
    type='button',
    caption='Close Test Gui'
}:on_event('click',function(event) event.element.parent.destroy() end)

local caption_test = Gui.inputs.add{
    name='text-button',
    type='button',
    caption='Test'
}:on_event('click',function(event) game.print('test') end)

local sprite_test = Gui.inputs.add{
    name='sprite-button',
    type='button',
    sprite='item/lab'
}:on_event('click',function(event) game.print('test') end)

local input_test = Gui.inputs.add_button('test-inputs','Try RMB','alt,ctrl,shift and mouse buttons',{
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.left and keys.alt end,
        function(player,element) player_return('Left: Alt',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.left and keys.ctrl end,
        function(player,element) player_return('Left: Ctrl',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.left and keys.shift end,
        function(player,element) player_return('Left: Shift',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.right and keys.alt end,
        function(player,element) player_return('Right: Alt',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.right and keys.ctrl end,
        function(player,element) player_return('Right: Ctrl',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.right and keys.shift end,
        function(player,element) player_return('Right: Shift',nil,player) end
    }
}):on_event('error',function(err) game.print('this is error handliling') end)

local elem_test = Gui.inputs.add_elem_button('test-elem','item','Testing Elems',function(player,element,elem)
    player_return(elem.type..' '..elem.value,nil,player)
end)

local check_test = Gui.inputs.add_checkbox('test-check',false,'Cheat Mode',function(player,parent) 
    return game.players[parent.player_index].cheat_mode 
end,function(player,element) 
    player.cheat_mode = true 
end,function(player,element)
    player.cheat_mode = false
end)

local radio_test = Gui.inputs.add_checkbox('test-radio',true,'Kill Self',function(player,parent) 
    return false
end,function(player,element) 
    if player.character then player.character.die() end
    Gui.inputs.reset_radio(element.parent['test-radio-reset'])
end)

local radio_test_reset = Gui.inputs.add_checkbox('test-radio-reset',true,'Reset Kill Self',function(player,parent) 
    return not parent['test-radio'].state
end,function(player,element) 
    Gui.inputs.reset_radio(element.parent['test-radio'])
end)

local text_test = Gui.inputs.add_text('test-text',false,'default text',function(player,text,element)
    player_return(text,nil,player)
end)

local box_test = Gui.inputs.add_text('test-box',true,'default text but a box',function(player,text,element)
    player_return(text,nil,player)
end)

local slider_test = Gui.inputs.add_slider('test-slider','vertical',0,5,function(player,parent)
    return player.character_running_speed_modifier
end,function(player,value,percent,element)
    player.character_running_speed_modifier = value
    player_return('Value In Percent of Max '..math.floor(percent*100)-(math.floor(percent*100)%5),nil,player)
end)

local drop_test = Gui.inputs.add_drop_down('test-drop',table.keys(defines.color),1,function(player,selected,items,element)
    player.color = defines.color[selected]
    player.chat_color = defines.color[selected]
end)

--- The funcation that is called when calling Gui.test
-- @function Gui.test
-- @usage Gui.test() -- draws test gui
-- @param[opt=game.player] player a pointer to a player to draw the test gui for
local function test_gui(player)
    local player = game.player or Game.get_player(player) or nil
    if not player then return end
    if mod_gui.get_frame_flow(player)['gui-test'] then mod_gui.get_frame_flow(player)['gui-test'].destroy() end
    local frame = mod_gui.get_frame_flow(player).add{type='frame',name='gui-test',direction='vertical'}
    gui_tset_close:draw(frame)
    caption_test:draw(frame)
    sprite_test:draw(frame)
    input_test:draw(frame)
    elem_test:draw(frame)
    check_test:draw(frame)
    radio_test:draw(frame)
    radio_test_reset:draw(frame)
    text_test:draw(frame)
    box_test:draw(frame)
    slider_test:draw(frame)
    drop_test:draw(frame)
end

Gui.toolbar.add('open-gui-test','Open Test Gui','Opens the test gui with every input',test_gui)

-- testing the center gui
Gui.center.add{
    name='test-center',
    caption='Gui Center',
    tooltip='Just a gui test'
}:add_tab('tab-1','Tab 1','Just a tab',function(frame)
    frame.add{type='label',caption='Test'}
end):add_tab('tab-2','Tab 2','Just a tab',function(frame)
    for i = 1,100 do
        frame.add{type='label',caption='Test 2'}
    end
end)

-- testing the left gui
Gui.left.add{
    name='test-left',
    caption='Gui Left',
    tooltip='just testing',
    draw=function(frame)
        for _,player in pairs(game.connected_players) do
            frame.add{type='label',caption=player.name}
        end
    end,
    can_open=function(player) return player.index == 1 end
}

local text_popup = Gui.inputs.add_text('test-popup-text',true,'Message To Send',function(player,text,element)
    element.text = text
end)
local send_popup = Gui.inputs.add{
    type='button',
    name='test-popup-send',
    caption='Send Message'
}:on_event('click',function(event)
    local player = Game.get_player(event)
    local message = event.element.parent['test-popup-text'].text
    Gui.popup.open('test-popup',{player=player.name,message=message})
end)
Gui.popup.add{
    name='test-popup',
    caption='Gui Popup',
    draw=function(frame,data)
        frame.add{type='label',caption='Opened by: '..data.player}
        frame.add{type='label',caption='Message: '..data.message}
    end
}:add_left{
    caption='Gui Left w/ Popup',
    tooltip='Send a message',
    draw=function(frame)
        text_popup:draw(frame)
        send_popup:draw(frame)
    end
}

return test_gui





