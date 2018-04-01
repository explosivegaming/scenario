--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

Event.register(defines.events.on_console_command,function(event)
    local command = event.command
    local args = {}
    if event.parameters then for word in event.parameters:gmatch('%S+') do table.insert(args,word) end end
    local data = {}
    data.title = string.gsub(command,'^%l',string.upper)
    data.by = event.player_index and game.players[event.player_index].name or '<server>'
    if data.by == '<server>' then return end
    if command == 'config' or command == 'banlist' then
        Sync.emit_embeded{
            title='Edit To '..data.title,
            color=Color.to_hex(defines.text_color.bg),
            description='A player edited the '..command..'.',
            ['By:']=data.by,
            ['Edit:']=table.concat(args,' ',1)
        }
    else
        if command == 'ban' then
            data.colour = Color.to_hex(defines.text_color.crit)
            data.reason = table.concat(args,' ',2)
        elseif command == 'kick' then
            data.colour = Color.to_hex(defines.text_color.high)
            data.reason = table.concat(args,' ',2)
        elseif command == 'unban' then data.colour = Color.to_hex(defines.text_color.low)
        elseif command == 'mute' then data.colour = Color.to_hex(defines.text_color.med)
        elseif command == 'unmute' then data.colour = Color.to_hex(defines.text_color.low)
        elseif command == 'promote' then data.colour = Color.to_hex(defines.text_color.info)
        elseif command == 'demote' then data.colour = Color.to_hex(defines.text_color.info)
        elseif command == 'purge' then data.colour = Color.to_hex(defines.text_color.med)
        else return end
        data.username = args[1]
        if not Game.get_player(data.username) then return end
        if string.sub(command,-1) == 'e' then data.command = command..'d' else  data.command = command..'ed' end
        data.reason = data.reason and data.reason ~= '' and data.reason or 'No Reason Required'
        Sync.emit_embeded{
            title='Player '..data.title,
            color=data.colour,
            description='There was a player '..data.command..'.',
            ['Player:']='<<inline>>'..data.username,
            ['By:']='<<inline>>'..data.by,
            ['Reason:']=data.reason
        }
    end
end)