--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

-- loads the stdlib and allows Core Game and Event
local StdLib = require '/locale/StdLib/load'
local Core, Game, Event = StdLib.Core, StdLib.Game, StdLib.Event

-- loads the ExpLib, functions are plased into the lua global
local ExpLib = require 'ExpLib'
ExpLib._load_to_G(ExpLib)