--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

--- Tests.
-- functions used to test
-- @section tests

local Gui = require 'expcore.gui'
local Game = require 'utils.game' -- @dep utils.game

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
:on_state_change(function(event)
    event.player.print('Basic checkbox is now: '..tostring(event.element.state))
end)

local game_checkbox =
Gui.clone_concept('checkbox',TEST 'game_checkbox')
:set_caption('Game Stored Checkbox')
:set_tooltip('Game stored checkbox')
:on_state_change(function(event)
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
:on_state_change(function(event)
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
:on_state_change(function(event)
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
:on_selection_change(function(event)
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
:on_selection_change(function(event)
    local value = Gui.get_dropdown_value(event.element)
    event.player.print('Dynamic dropdown is now: '..value)
end)

local static_player_dropdown =
Gui.clone_concept('dropdown',TEST 'static_player_dropdown')
:set_static_items{'Option 1','Option 2','Option 3'}
:on_selection_change(function(event)
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
:on_selection_change(function(event)
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