--- Gui structure define for center gui frames
--[[
>>>> Functions
    CenterFrames.get_flow(player) --- Gets the center flow for a player
    CenterFrames.clear_flow(player) --- Clears the center flow for a player
    CenterFrames.draw_frame(player,name) --- Draws the center frame for a player, if already open then will do nothing
    CenterFrames.redraw_frame(player,name) --- Draws the center frame for a player, if already open then will destroy it and redraw
    CenterFrames.toggle_frame(player,name,state) --- Toggles if the frame is currently open or not, will open if closed and close if open

    CenterFrames.new_frame(permission_name) --- Sets the frame to be the current active gui when opened and closes all other frames
    CenterFrames._prototype:on_draw(player,frame) --- Use to draw your elements onto the new frame
    CenterFrames._prototype:set_auto_focus(state) --- Sets the frame to be the current active gui when opened and closes all other frames
    CenterFrames._prototype:draw_frame(player) --- Draws this frame to the player, if already open does nothing (will call on_draw to draw to the frame)
    CenterFrames._prototype:redraw_frame(player) --- Draws this frame to the player, if already open it will remove it and redraw it (will call on_draw to draw to the frame)
    CenterFrames._prototype:toggle_frame(player) --- Toggles if the frame is open, if open it will close it and if closed it will open it
    CenterFrames._prototype:event_handler(action) --- Creates an event handler that will trigger one of its functions, use with Event.add
]]
local Gui = require 'expcore.gui.core' --- @dep expcore.gui.core
local Prototype = require 'expcore.gui.prototype' --- @dep expcore.gui.prototype
local Toolbar = require 'expcore.gui.concepts.toolbar' --- @dep expcore.gui.concepts.toolbar
local Game = require 'utils.game' --- @dep utils.game

local CenterFrames = {
	_prototype = Prototype.extend{
		on_creation = Prototype.event
	}
}

--- Gets the center flow for a player
-- @tparam LuaPlayer player the player to get the flow for
-- @treturn LuaGuiElement the center flow
function CenterFrames.get_flow(player)
    player = Game.get_player_from_any(player)
    return player.gui.center
end

--- Clears the center flow for a player
-- @tparam LuaPlayer player the player to clear the flow for
function CenterFrames.clear_flow(player)
    local flow = CenterFrames.get_flow(player)
    flow.clear()
end

--- Draws the center frame for a player, if already open then will do nothing
-- @tparam LuaPlayer player the player that will have the frame drawn
-- @tparam string name the name of the hui that will drawn
-- @treturn LuaGuiElement the new frame that was made
function CenterFrames.draw_frame(player,name)
    local define = Gui.get_define(name,true)
    if define then
        return define:draw_frame(player)
    end
end

--- Draws the center frame for a player, if already open then will destroy it and redraw
-- @tparam LuaPlayer player the player that will have the frame drawn
-- @tparam string name the name of the hui that will drawn
-- @treturn LuaGuiElement the new frame that was made
function CenterFrames.redraw_frame(player,name)
    local define = Gui.get_define(name,true)
    if define then
        return define:draw_frame(player)
    end
end

--- Toggles if the frame is currently open or not, will open if closed and close if open
-- @tparam LuaPlayer player the player that will have the frame toggled
-- @tparam string name the name of the hui that will be toggled
-- @tparam[opt] boolean state when set will force a state for the frame
-- @treturn boolean if the frame if no open or closed
function CenterFrames.toggle_frame(player,name,state)
    local define = Gui.get_define(name,true)
    if define then
        if state == true then
            define:draw_frame(player)
            return true
        elseif state == false then
            local flow = CenterFrames.get_flow(player)
            if flow[define.name..'-frame'] then
                flow[define.name..'-frame'].destroy()
            end
            return false
        else
            return define:toggle_frame(player)
        end
    end
end

--- Creates a new center frame define
-- @tparam string permission_name the name that can be used with the permission system
-- @treturn table the new center frame define
function CenterFrames.new_frame(permission_name)
	local self = Toolbar.new_button(permission_name)

	self:on_click(function(player,element)
		self:toggle_frame(player)
	end)

    local mt = getmetatable(self)
    mt.__index = CenterFrames._prototype
	mt.__call = self.event_handler

    Gui.on_custom_close(self.name..'-frame',function(event)
        local element = event.element
        if element and element.valid then element.destroy() end
    end)

	return self
end

--- Sets the frame to be the current active gui when opened and closes all other frames
-- @tparam[opt=true] boolean state when true will auto close other frames and set this frame as player.opened
function CenterFrames._prototype:set_auto_focus(state)
    if state == false then
        self.auto_focus = false
    else
        self.auto_focus = true
    end
end

--- Draws this frame to the player, if already open does nothing (will call on_draw to draw to the frame)
-- @tparam LuaPlayer player the player to draw the frame for
-- @treturn LuaGuiElement the new frame that was drawn
function CenterFrames._prototype:draw_frame(player)
    player = Game.get_player_from_any(player)
    local flow = CenterFrames.get_flow(player)

    if flow[self.name..'-frame'] then
        return flow[self.name..'-frame']
    end

    if self.auto_focus then
        flow.clear()
    end

    local frame = flow.add{
        type='frame',
        name=self.name..'-frame'
    }

    if self.auto_focus then
        player.opened = frame
    end

    self:raise_event('on_creation',player,frame)

    return frame
end

--- Draws this frame to the player, if already open it will remove it and redraw it (will call on_draw to draw to the frame)
-- @tparam LuaPlayer player the player to draw the frame for
-- @treturn LuaGuiElement the new frame that was drawn
function CenterFrames._prototype:redraw_frame(player)
    player = Game.get_player_from_any(player)
    local flow = CenterFrames.get_flow(player)

    if flow[self.name..'-frame'] then
        flow[self.name..'-frame'].destroy()
    end

    return self:draw_frame(player)
end

--- Toggles if the frame is open, if open it will close it and if closed it will open it
-- @tparam LuaPlayer player the player to draw the frame for
-- @treturn boolean with the gui frame is now open
function CenterFrames._prototype:toggle_frame(player)
    player = Game.get_player_from_any(player)
    local flow = CenterFrames.get_flow(player)

    if flow[self.name..'-frame'] then
        flow[self.name..'-frame'].destroy()
        return false
    else
        self:draw_frame(player)
        return true
    end
end

--- Creates an event handler that will trigger one of its functions, use with Event.add
-- @tparam[opt=update] string action the action to take on this event
function CenterFrames._prototype:event_handler(action)
    action = action or 'update'
    return function(event)
        local player = Game.get_player_by_index(event.player_index)
        self[action](self,player)
    end
end

return CenterFrames