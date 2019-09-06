--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

--- Tests.
-- functions used to test
-- @section tests

local Gui = require 'expcore.gui'
local Game = require 'utils.game'
local Event = require 'utils.event'
require 'expcore.toolbar'

local test_prefix = '__GUI_TEST_'
local tests = {}

local function TEST(str) return test_prefix..str end

--[[
The main test frame
]]

local test_frame =
Gui.clone_concept('frame',TEST 'test_frame')
:set_title('Gui Tests')
:define_draw(function(properties,parent,element)
    for category, _ in pairs(tests) do
        element.add{
            type = 'flow',
            name = category,
            direction = 'vertical'
        }
    end
end)

Gui.clone_concept('toolbar-button',TEST 'run_test_button')
:set_permission_alias('gui-test')
:set_caption('Element Tests')
:on_click(function(event)
    local player = event.player
    if not Gui.destroy(player.gui.center[test_frame.name]) then
        Gui.run_tests(event.player)
    end
end)

local test_left_frame =
Gui.clone_concept('toolbar-frame',TEST 'player_list')
:set_permission_alias('gui-test')
:set_caption('Frame Test Left')
:define_draw(function(properties,parent,element)
    local list_area =
    element.add{
        name = 'scroll',
        type = 'scroll-pane',
        direction = 'vertical',
        horizontal_scroll_policy = 'never',
        vertical_scroll_policy = 'auto-and-reserve-space'
    }
    Gui.set_padding(list_area,1,1,2,2)
    list_area.style.horizontally_stretchable = true
    list_area.style.maximal_height = 200

    for _,player in pairs(game.connected_players) do
        list_area.add{
            type='label',
            caption=player.name
        }
    end
end)
:on_update(function(event)
    local list_area = event.element.scroll
    list_area.clear()

    for _,player in pairs(game.connected_players) do
        list_area.add{
            type='label',
            caption=player.name
        }
    end
end)

Event.add(defines.events.on_player_joined_game,function(event)
    test_left_frame:update_all(event)
end)
Event.add(defines.events.on_player_left_game,function(event)
    test_left_frame:update_all(event)
end)

--[[-- Runs a set of gui tests to ensure that the system is working
@tparam LuaPlayer player the player that the guis are made for and who recives the results
@tparam[opt] string category when given only tests in this category are ran
@usage-- Run all gui tests
Gui.run_tests(game.player)
]]
function Gui.run_tests(player,category)
    local results = {
        passed = 0,
        failed = 0,
        total = 0,
        errors = {}
    }

    if not category then
        results.breakdown = {}

        for cat,_ in pairs(tests) do
            local rtn = Gui.run_tests(player,cat)
            results.passed = results.passed + rtn.passed
            results.failed = results.failed + rtn.failed
            results.total = results.total + rtn.total

            for test_name, err in pairs(rtn.errors) do
                results.errors[cat..'/'..test_name] = err
            end

            results.breakdown[cat] = rtn
        end

        player.print(string.format('All Tests Complete. %d failed.',results.failed))

        return results
    end

    local frame = player.gui.center[test_frame.name] or test_frame:draw(player.gui.center)
    local cat_tests = tests[category]

    results.total = #cat_tests

    local output = player.print
    for test_name, concept in pairs(cat_tests) do
        local success, err = pcall(concept.draw,concept,frame[category])

        if success then
            results.passed = results.passed + 1
        else
            results.errors[test_name] = err
            results.failed = results.failed + 1
            output(string.format('Test "%s / %s" failed:\n%s',category,test_name,err))
        end

    end

    output(string.format('Test Complete "%s". %d failed.',category,results.failed))

    return results
end

--[[
Buttons
> Basic Button -- Button with a caption and a tooltip
> Sprite Button -- Button with a single sprite and a tooltip
> Multi Sprite Button -- Button with three sprites and a tooltip
> Admin Button -- Button which is disabled if the player is not an admin
]]

local basic_button =
Gui.clone_concept('button',TEST 'basic_button')
:set_caption('Basic Button')
:set_tooltip('Basic button')
:on_click(function(event)
    event.player.print('You pressed basic button!')
end)

