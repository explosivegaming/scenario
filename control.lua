--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

-- replaces the base error function
_error = error
error = function(err)
    if _G.discord_emit and game then
        local color = _G.Color and Color.to_hex(defines.text_color.bg) or '0x0'
        discord_emit{title='SCRIPT ERROR',color=color,description=err}
    elseif _G.Game and game then
        if Game.print_all(err) == 0 then
            _error(err)
        end
    else
        _error(err)
    end
end

require("mod-gui")
-- loads the stdlib and allows Core Game and Event
Color, Game, Event = require('/StdLib/load'){'Color','Game','Event'}

-- loads the ExpLib, functions are plased into the lua global
local ExpLib = require 'ExpLib'
ExpLib._unpack_to_G(ExpLib)
_G.discord_emit = nil -- un-comment this line if you are not using the json.data

-- loads the ExpCore files these are need in order to run the other addons
Ranking, Server, Gui = require('/ExpCore/load'){'Ranking','Server','Gui'}
local success,err = pcall(require,'/ExpCore/GuiParts/test')
if success then Gui.test = err end
-- this loads the ranks that Ranking uses
require('/ExpCore/ranks')
-- this loads any edits that are not need in core pcall as file may not be preset
pcall(require,'/Addons/playerRanks')
-- this makes sure that all the little details are cleaned up
Ranking._auto_edit_ranks()

-- testing the center gui
Gui.center.add{
    name='test-center',
    caption='Gui Center',
    tooltip='Just a gui test'
}:add_tab('tab-1','Tab 1','Just a tab',function(frame)
    frame.add{type='label',caption='Test'}
end):add_tab('tab-2','Tab 2','Just a tab',function(frame)
    for i = 1,100 do
        frame.add{type='label',caption='Test 2'}
    end
end)