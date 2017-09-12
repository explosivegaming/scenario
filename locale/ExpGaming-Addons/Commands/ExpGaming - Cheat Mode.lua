--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Cheat Command',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Only For the best of the lazyest of the best',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
define_command('cheat-mode','Toggle Cheat Mode',{'player'},'Dev',function(player,event,args)
    if player == '<server>' then
        local p = game.players[args[1]]
        if not p then print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
        p.cheat_mode = not p.cheat_mode
    else
        local p = game.players[args[1]]
        if not p then player.print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
        p.cheat_mode = not p.cheat_mode
    end
end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits