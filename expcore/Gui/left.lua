--- Gui structure for the toolbar (just under top left)
--[[
>>>> Example Format
    local left_gui_frame = LeftFrames.new_frame()

    LeftFrames.set_open_by_default(left_gui_frame,true)

    LeftFrames.on_update(left_gui_frame,function(frame,player)
        frame.add('Hello, World!')
    end)

>>>> Functions
    LeftFrames.get_flow(player) --- Gets the left frame flow for a player
    LeftFrames.get_open(player) --- Gets all open frames for a player, if non are open it will remove the close all button
    LeftFrames.get_frame(player,name) --- Gets one frame from the left flow by its name
    LeftFrames.toggle_frame(player,name,state) --- Toggles the visiblty of a left frame, or sets its visiblty state

    LeftFrames.new_frame(name) --- Makes a new frame that can be used with on_update and adds a toggle button to the toolbar
    LeftFrames.add_frame(define_name,permision_name) --- Similar to new_frame but using an already defined name (this will still add a button to the toolbar)

    LeftFrames.set_open_by_default(define_name,state) --- Sets if the frame is visible when a player joins, can also be a function to return a boolean
    LeftFrames.on_update(define_name,callback) --- Registeres an update function for the gui that will be used to redraw the gui (frame is cleared before call)
    LeftFrames.update(define_name,player) --- Clears the gui frame for the player and calls the update callback

    LeftFrames.update_all_frames(player) --- Clears all frames and then re-draws all frames
    LeftFrames.update_all_players(define_name,update_offline) --- Clears and returns the gui frame for all players
    LeftFrames.update_all(update_offline) --- Clears and updates all frames for all players
]]
local Gui = require 'expcore.gui.core'
local Toolbar = require 'expcore.gui.toolbar'
local Buttons = require 'expcore.gui.buttons'
local mod_gui = require 'mod-gui'
local Game = require 'utils.game'
local Event = require 'utils.event'

local LeftFrames = {
    buttons={},
    draw_functions={},
    open_by_default={}
}

--- Gets the left frame flow for a player
-- @tparam player LuaPlayer the player to get the flow of
-- @treturn LuaGuiElement the left frame flow for the player
function LeftFrames.get_flow(player)
    player = Game.get_player_from_any(player)
    return mod_gui.get_frame_flow(player)
end

--- Gets all open frames for a player, if non are open it will remove the close all button
-- @tparam player LuaPlayer the player to get the flow of
-- @treturn table contains all the open (and registered) frames for the player
function LeftFrames.get_open(player)
    local open = {}
    local flow = LeftFrames.get_flow(player)

    for _,child in pairs(flow.children) do
        if LeftFrames.buttons[child.name] then
            if child.valid and child.visible then
                table.insert(open,child)
            end
        end
    end

    flow[LeftFrames.toogle_button.name].visible = #open ~= 0

    return open
end

--- Gets one frame from the left flow by its name
-- @tparam player LuaPlayer the player to get the frame of
-- @tparam name string the name of the gui frame to get
-- @treturn LuaGuiElement the frame in the left frame flow with that name
function LeftFrames.get_frame(player,name)
    local flow = LeftFrames.get_flow(player)
    if flow[name] and flow[name].valid then
        return flow[name]
    end
end

--- Toggles the visiblty of a left frame, or sets its visiblty state
-- @tparam player LuaPlayer the player to get the frame of
-- @tparam name string the name of the gui frame to toggle
-- @tparam[opt] state boolean when given will be the state that the visiblty is set to
-- @treturn boolean the new state of the visiblity
function LeftFrames.toggle_frame(player,name,state)
    local frame = LeftFrames.get_frame(player,name)
    if state ~= nil then
        frame.visible = state
    else
        Gui.toggle_visible(frame)
    end
    LeftFrames.get_open(player)
    return frame.visible
end

--- Gets the button that was created for this left frame
-- @tparam define_name the name of the left gui frame from new_frame
-- @treturn table the define for the toggle button
function LeftFrames.get_button(define_name)
    return LeftFrames.buttons[define_name]
end

--- Makes a new frame that can be used with on_update and adds a toggle button to the toolbar
-- @tparam[opt] name string when given allows an alias to the button for the permission system
-- @treturn string the name of the left frame to be used with on_update
-- @treturn table the button define that was created
function LeftFrames.new_frame(name)
    local frame_name = Gui.uid_name()
    local button = LeftFrames.add_frame(frame_name,name)
    return frame_name, button
end

--- Similar to new_frame but using an already defined name (this will still add a button to the toolbar)
-- @tparam define_name string the name that is used to refrence this frame (like what is returned by new_frame)
-- @tparam[opt] name string when given allows an alias to the button for the permission system
-- @treturn table the button define that was created
function LeftFrames.add_frame(define_name,permision_name)
    LeftFrames.buttons[define_name] =
    Toolbar.new_button(permision_name)
    :on_click(function(player,_element)
        LeftFrames.toggle_frame(player,define_name)
    end)
    return LeftFrames.buttons[define_name]
