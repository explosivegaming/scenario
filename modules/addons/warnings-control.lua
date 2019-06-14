local Game = require 'utils.game'
local Global = require 'utils.global'
local Event = require 'utils.event'
local config = require 'config.warnings'
local format_chat_player_name = ext_require('expcore.common','format_chat_player_name')
require 'utils.table'

local Warnings = {
    user_warnings={},
    user_temp_warnings={},
    events = {
        on_player_warned = script.generate_event_name(),
        on_player_warning_removed = script.generate_event_name(),
        on_temp_warning_added = script.generate_event_name(),
        on_temp_warning_removed = script.generate_event_name(),
    }
}

Global.register({
    user_warnings = Warnings.user_warnings,
    user_temp_warnings = Warnings.user_temp_warnings
},function(tbl)
    Warnings.user_warnings = tbl.user_warnings
    Warnings.user_temp_warnings = tbl.user_temp_warnings
end)

local function event_emit(event,player,by_player_name)
    local warnings = Warnings.user_warnings[player.name] or {}
    local temp_warnings = Warnings.user_temp_warnings[player.name] or {}
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
-- @tparam LuaPlayer player the player to add the warning to
-- @tparam[opt='<server>'] string by_player_name the name of the player doing the action
-- @tparam[opt=1] number count the number of warnings to add
-- @treturn number the new number of warnings
function Warnings.add_warnings(player,by_player_name,count)
    player = Game.get_player_from_any(player)
    if not player then return end
    count = count or 1
    by_player_name = by_player_name or '<server>'
    local warnings = Warnings.user_warnings[player.name]
    if not warnings then
        Warnings.user_warnings[player.name] = {}
        warnings = Warnings.user_warnings[player.name]
    end
    for _=1,count do
        table.insert(warnings,by_player_name)
        event_emit(Warnings.events.on_player_warned,player,by_player_name)
    end
    return #warnings
end

--- Removes X number (default 1) of warnings from a player, removes in order fifo
-- @tparam LuaPlayer player the player to remove the warnings from
-- @tparam[opt='<server>'] string by_playey_name the name of the player doing the action
-- @tparam[opt=1] number count the number of warnings to remove (if greater than current warning count then all are removed)
-- @treturn number the new number of warnings
function Warnings.remove_warnings(player,by_player_name,count)
    player = Game.get_player_from_any(player)
    if not player then return end
    count = count or 1
    by_player_name = by_player_name or '<server>'
    local warnings = Warnings.user_warnings[player.name]
    if not warnings then return end
    for _=1,count do
        if #warnings == 0 then break end
        table.remove(warnings,1)
        event_emit(Warnings.events.on_player_warning_removed,player,by_player_name)
    end
    if #warnings == 0 then
        Warnings.user_warnings[player.name] = nil
        return 0
    end
    return #warnings
end

--- Clears all warnings from a player, emits event multiple times as if remove_warnings was used
-- @tparam LuaPlayer player the player to clear the warnings of
-- @tparam[oot='<server>'] string by_player_name the name of the player who is doing the action
-- @treturn boolean true if the warnings were cleared, nil if error
function Warnings.clear_warnings(player,by_player_name)
    player = Game.get_player_from_any(player)
    if not player then return end
    local warnings = Warnings.user_warnings[player.name]
    if not warnings then return end
    by_player_name = by_player_name or '<server>'
    for _=1,#warnings do
        event_emit(Warnings.events.on_player_warning_removed,player,by_player_name)
    end
    Warnings.user_warnings[player.name] = {}
    return true
end

--- Gets the number of warnings that a player has, raw table will contain the names of who gave warnings
-- @tparam LuaPlayer player the player to get the warnings of
-- @tparam[opt=false] table table raw_table when true will return a which contains who gave warnings (the stored in global)
-- @treturn number the number of warnings a player has, a table if raw_table is true
function Warnings.get_warnings(player,raw_table)
    player = Game.get_player_from_any(player)
    if not player then return end
    local warnings = Warnings.user_warnings[player.name] or {}
    if raw_table then
        return warnings
    else
        return #warnings
    end
end

--- Adds a temp warning to a player that will timeout after some time, used for script given warnings (ie silent to outside players as a buffer)
-- @tparam LuaPlayer player the player to give the warnings to
-- @tparam[opt=1] number count the number of warnings to give to the player
-- @treturn number the new number of warnings
function Warnings.add_temp_warnings(player,count)
    player = Game.get_player_from_any(player)
    if not player then return end
    count = count or 1
    local warnings = Warnings.user_temp_warnings[player.name]
    if not warnings then
        Warnings.user_temp_warnings[player.name] = {}
        warnings = Warnings.user_temp_warnings[player.name]
    end
    for _=1,count do
        table.insert(warnings,game.tick)
        event_emit(Warnings.events.on_temp_warning_added,player,'<server>')
    end
    return #warnings
end

-- temp warnings cant be removed on demand only after X amount of time
local temp_warning_cool_down = config.temp_warning_cool_down*3600
Event.on_nth_tick(temp_warning_cool_down/4,function()
    local check_time = game.tick-temp_warning_cool_down
    for player_name,temp_warnings in pairs(Warnings.user_temp_warnings) do
        local player = Game.get_player_from_any(player)
        for index,time in pairs(temp_warnings) do
            if time <= check_time then
                table.remove(temp_warnings,index)
                player.print{'warnings.script-warning-removed',#temp_warnings,config.temp_warning_limit}
                event_emit(Warnings.events.on_temp_warning_removed,player,'<server>')
            end
        end
        if #temp_warnings == 0 then
            Warnings.user_temp_warnings[player_name] = nil
        end
    end
end)

--- Clears all temp warnings from a player, emits events as if the warnings had been removed due to time
-- @tparam LuaPlayer player the player to clear the warnings of
-- @tparam[opt='<server>'] string by_player_name the name of the player doing the action
-- @treturn boolean true if the warnings were cleared, nil for error
function Warnings.clear_temp_warnings(player,by_player_name)
    player = Game.get_player_from_any(player)
    if not player then return end
    local warnings = Warnings.user_temp_warnings[player.name]
    if not warnings then return end
    by_player_name = by_player_name or '<server>'
    for _=1,#warnings do
        event_emit(Warnings.events.on_temp_warning_removed,player,by_player_name)
    end
    Warnings.user_temp_warnings[player.name] = {}
    return true
end

--- Gets the number of temp warnings, raw table is a table of when temp warnings were given
-- @tparam LuaPlayer player the player to get the warnings of
-- @tparam[opt=false] table raw_table if true will return a of ticks when warnings were added (the global table)
-- @treturn number the number of warnings which the player has, a table if raw_table is true
function Warnings.get_temp_warnings(player,raw_table)
    player = Game.get_player_from_any(player)
    if not player then return end
    local warnings = Warnings.user_temp_warnings[player.name] or {}
    if raw_table then
        return warnings
    else
        return #warnings
    end
end

-- when a player gets a warning the actions in config are ran
Event.add(Warnings.events.on_player_warned,function(event)
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
Event.add(Warnings.events.on_temp_warning_added,function(event)
    local player = Game.get_player_by_index(event.player_index)
    if event.temp_warning_count > config.temp_warning_limit then
        Warnings.add_warnings(event.player_index,event.by_player_name)
        local player_name_color = format_chat_player_name(player)
        game.print{'warnings.script-warning-limit',player_name_color}
    else
        player.print{'warnings.script-warning',event.temp_warning_count,config.temp_warning_limit}
    end
end)

return Warnings