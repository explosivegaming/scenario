--[[-- Control Module - Warps
    - Stores warps for each force.
    @control Warps
    @alias Warps

    @usage
    -- import the module from the control modules
    local Warps = require 'modules.control.warps' --- @dep modules.control.warps

    -- Adding a warp require a force, surface and postion, and the option to set this as the spawn
    -- this function will also create the warp area unless set other wise
    Warps.new_warp('player',surface,{x=0,y=0})

    -- You can then update the warp information, name and icon, with the update function
    Warps.update_warp(warp_id,'Best Warp','iron-plate')

    -- Removeing a warp will restore the land that as under it, and remove any data linked with it
    Warps.remove_warp(warp_id)

    -- You can get the deatils for a warp which include last edit and postion
    Warps.get_details(warp_id)

    -- You can teleport a player to a warp, note that there is no limit on this action
    Warps.teleport_player(warp_id,player)

]]

local Store = require 'expcore.store' --- @dep expcore.store
local Global = require 'utils.global' --- @dep utils.global
local Token = require 'utils.token' --- @dep utils.token
local config = require 'config.warps' --- @dep config.warps
local table_values,table_keysort = ext_require('expcore.common','table_values','table_keysort') --- @dep expcore.common

local Warps = {
    store = {
        names = 'gui.left.warps.names',
        icons = 'gui.left.warps.tags'
    },
    details = {},
    forces = {},
    handlers = {}
}

local warp_details = Warps.details
local force_warps = Warps.forces
Global.register({
    warp_details=warp_details,
    force_warps=force_warps
},function(tbl)
    Warps.details = tbl.warp_details
    Warps.forces = tbl.force_warps
    warp_details = Warps.details
    force_warps = Warps.forces
end)

local warp_names = Warps.store.names
Store.register(warp_names,function(value,warp_id)
    local details = warp_details[warp_id]
    local force_name = details.force
    local force = game.forces[force_name]
    local warps = force_warps[force_name]
    local spawn_id = warps.spawn

    local names = {}
    for _,next_warp_id in pairs(warps) do
        local warp_name = Store.get(warp_names,next_warp_id)
        if next_warp_id ~= spawn_id then
            names[warp_name..next_warp_id] = next_warp_id
        end
    end

    force_warps[force_name] = table_values(table_keysort(names))
    table.insert(force_warps[force.name],1,spawn_id)
    force_warps[force_name].spawn = spawn_id

    for _,handler in pairs(Warps.handlers) do
        handler(force,warp_id)
    end
end)

local warp_icons = Warps.store.icons
Store.register(warp_icons,function(value,warp_id)
    if value then
        Warps.make_chart_tag(warp_id)
    else
        local warp = warp_details[warp_id]
        if warp.tag and warp.tag.valid then warp.tag.destroy() end
    end
end)

--- Generators.
-- functions used to create and alter warps with in the map
-- @section generators

--- Adds or updates the chart tag for a warp
-- @tparam string warp_id the uid of the warp you want to make the chart tag for
-- @treturn boolean true if a new tag was made, false if it was updated
function Warps.make_chart_tag(warp_id)
    local warp = warp_details[warp_id]

    local name = Store.get(warp_names,warp_id)
    local icon = Store.get(warp_icons,warp_id)

    if warp.tag and warp.tag.valid then
        warp.tag.text = 'Warp: '..name
        warp.tag.icon = {type='item',name=icon}
        return false
    end

    local force = game.forces[warp.force]
    local surface = warp.surface
    local position = warp.position

    local tag = force.add_chart_tag(surface,{
        position={position.x+0.5,position.y+0.5},
        text='Warp: '..name,
        icon={type='item',name=icon}
    })

    warp.tag = tag
    return true
end

--- Adds a new warp to a force and makes the in game warp area
-- @tparam string force_name the name of the force to add a new warp for
-- @tparam LuaSurface surface the surface to add the warp to
-- @tparam Position position the postion to have the warp go to
-- @tparam[opt='server'] string player_name the name of the player who added this warp
-- @tparam[opt='New warp'] string warp_name the name of the warp that will be made
-- @tparam[opt=false] boolean block_generation when true a in game area will not be made
-- @tparam[opt=false] boolean set_spawn when true this warp will become the spawn for the force
function Warps.new_warp(force_name,surface,position,player_name,warp_name,block_generation,set_spawn)
    local warp_id = tostring(Token.uid())
    warp_name = warp_name or 'New warp'

    if not force_warps[force_name] then
        force_warps[force_name] = {}
    end
    table.insert(force_warps[force_name],warp_id)

    warp_details[warp_id] = {
        warp_id = warp_id,
        force = force_name,
        position = {
            x=math.floor(position.x),
            y=math.floor(position.y)
        },
        surface = surface,
        last_edit_player=player_name or '<server>',
        last_edit_time=game.tick,
        editing={}
    }

    local warp = warp_details[warp_id]

    if player_name then
        warp.editing[player_name] = true
    end

    if set_spawn then
        force_warps[force_name].spawn = warp_id
        game.forces[force_name].set_spawn_position(position,surface)
    end

    Store.set(warp_names,warp_id,warp_name)
    Store.set(warp_icons,warp_id,config.default_icon)

    if block_generation then return warp_id end

    local posx = position.x
    local posy = position.y
    local radius = config.activation_range
    local radius2 = radius^2

    local old_tile = surface.get_tile(position).name
    warp.old_tile = old_tile

    local base_tile = config.base_tile
    local base_tiles = {}
    -- this makes a base plate to make the warp point
    for x = -radius, radius do
        local x2 = x^2
        for y = -radius, radius do
            local y2 = y^2
            if x2+y2 < radius2 then
                table.insert(base_tiles,{name=base_tile,position={x+posx,y+posy}})
            end
        end
    end
    surface.set_tiles(base_tiles)

    -- this adds the tile pattern
    local tiles = {}
    for _,pos in pairs(config.tiles) do
        table.insert(tiles,{name=base_tile,position={pos[1]+posx,pos[2]+posy}})
    end
    surface.set_tiles(tiles)

    -- this adds the enitites
    for _,entity in pairs(config.entities) do
        entity = surface.create_entity{
            name=entity[1],
            position={entity[2]+posx,entity[3]+posy},
            force='neutral'
        }
        entity.destructible = false
        entity.health = 0
        entity.minable = false
        entity.rotatable = false
    end

    return warp_id
