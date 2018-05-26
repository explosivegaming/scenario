--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

-- Replaces the base error function
_error = error
error = function(err)
    verbose('Error Called: '..err)
    if _G.error_handle and type(error_handle) == 'function' then
        verbose('Exception Caught By Error Handle')
        local success, _err = pcall(error_handle,err)
        if not success then _error({handle=_err,err=err}) end
    elseif _G.Game and game then
        verbose('Exception Caught By Game Print')
        if Game.print_all(err) == 0 then
            _error(err)
        end
    else
        verbose('Failed to catch error')
        _error(err)
    end
end
-- Replaces the base require function and verbose function
_verbose = false -- Set to true for more on the loading of the files
function verbose(str) if _verbose then log(str) print(str) end end
verbose('============================= START =============================')
require_return_err = false -- Set to false when removing files; set to true for debuging
_require = require
require = function(path)
    local _path = path
    if string.sub(path,1) ~= '/' then path = '/'..path end
    local _return = {pcall(_require,path)}
    if not table.remove(_return, 1) then
        local __return = {pcall(_require,'/Addons'..path)}
        if not table.remove(__return, 1) then
            verbose('Failed to load: '.._path..' ('.._return[1]..')')
            verbose('Also Attemped: /Addons'..path..' ('..__return[1]..')')
            if require_return_err then error(unpack(_return)) end
        else verbose('Loaded: '.._path) return unpack(__return) end
    else verbose('Loaded: '.._path) end
    return unpack(_return)
end

verbose('Begain Base Lib Loading')
require('mod-gui')
-- Loads the stdlib and allows Core Game and Event
Color, Game, Event = require('StdLib/load'){'Color','Game','Event'}

-- loads the ExpLib, functions are placed into the lua global
local ExpLib = require 'ExpLib'
verbose('ExpLib Extraction')
ExpLib._unpack_to_G(ExpLib)

verbose('Begain Core File Loading')
-- Loads the ExpCore files. These are need in order to run the other addons
Ranking, Sync, Server, Gui = require('ExpCore/load'){'Ranking','Sync','Server','Gui'}
verbose('Gui Test Initiation')
local success,err = require('ExpCore/GuiParts/test')
if success then Gui.test = err else verbose('No Test Present') end
if Gui.popup then verbose('Gui Popup Initiation') Gui.popup._load() end
if Sync._load then verbose('Sync Initiation') Sync._load() end
-- Loads the ranks that Ranking uses
verbose('Base Ranks Initiation')
require('ExpCore/ranks')
-- Loads any edits that are not need in core pcall as file may not be present
verbose('Extented Ranks Initiation')
require('Addons/playerRanks')
-- Makes sure that all the little details are cleaned up
verbose('Ranking Initiation')
Ranking._auto_edit_ranks()
-- Loads all the addons
verbose('Begain Addons Loading')
local success,err = pcall(require,'Addons/load')
if not success then error(err) end
-- Loads anything that does not use ExpCore (source given in the file)
verbose('Begain Stand Alone Loading')
local success,err = pcall(require,'StandAlone/load')
if not success then error(err) end
verbose('============================== END ==============================')