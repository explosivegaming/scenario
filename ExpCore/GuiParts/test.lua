-- this is just testing all the diffrent inputs to open test use /c Gui.test()

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
    return player.in_combat
end,function(player,element) 
    if player.character then player.character.die() end
    Gui.inputs.reset_radio(element.parent['test-radio-reset'])
end)

local radio_test_reset = Gui.inputs.add_checkbox('test-radio-reset',true,'Reset Kill Self',function(parent) 
    return false
end,function(player,element) 
    Gui.inputs.reset_radio(element.parent['test-radio'])
end)

local text_test = Gui.inputs.add_text('test-text',false,'default text',function(player,text,element)
    player_return(text,nil,player)
end)

local box_test = Gui.inputs.add_text('test-box',true,'default text but a box',function(player,text,element)
    player_return(text,nil,player)
end)

slider_test = Gui.inputs.add_slider('test-slider','vertical',0,5,function(player,parent)
    return player.character_running_speed_modifier
end,function(player,value,percent,element)
    player.character_running_speed_modifier = value
    player_return('Value In Percent of Max '..percent*100,nil,player)
end)

local function test_gui(event)
    if not game.player and not event.player_index then return end
    local player = game.player or Game.get_player(event)
    if player.gui.top['gui-test'] then player.gui.top['gui-test'].destroy() end
    local frame = player.gui.top.add{type='frame',name='gui-test'}
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
end

Gui.toolbar.add('open-gui-test','Open Test Gui','Opens the test gui with every input',test_gui)

return test_gui





