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
    if _G.discord_emit then
        local color = _G.Color and Color.to_hex(defines.text_color.bg) or '0x0'
        discord_emit{title='SCRIPT ERROR',color=color,description=err}
    elseif _G.game then
        if Game.print_all(err) == 0 then
            _error(err)
        end
    else
        _error(err)
    end
end

-- loads the stdlib and allows Core Game and Event
local Color, Game, Event = require('/locale/StdLib/load'){'Color','Game','Event'}

-- loads the ExpLib, functions are plased into the lua global
local ExpLib = require 'ExpLib'
ExpLib._load_to_G(ExpLib)
