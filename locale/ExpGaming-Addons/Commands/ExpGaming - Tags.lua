--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Tag Command',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Allows users to have custom tags',
	factorio_version='0.15.23',
	show=true
	}}

--Please Only Edit Below This Line-----------------------------------------------------------
define_command('tag','Use to add a custom tag, use /tag clear to remove.',{'tag',true},function(player,event,args)
    if player == '<server>' then
        local player = game.players[args[1]]
        local tag = table.concat(args,' ',2)
        if player then
            if args[2] == 'clear' then player.tag = get_rank(player).tag
            else player.tag = get_rank(player).tag..' - '..tag..' '
            end
        else print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
    else
        local tag = table.concat(args,' ',1)
        if args[1] == 'clear' then player.tag = get_rank(player).tag
        elseif string.len(tag) > 20 then player.print('Invaild Tag, must be less then 20 characters')
        else player.tag = get_rank(player).tag..' - '..tag..' '
        end
    end
end)

