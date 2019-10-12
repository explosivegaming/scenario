--[[-- Core Module - Gui
    @module Gui
    @alias tests
]]

--- Test.
-- This file creates a test gui that is used to test every input method
-- note that this does not cover every permutation only features in independence
-- for example store in most cases is just by player name, but other store methods are tested with checkbox
-- @section test

local Gui = require 'expcore.gui' --- @dep expcore.gui
local format_chat_colour,table_keys = ext_require('expcore.common','format_chat_colour','table_keys') --- @dep expcore.common
local Colors = require 'resources.color_presets' --- @dep resources.color_presets
local Event = require 'utils.event' --- @dep utils.event
local Store = require 'expcore.store' --- @dep expcore.store

local tests = {}

--[[
    Toolbar Tests
    > No display - Toolbar button with no display
    > With caption - Toolbar button with a caption display
    > With icons - Toolbar button with an icon
]]

Gui.new_toolbar_button('click-1')
:set_post_authenticator(function(player,button_name)
    return global.click_one
end)
:on_click(function(player,element)
    player.print('CLICK 1')
end)

Gui.new_toolbar_button('click-2')
:set_caption('Click Two')
:set_post_authenticator(function(player,button_name)
    return global.click_two
end)
:on_click(function(player,element)
    player.print('CLICK 2')
end)

Gui.new_toolbar_button('click-3')
:set_sprites('utility/questionmark')
:set_post_authenticator(function(player,button_name)
    return global.click_three
end)
:on_click(function(player,element)
    player.print('CLICK 3')
end)

--[[
    Center Frame Tests
    > Main test gui - Main test gui triggers all other tests
]]

local test_gui =
Gui.new_center_frame('gui-test-open')
:set_caption('Open Test Gui')
:set_tooltip('Main test gui triggers all other tests')
:set_post_authenticator(function(player,button_name)
    return global.show_test_gui
end)

:on_creation(function(player,frame)
    for test_group_name,test_group in pairs(tests) do

        player.print('Starting tests for: '..format_chat_colour(test_group_name,Colors.cyan))

        local pass_count = 0
        local test_count = 0

        local flow = frame.add{
            type='flow',
            name=test_group_name,
            direction='vertical'
        }

        for test_name,test in pairs(test_group) do
            local test_function = type(test) == 'function' and test or test.draw_to
            test_count = test_count+1

            local success,err = pcall(test_function,test,flow)
            if success then
                pass_count = pass_count+1
            else
                player.print('Failed Test: '..format_chat_colour(test_name,Colors.red))
                log('Gui Test Failed: '..test_name..' stacktrace:\n'..err)
            end

        end

        if pass_count == test_count then
            player.print('All tests '..format_chat_colour('passed',Colors.green)..' ('..test_group_name..')')
        else
            player.print('Passed '..format_chat_colour(pass_count..'/'..test_count,Colors.cyan)..' ('..test_group_name..')')
        end

    end
end)

--[[
    Left Frame Test
    > Left frame which holds all online player names, updates when player leaves or joins
]]

local left_frame =
Gui.new_left_frame('test-left-frame')
:set_caption('Test Left Gui')
:set_tooltip('Left frame which holds all online player names, updates when player leaves or joins')
:set_post_authenticator(function(player,button_name)
    return global.show_test_gui
end)

:set_open_by_default()
:on_creation(function(_player,frame)
    for _,player in pairs(game.connected_players) do
        frame.add{
            type='label',
            caption=player.name
        }
    end
end)

Event.add(defines.events.on_player_joined_game,left_frame 'update_all')
Event.add(defines.events.on_player_left_game,left_frame 'update_all')

--[[
    Popup Test
    > Allows opening a popup which contains the players name and tick it was opened
]]

local test_popup =
Gui.new_popup('test-popup')
:on_creation(function(player,frame)
    frame.add{
        type='label',
        caption=player.name
    }
    frame.add{
        type='label',
        caption=game.tick
    }
end)

Gui.new_toolbar_button('test-popup-open')
:set_caption('Test Popup')
:set_tooltip('Allows opening a popup which contains the players name and tick it was opened')
:set_post_authenticator(function(player,button_name)
    return global.show_test_gui
end)
:on_click(function(player,element)
    test_popup(player,300)
end)

