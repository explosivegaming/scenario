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