--- Gui structure define for center gui frames
--[[
>>>> Functions
    CenterFrames.get_flow(player) --- Gets the center flow for a player
    CenterFrames.clear_flow(player) --- Clears the center flow for a player
    CenterFrames.draw_frame(player,name) --- Draws the center frame for a player, if already open then will do nothing
    CenterFrames.redraw_frame(player,name) --- Draws the center frame for a player, if already open then will destroy it and redraw
    CenterFrames.toggle_frame(player,name,state) --- Toggles if the frame is currently open or not, will open if closed and close if open

    CenterFrames.new_frame(permision_name) --- Sets the frame to be the current active gui when opened and closes all other frames
    CenterFrames._prototype:set_auto_focus(state) --- Sets the frame to be the current active gui when opened and closes all other frames
    CenterFrames._prototype:draw_frame(player) --- Draws this frame to the player, if already open does nothing (will call on_draw to draw to the frame)
    CenterFrames._prototype:redraw_frame(player) --- Draws this frame to the player, if already open it will remove it and redraw it (will call on_draw to draw to the frame)
    CenterFrames._prototype:toggle_frame(player) --- Toggles if the frame is open, if open it will close it and if closed it will open it
    CenterFrames._prototype:event_handler(action) --- Creates an event handler that will trigger one of its functions, use with Event.add
]]
local Gui = require 'expcore.gui.core'
local Toolbar = require 'expcore.gui.toolbar'
local Game = require 'utils.game'

local CenterFrames = {
	_prototype = Gui._prototype_factory{
		on_draw = Gui._event_factory('on_draw')
	}
}

--- Gets the center flow for a player
-- @tparam player LuapPlayer the player to get the flow for
-- @treturn LuaGuiElement the center flow
function CenterFrames.get_flow(player)
    player = Game.get_player_from_any(player)
    return player.gui.center
end

--- Clears the center flow for a player
-- @tparam player LuapPlayer the player to clear the flow for
function CenterFrames.clear_flow(player)
    local flow = CenterFrames.get_flow(player)
    flow.clear()
end

--- Draws the center frame for a player, if already open then will do nothing
-- @tparam player LuapPlayer the player that will have the frame drawn
-- @tparam name string the name of the hui that will drawn
-- @treturn LuaGuiElement the new frame that was made
function CenterFrames.draw_frame(player,name)
    local define = Gui.get_define(name,true)
    if define then
        return define:draw_frame(player)
    end
end

--- Draws the center frame for a player, if already open then will destroy it and redraw
-- @tparam player LuapPlayer the player that will have the frame drawn
-- @tparam name string the name of the hui that will drawn
-- @treturn LuaGuiElement the new frame that was made
function CenterFrames.redraw_frame(player,name)
    local define = Gui.get_define(name,true)
    if define then
        return define:draw_frame(player)
    end
end

--- Toggles if the frame is currently open or not, will open if closed and close if open
-- @tparam player LuapPlayer the player that will have the frame toggled
-- @tparam name string the name of the hui that will be toggled
-- @tparam[opt] state boolean when set will force a state for the frame
-- @treturn boolean if the frame if no open or closed
function CenterFrames.toggle_frame(player,name,state)
    local define = Gui.get_define(name,true)
    if define then
        if state == true then
            define:draw_frame(player)
            return true
        elseif state == false then
            local flow = CenterFrames.get_flow(player)
            if flow[define.name] then
                flow[define.name].destroy()
            end
            return false
        else
            return define:toggle_frame(player)
        end
    end
end

--- Creates a new center frame define
-- @tparam permision_name string the name that can be used with the permision system
-- @treturn table the new center frame define
function CenterFrames.new_frame(permision_name)
	local self = Toolbar.new_button(permision_name)

	self:on_click(function(player,element)
		self:toggle_frame(player)
	end)

    local mt = getmetatable(self)
    mt.__index = CenterFrames._prototype
	mt.__call = self.event_handler

    Gui.on_custom_close(self.name,function(event)
        local element = event.element
        if element and element.valid then element.destroy() end
    end)

	return self
end

--- Sets the frame to be the current active gui when opened and closes all other frames
-- @tparam[opt=true] state boolean when true will auto close other frames and set this frame as player.opened
function CenterFrames._prototype:set_auto_focus(state)
    if state == false then
        self.auto_focus = false
    else
        self.auto_focus = true
    end
end

--- Draws this frame to the player, if already open does nothing (will call on_draw to draw to the frame)
-- @tparam player LuaPlayer the player to draw the frame for
-- @treturn LuaGuiElement the new frame that was drawn
function CenterFrames._prototype:draw_frame(player)
    player = Game.get_player_from_any(player)
    local flow = CenterFrames.get_flow(player)

    if flow[self.name] then
        return flow[self.name]
    end

    if self.auto_focus then
        flow.clear()
    end

    local frame = flow.add{
        type='frame',
        name=self.name
    }

    if self.auto_focus then
        player.opened = frame
    end

    if self.events.on_draw then
        self.events.on_draw(player,frame)
    end

    return frame
end

--- Draws this frame to the player, if already open it will remove it and redraw it (will call on_draw to draw to the frame)
-- @tparam player LuaPlayer the player to draw the frame for
-- @treturn LuaGuiElement the new frame that was drawn
function CenterFrames._prototype:redraw_frame(player)
    player = Game.get_player_from_any(player)
    local flow = CenterFrames.get_flow(player)

    if flow[self.name] then
        flow[self.name].destroy()
    end

    return self:draw_frame(player)
end

--- Toggles if the frame is open, if open it will close it and if closed it will open it
-- @tparam player LuaPlayer the player to draw the frame for
-- @treturn boolean with the gui frame is now open
function CenterFrames._prototype:toggle_frame(player)
    player = Game.get_player_from_any(player)
    local flow = CenterFrames.get_flow(player)

    if flow[self.name] then
        flow[self.name].destroy()
        return false
    else
        self:draw_frame(player)
        return true
    end
end

--- Creates an event handler that will trigger one of its functions, use with Event.add
-- @tparam[opt=update] action string the action to take on this event
function CenterFrames._prototype:event_handler(action)
    action = action or 'update'
    return function(event)
        local player = Game.get_player_by_index(event.player_index)
        self[action](self,player)
    end
end

return CenterFrames