local Gui = require 'expcore.gui'
local format_chat_colour,table_keys = ext_require('expcore.common','format_chat_colour','table_keys')
local Colors = require 'resources.color_presets'
local Game = require 'utils.game'
local clean_stack_trace = ext_require('modules.commands.interface','clean_stack_trace')

local tests = {}

local function categozie_by_player(element)
    local player = Game.get_player_by_index(element.player_index)
    return player.name
end

Gui.new_toolbar_button('click-1')
:set_post_authenticator(function(player,button_name)
    return global.click_one
end)
:on_click(function(player,element,event)
    player.print('CLICK 1')
end)

Gui.new_toolbar_button('click-2')
:set_caption('Click Two')
:set_post_authenticator(function(player,button_name)
    return global.click_two
end)
:on_click(function(player,element,event)
    player.print('CLICK 2')
end)

Gui.new_toolbar_button('click-3')
:set_sprites('utility/questionmark')
:set_post_authenticator(function(player,button_name)
    return global.click_three
end)
:on_click(function(player,element,event)
    player.print('CLICK 3')
end)

Gui.new_toolbar_button('gui-test-open')
:set_caption('Open Test Gui')
:set_post_authenticator(function(player,button_name)
    return global.show_test_gui
end)
:on_click(function(player,_element,event)
    if player.gui.center.TestGui then player.gui.center.TestGui.destroy() return end
    local frame = player.gui.center.add{type='frame',caption='Gui Test',name='TestGui'}
    frame = frame.add{type='table',column_count=5}
    for key,element in pairs(tests) do
        local test_function = type(element) == 'function' and element or element.draw_to
        local success,err = pcall(test_function,element,frame)
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

tests['Button icon'] = Gui.new_button('test button icon')
:set_sprites('utility/warning_icon','utility/warning','utility/warning_white')
:on_click(function(player,element,event)
    player.print('Button icon')
end)

tests['Button auth'] = Gui.new_button('test button auth')
:set_post_authenticator(function(player,button_name)
    return global.test_auth_button
end)
:on_click(function(player,element,event)
    player.print('Button auth')
end)

tests['Checkbox local'] = Gui.new_checkbox('test checkbox local')
:set_caption('Checkbox Local')
:on_state_change(function(player,element,state)
    player.print('Checkbox local: '..tostring(state))
end)

tests['Checkbox store game'] = Gui.new_checkbox('test checkbox store game')
:set_caption('Checkbox Store Game')
:add_store()
:on_state_change(function(player,element,state)
    player.print('Checkbox store game: '..tostring(state))
end)

tests['Checkbox store player'] = Gui.new_checkbox('test checkbox store player')
:set_caption('Checkbox Store Player')
:add_store(categozie_by_player)
:on_state_change(function(player,element,state)
    player.print('Checkbox store player: '..tostring(state))
end)

tests['Checkbox store force'] = Gui.new_checkbox('test checkbox store force')
:set_caption('Checkbox Store Force')
:add_store(function(element)
    local player = Game.get_player_by_index(element.player_index)
    return player.force.name
end)
:on_state_change(function(player,element,state)
    player.print('Checkbox store force: '..tostring(state))
end)

tests['Radiobutton local'] = Gui.new_radiobutton('test radiobutton local')
:set_caption('Radiobutton Local')
:on_state_change(function(player,element,state)
    player.print('Radiobutton local: '..tostring(state))
end)

tests['Radiobutton store player'] = Gui.new_radiobutton('test radiobutton store player')
:set_caption('Radiobutton Store Player')
:add_store(categozie_by_player)
:on_state_change(function(player,element,state)
    player.print('Radiobutton store player: '..tostring(state))
end)

local test_option_set = Gui.new_radiobutton_option_set('gui.test.share',function(value,category)
    game.print('Radiobutton option set for: '..category..' is now: '..tostring(value))
end,categozie_by_player)

tests['Radiobutton option one'] = Gui.new_radiobutton('test radiobutton option one')
:set_caption('Radiobutton Option One')
:add_as_option(test_option_set,'One')
:on_state_change(function(player,element,state)
    player.print('Radiobutton option one: '..tostring(state))
end)

tests['Radiobutton option two'] = Gui.new_radiobutton('test radiobutton option two')
:set_caption('Radiobutton Option Two')
:add_as_option(test_option_set,'Two')
:on_state_change(function(player,element,state)
    player.print('Radiobutton option two: '..tostring(state))
end)

tests['Radiobutton option three'] = Gui.new_radiobutton('test radiobutton option three')
:set_caption('Radiobutton Option Three')
:add_as_option(test_option_set,'Three')
:on_state_change(function(player,element,state)
    player.print('Radiobutton option three: '..tostring(state))
end)

tests['Dropdown local static general'] = Gui.new_dropdown('test dropdown local static general')
:set_tooltip('Dropdown Local Static General')
:add_options('One','Two','Three','Four')
:on_selection(function(player,element,value)
    player.print('Dropdown local static general: '..tostring(value))
end)

tests['Dropdown player static general'] = Gui.new_dropdown('test dropdown player static general')
:set_tooltip('Dropdown Player Static General')
:add_options('One','Two','Three','Four')
:add_store(categozie_by_player)
:on_selection(function(player,element,value)
    player.print('Dropdown player static general: '..tostring(value))
end)

local function print_option_selected_1(player,element,value)
    player.print('Dropdown local static case (case): '..tostring(value))
end
tests['Dropdown local static case'] = Gui.new_dropdown('test dropdown local static case')
:set_tooltip('Dropdown Local Static Case')
:add_options('One','Two')
:add_option_callback('One',print_option_selected_1)
:add_option_callback('Two',print_option_selected_1)
:add_option_callback('Three',print_option_selected_1)
:add_option_callback('Four',print_option_selected_1)
:on_selection(function(player,element,value)
    player.print('Dropdown local static case (general): '..tostring(value))
end)

local function print_option_selected_2(player,element,value)
    player.print('Dropdown player static case (case): '..tostring(value))
end
tests['Dropdown player static case'] = Gui.new_dropdown('test dropdown player static case')
:set_tooltip('Dropdown Player Static Case')
:add_store(categozie_by_player)
:add_options('One','Two')
:add_option_callback('One',print_option_selected_2)
:add_option_callback('Two',print_option_selected_2)
:add_option_callback('Three',print_option_selected_2)
:add_option_callback('Four',print_option_selected_2)
:on_selection(function(player,element,value)
    player.print('Dropdown player static case (general): '..tostring(value))
end)

tests['Dropdown local dynamic general'] = Gui.new_dropdown('test dropdown local dynamic general')
:set_tooltip('Dropdown Local Dynamic General')
:add_options('Static')
:add_dynamic(function(player,element)
    return table_keys(Colors)
end)
:on_selection(function(player,element,value)
    player.print('Dropdown local dynamic general: '..tostring(value))
end)

tests['Dropdown player dynamic general'] = Gui.new_dropdown('test dropdown player dynamic general')
:set_tooltip('Dropdown Player Dynamic General')
:add_options('Static')
:add_dynamic(function(player,element)
    return table_keys(Colors)
end)
:add_store(categozie_by_player)
:on_selection(function(player,element,value)
    player.print('Dropdown player dynamic general: '..tostring(value))
end)

tests['List box local static general'] = Gui.new_list_box('test list box local static general')
:set_tooltip('List Box Local Static General')
:add_options('One','Two','Three','Four')
:on_selection(function(player,element,value)
    player.print('Dropdown local static general: '..tostring(value))
end)

tests['List box player static general'] = Gui.new_list_box('test list box player static general')
:set_tooltip('List Box Player Static General')
:add_options('One','Two','Three','Four')
:add_store(categozie_by_player)
:on_selection(function(player,element,value)
    player.print('Dropdown player static general: '..tostring(value))
end)

tests['Slider local default'] = Gui.new_slider('test slider local default')
:set_tooltip('Silder Local Default')
:on_change(function(player,element,value,percent)
    player.print('Slider local default: '..tostring(math.round(value))..' '..tostring(math.round(percent,2)))
end)

tests['Slider player default'] = Gui.new_slider('test slider player default')
:set_tooltip('Silder Player Default')
:add_store(categozie_by_player)
:on_change(function(player,element,value,percent)
    player.print('Slider player default: '..tostring(math.round(value))..' '..tostring(math.round(percent,2)))
end)

tests['Slider static range'] = Gui.new_slider('test slider static range')
:set_tooltip('Silder Static Range')
:set_range(5,50)
:on_change(function(player,element,value,percent)
    player.print('Slider static range: '..tostring(math.round(value))..' '..tostring(math.round(percent,2)))
end)

tests['Slider dynamic range'] = Gui.new_slider('test slider dynamic range')
:set_tooltip('Silder Dynamic Range')
:set_range(function(player,element)
    return player.index - 5
end,function(player,element)
    return player.index + 4
end)
:on_change(function(player,element,value,percent)
    player.print('Slider static range: '..tostring(math.round(value))..' '..tostring(math.round(percent,2)))
end)

local label_slider = Gui.new_slider('test slider local lable')
:set_tooltip('Silder Local label')
:enable_auto_draw_label()
:on_change(function(player,element,value,percent)
    player.print('Slider local label: '..tostring(math.round(value))..' '..tostring(math.round(percent,2)))
end)

tests['Slider local label'] = function(self,frame)
    local flow = frame.add{type='flow'}
    label_slider:draw_to(flow)
end

local label_slider_player = Gui.new_slider('test slider player lable')
:set_tooltip('Silder Player label')
:enable_auto_draw_label()
:add_store(categozie_by_player)
:on_change(function(player,element,value,percent)
    player.print('Slider player label: '..tostring(math.round(value))..' '..tostring(math.round(percent,2)))
end)

tests['Slider player label'] = function(self,frame)
    local flow = frame.add{type='flow'}
    label_slider_player:draw_to(flow)
end