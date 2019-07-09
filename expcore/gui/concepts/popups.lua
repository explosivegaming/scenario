--- Gui structure define for popup gui
--[[
>>>> Functions
    PopupFrames.get_flow(player) --- Gets the left flow that contains the popup frames
    PopupFrames.open(define_name,player,open_time,...) --- Opens a popup for the player, can give the amount of time it is open as well as params for the draw function

    PopupFrames.close_progress --- Progress bar which when depleted will close the popup frame
    PopupFrames.close_button --- A button which can be used to close the gui before the timer runs out

    PopupFrames.new_popup(name) --- Creates a new popup frame define
    PopupFrames._prototype:set_default_open_time(amount) --- Sets the default open time for the popup, will be used if non is provided with open
    PopupFrames._prototype:open(player,open_time,...) --- Opens this define for a player, can be given open time and any other params for the draw function
]]
local Gui = require 'expcore.gui.core'
local Prototype = require 'expcore.gui.prototype'
local Game = require 'utils.game'
local Event = require 'utils.event'
local ProgressBar = require 'expcore.gui.elements.progress-bar'
local Button = require 'expcore.gui.elements.buttons'
local mod_gui = require 'mod-gui'
local Color = require 'resources.color_presets'
local Global = require 'utils.global'

local PopupFrames = {
    paused_popups={},
	popup_flow_name = Gui.uid_name(),
	main_frame_name = Gui.uid_name(),
	close_frame_name = Gui.uid_name(),
	_prototype = Prototype.extend{
		on_creation = Prototype.event
	}
}
Global.register(PopupFrames.paused_popups,function(tbl)
    PopupFrames.paused_popups = tbl
end)

--- Sets the state of the element in the paused list, nil or true
-- @tparam LuaGuiElement element the element to set the state of
-- @tparam[opt] boolean state the state to set it to, true will pause the the progress bar
local function set_paused_state(element,state)
    local name = element.player_index..':'..element.index
    PopupFrames.paused_popups[name] = state
end

--- Gets the state of the element in the paused list, nil or true
-- @tparam LuaGuiElement element the element to get the state of
local function get_paused_state(element)
    local name = element.player_index..':'..element.index
    return PopupFrames.paused_popups[name]
end

--- Gets the left flow that contains the popup frames
-- @tparam LuaPlayer player the player to get the flow for
-- @treturn LuaGuiElement the left flow that contains the popup frames
function PopupFrames.get_flow(player)
    player = Game.get_player_from_any(player)
    local flow = mod_gui.get_frame_flow(player)
	return flow[PopupFrames.popup_flow_name]
end

--- Opens a popup for the player, can give the amount of time it is open as well as params for the draw function
-- @tparam string define_name the name of the define that you want to open for the player
-- @tparam LuaPlayer player the player to open the popup for
-- @tparam[opt] number open_time the minimum number of ticks you want the popup open for, 0 means no limit, nil will take default
-- @tparam any ... the other params that you want to pass to your on_draw event
-- @treturn LuaGuiElement the frame that was drawn, the inner gui flow which contains the content
function PopupFrames.open(define_name,player,open_time,...)
    local define = Gui.get_define(define_name,true)
    player = Game.get_player_from_any(player)
    return define:open(player,open_time,...)
end

--- Closes the popup, is called by progress bar and close button
-- @tparam LuaGuiElement element either the progress bar or the close button
local function close_popup(element)
	local frame = element.parent.parent.parent
    if not frame or not frame.valid then return end
    set_paused_state(element.parent[PopupFrames.close_progress:uid()])
	frame.destroy()
end

--- Progress bar which when depleted will close the popup frame
PopupFrames.close_progress =
ProgressBar.new_progressbar()
:use_count_down()
:set_tooltip('Pause/Resume Auto-close')
:on_complete(function(player,element)
	close_popup(element)
end)

--- A button which can be used to close the gui before the timer runs out
PopupFrames.close_button =
Button.new_button()
:set_sprites('utility/close_white')
:set_tooltip('Close Popup')
:on_click(function(player,element)
	close_popup(element)
end)

