local Game = require 'utils.game'
local Global = require 'utils.global'
local Event = require 'utils.event'
local config = require 'config.warnings'

local Public = {
    user_warnings={},
    user_temp_warnings={},
    player_warning_added = script.generate_event_name(),
    player_warning_removed = script.generate_event_name(),
    player_temp_warning_added = script.generate_event_name(),
    player_temp_warning_removed = script.generate_event_name()
}

Global.register({
    Public.user_warnings,
    Public.user_temp_warnings
},function(tbl)
    Public.user_warnings = tbl[1]
    Public.user_temp_warnings = tbl[2]
end)

local function event_emit(event,player,by_player_name)
    local warnings = Public.user_warnings[player.name] or {}
    local temp_warnings = Public.user_temp_warnings[player.name] or {}
    script.raise_event(event,{
        name=event,
        tick=game.tick,
        player_index=player.index,
        by_player_name=by_player_name,
        warning_count=#warnings,
        temp_warning_count=#temp_warnings
    })
end

function Public.add_warnings(player,by_player_name,count)
    player = Game.get_player_from_any(player)
    if not player then return end
    count = count or 1
    by_player_name = by_player_name or '<server>'
    local warnings = Public.user_warnings[player.name]
    if not warnings then
        Public.user_warnings[player.name] = {}
        warnings = Public.user_warnings[player.name]
    end
    for _=1,count do
        table.insert(warnings,by_player_name)
        event_emit(Public.player_warning_added,player,by_player_name)
    end
    return #warnings
end

function Public.remove_warnings(player,by_player_name,count)
    player = Game.get_player_from_any(player)
    if not player then return end
    count = count or 1
    by_player_name = by_player_name or '<server>'
    local warnings = Public.user_warnings[player.name]
    if not warnings then return end
    for _=1,count do
        if #warnings == 0 then break end
        table.remove(warnings,1)
        event_emit(Public.player_warning_removed,player,by_player_name)
    end
    if #warnings == 0 then
        Public.user_warnings[player.name] = nil
        return 0
    end
    return #warnings
end

function Public.clear_warnings(player,by_player_name)
    player = Game.get_player_from_any(player)
    if not player then return end
    local warnings = Public.user_warnings[player.name]
    if not warnings then return end
    for _=1,#warnings do
        event_emit(Public.player_warning_removed,player,by_player_name)
    end
    Public.user_warnings[player.name] = {}
    return true
end

function Public.get_warnings(player,raw_table)
    player = Game.get_player_from_any(player)
    if not player then return end
    local warnings = Public.user_warnings[player.name] or {}
    if raw_table then
        return warnings
    else
        return #warnings
    end
end

function Public.add_temp_warnings(player,count)
    player = Game.get_player_from_any(player)
    if not player then return end
    count = count or 1
    local warnings = Public.user_temp_warnings[player.name]
    if not warnings then
        Public.user_temp_warnings[player.name] = {}
        warnings = Public.user_temp_warnings[player.name]
    end
    for _=1,count do
        table.insert(warnings,game.tick)
        event_emit(Public.player_temp_warning_added,player,'<server>')
    end
    return #warnings
end

local temp_warning_cool_down = config.temp_warning_cool_down*3600
Event.on_nth_tick(temp_warning_cool_down/4,function()
    local check_time = game.tick-temp_warning_cool_down
    for player_name,temp_warnings in pairs(Public.user_temp_warnings) do
        local player = Game.get_player_from_any(player)
        for index,time in pairs(temp_warnings) do
            if time <= check_time then
                table.remove(temp_warnings,index)
                event_emit(Public.player_temp_warning_removed,player,'<server>')
            end
        end
        if #temp_warnings == 0 then
            Public.user_temp_warnings[player_name] = nil
        end
    end
end)

function Public.clear_temp_warnings(player,by_player_name)
    player = Game.get_player_from_any(player)
    if not player then return end
    local warnings = Public.user_temp_warnings[player.name]
    if not warnings then return end
    for _=1,#warnings do
        event_emit(Public.player_temp_warning_removed,player,by_player_name)
    end
    Public.user_temp_warnings[player.name] = {}
    return true
end

function Public.get_temp_warnings(player,raw_table)
    player = Game.get_player_from_any(player)
    if not player then return end
    local warnings = Public.user_temp_warnings[player.name] or {}
    if raw_table then
        return warnings
    else
        return #warnings
    end
end

Event.add(Public.player_temp_warning_added,function(event)
    if event.temp_warning_count > config.temp_warning_limit then
        Public.add_warnings(event.player_index,event.by_player_name)
    end
end)

return Public