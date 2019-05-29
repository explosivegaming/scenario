--- Gui structure define for left frames
--[[
>>>> Example formating

    -- first we add config that relates to the button on the toolbar, all normal button functions are present
    local left_frame =
    Gui.new_left_frame('test-left-frame')
    :set_caption('Test Left Gui')
    :set_post_authenticator(function(player,button_name)
        return global.show_test_gui
    end)

    -- then we add the config for the left frame, on_draw should draw the gui from an empty frame, on_update should take a frame from on_draw on edit it
    :set_open_by_default()
    :on_draw(function(_player,frame)
        for _,player in pairs(game.connected_players) do
            frame.add{
                type='label',
                caption=player.name
            }
        end
    end)

    -- now we can use the action factory to call events on the gui, actions are: 'update', 'update_all', 'redraw', 'redraw_all'
    Event.add(defines.events.on_player_joined_game,left_frame 'update_all')
    Event.add(defines.events.on_player_left_game,left_frame 'update_all')

>>>> Functions
    LeftFrames.get_flow(player) --- Gets the left frame flow for a player
    LeftFrames.get_frame(name,player) --- Gets one frame from the left flow by its name
    LeftFrames.get_open(player) --- Gets all open frames for a player, if non are open it will remove the close all button
    LeftFrames.toggle_frame(name,player,state) --- Toggles the visiblty of a left frame, or sets its visiblty state

    LeftFrames.new_frame(permision_name) --- Creates a new left frame define
    LeftFrames._prototype:set_open_by_default(state) --- Sets if the frame is visible when a player joins, can also be a function to return a boolean
    LeftFrames._prototype:set_direction(direction) --- Sets the direction of the frame, either vertical or horizontal
    LeftFrames._prototype:get_frame(player) --- Gets the frame for this define from the left frame flow
    LeftFrames._prototype:is_open(player) --- Returns if the player currently has this define visible
    LeftFrames._prototype:toggle(player) --- Toggles the visiblty of the left frame

    LeftFrames._prototype:update(player) --- Updates the contents of the left frame, first tries update callback, oter wise will clear and redraw
    LeftFrames._prototype:update_all(update_offline) --- Updates the frame for all players, see update
    LeftFrames._prototype:redraw(player) --- Redraws the frame by calling on_draw, will always clear the frame
    LeftFrames._prototype:redraw_all(update_offline) --- Redraws the frame for all players, see redraw

    LeftFrames._prototype:on_draw(player,frame) --- Use to draw your elements to the new frame
    LeftFrames._prototype:on_update(player,frame) --- Use to edit your frame when there is no need to redraw it
    LeftFrames._prototype:event_handler(action) --- Creates an event handler that will trigger one of its functions, use with Event.add
]]
local Gui = require 'expcore.gui.core'
local Toolbar = require 'expcore.gui.toolbar'
local Buttons = require 'expcore.gui.buttons'
local mod_gui = require 'mod-gui'
local Game = require 'utils.game'
local Event = require 'utils.event'

local LeftFrames = {
    frames={},
    _prototype=Gui._prototype_factory{
        on_draw = Gui._event_factory('on_draw'),
        on_update = Gui._event_factory('on_update')
    }
}
setmetatable(LeftFrames._prototype, {
    __index = Buttons._prototype
})

--- Gets the left frame flow for a player
-- @tparam LuaPlayer player the player to get the flow of
-- @treturn LuaGuiElement the left frame flow for the player
function LeftFrames.get_flow(player)
    player = Game.get_player_from_any(player)
    return mod_gui.get_frame_flow(player)
end

--- Gets one frame from the left flow by its name
-- @tparam string name the name of the gui frame to get
-- @tparam LuaPlayer player the player to get the frame of
-- @treturn LuaGuiElement the frame in the left frame flow with that name
function LeftFrames.get_frame(name,player)
    local define = LeftFrames.frames[name]
    if not define then
        return error('Left Frame '..name..' is not defined.',2)
    end
    return define:get_frame(player)
end

--- Gets all open frames for a player, if non are open it will remove the close all button
-- @tparam LuaPlayer player the player to get the flow of
-- @treturn table contains all the open (and registered) frames for the player
function LeftFrames.get_open(player)
    local open = {}
    local flow = LeftFrames.get_flow(player)

    for _,define in pairs(LeftFrames.frames) do
        if define:is_open(player) then
            table.insert(open,define)
        end
    end

    flow[LeftFrames.toggle_button.name].visible = #open ~= 0

    return open
end

--- Toggles the visiblty of a left frame, or sets its visiblty state
-- @tparam string name the name of the gui frame to toggle
-- @tparam LuaPlayer player the player to get the frame of
-- @tparam[opt] boolean state when given will be the state that the visiblty is set to
-- @treturn boolean the new state of the visiblity
function LeftFrames.toggle_frame(name,player,state)
    local define = LeftFrames.frames[name]
    if not define then
        return error('Left Frame '..name..' is not defined.',2)
    end

    local frame = LeftFrames.get_frame(name,player)
    if state ~= nil then
        frame.visible = state
    else
        Gui.toggle_visible(frame)
    end

    LeftFrames.get_open(player)

    return frame.visible
