--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]

--[[
ExpCore

This file allow you to only require this one file to return the diffent libarys.
This file will return a function which can be used to access only the part you want.
Pass a table with the names of the objects you want and it will be return in that order
]]

local StdExpCoreLib = {}

require '/commands'
StdExpCoreLib.Server = require '/server'
StdExpCoreLib.Ranking = require '/ranking'
StdExpCoreLib.Gui = require '/gui'
StdExpCoreLib.Gui:_load_parts{
    'inputs',
    'toolbar',
    'center',
    --'left',
    --'popup'
}

return function(rtn)
    local _return = {}
    for _,name  in pairs(rtn) do
        if StdExpCoreLib[name] then
            table.insert(_return,StdExpCoreLib[name])
        end
    end
    return unpack(_return)
end