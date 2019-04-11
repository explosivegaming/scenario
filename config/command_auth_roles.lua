--- This will make commands only work if the role has been allowed it in the role config
local Commands = require 'expcore.commands'
local Roles = require 'expcore.roles'

Commands.add_authenticator(function(player,command,tags,reject)
    if Roles.player_allowed(player,'command/'..command) then
        return true
    else
        return reject()
    end
end)