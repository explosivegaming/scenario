local Commands = require 'expcore.commands'
local Game = require 'utils.game'

--[[
>>>>Adds parses:
    boolean
    string-options - options: array
    string-max-length - max_length: number
    number
    integer
    number-range - range_min: number, range_max: number
    integer-range - range_min: number, range_max: number
    player
    player-online
    player-alive
    force
    surface
]]

Commands.add_parse('boolean',function(input,player,reject)
    if not input then return end -- nil check
    input = input:lower()
    if input == 'yes'
    or input == 'y'
    or input == 'true'
    or input == '1' then
        return true
    else
        return false
    end
end)

Commands.add_parse('string-options',function(input,player,reject,options)
    if not input then return end -- nil check
    input = input:lower()
    for option in options do
        if input == option:lower() then
            return true
        end
    end
    return reject{'reject-string-options',options:concat(', ')}
end)

Commands.add_parse('string-max-length',function(input,player,reject,max_length)
    if not input then return end -- nil check
    local length = input:len()
    if length > max_length then
        return reject{'expcore-commands.reject-string-max-length',max_length}
    else
        return input
    end
end)

Commands.add_parse('number',function(input,player,reject)
    if not input then return end -- nil check
    local number = tonumber(input)
    if not number then
        return reject{'expcore-commands.reject-number'}
    else
        return number
    end
end)

Commands.add_parse('integer',function(input,player,reject)
    if not input then return end -- nil check
    local number = tonumber(input)
    if not number then
        return reject{'expcore-commands.reject-number'}
    else
        return number:floor()
    end
end)

Commands.add_parse('number-range',function(input,player,reject,range_min,range_max)
    local number = Commands.parse('number',input,player,reject)
    if not number then return end -- nil check
    if number < range_min or number > range_max then
        return reject{'expcore-commands.reject-number-range',range_min,range_max}
    else
        return number
    end
end)

Commands.add_parse('integer-range',function(input,player,reject,range_min,range_max)
    local number = Commands.parse('integer',input,player,reject)
    if not number then return end -- nil check
    if number < range_min or number > range_max then
        return reject{'expcore-commands.reject-number-range',range_min,range_max}
    else
        return number
    end
end)

Commands.add_parse('player',function(input,player,reject)
    if not input then return end -- nil check
    local input_player = Game.get_player_from_any(input)
    if not input_player then
        return reject{'expcore-commands.reject-player',input}
    else
        return input_player
    end
end)

Commands.add_parse('player-online',function(input,player,reject)
    local input_player = Commands.parse('player',input,player,reject)
    if not input_player then return end -- nil check
    if not input_player.connected then
        return reject{'expcore-commands.reject-player-online'}
    else
        return input_player
    end
end)

Commands.add_parse('player-alive',function(input,player,reject)
    local input_player = Commands.parse('player-online',input,player,reject)
    if not input_player then return end -- nil check
    if not input_player.character or not input_player.character.health > 0 then
        return reject{'expcore-commands.reject-player-alive'}
    else
        return input_player
    end
end)

Commands.add_parse('force',function(input,player,reject)
    if not input then return end -- nil check
    local force = game.forces[input]
    if not force then
        return reject{'expcore-commands.reject-force'}
    else
        return force
    end
end)

Commands.add_parse('surface',function(input,player,reject)
    if not input then return end
    local surface = game.surfaces[input]
    if not surface then
        return reject{'expcore-commands.reject-surface'}
    else
        return surface
    end
end)