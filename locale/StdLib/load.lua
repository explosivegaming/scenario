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
The array returned contains the stdlib modules so there can be decleared after the file require
]]

local StdLib = {}

StdLib.Core = require 'core'
StdLib.Game = require 'game'
StdLib.Event = require 'event'
require '/table'

return StdLib