--[[
    Button Tests
    > No display - Simple button which has no display
    > Caption - Simple button but has a caption on it
    > Icons - Button with an icon display plus two icons for hover and select
    > Auth - Button which can only be passed when auth is true (press no display to toggle; needs reopen)
]]

local button_no_display =
Gui.new_button('test-button-no-display')
:set_tooltip('Button no display')
:on_click(function(player,element)
    player.print('Button no display')
    global.test_auth_button = not global.test_auth_button
    player.print('Auth Button auth state: '..tostring(global.test_auth_button))
end)

local button_with_caption =
Gui.new_button('test-button-with-caption')
:set_tooltip('Button with caption')
:set_caption('Button Caption')
:on_click(function(player,element)
    player.print('Button with caption')
end)

local button_with_icon =
Gui.new_button('test-button-with-icon')
:set_tooltip('Button with icons')
:set_sprites('utility/warning_icon','utility/warning','utility/warning_white')
:on_click(function(player,element)
    player.print('Button with icons')
end)

local button_with_auth =
Gui.new_button('test-button-with-auth')
:set_tooltip('Button with auth')
:set_post_authenticator(function(player,button_name)
    return global.test_auth_button
end)
:on_click(function(player,element)
    player.print('Button with auth')
end)

tests.Buttons = {
    ['No display']=button_no_display,
    ['Caption']=button_with_caption,
    ['Icons']=button_with_icon,
    ['Auth']=button_with_auth
}

--[[
    Checkbox Test
    > Local -- Simple checkbox that can toggle
    > Game store -- Checkbox which syncs its state between all players
    > Force store -- Checkbox which syncs its state with all players on the same force
    > Player store -- Checkbox that stores its state between re-draws
]]

local checkbox_local =
Gui.new_checkbox('test-checkbox-local')
:set_tooltip('Checkbox local')
:set_caption('Checkbox Local')
:on_element_update(function(player,element,state)
    player.print('Checkbox local: '..tostring(state))
end)

local checkbox_game =
Gui.new_checkbox('test-checkbox-store-game')
:set_tooltip('Checkbox store game')
:set_caption('Checkbox Store Game')
:add_store()
:on_element_update(function(player,element,state)
    player.print('Checkbox store game: '..tostring(state))
end)

local checkbox_force =
Gui.new_checkbox('test-checkbox-store-force')
:set_tooltip('Checkbox store force')
:set_caption('Checkbox Store Force')
:add_store(Gui.categorize_by_force)
:on_element_update(function(player,element,state)
    player.print('Checkbox store force: '..tostring(state))
end)

local checkbox_player =
Gui.new_checkbox('test-checkbox-store-player')
:set_tooltip('Checkbox store player')
:set_caption('Checkbox Store Player')
:add_store(Gui.categorize_by_player)
:on_element_update(function(player,element,state)
    player.print('Checkbox store player: '..tostring(state))
end)

tests.Checkboxes = {
    ['Local']=checkbox_local,
    ['Game store']=checkbox_game,
    ['Force store']=checkbox_force,
    ['Player store']=checkbox_player
}

--[[
    Radiobutton Tests
    > Local -- Simple radiobutton that can only be toggled true
    > Player store -- Radio button that saves its state between re-draws
    > Option set -- A set of radio buttons where only one can be true at a time
]]

local radiobutton_local =
Gui.new_radiobutton('test-radiobutton-local')
:set_tooltip('Radiobutton local')
:set_caption('Radiobutton Local')
:on_element_update(function(player,element,state)
    player.print('Radiobutton local: '..tostring(state))
end)

local radiobutton_player =
Gui.new_radiobutton('test-radiobutton-store')
:set_tooltip('Radiobutton store')
:set_caption('Radiobutton Store')
:add_store(Gui.categorize_by_player)
:on_element_update(function(player,element,state)
    player.print('Radiobutton store: '..tostring(state))
end)