local sprite_button =
Gui.clone_concept('button',TEST 'sprite_button')
:set_sprite('utility/warning_icon')
:set_tooltip('Sprite button')
:on_click(function(event)
    event.player.print('You pressed sprite button!')
end)

local multi_sprite_button =
Gui.clone_concept('button',TEST 'multi_sprite_button')
:set_sprite('utility/warning_icon','utility/warning','utility/warning_white')
:set_tooltip('Multi-sprite button')
:on_click(function(event)
    event.player.print('You pressed multi sprite button!')
end)

local admin_button =
Gui.clone_concept('button',TEST 'admin_button')
:set_caption('Admin Button')
:set_tooltip('Admin button')
:define_draw(function(properties,parent,element)
    local player = Game.get_player_by_index(element.player_index)
    if not player.admin then
        element.enabled = false
        element.tooltip = 'You must be admin to press this button'
    end
end)
:on_click(function(event)
    event.player.print('You pressed admin button!')
end)

tests.Buttons = {
    ['Basic Button'] = basic_button,
    ['Sprite Button'] = sprite_button,
    ['Multi Sprite Button'] = multi_sprite_button,
    ['Admin Button'] = admin_button,
}

--[[
Checkboxs
> Basic Checkbox -- Simple checkbox that can be toggled
> Game Stored Checkbox -- Checkbox which syncs its state between all players
> Force Stored Checkbox -- Checkbox which syncs its state with all players on the same force
> Player Stored Checkbox -- Checkbox that stores its state between re-draws
]]

local basic_checkbox =
Gui.clone_concept('checkbox',TEST 'basic_checkbox')
:set_caption('Basic Checkbox')
:set_tooltip('Basic checkbox')
:on_state_changed(function(event)
    event.player.print('Basic checkbox is now: '..tostring(event.element.state))
end)

local game_checkbox =
Gui.clone_concept('checkbox',TEST 'game_checkbox')
:set_caption('Game Stored Checkbox')
:set_tooltip('Game stored checkbox')
:on_state_changed(function(event)
    local element = event.element
    event.concept.set_data(element,element.state) -- Update other instances
    event.player.print('Game stored checkbox is now: '..tostring(element.state))
end)
:define_combined_store(function(element,state)
    element.state = state or false
end)

local force_checkbox =
Gui.clone_concept('checkbox',TEST 'force_checkbox')
:set_caption('Force Stored Checkbox')
:set_tooltip('Force stored checkbox')
:on_state_changed(function(event)
    local element = event.element
    event.concept.set_data(element,element.state) -- Update other instances
    event.player.print('Force stored checkbox is now: '..tostring(element.state))
end)
:define_combined_store(Gui.categorize_by_force,function(element,state)
    element.state = state or false
end)

local player_checkbox =
Gui.clone_concept('checkbox',TEST 'player_checkbox')
:set_caption('Player Stored Checkbox')
:set_tooltip('Player stored checkbox')
:on_state_changed(function(event)
    local element = event.element
    event.concept.set_data(element,element.state) -- Update other instances
    event.player.print('Player stored checkbox is now: '..tostring(element.state))
end)
:define_combined_store(Gui.categorize_by_player,function(element,state)
    element.state = state or false
end)

tests.Checkboxs = {
    ['Basic Checkbox'] = basic_checkbox,
    ['Game Stored Checkbox'] = game_checkbox,
    ['Force Stored Checkbox'] = force_checkbox,
    ['Player Stored Checkbox'] = player_checkbox
}

--[[
Dropdowns
> Static Dropdown -- Simple dropdown with all options being static
> Dynamic Dropdown -- Dropdown which has items based on when it is drawn
> Static Player Stored Dropdown -- Dropdown where the values is synced for each player
> Dynamic Player Stored Dropdown -- Same as above but now with dynamic options
]]

local static_dropdown =
Gui.clone_concept('dropdown',TEST 'static_dropdown')
:set_static_items{'Option 1','Option 2','Option 3'}
:on_selection_changed(function(event)
    local value = Gui.get_dropdown_value(event.element)
    event.player.print('Static dropdown is now: '..value)
end)

