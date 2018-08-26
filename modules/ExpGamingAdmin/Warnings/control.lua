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

-- so it can be used during on_init
local take_action = 8 -- below this number no action is taken, the first admin given warning jumps to this number
local remove_warnings_time = {}
local min_time_to_remove_warning = 18000 -- this is in ticks

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Sync@^4.0.0'] then Sync = require('ExpGamingCore.Sync@^4.0.0') end
        if loaded_modules['ExpGamingAdmin.Reports@^4.0.0'] then
            take_action = take_action + 1
            table.insert(punishments,{'report',{'ExpGamingAdmin-Warnings@4-0-0.reported'},defines.text_color.med},take_action)
        end
    end,
    on_post=function()
        local highest = nil
        for power,rank in pairs(Ranking.ranks) do
            if not highest and not rank:allowed('no-report') then highest = power-1 end
            local _power = power; if highest then _power = power-highest end
            if rank:allowed('no-report') then remove_warnings_time[power] = 0 
            else remove_warnings_time[power] = min_time_to_remove_warning*_power end
        end
    end
}

-- Global Define
local global = global{}

-- Local Varibles
local punishments = {
    {'nothing'},
    {'nothing'},
    {'nothing'},
    {'nothing'},
    {'nothing'},
    {'message',{'ExpGamingAdmin-Warnings@4-0-0.message'},defines.text_color.info},
    {'message',{'ExpGamingAdmin-Warnings@4-0-0.message'},defines.text_color.info},
    {'message',{'ExpGamingAdmin-Warnings@4-0-0.kick-warn'},defines.text_color.med}, 
    {'kick'},
    {'message',{'ExpGamingAdmin-Warnings@4-0-0.temp-warn'},defines.text_color.high},
    {'temp-ban'},
    {'message',{'ExpGamingAdmin-Warnings@4-0-0.ban-warn'},defines.text_color.high},
    {'message',{'ExpGamingAdmin-Warnings@4-0-0.last-warn'},defines.text_color.crit},
    {'ban'}
}

-- Function Define
local function valid_players(player,by_player)
    local player = Game.get_player(player)
    local by_player_name = Game.get_player(by_player) and Game.get_player(by_player).name or '<server>'
    return player, by_player_name
end

local function give_punishment(player,by_player,reason)
    local player, by_player_name = valid_players(player,by_player)
    local warnings = Admin.get_warnings(player)
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
        Admin.report(player,'<server>',reason)
    elseif punishment[1] == 'kick' then
        global.actions[player.name] = actions.kick
        Admin.kick(player,by_player,'Too Many Warnings: '..warnings-(take_action-1)..' Also: '..reason)
    elseif punishment[1] == 'temp-ban' then
        Admin.temp_ban(player,by_player,'Too Many Warnings: '..warnings-(take_action-1)..' Also: '..reason)
    elseif punishment[1] == 'ban' then
        global.actions[player.name] = actions.ban
        Admin.ban(player,by_player,'Too Many Warnings: '..warnings-(take_action-1)..' Also: '..reason)
    end
end

function Admin.get_warnings(player)
    local player = Game.get_player(player)
    return global[player.name] or 0
end

function Admin.give_warning(player,by_player,reason,min)
    local player, by_player_name = valid_players(player,by_player)
    if not player then return end
    local min = Game.get_player(by_player) and take_action or min or 0
    local warnings = Admin.get_warnings(player)
    if warnings < min then warnings = min end
    warnings = warnings+1
    global[player.name] = warnings
    if warnings > take_action then 
        player_return({'ExpGamingAdmin-Warnings@4-0-0.warning-given-by',by_player_name},defines.text_color.info,player)
        game.print({'ExpGamingAdmin-Warnings@4-0-0.player-warning',player.name,by_player_name,reason})
    end
    give_punishment(player,by_player,reason)
end

function Admin.clear_warings(player,by_player,no_emit)
    local player, by_player_name = valid_players(player,by_player)
    if not player then return end
    global[player.name]=0
    if not no_emit and Sync then
        Sync.emit_embeded{
            title='Player Clear',
            color=Color.to_hex(defines.text_color.low),
            description='A player had their warnings cleared.',
            ['Player:']='<<inline>>'..player.name,
            ['By:']='<<inline>>'..by_player_name,
        }
    end
end

-- Event Handlers Define
script.on_event(defines.events.on_tick,function(event)
    if (game.tick % min_time_to_remove_warning) == 0 then
        for name,warnings in pairs(global) do
            if warnings > 0 then
                local rank = Ranking.get_rank(name)
                local time_to_remove = remove_warnings_time[rank.power]
                if (game.tick % time_to_remove) == 0 then
                    global[name]=warnings-1
                    if global.warnings[name] > 5 then
                        player_return({'ExpGamingAdmin-Warnings@4-0-0.remove-warn',global[name],tick_to_display_format(time_to_remove)},defines.text_color.low,name)
                    end
                end
            end
        end
    end
end)

-- Module Return
return ThisModule 