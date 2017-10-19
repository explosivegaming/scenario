--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
local function merge(first_table,second_table) for k,v in pairs(second_table) do first_table[k] = v end end
local ExpGui = require("ExpGaming - Module Setup")
merge(ExpGui,require("ExpGaming - Inputs"))
merge(ExpGui,require("ExpGaming - Toolbar"))
merge(ExpGui,require("ExpGaming - Center Gui"))
merge(ExpGui,require("ExpGaming - Left Gui"))
merge(ExpGui,require("ExpGaming - Popup"))
merge(ExpGui,require("ExpGaming - Player Table"))
return ExpGui