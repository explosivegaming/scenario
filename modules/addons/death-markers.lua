local Event = require 'utils.event'
local Game = require 'utils.game'
local Global = require 'utils.global'
local Commands = require 'expcore.commands'
local config = require 'config.death_markers'
local opt_require, format_time = ext_require('expcore.common','opt_require','format_time_simple')
opt_require 'config.command_auth_runtime_disable' -- if the file is present then we can disable the commands rather than not load them

local bodies = {
    --{player_name='Cooldude2606',time_of_death='15H 15M',body=LuaEntity,tag=LuaCustomChartTag}
}
Global.register(bodies,function(tbl)
    bodies = tbl
end)

--- Checks that all map tags are present and valid
-- adds missing ones, deletes expired ones
local function check_map_tags()

end

--- Teleports the owner of a body to the body
local function teleport_player(body)

end

--- Teleports the items in a body to a certain position putting it in chests
-- if there are no chests close by them some are created
local function teleport_items(body,position)

end

Event.add(defines.events.on_player_died,function(event)

end)

local check_period = 60*60*5 -- five minutes
Event.on_nth_tick(check_period,function(event)

end)