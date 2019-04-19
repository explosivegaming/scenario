local Game = require 'utils.game'
local Global = require 'utils.global'
local Event = require 'utils.event'
local config = require 'config.warnings'
local format_chat_player_name = ext_require('expcore.common','format_chat_player_name')
require 'utils.table'

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

--- Adds X number (default 1) of warnings to a player from the given player
-- @tparam player LuaPlayer the player to add the warning to
-- @tparam[opt='<server>'] by_player_name string the name of the player doing the action
-- @tparam[opt=1] count number the number of warnings to add
-- @treturn number the new number of warnings
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

--- Removes X number (default 1) of warnings from a player, removes in order fifo
-- @tparam player LuaPlayer the player to remove the warnings from
-- @tparam[opt='<server>'] by_playey_name string the name of the player doing the action
-- @tparam[opt=1] count number the number of warnings to remove (if greater than current warning count then all are removed)
-- @treturn number the new number of warnings
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

--- Clears all warnings from a player, emits event multiple times as if remove_warnings was used
-- @tparam player LuaPlayer the player to clear the warnings of
-- @tparam[oot='<server>'] by_player_name string the name of the player who is doing the action
-- @treturn boolean true if the warnings were cleared, nil if error
function Public.clear_warnings(player,by_player_name)
    player = Game.get_player_from_any(player)
    if not player then return end
    local warnings = Public.user_warnings[player.name]
    if not warnings then return end
    by_player_name = by_player_name or '<server>'
    for _=1,#warnings do
        event_emit(Public.player_warning_removed,player,by_player_name)
    end
    Public.user_warnings[player.name] = {}
    return true
end

--- Gets the number of warnings that a player has, raw table will contain the names of who gave warnings
-- @tparam player LuaPlayer the player to get the warnings of
-- @tparam[opt=false] raw_table when true will return a table which contains who gave warnings (the table stored in global)
-- @treturn number the number of warnings a player has, a table if raw_table is true
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

--- Adds a temp warning to a player that will timeout after some time, used for script given warnings (ie silent to outside players as a buffer)
-- @tparam player LuaPlayer the player to give the warnings to
-- @tparam[opt=1] count number the number of warnings to give to the player
-- @treturn number the new number of warnings
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

-- temp warnings cant be removed on demand only after X amount of time
local temp_warning_cool_down = config.temp_warning_cool_down*3600
Event.on_nth_tick(temp_warning_cool_down/4,function()
    local check_time = game.tick-temp_warning_cool_down
    for player_name,temp_warnings in pairs(Public.user_temp_warnings) do
        local player = Game.get_player_from_any(player)
        for index,time in pairs(temp_warnings) do
            if time <= check_time then
                table.remove(temp_warnings,index)
                player.print{'warnings.script-warning-removed',#temp_warnings,config.temp_warning_limit}
                event_emit(Public.player_temp_warning_removed,player,'<server>')
            end
        end
        if #temp_warnings == 0 then
            Public.user_temp_warnings[player_name] = nil
        end
    end
end)

--- Clears all temp warnings from a player, emits events as if the warnings had been removed due to time
-- @tparam player LuaPlayer the player to clear the warnings of
-- @tparam[opt='<server>'] by_player_name string the name of the player doing the action
-- @treturn boolean true if the warnings were cleared, nil for error
function Public.clear_temp_warnings(player,by_player_name)
    player = Game.get_player_from_any(player)
    if not player then return end
    local warnings = Public.user_temp_warnings[player.name]
    if not warnings then return end
    by_player_name = by_player_name or '<server>'
    for _=1,#warnings do
        event_emit(Public.player_temp_warning_removed,player,by_player_name)
    end
    Public.user_temp_warnings[player.name] = {}
    return true
end

--- Gets the number of temp warnings, raw table is a table of when temp warnings were given
-- @tparam player LuaPlayer the player to get the warnings of
-- @tparam[opt=false] raw_table if true will return a table of ticks when warnings were added (the global table)
-- @treturn number the number of warnings which the player has, a table if raw_table is true
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

-- when a player gets a warning the actions in config are ran
Event.add(Public.player_warning_added,function(event)
    local action = config.actions[event.warning_count]
    if not action then return end
    local player = Game.get_player_by_index(event.player_index)
    if type(action) == 'function' then
        -- player: player who got the warnings,by_player_name: player who gave the last warning,number_of_warnings: the current number of warnings
        local success,err = pcall(action,player,event.by_player_name,event.warning_count)
        if not success then error(err) end
    elseif type(action) == 'table' then
        -- {locale,by_player_name,number_of_warning,...}
        local current_action = table.deep_copy(action)
        table.insert(current_action,2,event.by_player_name)
        table.insert(current_action,3,event.warning_count)
        player.print(current_action)
    elseif type(action) == 'string' then
        player.print(action)
    end
end)

-- when a player gets a tempo warnings it is checked that it is not above the max
Event.add(Public.player_temp_warning_added,function(event)
    local player = Game.get_player_by_index(event.player_index)
    if event.temp_warning_count > config.temp_warning_limit then
        Public.add_warnings(event.player_index,event.by_player_name)
        local player_name_color = format_chat_player_name(player)
        game.print{'warnings.script-warning-limit',player_name_color}
    else
        player.print{'warnings.script-warning',event.temp_warning_count,config.temp_warning_limit}
    end
end)

return Public