local radiobutton_option_set =
Gui.new_radiobutton_option_set('gui.test.share',function(value,category)
    game.print('Radiobutton option set for: '..category..' is now: '..tostring(value))
end,Gui.categorize_by_player)

local radiobutton_option_one =
Gui.new_radiobutton('test-radiobutton-option-one')
:set_tooltip('Radiobutton option set')
:set_caption('Radiobutton Option One')
:add_as_option(radiobutton_option_set,'One')
:on_element_update(function(player,element,state)
    player.print('Radiobutton option one: '..tostring(state))
end)

local radiobutton_option_two =
Gui.new_radiobutton('test-radiobutton-option-two')
:set_tooltip('Radiobutton option set')
:set_caption('Radiobutton Option Two')
:add_as_option(radiobutton_option_set,'Two')
:on_element_update(function(player,element,state)
    player.print('Radiobutton option two: '..tostring(state))
end)

local radiobutton_option_three =
Gui.new_radiobutton('test-radiobutton-option-three')
:set_tooltip('Radiobutton option set')
:set_caption('Radiobutton Option Three')
:add_as_option(radiobutton_option_set,'Three')
:on_element_update(function(player,element,state)
    player.print('Radiobutton option three: '..tostring(state))
end)

tests.Radiobuttons = {
    ['Local']=radiobutton_local,
    ['Player store']=radiobutton_player,
    ['Option set']=function(self,frame)
        Gui.draw_option_set(radiobutton_option_set,frame)
    end
}

--[[
    Dropdown Test
    > Local static general -- Simple dropdown with all static options and general handler
    > Player startic general -- Dropdown with all static options and general handler and stores option between re-draws
    > Local static case -- Dropdown with all static options but case handlers and a general handler
    > Player static case -- Dropdown with all static options but case handlers and a general handler and stores option between re-draws
    > Local dynamic -- Dropdown with one static option with the reset generated by a function
    > Player dynamic -- Dropdown with one static option with the reset generated by a function and stores option between re-draws
]]

local dropdown_local_static_general =
Gui.new_dropdown('test-dropdown-local-static-general')
:set_tooltip('Dropdown local static general')
:add_options('One','Two','Three','Four')
:on_element_update(function(player,element,value)
    player.print('Dropdown local static general: '..tostring(value))
end)

local dropdown_player_static_general =
Gui.new_dropdown('test-dropdown-store-static-general')
:set_tooltip('Dropdown store static general')
:add_options('One','Two','Three','Four')
:add_store(Gui.categorize_by_player)
:on_element_update(function(player,element,value)
    player.print('Dropdown store static general: '..tostring(value))
end)

local function print_option_selected_1(player,element,value)
    player.print('Dropdown local static case (case): '..tostring(value))
end

local dropdown_local_static_case =
Gui.new_dropdown('test-dropdown-local-static-case')
:set_tooltip('Dropdown local static case')
:add_options('One','Two')
:add_option_callback('One',print_option_selected_1)
:add_option_callback('Two',print_option_selected_1)
:add_option_callback('Three',print_option_selected_1)
:add_option_callback('Four',print_option_selected_1)
:on_element_update(function(player,element,value)
    player.print('Dropdown local static case (general): '..tostring(value))
end)

local function print_option_selected_2(player,element,value)
    player.print('Dropdown store static case (case): '..tostring(value))
end

local dropdown_player_static_case =
Gui.new_dropdown('test-dropdown-store-static-case')
:set_tooltip('Dropdown store static case')
:add_store(Gui.categorize_by_player)
:add_options('One','Two')
:add_option_callback('One',print_option_selected_2)
:add_option_callback('Two',print_option_selected_2)
:add_option_callback('Three',print_option_selected_2)
:add_option_callback('Four',print_option_selected_2)
:on_element_update(function(player,element,value)
    player.print('Dropdown store static case (general): '..tostring(value))
end)

local dropdown_local_dynamic =
Gui.new_dropdown('test-dropdown-local-dynamic')
:set_tooltip('Dropdown local dynamic')
:add_options('Static')
:add_dynamic(function(player,element)
    return table_keys(Colors)
end)
:on_element_update(function(player,element,value)
    player.print('Dropdown local dynamic: '..tostring(value))
end)

