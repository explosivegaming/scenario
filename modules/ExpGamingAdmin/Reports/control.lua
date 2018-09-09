--- Desction <get from json>
-- @module ThisModule@X.Y.Z
-- @author <get from json>
-- @license <get from json>
-- @alais ThisModule 

-- Module Require
local Admin = require('ExpGamingAdmin.AdminLib@^4.0.0')
local Server = require('ExpGamingCore.Server@^4.0.0')
local Ranking = require('ExpGamingCore.Ranking@^4.0.0')
local Game = require('FactorioStdLib.Game@^0.8.0')
local Color = require('FactorioStdLib.Color@^0.8.0')
local Sync -- ExpGamingCore.Sync@^4.0.0

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Sync@^4.0.0'] then Sync = require('ExpGamingCore.Sync@^4.0.0') end
    end
}

-- Global Define
local global = global{
    reports={},
    varified={}
}

-- Local Varibles
local report_to_warnings = 1 -- used in count_reports
local varified_to_warings = 3 -- used in count_reports
local reports_needed_for_jail = 6

-- Function Define
local function valid_players(player,by_player)
    local player = Game.get_player(player)
    local by_player_name = Game.get_player(by_player) and Game.get_player(by_player).name or '<server>'
    return player, by_player_name
end

local function report_message(player,by_player,reason)
    local low_rank = Ranking.get_group('User').highest
    local high_rank = Ranking.get_group('Admin').lowest
    local player, by_player_name = valid_players(player,by_player)
    if not player then return end
    if Admin.is_banned(player,true) == 'report' then return end
    Ranking.print(low_rank,{'ExpGamingAdmin.low-print',player.name,reason},defines.textcolor.info,true)
    Ranking.print(high_rank,{'ExpGamingAdmin.high-print',player.name,by_player_name,reason},defines.textcolor.med)
    if Sync then Sync.emit_embeded{
        title='Player Report',
        color=Color.to_hex(defines.textcolor.med),
        description='A player was reported.',
        ['Player:']='<<inline>>'..player.name,
        ['By:']='<<inline>>'..by_player_name,
        ['Reason:']=reason
    } end
end

local function cheak_reports(player)
    local player = Game.get_player(player)
    if not player then return end
    local reports = Admin.count_reports(player)
    if reports >= reports_needed_for_jail and global.actions[player.name] ~= 'report-jail' and Ranking.get_rank(player).group.name ~= 'Jail' then
        global.actions[player.name] = actions.report
        Admin.jail(player,'<server>','Too many user reports. Contact an Admin to be unjailed.')
    end
end

function Admin.count_reports(player)
    local player = Game.get_player(player)
    if not player then return 0 end
    local _count = 0
    if global.reports[player.name] then
        for _,report in pairs(global.reports[player.name]) do
            _count=_count+report_to_warnings
        end
    end
    if global.varified[player.name] then
        for _,report in pairs(global.varified[player.name]) do
            _count=_count+varified_to_warings
        end
    end
    return _count
end

function Admin.report(player,by_player,reason)
    local player, by_player_name = valid_players(player,by_player)
    if not player or Ranking.get_rank(player):allowed('no-report') then return end
    if Admin.is_banned(by_player) or Ranking.get_group(by_player).name == 'Jail' then return end
    if Ranking.get_rank(by_player):allowed('varified') then 
        global.varified[player.name] = global.varified[player.name] or {} 
        local reports = global.varified[player.name]
        for _,value in pairs(reports) do
            if value[1] == by_player_name then return end
        end
        table.insert(reports,{by_player_name,reason})
    else
        global.reports[player.name] = global.reports[player.name] or {}
        local reports = global.reports[player.name]
        for _,value in pairs(reports) do
            if value[1] == by_player_name then return end
        end
        table.insert(reports,{by_player_name,reason}) 
    end
    report_message(player,by_player,reason)
    cheak_reports(player)
end

function Admin.clear_reports(player,by_player,no_emit)
    local player, by_player_name = valid_players(player,by_player)
    if not player then return end
    global.reports[player.name]={}
    global.varified[player.name]={}
    if not no_emit and Sync then
        Sync.emit_embeded{
            title='Player Clear',
            color=Color.to_hex(defines.textcolor.low),
            description='A player had their reports cleared.',
            ['Player:']='<<inline>>'..player.name,
            ['By:']='<<inline>>'..by_player_name,
        }
    end
end

-- Module Return
return ThisModule 