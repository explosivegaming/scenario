--- Gives players random colours when they join, also applies preset colours to those who have them
-- @addon Player-Colours

local Event = require 'utils.event' --- @dep utils.event
local Colours = require 'utils.color_presets' --- @dep utils.color_presets
local config = require 'config.preset_player_colours' --- @dep config.preset_player_colours

--- Stores the colour that the player wants
local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data
local PlayerColours = PlayerData.Settings:combine('Colour')

--- Used to compact player colours to take less space
local floor = math.floor
local function compact(colour)
    return {
        floor(colour.r * 255),
        floor(colour.g * 255),
        floor(colour.b * 255)
    }
end

--- When your data loads apply the players colour, or a random on if none is saved
PlayerColours:on_load(function(player_name, player_colour)
    if not player_colour then
        local preset = config.players[player_name]
        if preset then
            player_colour = {preset, preset}
        else
            local colour_name = 'white'
            while config.disallow[colour_name] do
                colour_name = table.get_random_dictionary_entry(Colours, true)
            end
            player_colour = {Colours[colour_name], Colours[colour_name]}
        end
    end

    local player = game.players[player_name]
    player.color = player_colour[1]
    player.chat_color = player_colour[2]
end)

--- Save the players color when they use the color command
Event.add(defines.events.on_console_command, function(event)
    if event.command ~= 'color' then return end
    if event.parameters == '' then return end
    if not event.player_index then return end
    local player = game.players[event.player_index]
    if not player or not player.valid then return end
    PlayerColours:set(player, {compact(player.color), compact(player.chat_color)})
end)