local dropdown_player_dynamic =
Gui.new_dropdown('test-dropdown-store-dynamic')
:set_tooltip('Dropdown store dynamic')
:add_options('Static')
:add_dynamic(function(player,element)
    return table_keys(Colors)
end)
:add_store(Gui.categorize_by_player)
:on_element_update(function(player,element,value)
    player.print('Dropdown store dynamic: '..tostring(value))
end)

tests.Dropdowns = {
    ['Local static general']=dropdown_local_static_general,
    ['Player startic general']=dropdown_player_static_general,
    ['Local static case']=dropdown_local_static_case,
    ['Player static case']=dropdown_player_static_case,
    ['Local dynamic general']=dropdown_local_dynamic,
    ['Player dynamic general']=dropdown_player_dynamic
}

--[[
    List Box Tests
    > Local -- A list box with all static options and general handler
    > Store -- A list box with all static options and general handler and stores options between re-draws
]]

local list_box_local =
Gui.new_list_box('test-list-box-local')
:set_tooltip('List box local')
:add_options('One','Two','Three','Four')
:on_element_update(function(player,element,value)
    player.print('Dropdown local: '..tostring(value))
end)

local list_box_player =
Gui.new_list_box('test-list-box-store')
:set_tooltip('List box store')
:add_options('One','Two','Three','Four')
:add_store(Gui.categorize_by_player)
:on_element_update(function(player,element,value)
    player.print('Dropdown store: '..tostring(value))
end)

tests["List Boxes"] = {
    ['Local']=list_box_local,
    ['Player']=list_box_player
}

--[[
    Slider Tests
    > Local default -- Simple slider with default range
    > Store default -- Slider with default range that stores value between re-draws
    > Static range -- Simple slider with a static range
    > Dynamic range -- Slider with a dynamic range
    > Local label -- Simple slider with default range which has a label
    > Store label -- Slider with default range which has a label and stores value between re-draws
]]

local slider_local_default =
Gui.new_slider('test-slider-local-default')
:set_tooltip('Slider local default')
:on_element_update(function(player,element,value,percent)
    player.print('Slider local default: '..tostring(math.round(value))..' '..tostring(math.round(percent,1)))
end)


local slider_player_default =
Gui.new_slider('test-slider-store-default')
:set_tooltip('Slider store default')
:add_store(Gui.categorize_by_player)
:on_element_update(function(player,element,value,percent)
    player.print('Slider store default: '..tostring(math.round(value))..' '..tostring(math.round(percent,1)))
end)

local slider_static =
Gui.new_slider('test-slider-static-range')
:set_tooltip('Slider static range')
:set_range(5,50)
:on_element_update(function(player,element,value,percent)
    player.print('Slider static range: '..tostring(math.round(value))..' '..tostring(math.round(percent,1)))
end)

local slider_dynamic =
Gui.new_slider('test-slider-dynamic-range')
:set_tooltip('Slider dynamic range')
:set_range(function(player,element)
    return player.index - 5
end,function(player,element)
    return player.index + 4
end)
:on_element_update(function(player,element,value,percent)
    player.print('Slider dynamic range: '..tostring(math.round(value))..' '..tostring(math.round(percent,1)))
end)

local label_slider_local =
Gui.new_slider('test-slider-local-label')
:set_tooltip('Slider local label')
:enable_auto_draw_label()
:on_element_update(function(player,element,value,percent)
    player.print('Slider local label: '..tostring(math.round(value))..' '..tostring(math.round(percent,1)))
end)

local label_slider_player =
Gui.new_slider('test-slider-store-label')
:set_tooltip('Slider store label')
:enable_auto_draw_label()
:add_store(Gui.categorize_by_player)
:on_element_update(function(player,element,value,percent)
    player.print('Slider store label: '..tostring(math.round(value))..' '..tostring(math.round(percent,1)))
end)

tests.Sliders = {
    ['Local default']=slider_local_default,
    ['Player default']=slider_player_default,
    ['Static range']=slider_static,
    ['Dynamic range']=slider_dynamic,
    ['Local label']=function(self,frame)
        local flow = frame.add{type='flow'}
        label_slider_local:draw_to(flow)
    end,
    ['Player label']=function(self,frame)
        local flow = frame.add{type='flow'}
        label_slider_player:draw_to(flow)
    end
}

