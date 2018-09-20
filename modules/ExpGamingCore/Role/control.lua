--- Adds roles where a player can have more than one role
-- @module ExpGamingCore.Role@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/releases/download/v4.0-core/ExpGamingCore.Ranking_4.0.0.zip
-- @alais Role 

-- Module Require
local Group = require('ExpGamingCore.Group@^4.0.0')

-- Local Varibles

-- Module Define
local module_verbose = false
local Role = {
    _prototype={},
    roles={},
    order={},
    flags={},
    actions={},
    on_init=function()
        --code
    end,
    on_post=function()
        --code
    end
}

-- Global Define
local global = global{
    changes={},
    players={},
    roles={}
}

-- Function Define
function Role.define(obj) 
    -- creates role object
end

function Role.get(mixed)
    -- gets all roles of a user or a role by name
end

function Role.assign(player,role)
    -- gives a player a role by name or a table of roles
end

function Role.unassign(player,role)
    -- removes a player from a role by name or a table of roles
end

function Role.highest(options)
    -- gets the highest role from a set of options; player can be passed
end

function Role.revert(player)
    -- reverts the last change to a user's roles
end

function Role.add_flag(flag,callback)
    -- when a role has the given flag the callback is called, params: player, state
    -- all the flags a player has are combined with true as pirority
    -- example Role.add_flag('is_admin',function(player,state) player.admin = state end)
end

function Role.has_flag(mixed,flag)
    -- tests if mixed (either player or role) has the requested flag
end

function Role.add_action(action)
    -- allows a table to be made that includes all possible actions and thus can test who is allowed
    -- used purly as a way to loop over all actions
end

function Role.allowed(mixed,action)
    -- returns if mixed (either player or role) is allowed to do this action
end

function Role.print(role,rtn,colour,inv)
    -- prints to this role and all below it or above if inv
end

function Role.debug_output(role,player)
    -- outputs all info on a role
end

function Role._prototype:has_flag(flag)
    -- if this role has this flag
end

function Role._prototype:allowed(action)
    -- if this role is allowed this action
end

function Role._prototype:get_players(online)
    -- gets all/online players who have this role
end

function Role._prototype:print(rtn,colour)
    -- prints a message to all players with this role
end

function Role._prototype:get_permissions()
    -- runs though Role.actions and returns a list of which this role can do
end

function Role._prototype.add_player(player)
    -- adds a player to this role
end

function Role._prototype.remove_player(player)
    -- removes this role from the player
end

-- Event Handlers Define

-- event call for role updates

-- Module Return
return setmetatable(Role,{__call=function(tbl,...) tbl.define(...) end}) 