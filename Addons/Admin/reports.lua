--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local report_to_warnings = 1
local varified_to_warings = 3
local reports_needed_for_jail = 10
local take_action = 5 -- below this number no action is taken, the first admin given warning jumps to this number
local punishments = {
    {'nothing'},
    {'nothing'},
    {'nothing'},
    {'nothing'},
    {'nothing'},
    {'message'},
    {'message'},
    {'message-reported'},
    {'message-kick'},
    {'kick'},
    {'message-temp-ban'},
    {'temp-ban'},
    {'message-ban'},
    {'message-last-waring'},
    {'ban'}
}

local function _reports(reset)
    global.addons = not reset and global.addons or {}
    global.addons.reports = not reset and global.addons.reports or {warnings={},reports={},varified={},actions={}}
    return global.addons.reports
end

local function get_warnings(player)
    local player = Game.get_player(player)
    return Admin._reports()[player.name] or 0
end

local function report_message(player,by_player,reason)
    
end

local function count_reports(player)
    -- counts the value of the reports
end

local function cheak_reports(player)
    -- jails a player if too many reports
end

local function give_punishment(player)
    -- gives a punishment based on the warnings, or nothing
end

function Admin.give_warning(player,by_player,reason)
    -- gives a waring, by_player is nil when done by script
end

function Admin.report(player,by_player,reason)
    -- reports a user and adds to the right area
end

function Admin.clear_warings(player,by_player)
    -- clears all warnings
end

function Admin.clear_reports(player,by_player)
    -- clears any reports
end

function Admin.clear_player(player,by_player)
    -- clears, warnings, reports, jail
end

function Admin.temp_ban(player,by_player,reason)
    -- jails a player and cant be unjailed and custom gui
end

-- add an on_tick event to slowly remove warnings, faster for higher ranks

-- add warnings to tree decon, then add warnings file to give warnings for diffrent actions