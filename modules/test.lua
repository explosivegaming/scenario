local Event = require 'utils.event'

function thisIsATestFunction(...)
    game.print(serpent.line({...}))
end

Event.add(defines.events.on_console_chat,function(event)
    if event.player_index then game.print('Message: '..event.message) end
end)



local Commands = require 'expcore.commands' -- require the Commands module

Commands.add_authenticator(function(player,command,tags,reject)
    if tags.admin_only then
        if player.admin then
            return true
        else
            return reject('This command is for admins only!')
        end
    else
        return true
    end
end)

Commands.add_parse('number_range_int',function(input,player,reject,range_min,range_max)
    local rtn = tonumber(input) and math.floor(tonumber(input)) or nil
    if not rtn or rtn < range_min or rtn > range_max then
        return reject('Number entered is not in range: '..range_min..', '..range_max)
    else
        return rtn
    end
end)

Commands.add_command('repeat-name','Will repeat you name a number of times in chat.')
    :add_param('repeat-count',false,'number_range_int',1,5)
    :add_param('smiley',true,function(input,player,reject)
    if not input then return end
    if input:lower() == 'true' or input:lower() == 'yes' then
        return true
    else
        return false
    end
end)
:add_defaults{smiley=false}
:add_tag('admin_only',true)
:add_alias('name','rname')
:register(function(player,repeat_count,smiley,raw)
    game.print(player.name..' used a command with input: '..raw)
    local msg = ') '..player.name
    if smiley then
        msg = ':'..msg
    end
    for i = 1,repeat_count do
        Commands.print(i..msg)
end
end)