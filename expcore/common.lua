local Colours = require 'resources.color_presets'
local Game = require 'utils.game'

local Public = {}

--- Compare types faster for faster validation of prams
-- @usage is_type('foo','string') -- return true
-- @usage is_type('foo') -- return false
-- @param v the value to be tested
-- @tparam[opt=nil] string test_type the type to test for if not given then it tests for nil
-- @treturn boolean is v of type test_type
function Public.type_check(value,test_type)
    return test_type and value and type(value) == test_type or not test_type and not value or false
end

--- Will return a value of any type to the player/server console, allows colour for in-game players
-- @usage player_return('Hello, World!') -- returns 'Hello, World!' to game.player or server console
-- @usage player_return('Hello, World!','green') -- returns 'Hello, World!' to game.player with colour green or server console
-- @usage player_return('Hello, World!',nil,player) -- returns 'Hello, World!' to the given player
-- @param value any value of any type that will be returned to the player or console
-- @tparam[opt=defines.colour.white] ?defines.color|string colour the colour of the text for the player, ignored when printing to console
-- @tparam[opt=game.player] LuaPlayer player  the player that return will go to, if no game.player then returns to server
function Public.player_return(value,colour,player)
    colour = Public.type_check(colour,'table') and colour or Colours[colour] ~= Colours.white and Colours[colour] or Colours.white
    player = player or game.player
    -- converts the value to a string
    local returnAsString
    if Public.type_check(value,'table') then
        if Public.type_check(value.__self,'userdata') then
            -- value is userdata
            returnAsString = 'Cant Display Userdata'
        elseif Public.type_check(value[1],'string') and string.find(value[1],'.+[.].+') and not string.find(value[1],'%s') then
            -- value is a locale string
            returnAsString = value
        elseif getmetatable(value) ~= nil and not tostring(value):find('table: 0x') then
            -- value has a tostring meta method
            returnAsString = tostring(value)
        else
            -- value is a table
            returnAsString = serpent.block(value)
        end
    elseif Public.type_check(value,'function') then
        -- value is a function
        returnAsString = 'Cant Display Functions'
    else returnAsString = tostring(value) end
    -- returns to the player or the server
    if player then
        -- allows any valid player identifier to be used
        player = Game.get_player_from_any(player)
        if not player then error('Invalid Player given to player_return',2) end
        -- plays a nice sound that is different to normal message sound
        player.play_sound{path='utility/scenario_message'}
        player.print(returnAsString,colour)
    else rcon.print(returnAsString) end
end

return Public