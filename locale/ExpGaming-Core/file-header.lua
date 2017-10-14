--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b
]]
--Please Only Edit Below This Line-----------------------------------------------------------
--As this is the core file, the order in which the files are loaded does matter. Do not change!
require("ExpGaming - Lib")
local ranking = require("ExpGaming - Rank Control")
local ExpGui = require("GUI/file-header")
require("ExpGaming - Command Maker")
local server = require("ExpGaming - Server Interface")
--Please Only Edit Above This Line-----------------------------------------------------------
return ranking,ExpGui,server