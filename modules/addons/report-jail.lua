--- When a player is reported, the player is automatically jailed if the combined playtime of the reporters exceeds the reported player
-- @addon report-jail

local Event = require 'utils.event' ---@dep utils.event
local config = require 'config.report-jail' --- @dep config.afk_kick
local Jail = require 'modules.control.jail' ---@dep modules.control.jail
local Reports = require 'modules.control.reports' --- @dep modules.control.reports
local format_chat_player_name = _C.format_chat_player_name --- @dep expcore.common
local has_role = Roles.player_has_role
local get_roles = Roles.get_player_roles

--- Returns the playtime of the reporter. Used when calculating the total playtime of all reporters
local function reporter_playtime(_, by_player_name, _)
    local player = game.get_player(by_player_name)
    if player == nil then return 0 end
    return player.online_time
end

--- Tests the combined playtime of all reporters against the reported player
--[[
    If there is active moderator,
    then let moderator do it.
]]

Event.add(Reports.events.on_player_reported, function(event)
    local player = game.get_player(event.player_index)
    local total_playtime = Reports.count_reports(player, reporter_playtime)
    local moderator_count_bool = false

    for _, player_ in ipairs(game.connected_players) do
        if player_.admin then
            if player_.afk_time < config.afk_time then
                -- No instant jail if a moderator is active
                moderator_count_bool = true
            end
        end
    end
    
    if not moderator_count_bool then
        -- if player.online_time ~= nil and player.MachinesRemoved ~= nil then
        -- if has_role(player, 'Member') or has_role(player, 'Veteran') then
        -- Combined playtime is greater than 200% of the reported's playtime
        -- 30 min = 108,000

        if ((player.online_time * 2) > total_playtime) and (player.online_time > 108000) then
            return
        elseif #Reports.get_reports(player) > 1 then
            local player_name_color = format_chat_player_name(player)
            Jail.jail_player(player, '<reports>', 'Reported by too many players, please wait for a moderator.')
            game.print{'report-jail.jail', player_name_color}
        end
    end
end)
