local Global = require 'utils.global' --- @dep utils.global
local Commands = require 'expcore.commands' --- @dep expcore.commands
local config = require 'config.research' --- @dep config.research

local research = {}
Global.register(research, function(tbl)
    research = tbl
end)

local res = {}

function res.res_queue(event)
    if event.research.force.rockets_launched == 0 or event.research.force.technologies['mining-productivity-4'].level <= 4 then
        return
    end

    local res_q = event.research.research_queue

    if #res_q < config.queue_amount then
        for i=1, config.queue_amount - #res_q do
            event.research.force.add_research(event.research.force.technologies['mining-productivity-4'])

            if not (event.by_script) then
                game.print{'expcom-res.inf-q', event.research.name, event.research.level + i}
            end
        end
    end
end

Commands.new_command('auto-research', 'Automatically queue up research')
:add_alias('ares')
:register(function(player)
    research.res_queue_enable = not research.res_queue_enable

    if research.res_queue_enable then
        res.res_queue(player.force)
    end

    game.print{'expcom-res.res', player.name, research.res_queue_enable}
    return Commands.success
end)

return res
