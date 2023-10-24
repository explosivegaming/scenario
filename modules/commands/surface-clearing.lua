--[[-- Commands Module - Clear Item On Ground
    - Adds a command that clear item on ground so blueprint can deploy safely
    @commands Clear Item On Ground
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

Commands.new_command('clear-item-on-ground', 'Clear Item On Ground')
:add_param('range', false, 'integer-range', 1, 1000)
:register(function(player, range)
    for _, e in pairs(player.surface.find_entities_filtered{position=player.position, radius=range, name='item-on-ground'}) do
        if e.stack then
            e.stack.clear()
        end
    end

    return Commands.success
end)

--[[-- Commands Module - Clear Blueprint
    - Adds a command that clear blueprint spamming or leftover
    @commands Clear Blueprint
]]

Commands.new_command('clear-blueprint', 'Clear Blueprint')
:add_param('range', false, 'integer-range', 1, 1000)
:register(function(player, range)
    for _, e in pairs(player.surface.find_entities_filtered{position=player.position, radius=range, type='entity-ghost'}) do
        e.destroy()
    end

    return Commands.success
end)