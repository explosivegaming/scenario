local Global = require 'utils.global' --- @dep utils.global

local Jail = {
    old_roles = {}
}

local old_roles = Jail.old_roles
Global.register(old_roles, function(tbl)
    Jail.old_roles = tbl
    old_roles = tbl
end)

return Jail
