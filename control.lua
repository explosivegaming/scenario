--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

-- A base for functions to keep things clean
_G._ = {}

-- Replaces the base error function
_error = error
error = function(err)
    if _G.Sync and _G.Sync.emit_embeded and game then
        local color = _G.Color and Color.to_hex(defines.text_color.bg) or '0x0'
        Sync.emit_embeded{title='SCRIPT ERROR',color=color,description='There was an error in the script @Developers ',Error=err}
    elseif _G.error_handle and type(error_handle) == 'function' then
        local success, _err = error_handle(err)
        if not success then _error({handle=_err,err=err}) end
    elseif _G.Game and game then
        if Game.print_all(err) == 0 then
            _error(err)
        end
    else
        _error(err)
    end
end
-- Replaces the base require function
require_return_err = false -- Set to false when removing files; set to true for debuging
_require = require
require = function(path)
    local _return = {pcall(_require,path)}
    if not table.remove(_return, 1) and require_return_err then error(unpack(_return)) end
    return unpack(_return)
end

require("mod-gui")
-- Loads the stdlib and allows Core Game and Event
Color, Game, Event = require('/StdLib/load'){'Color','Game','Event'}

-- loads the ExpLib, functions are placed into the lua global
local ExpLib = require 'ExpLib'
ExpLib._unpack_to_G(ExpLib)
--_G.Sync.emit_embeded = nil -- Un-comment this line if you are not using the json.data

-- Loads the ExpCore files. These are need in order to run the other addons
Ranking, Sync, Server, Gui = require('/ExpCore/load'){'Ranking','Sync','Server','Gui'}
local success,err = pcall(require,'/ExpCore/GuiParts/test')
if success then Gui.test = err end
if Gui.popup then Gui.popup._load() end
if Sync._load then Sync._load() end
-- Loads the ranks that Ranking uses
require('/ExpCore/ranks')
-- Loads any edits that are not need in core pcall as file may not be present
pcall(require,'/Addons/playerRanks')
-- Makes sure that all the little details are cleaned up
Ranking._auto_edit_ranks()
-- Loads all the addons
local success,err = pcall(require,'Addons/load')
if not success then error(err) end
-- Loads anything that does not use ExpCore (source given in the file)
local success,err = pcall(require,'StandAlone/load')
if not success then error(err) end
