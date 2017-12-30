--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local function format_label(label)
    label.style.maximal_width = 480
    label.style.single_line = false
end

Gui.center.add{
    name='readme',
    caption='utility/questionmark',
    tooltip={'readme.tooltip'}
}:add_tab('guildlines',{'readme.guildlines-name'},{'readme.guildlines-tooltip'},function(frame)
    for i = 1,10 do
        local style=nil; if i == 1 then style = 'caption_label' end
        format_label(frame.add{
            type='label',
            caption={'readme.guildlines-line'..tostring(i)},
            style=style
        })
    end
end):add_tab('chat',{'readme.chat-name'},{'readme.chat-tooltip'},function(frame)
    format_label(frame.add{
        type='label',
        caption={'readme.chat-singleline'}
    })
end):add_tab('commands',{'readme.commands-name'},{'readme.commands-tooltip'},function(frame)
    format_label(frame.add{
        type='label',
        caption={'readme.commands-singleline'}
    })
    Gui.bar(frame,480)
    local table = frame.add{name='command_table',type='table',column_count=2}
    table.add{
        type='label',
        caption={'readme.commands-col1'},
        style='caption_label'
    }
    table.add{
        type='label',
        caption={'readme.commands-col2'},
        style='caption_label'
    }
    table.style.width = 480
    table.draw_vertical_lines = true
    table.draw_horizontal_line_after_headers = true
    for _,command in pairs(commands.get_commands(frame.player_index)) do
        table.add{
            type='label',
            caption='/'..command.name
        }
        local discription = table.add{
            type='label',
            caption=command.description,
        }
        discription.style.maximal_width = 400
        discription.style.single_line = false
    end
end):add_tab('links',{'readme.links-name'},{'readme.links-tooltip'},function(frame)
    local links={
		'https://discord.me/explosivegaming',
		'https://explosivegaming.nl',
		'http://steamcommunity.com/groups/tntexplosivegaming',
		'https://www.patreon.com/badgamernl'
	}
    local function format(text_box)
        text_box.style.minimal_width=400
        text_box.read_only = true
	    text_box.word_wrap = true
	    text_box.selectable = true
    end
    for i = 1,4 do
    	frame.add{
            type="label",
            caption={'readme.links-cap'..tostring(i)},
            style='caption_label'
        }
		format(frame.add{
            type='text-box',
            text=links[i]
        })
	end
end):add_tab('servers',{'readme.servers-name'},{'readme.servers-tooltip'},function(frame)
    format_label(frame.add{
        type='label',
        caption={'readme.servers-singleline'}
    })
    Gui.bar(frame,480)
    for i = 1,6 do
        frame.add{
            type='label',
            caption={'readme.servers-format',tostring(i),{'readme.servers-cap'..tostring(i)}},
            style='caption_label'
        }
        format_label(frame.add{
            type='label',
            caption={'readme.servers-des'..tostring(i)}
        })
    end
end):add_tab('rules',{'readme.rules-name'},{'readme.rules-tooltip'},function(frame)
    format_label(frame.add{
        type='label',
        caption={'readme.rules-singleline'}
    })
    Gui.bar(frame,480)
    for i = 1,20 do
        format_label(frame.add{
            type='label',
            caption={'readme.rules-format',i,{'readme.rules-rule'..tostring(i)}}
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