end

--- Creates a new left frame define
-- @tparam string permision_name the name that can be used with the permision system
-- @treturn table the new left frame define
function LeftFrames.new_frame(permision_name)

    local self = Toolbar.new_button(permision_name)

    local mt = getmetatable(self)
    mt.__index = LeftFrames._prototype
    mt.__call = self.event_handler

    self:on_click(function(player,_element)
        self:toggle(player)
    end)

    LeftFrames.frames[self.name] = self

    return self
end

--- Sets if the frame is visible when a player joins, can also be a function to return a boolean
-- @tparam[opt=true] ?boolean|function state the default state of the visiblty, can be a function
-- state param - player LuaPlayer - the player that has joined the game
-- state param - define_name string - the define name for the frame
-- state return - boolean - false will hide the frame
function LeftFrames._prototype:set_open_by_default(state)
    if state == false then
        self.open_by_default = false
    elseif state == nil then
        self.open_by_default = true
    else
        self.open_by_default = state
    end
    return self
end

--- Sets the direction of the frame, either vertical or horizontal
-- @tparam string direction the direction to have the elements be added to thef frame
function LeftFrames._prototype:set_direction(direction)
    self.direction = direction
    return self
end

--- Gets the frame for this define from the left frame flow
-- @tparam LuaPlayer player the player to get the frame of
-- @treturn LuaGuiElement the frame in the left frame flow for this define
function LeftFrames._prototype:get_frame(player)
    local flow = LeftFrames.get_flow(player)
    if flow[self.name..'-frame'] and flow[self.name..'-frame'].valid then
        return flow[self.name..'-frame']
    end
end

--- Returns if the player currently has this define visible
-- @tparam LuaPlayer player the player to get the frame of
-- @treturn boolean true if it is open/visible
function LeftFrames._prototype:is_open(player)
    local frame = self:get_frame(player)
    return frame and frame.visible or false
end

--- Toggles the visiblty of the left frame
-- @tparam LuaPlayer player the player to toggle the frame of
-- @treturn boolean the new state of the visiblity
function LeftFrames._prototype:toggle(player)
    local frame = self:get_frame(player)
    Gui.toggle_visible(frame)
    LeftFrames.get_open(player)
    return frame.visible
end

--- Updates the contents of the left frame, first tries update callback, oter wise will clear and redraw
-- @tparam LuaPlayer player the player to update the frame of
function LeftFrames._prototype:update(player)
    local frame = self:get_frame(player)
    if self.events.on_update then
        self.events.on_update(player,frame)
    elseif self.events.on_draw then
        frame.clear()
        self.events.on_draw(player,frame)
    end
end

--- Updates the frame for all players, see update
-- @tparam[opt=false] boolean update_offline when true will update the frame for offline players
function LeftFrames._prototype:update_all(update_offline)
    local players = update_offline == true and game.players or game.connected_players
    for _,player in pairs(players) do
        self:update(player)
    end
end

--- Redraws the frame by calling on_draw, will always clear the frame
-- @tparam LuaPlayer player the player to update the frame of
function LeftFrames._prototype:redraw(player)
    local frame = self:get_frame(player)
    frame.clear()
    if self.events.on_draw then
        self.events.on_draw(player,frame)
    end
end

--- Redraws the frame for all players, see redraw
-- @tparam[opt=false] boolean update_offline when true will update the frame for offline players
function LeftFrames._prototype:redraw_all(update_offline)
    local players = update_offline == true and game.players or game.connected_players
    for _,player in pairs(players) do
        self:redraw(player)
    end
end

--- Creates an event handler that will trigger one of its functions, use with Event.add
-- @tparam[opt=update] string action the action to take on this event
function LeftFrames._prototype:event_handler(action)
    action = action or 'update'
    return function(event)
        local player
        if event and event.player_index then
            player = Game.get_player_by_index(event.player_index)
        end
        self[action](self,player)
    end
end

LeftFrames.toggle_button =
Buttons.new_button()
:set_tooltip{'expcore-gui.left-button-tooltip'}
:set_caption('<')
:on_click(function(player,element)
    for _,define in pairs(LeftFrames.frames) do
        local frame = LeftFrames.get_frame(define.name,player)
        frame.visible = false
    end
    element.visible = false
end)

Event.add(defines.events.on_player_created,function(event)
    local player = Game.get_player_by_index(event.player_index)
    local flow = LeftFrames.get_flow(player)

    local close_button = LeftFrames.toggle_button(flow)
    Gui.set_padding(close_button)
    local style = close_button.style
    style.width = 18
    style.height = 36
    style.font = 'default-small-bold'

    for _,define in pairs(LeftFrames.frames) do
        local frame = flow.add{
            type='frame',
            name=define.name..'-frame',
            direction=define.direction
        }

        if define.events.on_draw then
            define.events.on_draw(player,frame)
        end

        if not define.open_by_default then
            frame.visible = false
        elseif type(define.open_by_default) == 'function' then
            if not define.open_by_default(player,define.name) then
                frame.visible = false
            end
        end

        if not Toolbar.allowed(player,define.name) then
            frame.visible = false
        end

    end

    LeftFrames.get_open(player)
end)

return LeftFrames