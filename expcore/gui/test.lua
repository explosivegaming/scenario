--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui'

local tests = {}

--[[-- Runs a set of gui tests to ensure that the system is working
@tparam LuaPlayer player the player that the guis are made for and who recives the results
@tparam[opt] string category when given only tests in this category are ran
@usage-- Run all gui tests
Gui.run_tests(Gui.test_string_return(game.print))
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

    local cat_tests = tests[category]

    results.total = #cat_tests

    local output = player.print
    for test_name, callback in pairs(cat_tests) do
        local success, err = pcall(callback,player)

        if success then
            results.passed = results.passed + 1
        else
            results.erorrs[test_name] = err
            output(string.format('Test "%s / %s" failed:\n%s',category,test_name,err))
        end

    end

    output(string.format('Test Complete "%s". %d failed.',category,results.failed))

    return results
end

--[[
Basic frame creation
]]

local test_frame =
Gui.new_concept('test_frame')
:define_draw(function(properties,parent,element)
    element =
    parent.add{
        name = properties.name,
        type = 'frame',
        caption = 'Gui Tests'
    }

    element.add{
        type = 'label',
        caption = 'Hello, World!'
    }

    return element
end)

tests.Frame = {
    ['Draw Frame'] = function(player)
        test_frame:draw(player.gui.center)
    end
}