--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local report_to_warnings = 1 -- used in count_reports
local varified_to_warings = 3 -- used in count_reports
local reports_needed_for_jail = 6
local min_time_to_remove_warning = 18000 -- this is in ticks
local take_action = 8 -- below this number no action is taken, the first admin given warning jumps to this number
local punishments = {
    {'nothing'},
    {'nothing'},
    {'nothing'},
    {'nothing'},
    {'nothing'},
    {'message',{'reports.message'},defines.text_color.info},
    {'message',{'reports.message'},defines.text_color.info},
    {'report',{'reports.reported'},defines.text_color.med},
    {'message',{'reports.kick-warn'},defines.text_color.med},
    {'kick'},
    {'message',{'reports.temp-warn'},defines.text_color.high},
    {'temp-ban'},
    {'message',{'reports.ban-warn'},defines.text_color.high},
    {'message',{'reports.last-warn'},defines.text_color.crit},
    {'ban'}
}

local actions = {
    none=0,
    report=1,
    jail=2,
    kick=3,
    temp=4,
    ban=5
}

local function valid_players(player,by_player)
    local player = Game.get_player(player)
    local by_player_name = Game.get_player(by_player) and Game.get_player(by_player).name or '<server>'
    local rank = Ranking.get_rank(by_player_name)
    return player, by_player_name, rank
end

local function _reports(reset)
    global.addons = not reset and global.addons or {}
    global.addons.reports = not reset and global.addons.reports or {warnings={},reports={},varified={},actions={}}
    return global.addons.reports
end

local function get_warnings(player)
    local player = Game.get_player(player)
    return _reports().warnings[player.name] or 0
end

local function report_message(player,by_player,reason)
    local low_rank = Ranking.get_group('User').highest
    local high_rank = Ranking.get_group('Admin').lowest
    local player, by_player_name = valid_players(player,by_player)
    if not player then return end
    if _reports().actions[player.name] == actions.report then return end
    Ranking.print(low_rank,{'reports.low-print',player.name,reason},defines.text_color.info,true)
    Ranking.print(high_rank,{'reports.high-print',player.name,by_player_name,reason},defines.text_color.med)
    Sync.emit_embeded{
        title='Player Report',
        color=Color.to_hex(defines.text_color.med),
        description='A player was reported.',
        ['Player:']='<<inline>>'..player.name,
        ['By:']='<<inline>>'..by_player_name,
        ['Reason:']=reason
    }
end

function count_reports(player)
    local player = Game.get_player(player)
    if not player then return 0 end
    local _count = 0
    local data = _reports()
    if data.reports[player.name] then
        for _,report in pairs(data.reports[player.name]) do
            _count=_count+report_to_warnings
        end
    end
    if data.varified[player.name] then
        for _,report in pairs(data.varified[player.name]) do
            _count=_count+varified_to_warings
        end
    end
    return _count
end

local function cheak_reports(player)
    local player = Game.get_player(player)
    if not player then return end
    local reports = count_reports(player)
    if reports >= reports_needed_for_jail and _reports().actions[player.name] ~= 'report-jail' and Ranking.get_rank(player).group.name ~= 'Jail' then
        _reports().actions[player.name] = actions.report
        Admin.jail(player,'<server>','Too many user reports. Contact an Admin to be unjailed.')
    end
end

local function give_punishment(player,by_player,reason)
    local player, by_player_name = valid_players(player,by_player)
    local warnings = get_warnings(player)
    local punishment = punishments[warnings]
    local reason = reason or 'No Other Reason'
    if not punishment or punishment[1] == 'nothing' then return
    elseif punishment[1] == 'message' then
        local message = punishment[2]
        local colour = punishment[3]
        player_return(message,colour,player)
    elseif punishment[1] == 'report' then
        local message = punishment[2]
        local colour = punishment[3]
        player_return(message,colour,player)
        report_message(player,'<server>',reason)
    elseif punishment[1] == 'kick' then
        _reports().actions[player.name] = actions.kick
        Admin.kick(player,by_player,'Too Many Warnings: '..warnings-(take_action-1)..' Also: '..reason)
    elseif punishment[1] == 'temp-ban' then
        --_reports().actions[player.name] = actions.temp -- see Admin.temp-ban
        Admin.temp_ban(player,by_player,'Too Many Warnings: '..warnings-(take_action-1)..' Also: '..reason)
    elseif punishment[1] == 'ban' then
        _reports().actions[player.name] = actions.ban
        Admin.ban(player,by_player,'Too Many Warnings: '..warnings-(take_action-1)..' Also: '..reason)
    end
end

function Admin.give_warning(player,by_player,reason,min)
    local player, by_player_name = valid_players(player,by_player)
    if not player then return end
    local min = Game.get_player(by_player) and take_action or min or 0
    local warnings = get_warnings(player)
    if warnings < min then warnings = min end
    warnings = warnings+1
    _reports().warnings[player.name] = warnings
    if warnings > take_action then 
        player_return({'reports.warning-given-by',by_player_name},defines.text_color.info,player)
        game.print({'reports.player-warning',player.name,by_player_name,reason})
    end
    give_punishment(player,by_player,reason)
