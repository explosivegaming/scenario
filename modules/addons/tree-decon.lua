--- Makes trees which are marked for decon "decay" quickly to allow faster building
-- @addon Tree-Decon

local Event = require 'utils.event' --- @dep utils.event
local Global = require 'utils.global' --- @dep utils.global
local Roles = require 'expcore.roles' --- @dep expcore.roles

-- Global queue used to store trees that need to be removed, also chache for player roles
local chache = {}
local tree_queue = { _head=0 }
Global.register({ tree_queue, chache }, function(tbl)
    tree_queue = tbl[1]
    chache = tbl[2]
end)

-- Add trees to queue when marked, only allows simple entities and for players with role permission
Event.add(defines.events.on_marked_for_deconstruction, function(event)
    -- Check which type of decon a player is allowed
    local index = event.player_index
    if not index then return end
    if chache[index] == nil then
        local player = game.players[index]
        if Roles.player_allowed(player, 'fast-tree-decon') then chache[index] = 'fast'
        elseif Roles.player_allowed(player, 'standard-decon') then chache[index] = 'standard'
        else chache[index] = player.force end
    end

    -- Check what should happen to this entity
    local entity = event.entity
    local allow = chache[index]
    if not entity or not entity.valid then return end

    -- Not allowed to decon this entity
    local last_user = entity.last_user
    if last_user and allow ~= 'standard' and allow ~= 'fast' then
        entity.cancel_deconstruction(allow)
        return
    end

    -- Allowed to decon this entity, but not fast
    if allow ~= 'fast' then return end

    -- Allowed fast decon on this entity, just trees
    local head = tree_queue._head + 1
    if not last_user and entity.type ~= 'cliff' then
        tree_queue[head] = entity
        tree_queue._head = head
    end

end)

-- Remove trees at random till the queue is empty
Event.add(defines.events.on_tick, function()
    local head = tree_queue._head
    if head == 0 then return end

    local max_remove = math.floor(head/100)+1
    local remove_count = math.random(0, max_remove)
    while remove_count > 0 and head > 0 do
        local remove_index = math.random(1, head)
        local entity = tree_queue[remove_index]
        tree_queue[remove_index] = tree_queue[head]
        head = head - 1
        if entity and entity.valid then
            remove_count = remove_count - 1
            entity.destroy()
        end
    end
    tree_queue._head = head
end)

-- Clear the chache
Event.on_nth_tick(300, function()
    for key, _ in pairs(chache) do
        chache[key] = nil
    end
end)