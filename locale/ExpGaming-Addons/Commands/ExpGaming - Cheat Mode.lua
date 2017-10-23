--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
define_command('cheat-mode',{'cheat-mode.help'},{'player'},function(player,event,args)
    if player == '<server>' then
        local p = game.players[args[1]]
        if not p then print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
        p.cheat_mode = not p.cheat_mode
    else
        local p = game.players[args[1]]
        if not p then player.print{'commands.invalid-player',args[1]} return end
        p.cheat_mode = not p.cheat_mode
    end
end)