end

function Admin.report(player,by_player,reason)
    local player, by_player_name = valid_players(player,by_player)
    if not player or Ranking.get_rank(player):allowed('no-report') then return end
    if Admin.is_banned(by_player) or Ranking.get_group(by_player).name == 'Jail' then return end
    if rank:allowed('varified') then 
        _reports().varified[player.name] = _reports().varified[player.name] or {} 
        local reports = _reports().varified[player.name]
        for _,value in pairs(reports) do
            if value[1] == by_player_name then return end
        end
        table.insert(reports,{by_player_name,reason})
    else
        _reports().reports[player.name] = _reports().reports[player.name] or {}
        local reports = _reports().reports[player.name]
        for _,value in pairs(reports) do
            if value[1] == by_player_name then return end
        end
        table.insert(reports,{by_player_name,reason}) 
    end
    report_message(player,by_player,reason)
    cheak_reports(player)
end

function Admin.clear_warings(player,by_player,no_emit)
    local player, by_player_name = valid_players(player,by_player)
    if not player then return end
    _reports().warnings[player.name]=0
    if not no_emit then
        Sync.emit_embeded{
            title='Player Clear',
            color=Color.to_hex(defines.text_color.low),
            description='A player had their warnings cleared.',
            ['Player:']='<<inline>>'..player.name,
            ['By:']='<<inline>>'..by_player_name,
        }
    end
end

function Admin.clear_reports(player,by_player,no_emit)
    local player, by_player_name = valid_players(player,by_player)
    if not player then return end
    _reports().reports[player.name]={}
    _reports().varified[player.name]={}
    if not no_emit then
        Sync.emit_embeded{
            title='Player Clear',
            color=Color.to_hex(defines.text_color.low),
            description='A player had their reports cleared.',
            ['Player:']='<<inline>>'..player.name,
            ['By:']='<<inline>>'..by_player_name,
        }
    end
end

function Admin.clear_player(player,by_player)
    local player, by_player_name = valid_players(player,by_player)
    if not player then return end
    Admin.clear_warings(player,by_player,true)
    Admin.clear_reports(player,by_player,true)
    _reports().actions[player.name]=actions.none
    if Ranking.get_rank(player).group.name == 'Jail' then Server.interface(Ranking.revert,true,player,by_player) end
    Sync.emit_embeded{
        title='Player Clear',
        color=Color.to_hex(defines.text_color.low),
        description='A player had their reports and warnings cleared.',
        ['Player:']='<<inline>>'..player.name,
        ['By:']='<<inline>>'..by_player_name,
    }
end

function Admin.temp_ban(player,by_player,reason)
    local function append_name(reason,name)
        local reason = reason or 'No Reason'
        if not string.find(string.lower(reason),string.lower(name)) then return reason..' - '..name
        else return reason end
    end
    local player, by_player_name = valid_players(player,by_player)
    if not player or Admin.is_banned(player) then return end
    _reports().actions[player.name] = actions.temp
    Sync.emit_embeded{
        title='Player Temp-Ban',
        color=Color.to_hex(defines.text_color.high),
        description='A player was jailed.',
        ['Player:']='<<inline>>'..player.name,
        ['By:']='<<inline>>'..by_player_name,
        ['Reason:']=append_name(reason,by_player_name)
    }
    game.print({'reports.temp-ban',player.name,by_player_name,reason},defines.text_color.info)
    Admin.move_inventory(player)
    Ranking._presets().last_jail = player.name
    Server.interface(Ranking.give_rank,true,player,'Jail',by_player_name)
end

function Admin.is_banned(player)
    local player=Game.get_player(player)
    if not player then return false end
    local action = _reports().actions[player.name]
    if action == actions.temp then return 'temp'
    elseif action == actions.ban then return true
    else return false end
end

Event.register(defines.events.on_tick,function(event)
    if not _reports().remove_warnings_time then
        _reports().remove_warnings_time = {}
        local highest = nil
        for power,rank in pairs(Ranking._ranks()) do
            if not highest and not rank:allowed('no-report') then highest = power-1 end
            local _power = power; if highest then _power = power-highest end
            if rank:allowed('no-report') then _reports().remove_warnings_time[power] = 0 
            else _reports().remove_warnings_time[power] = min_time_to_remove_warning*_power end
        end
    end
    if (game.tick % min_time_to_remove_warning) == 0 then
        for name,warnings in pairs(_reports().warnings) do
            if warnings > 0 then
                local rank = Ranking.get_rank(name)
                local time_to_remove = _reports().remove_warnings_time[rank.power]
                if (game.tick % time_to_remove) == 0 then
                    _reports().warnings[name]=warnings-1
                    if _reports().warnings[name] > 5 then
                        player_return({'reports.remove-warn',_reports().warnings[name],tick_to_display_format(time_to_remove)},defines.text_color.low,name)
                    end
                end
            end
        end
    end
end)