local dynamic_dropdown =
Gui.clone_concept('dropdown',TEST 'dynamic_dropdown')
:set_dynamic_items(function(element)
    local items = {}
    for concept_name,_ in pairs(Gui.concepts) do
        if concept_name:len() < 16 then
            items[#items+1] = concept_name
        end
    end
    return items
end)
:on_selection_changed(function(event)
    local value = Gui.get_dropdown_value(event.element)
    event.player.print('Dynamic dropdown is now: '..value)
end)

local static_player_dropdown =
Gui.clone_concept('dropdown',TEST 'static_player_dropdown')
:set_static_items{'Option 1','Option 2','Option 3'}
:on_selection_changed(function(event)
    local element = event.element
    local value = Gui.get_dropdown_value(element)
    event.concept.set_data(element,value)
    event.player.print('Static player stored dropdown is now: '..value)
end)
:define_combined_store(Gui.categorize_by_player,function(element,value)
    Gui.set_dropdown_value(element,value)
end)

local dynamic_player_dropdown =
Gui.clone_concept('dropdown',TEST 'dynamic_player_dropdown')
:set_dynamic_items(function(element)
    local items = {}
    for concept_name,_ in pairs(Gui.concepts) do
        if concept_name:len() < 16 then
            items[#items+1] = concept_name
        end
    end
    return items
end)
:on_selection_changed(function(event)
    local element = event.element
    local value = Gui.get_dropdown_value(element)
    event.concept.set_data(element,value)
    event.player.print('Dynamic player dropdown is now: '..value)
end)
:define_combined_store(Gui.categorize_by_player,function(element,value)
    Gui.set_dropdown_value(element,value)
end)

tests.Dropdowns = {
    ['Static Dropdown'] = static_dropdown,
    ['Dynamic Dropdown'] = dynamic_dropdown,
    ['Static Player Stored Dropdown'] = static_player_dropdown,
    ['Dynamic Player Stored Dropdown'] = dynamic_player_dropdown
}

--[[
Listboxs
> Static Listbox -- Simple Listbox with all options being static
> Static Player Stored Listbox -- Listbox where the values is synced for each player
]]

local static_listbox =
Gui.clone_concept('dropdown',TEST 'static_listbox')
:set_use_list_box(true)
:set_static_items{'Option 1','Option 2','Option 3'}
:on_selection_changed(function(event)
    local value = Gui.get_dropdown_value(event.element)
    event.player.print('Static listbox is now: '..value)
end)

local static_player_listbox =
Gui.clone_concept('dropdown',TEST 'static_player_listbox')
:set_use_list_box(true)
:set_static_items{'Option 1','Option 2','Option 3'}
:on_selection_changed(function(event)
    local element = event.element
    local value = Gui.get_dropdown_value(element)
    event.concept.set_data(element,value)
    event.player.print('Static player stored listbox is now: '..value)
end)
:define_combined_store(Gui.categorize_by_player,function(element,value)
    Gui.set_dropdown_value(element,value)
end)

tests.Listboxs = {
    ['Static Listbox'] = static_listbox,
    ['Static Player Stored Listbox'] = static_player_listbox
}

--[[
Elem Buttons
> Basic Elem Button -- Basic elem button
> Defaut Selection Elem Button -- Same as above but has a default selection
> Player Stored Elem Button -- Same as above but is stored per player
]]

local basic_elem_button =
Gui.clone_concept('elem_button',TEST 'basic_elembutton')
:on_selection_changed(function(event)
    event.player.print('Basic elem button is now: '..event.element.elem_value)
end)

local default_selection_elem_button =
Gui.clone_concept('elem_button',TEST 'default_selection_elem_button')
:set_elem_type('signal')
:set_default{type='virtual',name='signal-info'}
:on_selection_changed(function(event)
    local value = event.element.elem_value
    event.player.print('Default selection elem button is now: '..value.type..'/'..value.name)
end)

local player_elem_button =
Gui.clone_concept('elem_button',TEST 'player_elem_button')
:set_elem_type('technology')
:on_selection_changed(function(event)
    local element = event.element
    local value = element.elem_value
    event.concept.set_data(element,value)
    event.player.print('Player stored elem button is now: '..value)
end)
:define_combined_store(Gui.categorize_by_player,function(element,value)
    element.elem_value = value
end)

tests['Elem Buttons'] = {
    ['Basic Elem Button'] = basic_elem_button,
    ['Defaut Selection Elem Button'] = default_selection_elem_button,
    ['Player Stored Elem Button'] = player_elem_button
}

--[[
Progress Bars
> Basic Progress Bar -- will increse when pressed, when full then it will reset
> Inverted Progress Bar -- will increse when pressed, when empty then it will reset
> Game Instance Progress Bar -- will take 5 seconds to fill, when full it will reset, note instances are required due to on_tick
> Force Instance Progress Bar -- will increse when pressed, instance only means all instances will increse at same time but may not have the same value
> Force Stored Progress Bar -- will increse when pressed, unlike above all will increse at same time and will have the same value
]]

local basic_progress_bar =
Gui.clone_concept('progress_bar',TEST 'basic_progress_bar')
:set_tooltip('Basic progress bar')
:set_maximum(5)
:new_event('on_click',defines.events.on_gui_click)
:on_click(function(event)
    event.concept:increment(event.element)
end)
:set_delay_completion(true)
:on_completion(function(event)
    event.concept:reset(event.element)
end)

local inverted_progress_bar =
Gui.clone_concept('progress_bar',TEST 'inverted_progress_bar')
:set_tooltip('Inverted progress bar')
:set_inverted(true)
:set_maximum(5)
:new_event('on_click',defines.events.on_gui_click)
:on_click(function(event)
    event.concept:increment(event.element)
end)
:on_completion(function(event)
    event.concept:reset(event.element)
end)

local game_progress_bar =
Gui.clone_concept('progress_bar',TEST 'game_progress_bar')
:set_tooltip('Game progress bar')
:set_maximum(300)
:new_event('on_tick',defines.events.on_tick)
:on_tick(function(event)
    event.concept:increment(event.element)
end)
:set_delay_completion(true)
:on_completion(function(event)
    event.concept:reset(event.element)
end)
:define_instance_store()

local force_instance_progress_bar =
Gui.clone_concept('progress_bar',TEST 'force_instance_progress_bar')
:set_tooltip('Force instance progress bar')
:set_maximum(5)
:new_event('on_click',defines.events.on_gui_click)
:on_click(function(event)
    event.concept:increment(event.element)
end)
:set_delay_completion(true)
:on_completion(function(event)
    event.concept:reset(event.element)
end)
:define_instance_store(Gui.categorize_by_force)

local force_stored_progress_bar =
Gui.clone_concept('progress_bar',TEST 'force_stored_progress_bar')
:set_tooltip('Force stored progress bar')
:set_maximum(5)
:new_event('on_click',defines.events.on_gui_click)
:on_click(function(event)
    local element = event.element
    local concept = event.concept
    local new_value = concept:increment(element)
    if new_value then concept.set_data(element,new_value) end
end)
:set_delay_completion(true)
:on_completion(function(event)
    local element = event.element
    local concept = event.concept
    local new_value = concept:reset(element)
    concept.set_data(element,new_value)
end)
:define_combined_store(Gui.categorize_by_force,function(element,value)
    element.value = value or 0
end)

tests['Progress Bars'] = {
    ['Basic Progress Bar'] = basic_progress_bar,
    ['Inverted Progress Bar'] = inverted_progress_bar,
    ['Game Instance Progress Bar'] = game_progress_bar,
    ['Force Instance Progress Bar'] = force_instance_progress_bar,
    ['Force Stored Progress Bar'] = force_stored_progress_bar
}

--[[
Sliders
> Basic Slider -- Just a basic slider with range 1 to 10
> Interval Slider -- Same as above but can only be intergers
> Discrete Slider -- A discrete slider
> Dynamic Slider -- A slider which has a dynamic range
> Player Stored Slider -- Slider which stores the value per player, also goes 1 to 10
]]

local basic_slider =
Gui.clone_concept('slider',TEST 'basic_slider')
:set_range(1,10)
:on_value_changed(function(event)
    event.player.print('Basic slider is now: '..event.element.slider_value)
end)

local interval_slider =
Gui.clone_concept('slider',TEST 'interval_slider')
:set_range(1,10)
:set_value_step(1)
:on_value_changed(function(event)
    event.player.print('Interval slider is now: '..event.element.slider_value)
end)

local discrete_slider =
Gui.clone_concept('slider',TEST 'discrete_slider')
:set_range(1,10)
:set_value_step(1)
:set_discrete_slider(true)
:on_value_changed(function(event)
    event.player.print('Discrete slider is now: '..event.element.slider_value)
end)

local dynamic_slider =
Gui.clone_concept('slider',TEST 'dynamic_slider')
:set_range(function(element)
    local player = Gui.get_player_from_element(element)
    return 1, player.name:len()
end)
:set_value_step(1)
:set_discrete_slider(true)
:on_value_changed(function(event)
    event.player.print('Dynamic slider is now: '..event.element.slider_value)
end)

local player_slider =
Gui.clone_concept('slider',TEST 'player_slider')
:set_range(1,10)
:set_value_step(1)
:set_discrete_slider(true)
:on_value_changed(function(event)
    local element = event.element
    local value = element.slider_value
    event.concept.set_data(element,value)
    event.player.print('Player stored slider is now: '..value)
end)
:define_combined_store(Gui.categorize_by_player,function(element,value)
    element.slider_value = value or 0
end)

tests.Sliders = {
    ['Basic Slider'] = basic_slider,
    ['Interval Slider'] = interval_slider,
    ['Discrete Slider'] = discrete_slider,
    ['Dynamic Slider'] = dynamic_slider,
    ['Player Stored Slider'] = player_slider
}

--[[
Text Fields
> Basic Text Field -- Just a text field which text can be entered into
> Better Text Field -- Same as above but will clear on rmb and un forcus on confirmation
> Decimal Text Field -- Text field which accepts decimal values
> Password Text Field -- Text field which stars out the typed characters
> Player Stored Text Field - Same as basic but will store value per player
]]

-- Making a text field
local basic_text_field =
Gui.clone_concept('text_field',TEST 'basic_text_field')
:set_tooltip('Basic text field')
:on_confirmation(function(event)
    event.player.print('Basic text field is now: '..event.element.text)
end)

local better_text_field =
Gui.clone_concept('text_field',TEST 'better_text_field')
:set_tooltip('Better text field')
:set_clear_on_rmb(true)
:set_lose_forcus(true)
:on_confirmation(function(event)
    event.player.print('Better text field is now: '..event.element.text)
end)

local decimal_text_field =
Gui.clone_concept('text_field',TEST 'decimal_text_field')
:set_tooltip('Decimal text field')
:set_is_decimal(true)
:on_confirmation(function(event)
    event.player.print('Decimal text field is now: '..event.element.text)
end)

local password_text_field =
Gui.clone_concept('text_field',TEST 'password_text_field')
:set_tooltip('Password text field')
:set_is_password(true)
:on_confirmation(function(event)
    event.player.print('Password text field is now: '..event.element.text)
end)

local player_text_field =
Gui.clone_concept('text_field',TEST 'player_text_field')
:set_tooltip('Player stored text field')
:on_confirmation(function(event)
    local element = event.element
    local text = element.text
    event.concept.set_data(element,text)
    event.player.print('Player stored text field is now: '..text)
end)
:define_combined_store(Gui.categorize_by_player, function(element,value)
    element.text = value or ''
end)

tests['Text Fields'] = {
    ['Basic Text Field'] = basic_text_field,
    ['Better Text Field'] = better_text_field,
    ['Decimal Text Field'] = decimal_text_field,
    ['Password Text Field'] = password_text_field,
    ['Player Stored Text Field'] = player_text_field
}

--[[
Text Boxs
> Basic Text Box -- A text box that can not be edited
> Editible Text Box -- A text box that can be edited
]]

local basic_text_box =
Gui.clone_concept('text_box',TEST 'basic_text_box')
:set_tooltip('Basic text box')
:set_default('I am the text that will show in the text box')
:define_draw(function(properties,parent,element)
    element.style.height = 75
end)

local editible_text_box =
Gui.clone_concept('text_box',TEST 'editible_text_box')
:set_tooltip('Editible text box')
:set_is_read_only(false)
:set_default('I am the text that will show in the text box')
:on_text_changed(function(event)
    event.player.print('Editible text box is now: '..event.element.text)
end)
:define_draw(function(properties,parent,element)
    element.style.height = 75
end)

tests['Text Boxs'] = {
    ['Basic Text Box'] = basic_text_box,
    ['Editible Text Box'] = editible_text_box
}