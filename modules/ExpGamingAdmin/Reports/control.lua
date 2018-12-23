--- Adds a report system into the game that can also push notifactions to discord.
-- @module ExpGamingAdmin.Reports@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ThisModule 

-- Module Require
local Admin = require('ExpGamingAdmin')
local Server = require('ExpGamingCore.Server')
local Role = require('ExpGamingCore.Role')
local Gui = require('ExpGamingCore.Gui')
local Game = require('FactorioStdLib.Game')
local Color -- FactorioStdLib.Color@^0.8.0
local Sync -- ExpGamingCore.Sync@^4.0.0

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Sync'] then Sync = require('ExpGamingCore.Sync') end
        if loaded_modules['FactorioStdLib.Color'] then Color = require('FactorioStdLib.Color') end
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
local function report_message(player,by_player,reason)
    local player, by_player = Admin.valid_players(player,by_player)
    if not player then return end
    if Admin.is_banned(player,true) == 'report' then return end
    Role.print(Role.meta.groups.User.lowest,{'ExpGamingAdmin.low-print',player.name,reason},defines.textcolor.info,true)
    Role.print(Role.meta.groups.Admin.lowest,{'ExpGamingAdmin.high-print',player.name,by_player.name,reason},defines.textcolor.med)
    if Sync then Sync.emit_embeded{
        title='Player Report',
        color=Color.to_hex(defines.textcolor.med),
        description='A player was reported.',
        ['Player:']='<<inline>>'..player.name,
        ['By:']='<<inline>>'..by_player.name,
        ['Reason:']=reason
    } end
end

local function cheak_reports(player)
    local player = Game.get_player(player)
    if not player then return end
    local reports = Admin.count_reports(player)
    if reports >= reports_needed_for_jail and Role.get_highest(player).group.name ~= 'Jail' then
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
    local player, by_player = Admin.valid_players(player,by_player)
    if not player or Role.has_flag(player,'not_reportable') then return end
    if Admin.is_banned(by_player) or Role.has_flag(by_player,'is_jail') then return end
    if Role.has_flag(by_player,'is_varified') then 
        global.varified[player.name] = global.varified[player.name] or {} 
        local reports = global.varified[player.name]
        for _,value in pairs(reports) do
            if value[1] == by_player.name then return end
        end
        table.insert(reports,{by_player.name,reason})
    else
        global.reports[player.name] = global.reports[player.name] or {}
        local reports = global.reports[player.name]
        for _,value in pairs(reports) do
            if value[1] == by_player.name then return end
        end
        table.insert(reports,{by_player.name,reason}) 
    end
    report_message(player,by_player,reason)
    cheak_reports(player)
end

function Admin.clear_reports(player,by_player,no_emit)
    local player, by_player = Admin.valid_players(player,by_player)
    if not player then return end
    global.reports[player.name]={}
    global.varified[player.name]={}
    if not no_emit and Sync then
        Sync.emit_embeded{
            title='Player Clear',
            color=Color.to_hex(defines.textcolor.low),
            description='A player had their reports cleared.',
            ['Player:']='<<inline>>'..player.name,
            ['By:']='<<inline>>'..by_player.name,
        }
    end
end

local confirm_report = Gui.inputs{
    type='button',
    name='admin-report-confirm',
    caption='utility/spawn_flag',
    tooltip={'ExpGamingAdmin.report'}
}:on_event('click',function(event)
    local parent = event.element.parent
    local player = Game.get_player(parent.player.caption)
    local reason = parent.reason.text
    Admin.report(player,event.player_index,reason)
    Gui.center.clear(event.player_index)
end)

Admin.report_btn = Gui.inputs{
    type='button',
    name='admin-report',
    caption='utility/spawn_flag',
    tooltip={'ExpGamingAdmin.report'}
}:on_event('click',function(event)
    local parent = event.element.parent
    local player = Game.get_player(parent.children[1].name)
    if not player then return end
    local _player = Game.get_player(event)
    Gui.center.clear(_player)
    local frame = Gui.center.get_flow(_player).add{
        type='frame',
        name='report-gui'
    }
    _player.opened=frame
    frame.caption={'ExpGamingAdmin.report'}
    frame.add{
        type='textfield',
        name='reason'
    }.style.width = 300
    local btn = confirm_report:draw(frame)
    btn.style.height = 30
    btn.style.width = 30
    frame.add{
        type='label',
        name='player',
        caption=player.name
    }.style.visible = false
end)

-- Module Return
return ThisModule 