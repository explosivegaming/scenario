--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]

--[[
StdLib

This file allow you to only require this one file to return the diffent libarys.
This file will return a function which can be used to access only the part you want.
Pass a table with the names of the objects you want and it will be return in that order
]]

local StdLib = {}

require('table')
require('string')
require('time')
StdLib.Color = require('color')
StdLib.Game = require('game')
StdLib.Event = require('event')

return function(rtn)
    local _return = {}
    for _,name  in pairs(rtn) do
        if StdLib[name] then
            verbose('StdLib Extraction: '..name)
            table.insert(_return,StdLib[name])
        end
    end
    return unpack(_return)
end