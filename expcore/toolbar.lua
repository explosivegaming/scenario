--[[-- Core Module - Toolbar
    @core Toolbar
    @alias Toolbar
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local Game = require 'utils.game' --- @dep utils.game
local mod_gui = require 'mod-gui' --- @dep mod-gui

Gui.require_concept('button') --- @dep Gui.concept.button

local toolbar_toggle_concept
local toolbar_hide_concept
local toolbar_concept
local Toolbar = {
    button_concepts = {},
    frame_concepts = {},
    permissions = {}
}

Gui.Toolbar = Toolbar

--- Permissions.
-- Functions to do with deciding which player can do what
-- @section permissions

--[[-- Used to test if a player is allowed to use a button on the toolbar, if you are not using expcore.roles then change this function
@tparam LuaPlayer player the player you want ot test is allowed to use this button
@tparam string concept_name the name of the button concept that you want to see if the player is allowed to use
@treturn boolean true if the player is allowed to use it
@usage-- Test if a player can use 'test-player-list'
local allowed = Toolbar.allowed(game.player,'test-player-list')
]]
function Toolbar.allowed(player,concept_name)
    local permission = Toolbar.permissions[concept_name] or concept_name
    return Roles.player_allowed(player,permission)
end

--[[-- Use to add an alias for the allowed test, alias is what is tested for rather than the concept name
@tparam string concept_name the name of the concept that will point to this alias
@tparam string alias the permission string that will be tested when this concept is used with Toolbar.allowed
@usage-- Adding an alias for the 'test-player-list' concept
Toolbar.set_permission_alias('test-player-list','gui/player-list')
]]
function Toolbar.set_permission_alias(concept_name,alias)
    Toolbar.permissions[concept_name] = alias
end

--- Buttons.
-- All function to do with the toolbar buttons
-- @section buttons

--[[-- Adds a concept to be drawn to the button area and allows it to be toggled with the toggle toolbar button
@tparam table concept the gui concept that you want to add to the button area
@usage-- Adding a basic button to the toolbar
local new_button =
Gui.new_concept('button')
:set_caption('Click Me')
:on_click(function(event)
    event.player.print('You Clicked Me!!')
end)

Toolbar.add_button_concept(new_button)
]]
function Toolbar.add_button_concept(concept)
    local concepts = Toolbar.button_concepts
    concepts[#concepts+1] = concept
end

--[[-- Updates all the buttons for a player, this means hide and show buttons based on permissions
@tparam LuaPlayer player the player to update the toolbar buttons for
@usage-- Updating your toolbar
Toolbar.update_buttons(player)
]]
function Toolbar.update_buttons(player)
    toolbar_concept:raise_event('on_button_update',{
        player_index = player.index
    })
end

--[[-- Returns an array of buttons names that the given player is able to see, returns none if toolbar hidden
@tparam LuaPlayer player the player you want to get the visible buttons of
@treturn table an array of names of the visible buttons
@usage-- Get a list of all your visible buttons
Toolbar.get_visible_buttons(game.player)
]]
function Toolbar.get_visible_buttons(player)
    local rtn = {}
    local top_flow = mod_gui.get_button_flow(player)

    for _,concept in pairs(Toolbar.button_concepts) do
        local element = top_flow[concept.name]
        if element.visible then
            rtn[#rtn+1] = element.name
        end
    end

    return rtn
end

--[[-- The base element to be used with the toolbar, others can be used but this is recomented
@element toolbar-button

@tparam string permission_alias the alias used with Toolbar.allowed

@usage-- Adding a basic button to the toolbar, note no need to call Toolbar.add_button_concept
Gui.new_concept('toolbar-button')
:set_caption('Click Me')
:on_click(function(event)
    event.player.print('You Clicked Me!!')
end)

]]
Toolbar.button =
Gui.new_concept('button')
:save_as('toolbar-button')

:new_property('permission_alias',nil,function(properties,value)
    Toolbar.set_permission_alias(properties.name,value)
end)

:define_clone(Toolbar.add_button_concept)
:define_draw(function(properties,parent,element)
    element.style = mod_gui.button_style
end)

--- Frames.
-- Functions to do with the toolbar frames
-- @section frames

--[[-- Adds a frame concept to the toolbar frame area, this will not add a button to the toolbar
@tparam table concept the gui concept that you want to add to the toolbar frame area
@usage-- Adding a basic frame to the frame area
local new_frame =
Gui.new_concept('frame')
:set_title('Test')

Toolbar.add_frame_concept(new_frame)
]]
function Toolbar.add_frame_concept(concept)
    local concepts = Toolbar.frame_concepts
    concepts[#concepts+1] = concept
end

--[[-- Hides all the frames for a player
@tparam LuaPlayer player the player to hide the frames for
@usage-- Hiding all your frames
Toolbar.hide_frames(game.player)
]]
function Toolbar.hide_frames(player)
    toolbar_concept:raise_event('on_hide_frames',{
        player_index = player.index
    })
end

--[[-- Gets an array of the names of all the visible frames for a player
@tparam LuaPlayer player the player that you want to get the visible frames of
@treturn table an array of names of the visible frames for the given player
@usage-- Get all your visible frames
Toolbar.get_visible_frames(game.player)
]]
function Toolbar.get_visible_frames(player)
    local rtn = {}
    local left_flow = mod_gui.get_frame_flow(player)

    for _,concept in pairs(Toolbar.frame_concepts) do
        local element = left_flow[concept.name..'-frame']
        if element.visible then
            rtn[#rtn+1] = element.name
        end
    end

    left_flow[toolbar_hide_concept.name].visible = #rtn > 0

    return rtn
end

--[[-- The base toolbar frame, others can be used but this is recomented
@element toolbar-frame

@param on_update fired when the frame is to have its content updated

@tparam boolean open_by_default weather the frame should be open when a player first joins
@tparam boolean use_container true by default and will place a container inside the frame for content
@tparam string direction the direction that the items in the frame are added

@usage-- Adding a basic player list
local player_list =
Gui.new_concept('toolbar-frame')
:set_permission_alias('player_list')
:set_caption('Player List')
:toggle_with_click()

:define_draw(function(properties,parent,element)
    local list_area =
    element.add{
        name = 'scroll',
        type = 'scroll-pane',
        direction = 'vertical',
        horizontal_scroll_policy = 'never',
        vertical_scroll_policy = 'auto-and-reserve-space'
    }
    Gui.set_padding(list_area,1,1,2,2)
    list_area.style.horizontally_stretchable = true
    list_area.style.maximal_height = 200

    for _,player in pairs(game.connected_players) do
        list_area.add{
            type='label',
            caption=player.name
        }
    end
end)

:on_update(function(event)
    local list_area = event.element.scroll
    list_area.clear()

    for _,player in pairs(game.connected_players) do
        list_area.add{
            type='label',
            caption=player.name
        }
    end
end)

]]
Toolbar.frame =
Gui.new_concept('toolbar-button')
:save_as('toolbar-frame')

-- Properties
:new_property('open_by_default',nil,false)
:new_property('use_container',nil,true)
:new_property('direction',nil,'horizontal')
:new_event('on_update')

-- Clone
:define_clone(function(concept)
    Toolbar.add_frame_concept(concept)
    concept:on_click(function(event)
        event.concept:toggle_visible_state(event.player)
    end)
end)

-- Draw
:define_draw(function(properties,parent,element)
    -- Add the base frame element, the button is already drawn to parent
    local player = Gui.get_player_from_element(element)
    local left_flow = mod_gui.get_frame_flow(player)
    local frame = left_flow.add{
        name = properties.name..'-frame',
        type = 'frame',
        direction = properties.direction
    }

    frame.style.padding = 2

    if properties.use_container then
        local container =
        frame.add{
            name = 'container',
            type = 'frame',
            direction = properties.direction,
            style = 'window_content_frame_packed'
        }
        Gui.set_padding(container)

        return container
    end

    return frame
end)

--[[-- Gets the content area of the frame concept for this player, each player only has one area
@tparam LuaPlayer player the player that you want to get the frame content for
@treturn LuaGuiElement the content area of this concept for this player
@usage-- Get the content area of a concept
local frame = player_list:get_content(game.player)
]]
function Toolbar.frame:get_content(player)
    local left_flow = mod_gui.get_frame_flow(player)
    local frame = left_flow[self.name..'-frame']
    return frame.container or frame
end

--[[-- Toggles the visibilty of this concept for the given player
@tparam LuaPlayer player the player that you want to toggle the frame for
@treturn boolean the new state of the visibilty of this concept for the player
@usage-- Toggle the frame for your self
player_list:toggle_visible_state(game.player)
]]
function Toolbar.frame:toggle_visible_state(player)
    local left_flow = mod_gui.get_frame_flow(player)
    local frame = left_flow[self.name..'-frame']
    if frame.visible then
        frame.visible = false
        Toolbar.get_visible_frames(player)
        return false
    else
        frame.visible = true
        Toolbar.get_visible_frames(player)
        return true
    end
end

--[[-- Gets the current visibilty state of this conept for this player
@tparam LuaPlayer player the player that you want the visibilty state for
@treturn boolean the current visiblity state of this concept to the player
@usage-- Getting the current visiblity state
player_list:get_visible_state(player)]]
function Toolbar.frame:get_visible_state(player)
    local left_flow = mod_gui.get_frame_flow(player)
    return left_flow[self.name..'-frame'].visible
end

--[[-- Triggers an update of the content within the concept for this player, uses on_update handlers
@tparam LuaPlayer player the player to update the concept content for
@tparam[opt] table event the event data that you want to pass to the update handlers
@usage-- Updating the frame for your player
player_list:update(game.player)
]]
function Toolbar.frame:update(player,event)
    event = event or {}
    event.player_index = player.index
    event.element = self:get_content(player)
    self:raise_event('on_update',event)
end

--[[-- Triggers an update of the content with in this frame for all players
@tparam[opt] table event the event data that you want to pass to the update handlers
@usage-- Update the grame for all players
player_list:update_all()
]]
function Toolbar.frame:update_all(event)
    local players = event.update_offline == true and game.players or game.connected_players
    for _,player in pairs(players) do
        self:update(player)
    end
end

--- Other Elements.
-- All the other elements that are used to make this work
-- @section elements

--[[-- The main toolbar element, draws, updates, and controls the other concepts
@element toolbar
@param on_button_update fired when the buttons are updated for a player
@param on_hide_frames fired when the frames are hidden for a player
]]
toolbar_concept =
Gui.new_concept()
:debug('toolbar')
:define_draw(function(properties,player)
    -- Get the main flows
    local top_flow = mod_gui.get_button_flow(player)
    if not top_flow then return end
    local left_flow = mod_gui.get_frame_flow(player)
    if not left_flow then return end

    -- Draw toggle buttons first
    toolbar_toggle_concept:draw(top_flow)
    toolbar_hide_concept:draw(left_flow)

    -- Draw all the buttons and frames
    local done = {}
    for _,concept in pairs(Toolbar.button_concepts) do
        done[concept.name] = true
        concept:draw(top_flow)
        top_flow[concept.name].visible = Toolbar.allowed(player,concept.name)

        local frame = left_flow[concept.name..'-frame']
        if frame then
            frame.visible = Gui.resolve_property(concept.properties.open_by_default,frame)
        end
    end

    -- Draws frames that did not have buttons
    for _,concept in pairs(Toolbar.frame_concepts) do
        if not done[concept.name] then
            concept:draw(left_flow)
            local frame = left_flow[concept.name..'-frame']
            if frame then
                frame.visible = Gui.resolve_property(concept.properties.open_by_default,frame)
            end
        end
    end

    -- Toggle the clear toobar if needed
    Toolbar.get_visible_frames(player)

end)

-- When the buttons are updated
:new_event('on_button_update')
:on_button_update(function(event)
    -- Get the top flow
    local player = event.player
    local top_flow = mod_gui.get_button_flow(player)
    if not top_flow then return end

    -- Set the visiblity of the elements
    local visible = top_flow[toolbar_toggle_concept.name].caption == '<'
    for _,concept in pairs(Toolbar.button_concepts) do
        local element = top_flow[concept.name]
        if Gui.valid(element) then
            element.visible = visible and Toolbar.allowed(player,concept.name)
        end
    end

end)

-- When frames are hidden
:new_event('on_hide_frames')
:on_hide_frames(function(event)
    -- Get the left flow
    local player = event.player
    local left_flow = mod_gui.get_frame_flow(player)
    if not left_flow then return end

    -- Set the visiblity of the elements
    left_flow[toolbar_hide_concept.name].visible = false
    for _,concept in pairs(Toolbar.frame_concepts) do
        local element = left_flow[concept.name..'-frame']
        if Gui.valid(element) then element.visible = false end
    end
end)

--- Used so toggle and hide can have the same look as each other
local function toolbar_button_draw(properties,parent,element)
    element.style = mod_gui.button_style
    local style = element.style
    style.width = 18
    style.height = 36
    style.padding = 0
    style.left_padding = 1
    style.font = 'default-small-bold'
end

--[[-- Button which toggles the the visible state of all toolbar buttons, triggers on_button_update
@element toolbar-toggle
]]
toolbar_toggle_concept =
Gui.new_concept('button')
:set_caption('<')
:set_tooltip{'gui_util.button_tooltip'}
:define_draw(toolbar_button_draw)
:on_click(function(event)
    local element = event.element
    element.caption = element.caption == '<' and '>' or '<'
    toolbar_concept:raise_event('on_button_update',{
        player_index = event.player_index
    })
end)

--[[-- Button which hides all visible toolbar frames, triggers on_hide_frames
@element toolbar-clear
]]
toolbar_hide_concept =
Gui.new_concept('button')
:set_caption('<')
:set_tooltip{'expcore-gui.left-button-tooltip'}
:define_draw(toolbar_button_draw)
:on_click(function(event)
    event.element.visible = false
    toolbar_concept:raise_event('on_hide_frames',{
        player_index = event.player_index
    })
end)

--- When there is a new player they will have the toolbar update
Event.add(defines.events.on_player_created,function(event)
    local player = Game.get_player_by_index(event.player_index)
    toolbar_concept:draw(player)
end)

--- When a player gets a new role they will have the toolbar updated
Event.add(Roles.events.on_role_assigned,function(event)
    toolbar_concept:raise_event('on_button_update',{
        player_index = event.player_index
    })
end)

--- When a player loses a role they will have the toolbar updated
Event.add(Roles.events.on_role_unassigned,function(event)
    toolbar_concept:raise_event('on_button_update',{
        player_index = event.player_index
    })
end)

return Toolbar