end

--- Sets if the frame is visible when a player joins, can also be a function to return a boolean
-- @tparam define_name the name of the left gui frame from new_frame
-- @tparam[opt=true] state ?boolean|function the default state of the visiblty, can be a function
-- state param - player LuaPlayer - the player that has joined the game
-- state param - define_name string - the define name for the frame
-- state return - boolean - false will hide the frame
function LeftFrames.set_open_by_default(define_name,state)
    if not LeftFrames.buttons[define_name] then
        return error('Left frame is not registered',2)
    end

    LeftFrames.draw_functions[define_name] = state
end

--- Registeres an update function for the gui that will be used to redraw the gui (frame is cleared before call)
-- @tparam define_name the name of the left gui frame from new_frame
-- @tparam callback function the function which is called to update the gui frame
-- callback param - frame LuaGuiElement - the frame which has be cleared to have its elements redrawn
-- callback param - player LuaPlayer - the player who owns the frame
function LeftFrames.on_update(define_name,callback)
    if not LeftFrames.buttons[define_name] then
        return error('Left frame is not registered',2)
    end

    LeftFrames.draw_functions[define_name] = callback
end

--- Returns a function that can be called from a factorio event to update the frame
-- @tparam define_name string the name of the left gui frame from new_frame
-- @treturn function when this function is called it will update the frame from event.player_index
function LeftFrames.update_factory(define_name)
    if not LeftFrames.draw_functions[define_name] then
        return error('Left frame has no update callback',2)
    end

    return function(event)
        LeftFrames.update(define_name,event.player_index)
    end
end

--- Clears the gui frame for the player and calls the update callback
-- @tparam define_name the name of the left gui frame from new_frame
-- @tparam player LuaPlayer the player to update the frame for
function LeftFrames.update(define_name,player)
    player = Game.get_player_from_any(player)
    local frame = LeftFrames.get_frame(player,define_name)
    frame.clear()
    if LeftFrames.draw_functions[define_name] then
        LeftFrames.draw_functions[define_name](frame,player)
    end
end

--- Clears all frames and then re-draws all frames
-- @tparam player LuaPlayer the player to update the frames for
function LeftFrames.update_all_frames(player)
    player = Game.get_player_from_any(player)
    for define_name,draw_function in pairs(LeftFrames.draw_functions) do
        local frame = LeftFrames.get_frame(player,define_name)
        frame.clear()
        draw_function(frame,player)
    end
end

--- Clears and returns the gui frame for all players
-- @tparam define_name the name of the left gui frame from new_frame
-- @tparam[opt=false] update_offline boolean when true will also update the frame for offline players
function LeftFrames.update_all_players(define_name,update_offline)
    local players = update_offline and game.players or game.connected_players
    for _,player in pairs(players) do
        LeftFrames.update(define_name,player)
    end
end

--- Clears and updates all frames for all players
-- @tparam[opt=false] update_offline boolean when true will also update the frame for offline players
function LeftFrames.update_all(update_offline)
    local players = update_offline and game.players or game.connected_players
    for _,player in pairs(players) do
        LeftFrames.update_all_frames(player)
    end
end

LeftFrames.toogle_button =
Buttons.new_button()
:set_tooltip('Close Windows')
:set_caption('<')
:on_click(function(player,_element)
    local flow = LeftFrames.get_flow(player)

    for _,child in pairs(flow.children) do
        if LeftFrames.buttons[child.name] then
            if child.valid and child.visible then
                child.visible = false
            end
        end
    end

    _element.visible = false
end)

Event.add(defines.events.on_player_created,function(event)
    local player = Game.get_player_by_index(event.player_index)
    local flow = LeftFrames.get_flow(player)

    local style = LeftFrames.toogle_button(flow).style
    style.width = 18
    style.height = 36
    style.left_padding = 0
    style.top_padding = 0
    style.right_padding = 0
    style.bottom_padding = 0
    style.font = 'default-small-bold'

    for define_name,_ in pairs(LeftFrames.buttons) do
        local frame = flow.add{
            type='frame',
            name=define_name
        }

        if LeftFrames.draw_functions[define_name] then
            LeftFrames.draw_functions[define_name](frame,player)
        end

        if LeftFrames.open_by_default[define_name] == false then
            frame.visible = false
        elseif type(LeftFrames.open_by_default[define_name]) == 'function' then
            if not LeftFrames.open_by_default[define_name](player,define_name) then
                frame.visible = false
            end
        end

        if not Toolbar.allowed(player,define_name) then
            frame.visible = false
        end

    end

    LeftFrames.get_open(player)
end)

return LeftFrames