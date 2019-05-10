local Gui = require 'expcore.gui'
local format_chat_colour = ext_require('expcore.common','format_chat_colour')
local Colors = require 'resources.color_presets'
local Game = require 'utils.game'
local clean_stack_trace = ext_require('modules.commands.interface','clean_stack_trace')

local tests = {}

Gui.new_toolbar_button('click-1')
:set_authenticator(function(player,button_name)
    return global.click_one
end)
:on_click(function(player,element,event)
    player.print('CLICK 1')
end)

Gui.new_toolbar_button('click-2')
:set_caption('Click Two')
:set_authenticator(function(player,button_name)
    return global.click_two
end)
:on_click(function(player,element,event)
    player.print('CLICK 2')
end)

Gui.new_toolbar_button('click-3')
:set_sprites('utility/questionmark')
:set_authenticator(function(player,button_name)
    return global.click_three
end)
:on_click(function(player,element,event)
    player.print('CLICK 3')
end)

Gui.new_toolbar_button('gui-test-open')
:set_caption('Open Test Gui')
:set_authenticator(function(player,button_name)
    return global.show_test_gui
end)
:on_click(function(player,_element,event)
    if player.gui.center.TestGui then player.gui.center.TestGui.destroy() return end
    local frame = player.gui.center.add{type='frame',caption='Gui Test',name='TestGui'}
    frame = frame.add{type='table',column_count=5}
    for key,element in pairs(tests) do
        local success,err = pcall(element.draw_to,element,frame)
        if success then
            player.print('Drawing: '..key..format_chat_colour(' SUCCESS',Colors.green))
        else
            player.print('Drawing: '..key..format_chat_colour(' FAIL',Colors.red)..' '..clean_stack_trace(err))
        end
    end
end)

tests['Button no display'] = Gui.new_button('test button no display')
:on_click(function(player,element,event)
    player.print('Button no display')
    global.test_auth_button = not global.test_auth_button
    player.print('Auth Button auth state: '..tostring(global.test_auth_button))
end)

tests['Button caption'] = Gui.new_button('test button caption')
:set_caption('Button Caption')
:on_click(function(player,element,event)
    player.print('Button caption')
end)

tests['Button icon'] = Gui.new_button('test Bbutton icon')
:set_sprites('utility/warning_icon','utility/warning','utility/warning_white')
:on_click(function(player,element,event)
    player.print('Button icon')
end)

tests['Button auth'] = Gui.new_button('test button auth')
:set_authenticator(function(player,button_name)
    return global.test_auth_button
end)
:on_click(function(player,element,event)
    player.print('Button auth')
end)

tests['Checkbox local'] = Gui.new_checkbox('test checkbox local')
:set_caption('Checkbox Local')
:on_state_change(function(player,element)
    player.print('Checkbox local: '..tostring(element.state))
end)

tests['Checkbox store game'] = Gui.new_checkbox('test checkbox store game')
:set_caption('Checkbox Store Game')
:add_store()
:on_state_change(function(player,element)
    player.print('Checkbox store game: '..tostring(element.state))
end)

tests['Checkbox store player'] = Gui.new_checkbox('test checkbox store player')
:set_caption('Checkbox Store Player')
:add_store(function(element)
    local player = Game.get_player_by_index(element.player_index)
    return player.name
end)
:on_state_change(function(player,element)
    player.print('Checkbox store player: '..tostring(element.state))
end)

tests['Checkbox store force'] = Gui.new_checkbox('test checkbox store force')
:set_caption('Checkbox Store Force')
:add_store(function(element)
    local player = Game.get_player_by_index(element.player_index)
    return player.force.name
end)
:on_state_change(function(player,element)
    player.print('Checkbox store force: '..tostring(element.state))
end)