--- This config for command auth allows commands to be globally enabled and disabled during runtime
-- this config adds Commands.disable and Commands.enable to enable and disable commands for all users
local Commands = require 'expcore.commands'
local Global = require 'utils.global'

local disabled_commands = {}
Global.register(disabled_commands,function(tbl)
    disabled_commands = tbl
end)

function Commands.disable(command_name)
    disabled_commands[command_name] = true
end

function Commands.enable(command_name)
    disabled_commands[command_name] = nil
end

Commands.add_authenticator(function(player,command,tags,reject)
    if disabled_commands[command] then
        return reject{'command-auth.command-disabled'}
    else
        return true
    end
end)