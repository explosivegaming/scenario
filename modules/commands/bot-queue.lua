--[[-- Commands Module - Bot queue
    - Adds a command that allows changing bot queue
    @commands Bot Queue
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

Commands.new_command('bot-queue-get', 'Get bot queue')
:set_flag('admin_only')
:register(function(_)
    local f = game.player.force.max_failed_attempts_per_tick_per_construction_queue
    local s = game.player.force.max_successful_attempts_per_tick_per_construction_queue
    return Commands.success{'expcom-bot-queue.result', s, f}
end)

Commands.new_command('bot-queue-set', 'Set bot queue')
:add_param('amount', 'integer-range', 1, 3)
:set_flag('admin_only')
:register(function(_, amount)
    game.player.force.max_failed_attempts_per_tick_per_construction_queue = 3 * amount
    game.player.force.max_successful_attempts_per_tick_per_construction_queue = 1 * amount
    return Commands.success{'expcom-bot-queue.result', 1 * amount, 3 * amount}
end)