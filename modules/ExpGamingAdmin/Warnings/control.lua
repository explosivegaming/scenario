--- Adds a warning system into the admin set which can be used by admins and the script.
-- @module ExpGamingAdmin.Warnings@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alias ThisModule

-- Module Require
local Admin = require('ExpGamingAdmin')
local Server = require('ExpGamingCore.Server')
local Role = require('ExpGamingCore.Role')
local Game = require('FactorioStdLib.Game')
local Color -- FactorioStdLib.Color@^0.8.0
local Sync -- ExpGamingCore.Sync@^4.0.0

-- Local Variables
local take_action = 8 -- the first admin given warning jumps to this number, this case kick-warn is giving
local remove_warnings_time = {}
local min_time_to_remove_warning = 18000 -- this is in ticks
local punishments = {
    {'nothing'},
    {'nothing'},
    {'nothing'},
    {'nothing'},
    {'nothing'},
    {'message',{'ExpGamingAdmin-Warnings.message'},defines.textcolor.info},
    {'message',{'ExpGamingAdmin-Warnings.message'},defines.textcolor.info},
    {'message',{'ExpGamingAdmin-Warnings.kick-warn'},defines.textcolor.med}, 
    {'kick'},
    {'message',{'ExpGamingAdmin-Warnings.temp-warn'},defines.textcolor.high},
    {'temp-ban'},
    {'message',{'ExpGamingAdmin-Warnings.ban-warn'},defines.textcolor.high},
    {'message',{'ExpGamingAdmin-Warnings.last-warn'},defines.textcolor.crit},
    {'ban'}
}

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Sync'] then Sync = require('ExpGamingCore.Sync') end
        if loaded_modules['FactorioStdLib.Color'] then Color = require('FactorioStdLib.Color') end
        if loaded_modules['ExpGamingAdmin.Reports'] then
            take_action = take_action + 1
            table.insert(punishments,take_action,{'report',{'ExpGamingAdmin-Warnings.reported'},defines.textcolor.med})
        end
    end,
    on_post=function()
        local highest = nil
        for _,role in pairs(Role.roles) do
            local power = role.index
            if not highest and not role.not_reportable then highest = power-1 end
            local _power = power; if highest then _power = power-highest end
            if role.not_reportable then remove_warnings_time[power] = 0 
            else remove_warnings_time[power] = min_time_to_remove_warning*_power end
        end
    end
}

-- Global Define
local global = global{}

-- Function Define
local function give_punishment(player,by_player,reason)
    player, by_player = Admin.valid_players(player,by_player)
    reason = reason or 'No Other Reason'
    local warnings = Admin.get_warnings(player)
    local punishment = punishments[warnings]
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
        Admin.kick(player,by_player,'Too Many Warnings: '..warnings-(take_action-1)..' Also: '..reason)
    elseif punishment[1] == 'temp-ban' then
        Admin.temp_ban(player,by_player,'Too Many Warnings: '..warnings-(take_action-1)..' Also: '..reason)
    elseif punishment[1] == 'ban' then
        Admin.ban(player,by_player,'Too Many Warnings: '..warnings-(take_action-1)..' Also: '..reason)
    end
end

function Admin.get_warnings(player)
    player = Game.get_player(player)
    return global[player.name] or 0
end

function Admin.give_warning(player,by_player,reason,min)
    player, by_player = Admin.valid_players(player,by_player)
    if not player then return end
    min = Game.get_player(by_player) and Game.get_player(by_player) ~= SERVER and take_action or min or 0
    local warnings = Admin.get_warnings(player)
    if warnings < min then warnings = min-1 end
    warnings = warnings+1
    global[player.name] = warnings
    if warnings > take_action then 
        player_return({'ExpGamingAdmin-Warnings.warning-given-by',by_player.name},defines.textcolor.info,player)
        game.print({'ExpGamingAdmin-Warnings.player-warning',player.name,by_player.name,reason})
    end
    give_punishment(player,by_player,reason)
end

function Admin.clear_warnings(player,by_player,no_emit)
    player, by_player = Admin.valid_players(player,by_player)
    if not player then return end
    global[player.name]=nil
    if not no_emit and Sync then
        Sync.emit_embedded{
            title='Player Clear',
            color=Color.to_hex(defines.textcolor.low),
            description='A player had their warnings cleared.',
            ['Player:']='<<inline>>'..player.name,
            ['By:']='<<inline>>'..by_player.name,
        }
    end
end

-- Event Handlers Define
script.on_event(defines.events.on_tick,function(event)
    if (game.tick % min_time_to_remove_warning) == 0 then
        for name,warnings in pairs(global) do
            if warnings > 0 then
                local role = Role.get_highest(name)
                local time_to_remove = remove_warnings_time[role.index]
                if (game.tick % time_to_remove) == 0 then
                    global[name]=warnings-1
                    if global[name] > 5 then
                        player_return({'ExpGamingAdmin-Warnings.remove-warn',global[name],tick_to_display_format(time_to_remove)},defines.textcolor.low,name)
                    end
                end
            end
        end
    end
end)

-- Module Return
return ThisModule