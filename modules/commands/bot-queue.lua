--[[-- Commands Module - Bot queue
    - Adds a command that allows changing bot queue
    @commands Bot Queue
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

Commands.new_command('bot-queue-get', 'Set bot queue')
:set_flag('admin_only')
:register(function(player)
    local f = game.player.force.max_failed_attempts_per_tick_per_construction_queue
    local s = game.player.force.max_successful_attempts_per_tick_per_construction_queue
    Commands.print{'The successful attempts are currently __1__ and failed attempts are __2__', s, f}
end)

Commands.new_command('bot-queue-set', 'Set bot queue')
:add_param('amount', 'integer-range', 1, 3)
:set_flag('admin_only')
:register(function(player, amount)
    game.player.force.max_failed_attempts_per_tick_per_construction_queue = 3 * amount
    game.player.force.max_successful_attempts_per_tick_per_construction_queue = 1 * amount
    Commands.print{'The successful attempts are currently __1__ and failed attempts are __2__', 1 * amount, 3 * amount}
end)
