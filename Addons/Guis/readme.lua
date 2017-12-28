--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local function format_480(label)
    label.style.maximal_width = 480
    label.style.single_line = false
end

Gui.center.add{
    name='readme',
    caption='utility/questionmark',
    tooltip={'readme.tooltip'}
}:add_tab('guildlines',{'readme.tab1-name'},{'readme.tab1-tooltip'},function(frame)
    for i = 1,10 do 
        format_480(frame.add{
            type='label',
            caption={'readme.tab1-line'..tostring(i)}
        })
    end
end):add_tab('chat',{'readme.tab2-name'},{'readme.tab2-tooltip'},function(frame)
    format_480(frame.add{
        type='label',
        caption={'readme.tab2-singleline'}
    })
end):add_tab('commands',{'readme.tab3-name'},{'readme.tab3-tooltip'},function(frame)
    format_480(frame.add{
        type='label',
        caption={'readme.tab3-singleline'}
    })
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
    for _,command in pairs(commands.get_commands(frame)) do
        table.add{
            type='label',
            caption='/'..command.name
        }
        local discription = table.add{
            type='label',
            caption=command.description,
        }
        discription.style.width = 400
        discription.style.single_line = false
    end
end):add_tab('links',{'readme.tab4-name'},{'readme.tab4-tooltip'},function(frame)
    local function format(text_box)
        text_box.style.minimal_width=400
        text_box.read_only = true
	    text_box.word_wrap = true
	    text_box.selectable = true
    end
    for i = 1,4 do
    	frame.add{
            type="label",
            caption={'readme.tab4-cap'..tostring(i)}
        }
		format(frame.add{
            type='text-box',
            text={'readme.tab4-link'..tostring(i)}
        })
	end
end):add_tab('servers'.{'readme.tab5-name'},{'readme.tab5-tooltip'},function(frame)
    format_480(frame.add{
        type='label',
        caption={'readme.tab5-singleline'}
    })
    for i = 1,6 do
        frame.add{
            type='label',
            caption={'readme.tab5-format',tostring(i),{'readme.tab5-cap'..tostring(i)}}
        }
        format_480(frame.add{
            type='label',
            caption={'readme.tab5-des'..tostring(i)}
        })
    end
end)

Event.register(defines.events.on_player_joined_game,function(event)
    local player = Game.get_player(event)
    if not player.admin and player.online_time < 60 then
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