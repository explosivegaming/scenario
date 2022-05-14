local Commands = require("expcore.commands")
local config = require("config.graftorio")

local general = require("modules.graftorio.general")
local statics = require("modules.graftorio.statics")
local forcestats = {}
if config.modules.forcestats then
	forcestats = require("modules.graftorio.forcestats")
end

Commands.new_command("collectdata", "Collect data for RCON usage")
		:add_param("location", true)
		:register(function()
			-- this must be first as it overwrites the stats
			-- also makes the .other table for all forces
			statics.collect_statics()
			general.collect_other()
			if config.modules.forcestats then
				forcestats.collect_production()
			end
			rcon.print(game.table_to_json(general.data.output))
			return Commands.success()
		end)