--- When the progress bar is clicked it will pause its progress, or resume if previously paused
Gui.on_click(PopupFrames.close_progress:uid(),function(event)
    local element = event.element
    if get_paused_state(element) then
        set_paused_state(element)
    else
        set_paused_state(element,true)
    end
end)

--- When the parent flow of the progress bar is clicked it will pause its progress, or resume if previously paused
Gui.on_click(PopupFrames.close_frame_name,function(event)
    local element = event.element[PopupFrames.close_progress:uid()]
    if get_paused_state(element) then
        set_paused_state(element)
    else
        set_paused_state(element,true)
    end
end)

--- Creates a new popup frame define
-- @tparam[opt] string name the optional debug name that can be added
-- @treturn table the new popup frame define
function PopupFrames.new_popup(name)
	local self = Gui.new_define(PopupFrames._prototype,name)
    self.draw_data.type = 'flow'
	self.draw_data.direction = 'vertical'

    local mt = getmetatable(self)
    mt.__call = function(tbl,player,open_time,...)
        return tbl:open(player,open_time,...)
    end

    self:on_draw(function(player,element,maximum,...)
        -- main content frame
		local frame = element.add{
            type='flow',
			name=PopupFrames.main_frame_name
        }
        frame.style.horizontally_stretchable = true

        -- flow for progress bar and close button
		local close_flow = element.add{
            type='flow',
			name=PopupFrames.close_frame_name
        }
        close_flow.style.horizontally_stretchable = true

        -- progress bar, when 0 then a static full one is drawn
        local progress_style
        if maximum == 0 then
            progress_style = close_flow.add{
                type='progressbar',
                tooltip='No Auto-close',
                value=1
            }.style
        else
            progress_style = PopupFrames.close_progress(close_flow,maximum).style
        end
        progress_style.top_padding = 6
        progress_style.bottom_padding = 3
        progress_style.height = 11
        progress_style.color = Color.grey

        -- close button, will close the popup when clicked
        local close_button = PopupFrames.close_button(close_flow)
        Gui.set_padding(close_button)
        local close_button_style = close_button.style
        close_button_style.width = 20
        close_button_style.height = 20

        -- event trigger to draw the gui content
        self:raise_event('on_creation',player,frame,...)
	end)

	return self
end

--- Sets the default open time for the popup, will be used if non is provided with open
-- @tparam number amount the number of ticks, by default, the popup will be open for
-- @treturn table the define to allow for chaining
function PopupFrames._prototype:set_default_open_time(amount)
	self.default_open_time = amount
	return self
end

--- Opens this define for a player, can be given open time and any other params for the draw function
-- @tparam LuaPlayer player the player to open the popup for
-- @tparam[opt] number open_time the minimum number of ticks you want the popup open for, 0 means no limit, nil will take default
-- @tparam any ... the other params that you want to pass to your on_draw event
-- @treturn LuaGuiElement the frame that was drawn, the inner gui flow which contains the content
function PopupFrames._prototype:open(player,open_time,...)
    open_time = open_time or self.default_open_time or 0
    player = Game.get_player_from_any(player)

    local flow = PopupFrames.get_flow(player)
    local frame = flow.add{
        type='frame',
        style='blurry_frame'
    }

    Gui.set_padding(frame,3,3,4,4)
    return self:draw_to(frame,open_time,...)[PopupFrames.main_frame_name]
end

--- When player is first created the popup flow is added to they left flow
Event.add(defines.events.on_player_created,function(event)
	local player = Game.get_player_by_index(event.player_index)
	local flow = mod_gui.get_frame_flow(player)

	flow.add{
		type='flow',
		direction='vertical',
		name=PopupFrames.popup_flow_name
    }
end)

--- Every tick any, not paused, progress bars will go down by one tick
Event.add(defines.events.on_tick,PopupFrames.close_progress:event_countdown(function(element)
    return not get_paused_state(element)
end))

return PopupFrames