--[[
    Text Tests
    > Local field -- Simple text field
    > Store field -- Test field that stores text between re-draws
    > Local box -- Simple text box
    > Wrap box -- Text box which has word wrap and selection disabled
]]

local text_filed_local =
Gui.new_text_filed('test-text-field-local')
:set_tooltip('Text field local')
:on_element_update(function(player,element,value)
    player.print('Text field local: '..value)
end)

local text_filed_store =
Gui.new_text_filed('test-text-field-store')
:set_tooltip('Text field store')
:add_store(Gui.categorize_by_player)
:on_element_update(function(player,element,value)
    player.print('Text field store: '..value)
end)

local text_box_local =
Gui.new_text_box('test-text-box-local')
:set_tooltip('Text box local')
:on_element_update(function(player,element,value)
    player.print('Text box local: '..value)
end)

local text_box_wrap =
Gui.new_text_box('test-text-box-wrap')
:set_tooltip('Text box wrap')
:set_selectable(false)
:set_word_wrap()
:on_element_update(function(player,element,value)
    player.print('Text box wrap: '..value)
end)

tests.Texts = {
    ['Local field']=text_filed_local,
    ['Store field']=text_filed_store,
    ['Local box']=text_box_local,
    ['Wrap box']=text_box_wrap
}

--[[
    Elem Button Tests
    > Local -- Simple elem button
    > Default -- Simple elem button which has a default value
    > Function -- Elem button which has a dynamic default
    > Store -- Elem button which stores its value between re-draws
]]

local elem_local =
Gui.new_elem_button('test-elem-local')
:set_tooltip('Elem')
:set_type('item')
:on_element_update(function(player,element,value)
    player.print('Elem: '..value)
end)

local elem_default =
Gui.new_elem_button('test-elem-default')
:set_tooltip('Elem default')
:set_type('item')
:set_default('iron-plate')
:on_element_update(function(player,element,value)
    player.print('Elem default: '..value)
end)

local elem_function =
Gui.new_elem_button('test-elem-function')
:set_tooltip('Elem function')
:set_type('item')
:set_default(function(player,element)
    return 'iron-plate'
end)
:on_element_update(function(player,element,value)
    player.print('Elem function: '..value)
end)

local elem_store =
Gui.new_elem_button('test-elem-store')
:set_tooltip('Elem store')
:set_type('item')
:add_store(Gui.categorize_by_player)
:on_element_update(function(player,element,value)
    player.print('Elem store: '..value)
end)

tests["Elem Buttons"] = {
    ['Local']=elem_local,
    ['Default']=elem_default,
    ['Function']=elem_function,
    ['Store']=elem_store
}

--[[
    Progress bar tests
    > Simple -- Progress bar that fills every 2 seconds
    > Store -- Progress bar that fills every 5 seconds with synced value
    > Reverse -- Progress bar that decreases every 2 seconds
]]

local progressbar_one =
Gui.new_progressbar('test-prog-one')
:set_default_maximum(120)
:on_complete(function(player,element,reset_element)
    reset_element()
end)

local progressbar_two =
Gui.new_progressbar('test-prog-one')
:set_default_maximum(300)
:add_store(Gui.categorize_by_force)
:on_complete(function(player,element,reset_element)
    reset_element()
end)
:on_store_complete(function(category,reset_store)
    reset_store()
end)

local progressbar_three =
Gui.new_progressbar('test-prog-one')
:set_default_maximum(120)
:use_count_down()
:on_complete(function(player,element,reset_element)
    reset_element()
end)

Event.add(defines.events.on_tick,function()
    progressbar_one:increment()
    progressbar_three:decrement()
    local categories = Store.get(progressbar_two.store) or {}
    for category,_ in pairs(categories) do
        progressbar_two:increment(1,category)
    end
end)

tests["Progress Bars"] = {
    ['Simple']=progressbar_one,
    ['Store']=progressbar_two,
    ['Reverse']=progressbar_three
}