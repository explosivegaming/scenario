local Commands = require 'expcore.commands'

Commands.add_authenticator(function(player,command,tags,reject)
    if tags.admin_only then
        if player.admin then
            return true
        else
            return reject('This command is for admins only!')
        end
    else
        return true
    end
end)