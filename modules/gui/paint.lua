--[[-- Gui Module - Paint
    - Adds a window to select wich color concrete to place down
    @gui Paint
    @alias paint
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Global = require 'utils.global' --- @dep utils.global
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.gui.paint' --- @dep config.gui.paint

local paint_container

--- Table that stores a boolean value of weather to keep the warp gui open
local paint = {}
Global.register(paint, function(tbl)
    paint = tbl
end)

local function update_active_button(player, from_tile_name, to_tile_name)
  local frame = Gui.get_left_element(player, paint_container)
  local colors = frame.container.scroll.table
  if from_tile_name then
    -- Set the old active tile button to deactive
    colors[from_tile_name].children[1].style = 'slot_button'
    colors[from_tile_name].children[1].style.height = 32
    colors[from_tile_name].children[1].style.width = 32
  end
  if to_tile_name then
    -- Set the new active tile button to active
    colors[to_tile_name].children[1].style = 'yellow_slot_button'
    colors[to_tile_name].children[1].style.height = 32
    colors[to_tile_name].children[1].style.width = 32
  end
end

local paint_tile =
Gui.element(function(event_trigger, parent, tile)
    local flow = parent.add{
      type = 'flow',
      name = tile.name
    }
    -- Draw the element
    return flow.add{
        name = event_trigger,
        type = 'sprite-button',
        sprite = 'tile/'..tile.name,
        tooltip = {'paint.tile-tooltip', '[img=tile/'..tile.name..']'},
        style = 'slot_button'
    }
end)
:style({ height = 32, width = 32, left_margin = 0, padding = 0 })
:on_click(function(player, element, _)
  local tile_name = element.parent.name
  local active = paint[player.name].active
  -- Check if the active tile is equal to clicked tile
  if active == tile_name then return end
  update_active_button(player, active, tile_name)
  paint[player.name].active = tile_name
end)

--- Main paint container for the left flow
-- @element paint_container
paint_container =
Gui.element(function(event_trigger, parent)
    -- Draw the internal container
    local container = Gui.container(parent, event_trigger, 200)

    -- Draw the header
    Gui.header(
        container,
        {'paint.main-caption'},
        {'paint.main-tooltip'},
        true
    )

    local colors = Gui.scroll_table(container, 250, 6)

    for _, tile in pairs(game.tile_prototypes) do
      local name = tile.name
      if string.find(name, config.default_tile_find) then
        paint_tile(colors, tile)
      end
    end

    return container.parent
end)
:add_to_left_flow()

--- Button on the top flow used to toggle the Paint container
-- @element paint_toggle
Gui.left_toolbar_button(config.default_icon, {'paint.main-tooltip'}, paint_container, function(player)
  return Roles.player_allowed(player, 'gui/paint')
end)

--- When a player is created make sure that the active element is set
Event.add(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  paint[player.name] = { active = config.default_tile, eraser = false}
  update_active_button(player, nil, config.default_tile)
end)

Event.add(defines.events.on_player_built_tile, function(event)
  local player = game.players[event.player_index]
  local placed_tile = event.tile

  local active = paint[player.name].active
  local eraser = paint[player.name].eraser
  -- Is mode eraser
  if eraser or placed_tile.name == active or not string.find(placed_tile.name, config.default_tile_find) then
    -- Tiles that were below placed tiles
    local tiles = event.tiles
    -- New tiles to place
    local new_tiles = {}
    -- Surface that the tiles are placed on
    local surface = game.surfaces[event.surface_index]
    local count = 0
    for _, tile in pairs(tiles) do
      local name = tile.old_tile.name
      if not string.find(name, config.default_tile_find) then goto eraser end
      local ft = surface.find_entity('tutorial-flying-text', tile.position)
      -- Check if a entity has been found
      if not ft or ft.active == true then goto eraser end
      -- Add a new tile to set to the
      count = count + 1
      new_tiles[count] = { name = ft.text, position = tile.position}

      if placed_tile.name == config.default_tile then
        player.insert{name = config.default_tile, count = 2}
      else
        player.insert{name = config.default_tile, count = 1}
        player.insert{name = placed_tile.items_to_place_this[1].name, count = 1}
      end
      ft.destroy()
      ::eraser::
    end
    surface.set_tiles(new_tiles)
    return
  end
  -- Is not mode eraser
  if not placed_tile.name == config.default_tile then return end
  if active == config.default_tile then return end

  -- Tiles that were below placed tiles
  local tiles = event.tiles
  -- New tiles to place
  local new_tiles = {}
  -- Surface that the tiles are placed on
  local surface = game.surfaces[event.surface_index]
  -- Amount of concrete to give back to the player after
  local give_back = 0
  -- Loop over old positions to create a new tiles array
  for key, tile in pairs(tiles) do
    local name = tile.old_tile.name
    -- If the tile already on the ground is not one of the concrete
    if not string.find(name, config.default_tile_find) then
      -- Get the tile to look if there is a hidden tile (used for when there you're placing for example stone-path)
      local lt = surface.get_tile(tile.position)
      local text = (lt and lt.hidden_tile) or name
      local ft = surface.create_entity { name = 'tutorial-flying-text', position = tile.position, text = text }
      ft.active = false
      ft.render_to_forces = {"enemy"}
    else
      give_back = give_back + 1
    end
    new_tiles[key] = { name = active, position = tile.position }
    -- ::continue::
  end
  surface.set_tiles(new_tiles)
  if give_back > 0 then
    player.insert{ name = config.default_tile, count = give_back}
  end
end)