end

--- Removes a warp and clears the area where it was added
-- @tparam string warp_id the uid of the warp that you want to remove
function Warps.remove_warp(warp_id)
    local force_name = warp_details[warp_id].force
    local warps = force_warps[force_name]
    local key = table.index_of(warps,warp_id)
    warps[key] = nil
    Store.clear(warp_names,warp_id)
    Store.clear(warp_icons,warp_id)

    local warp = warp_details[warp_id]
    local position = warp.position
    local surface = warp.surface
    local radius = config.activation_range
    local radius2 = radius^2

    local base_tile = warp.old_tile
    local tiles = {}
    -- clears the area where the warp was
    for x = -radius, radius do
        local x2 = x^2
        for y = -radius, radius do
            local y2 = y^2
            if x2+y2 < radius2 then
                table.insert(tiles,{name=base_tile,position={x+position.x,y+position.y}})
            end
        end
    end
    surface.set_tiles(tiles)

    -- removes all entites (in the area) on the neutral force
    local entities = surface.find_entities_filtered{
        force='neutral',
        area={
            {position.x-radius,position.y-radius},
            {position.x+radius,position.y+radius}
        }
    }
    for _,entity in pairs(entities) do if entity.name ~= 'player' then entity.destroy() end end

    warp_details[warp_id] = nil
end

--- Setters.
-- functions used to created and alter warps
-- @section setters

--- Adds a new handler for when a warp is updated
-- @tparam function callback the callback which is ran when a warp is updated
-- @treturn boolean true if the callback was added
function Warps.add_handler(callback)
    if type(callback) == 'function' then
        table.insert(Warps.handlers,callback)
        return true
    end
    return false
end

--- Sets a player to be editing this warp, used with is_editing
-- @tparam string warp_id the uid of the warp that you want to editing for
-- @tparam string player_name the name of the player you want to set editing for
-- @tparam[opt] boolean state the new state to set editing to
function Warps.set_editing(warp_id,player_name,state)
    local details = warp_details[warp_id]
    details.editing[player_name] = state
end

--- Updates a warp to a differecnt name and icon, both must be given
-- @tparam string warp_id the uid of the warp that you want to update
-- @tparam string name the name that you want the warp to have
-- @tparam string icon the new icon that you want the warp to have
-- @tparam[opt='server'] string player_name the name of the player that is updating the warp
function Warps.update_warp(warp_id,name,icon,player_name)
    local warp = warp_details[warp_id]
    warp.last_edit_player = player_name or '<server>'
    warp.last_edit_time = game.tick
    Store.set(warp_icons,warp_id,icon)
    Store.set(warp_names,warp_id,name)
end

--- Getters.
-- function used to get information about warps
-- @section getters

--- Gets the name of a warp
-- @tparam string warp_id the uid of the warp you want to get
-- @treturn string the warp name that was stored here
function Warps.get_warp_name(warp_id)
    return Store.get(warp_names,warp_id)
end

--- Gets the icon of a warp
-- @tparam string warp_id the uid of the warp you want to get
-- @treturn string the warp icon that was stored here
function Warps.get_warp_icon(warp_id)
    return Store.get(warp_icons,warp_id) or config.default_icon
end

--- Gets the task details stored at this id
-- @tparam string warp_id the uid of the warp you want to get
-- @treturn table the warp details that was stored here
function Warps.get_details(warp_id)
    return warp_details[warp_id]
end

--- Gets all warps for a force
-- @tparam string force_name the name of the force to get the warps for
-- @treturn table an array of warp ids that belong to this force, spawn key is included
function Warps.get_warps(force_name)
    return force_warps[force_name] or {}
end

--- Gets all warps from all forces
-- @treturn table array of all warp details
function Warps.get_all_warps()
    return warp_details
end

--- Gets if a player is currently editing this warp
-- @tparam string warp_id the uid of the warp you want to check
-- @tparam string player_name the name of the player that you want to check
-- @treturn boolean weather the player is currently editing this warp
function Warps.is_editing(warp_id,player_name)
    local details = warp_details[warp_id]
    return details.editing[player_name]
end

--- Teleports a player to a warp point
-- @tparam string warp_id the uid of the warp to send the player to
-- @tparam LuaPlayer player the player to teleport to the warp
function Warps.teleport_player(warp_id,player)
    local warp = warp_details[warp_id]
    local surface = warp.surface
    local position = {
        x=warp.position.x+0.5,
        y=warp.position.y+0.5
    }

    local goto_position = surface.find_non_colliding_position('character',position,32,1)
    if player.driving then player.driving = false end
    player.teleport(goto_position,surface)
end

return Warps