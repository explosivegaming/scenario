--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

Gui.center.add{
    name='readme',
    caption='utility/questionmark',
    tooltip={'readme.tooltip'}
}:add_tab('guildlines',{'readme.tab1-name'},{'readme.tab1-tooltip'},function(frame)
    for i = 1,10 do 
        local line = frame.add{
            type='label',
            caption={'readme.tab1-line'..tostring(i)}
        }
        line.style.maximal_width = 480
        line.style.single_line = false
    end
end):add_tab('chat',{'readme.tab2-name'},{'readme.tab2-tooltip'},function(frame)
    local line = frame.add{
        type='label',
        caption={'readme.tab2-singleline'}
    }
    line.style.maximal_width = 480
    line.style.single_line = false
end):add_tab('commands',{'readme.tab3-name'},{'readme.tab3-tooltip'},function(frame)
    local line = frame.add{
        type='label',
        caption={'readme.tab3-singleline'}
    }
    line.style.maximal_width = 480
    line.style.single_line = false
    local table = frame.add{name='command_table',type='table',column_count=2}
    table.add{
        type='label',
        caption={'readme.tab3-col1'}
    }
    table.add{
        type='label',
        caption={'readme.tab3-col2'}
    }
    table.draw_vertical_lines = true
    table.draw_horizontal_line_after_headers = true
    for _,command in pairs(Commands.get_commands(frame.player_index)) do
        table.add{
            type='label',
            caption='/'..comand.name
        }
        local help = table.add{
            type='label',
            caption=command.help,
        }
        help.style.width = 400
        help.style.single_line = false
    end
end)

Event.register(defines.events.on_player_created,function(event)
    if not player.admin then
        local player = Game.get_player(event)
        script.raise_event(defines.events.on_gui_click,{
            name=defines.events.on_gui_click,
            tick=event.tick,
            element=mod_gui.get_button_flow(player).readme,
            player_index=player.index,
            button=defines.mouse_button_type.left,
            alt=false,
            control=false,
            shift=false
        })
    end
end)