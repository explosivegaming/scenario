--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='File Header - ExpGaming-Core-GUI',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Just A File Header To Organise Code',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
credit_loop(require("ExpGaming - Module Setup"))
credit_loop(require("ExpGaming - Inputs"))
credit_loop(require("ExpGaming - Toolbar"))
credit_loop(require("ExpGaming - Center Gui"))
credit_loop(require("ExpGaming - Left Gui"))
credit_loop(require("ExpGaming - Popup"))
credit_loop(require("ExpGaming - Player Table"))
--Please Only Edit Above This Line-----------------------------------------------------------
return credits