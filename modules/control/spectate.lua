
local Event = require 'utils.event' --- @dep utils.event
local Global = require 'utils.global' --- @dep utils.global
local Gui = require 'expcore.gui' --- @dep expcore.gui

----- Locals -----
local follow_label -- Gui constructor
local following = {}
local spectating = {}
local Public = {}

----- Global data -----
Global.register({
    following = following,
    spectating = spectating
}, function(tbl)
    following = tbl.following
    spectating = tbl.spectating
end)

----- Public Functions -----

--- Test if a player is in spectator mode
-- @tparam LuaPlayer player The player to test the controller type of
-- @treturn boolean True if the player is in spectator mode
function Public.is_spectating(player)
    assert(player and player.valid, 'Invalid player given to follower')
    return player.controller_type == defines.controllers.spectator
end

--- Puts a player into spectator while maintaining an association to their character
-- @tparam LuaPlayer player The player that will be placed into spectator
-- @treturn boolean Returns false if the player was already in spectator
function Public.start_spectate(player)
    assert(player and player.valid, 'Invalid player given to follower')
    if spectating[player.index] or not player.character then return false end
    local character = player.character
    player.set_controller{ type = defines.controllers.spectator }
    player.associate_character(character)
    spectating[player.index] = character
    return true
end

--- Return a player from spectator back to their character, if the character was killed then respawn the character
-- @tparam LuaPlayer player The player that will leave spectator
function Public.stop_spectate(player)
    assert(player and player.valid, 'Invalid player given to follower')
    local character = spectating[player.index]
    spectating[player.index] = nil
    if character and character.valid then
        player.teleport(character.position, character.surface)
        player.set_controller{ type = defines.controllers.character, character = character }
    else
        player.ticks_to_respawn = 300
    end
end

--- Test if a player is in follow mode
-- @tparam LuaPlayer player The player to test the follow mode of
-- @treturn boolean True if the player is in follow mode
function Public.is_following(player)
    assert(player and player.valid, 'Invalid player given to follower')
    return following[player.index] ~= nil
end

--- Puts a player into spectator and follows an entity as it moves
-- @tparam LuaPlayer player The player that will follow the entity
-- @tparam ?LuaPlayer|LuaEntity entity The player or entity that will be followed
function Public.start_follow(player, entity)
    assert(player and player.valid, 'Invalid player given to follower')
    assert(entity and entity.valid, 'Invalid entity given to follower')
    local spectate = Public.start_spectate(player)

    player.close_map()
    follow_label(player.gui.screen, entity)
    player.teleport(entity.position, entity.surface)
    following[player.index] = { player, entity, entity.position, spectate }
end

--- Stops a player from following their current entity, can also return a player from spectate
-- @tparam LuaPlayer player The player that you want to stop following their entity
function Public.stop_follow(player)
    assert(player and player.valid, 'Invalid player given to follower')
    if following[player.index] and following[player.index][4] then Public.stop_spectate(player) end

    Gui.destroy_if_valid(player.gui.screen[follow_label.name])
    following[player.index] = nil
end

--- Used to stop all players following an entity or player
function Public.stop_all()
    for key, data in pairs(following) do
        Public.stop_follow(data[1])
    end
end

----- Gui -----

--- Label used to show that the player is following, also used to allow esc to stop following
-- @element follow_label
follow_label =
Gui.element(function(event_trigger, parent, target)
    Gui.destroy_if_valid(parent[event_trigger])

    local label = parent.add{
        name = event_trigger,
        type = 'label',
        style = 'heading_1_label',
        caption = 'Following '..target.name..'.\nClick here or press esc to stop following.'
    }

    local player = Gui.get_player_from_element(parent)
    local res = player.display_resolution
    label.location = {0, res.height-150}
    label.style.width = res.width
    label.style.horizontal_align = 'center'
    player.opened = label

    return label
end)
:on_close(Public.stop_follow)
:on_click(Public.stop_follow)

----- Events -----

--- Updates the location of the player as well as doing some sanity checks
-- @tparam LuaPlayer player The player to update the position of
-- @tparam ?LuaPlayer|LuaEntity entity The player or entity being followed
local function update_player_location(player, entity, old_position)
    if player.character or not entity.valid then
        Public.stop_follow(player)
    elseif player.position.x ~= old_position.x or player.position.y ~= old_position.y then
        Public.stop_follow(player)
    else
        player.teleport(entity.position, entity.surface)
    end
end

--- Updates the locations of all players currently following something
local function update_all()
    for _, data in pairs(following) do
        update_player_location(data[1], data[2], data[3])
        data[3] = data[1].position
    end
end

-- Update the location of all players each tick
Event.add(defines.events.on_tick, update_all)

-- Check for player leaving
Event.add(defines.events.on_player_left_game, function(event)
    local player = game.players[event.player_index]
    Public.stop_follow(player)
    for _, data in pairs(following) do
        if data[2] == player then
            Public.stop_follow(data[1])
        end
    end
end)

----- Module Return -----
return Public