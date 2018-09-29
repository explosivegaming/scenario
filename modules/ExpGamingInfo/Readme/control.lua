--- Adds a readme gui to the game that contains useful information
-- @module ExpGamingInfo.Readme
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ThisModule 

-- Module Require
local Gui = require('ExpGamingCore.Gui@^4.0.0')
local Game = require('FactorioStdLib.Game@^0.8.0')

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Sync^4.0.0'] then require(module_path..'/src/sync',{Gui=Gui}) end
    end
}

-- Function Define
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
		'https://discord.explosivegaming.nl',
		'https://explosivegaming.nl',
		'http://steamcommunity.com/groups/tntexplosivegaming',
		'https://www.patreon.com/badgamernl',
		'https://wiki.explosivegaming.nl/'
	}
    local function format(text_box)
        text_box.style.minimal_width=400
        text_box.read_only = true
	    text_box.word_wrap = true
	    text_box.selectable = true
    end
    for i,link in pairs(links) do
    	frame.add{
            type="label",
            caption={'readme.links-cap'..tostring(i)},
            style='caption_label'
        }
		format(frame.add{
            type='text-box',
            text=link
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

-- Module Return
return ThisModule