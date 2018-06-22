--- Adds a uniform preset for guis in the center of the screen which allow for different tabs to be opened
-- @module ExpGamingCore.Gui.Center
-- @alias center
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

--- This is a submodule of ExpGamingCore.Gui but for ldoc reasons it is under its own module
-- @function _comment

local Game = require('FactorioStdLib.Game')
local Color = require('FactorioStdLib.Color')
local mod_gui = require("mod-gui")

local center = {}
center._center = {}

--- Adds a new obj to the center gui
-- @usage Gui.center.add{name='foo',caption='Foo',tooltip='Testing',draw=function}
-- @param obj contains the new object, needs name, fraw is opt and is function(root_frame)
-- @return the object made, used to add tabs
function center.add(obj)
    if not is_type(obj,'table') then return end    
    if not is_type(obj.name,'string') then return end 
    verbose('Created Center Gui: '..obj.name)
    setmetatable(obj,{__index=center._center})
    obj.tabs = {}
    obj._tabs = {}
    Gui.data('center',obj.name,obj)
    Gui.toolbar.add(obj.name,obj.caption,obj.tooltip,obj.open)
    return obj
end

--- Used to get the center frame of the player, used mainly in script
-- @usage Gui.center.get_flow(player) -- returns gui emelemt
-- @param player a player indifier to get the flow for
-- @treturn table the gui element flow
function center.get_flow(player)
    local player = Game.get_player(player)
    return player.gui.center.exp_center or player.gui.center.add{name='exp_center',type='flow'}
end

--- Used to open a center frame for a player
-- @usage Gui.center.open(player,'server-info') -- return true
-- @param player a player indifier to get the flow for
-- @tparam string center the name of the center frame to open
-- @treturn boelon based on if it successed or not
function center.open(player,center)
    local player = Game.get_player(player)
    Gui.center.clear(player)
    if not Gui.data.center[center] then return false end
    Gui.data.center[center].open{
        element={name=center},
        player_index=player.index
    }
    return true
end

--- Used to open a center frame for a player
-- @usage Gui.center.open_tab(player,'readme','rules') -- return true
-- @param player a player indifier to get the flow for
-- @tparam string center the name of the center frame to open
-- @tparam string tab the name of the tab to open
-- @treturn boelon based on if it successed or not
function center.open_tab(player,center,tab)
    local player = Game.get_player(player)
    if not Gui.center.open(player,center) then return false end
    local name = center..'_'..tab
    if not Gui.data.inputs_button[name] then return false end
    Gui.data.inputs_button[name].events[defines.events.on_gui_click]{
        element=Gui.center.get_flow(player)[center].tab_bar.tab_bar_scroll.tab_bar_scroll_flow[name],
    }
    return true
end

--- Used to clear the center frame of the player, used mainly in script
-- @usage Gui.center.clear(player)
-- @param player a player indifier to get the flow for
function center.clear(player)
    local player = Game.get_player(player)
    center.get_flow(player).clear()
end

-- used on the button press when the toolbar button is press, can be overriden
-- not recomented for direct use see Gui.center.open
function center._center.open(event)
    local player = Game.get_player(event)
    local _center = Gui.data.center[event.element.name]
    local center_flow = center.get_flow(player)
    if center_flow[_center.name] then Gui.center.clear(player) return end
    local center_frame = center_flow.add{
        name=_center.name,
        type='frame',
        caption=_center.caption,
        direction='vertical',
        style=mod_gui.frame_style
    }
    if is_type(center_frame.caption,'string') and player.gui.is_valid_sprite_path(center_frame.caption) then center_frame.caption = '' end
    if is_type(_center.draw,'function') then
        local success, err = pcall(_center.draw,_center,center_frame)
        if not success then error(err) end
    else error('No Callback on center frame '.._center.name)
    end
    player.opened=center_frame
end

-- this is the default draw function if one is not provided, can be overriden
-- not recomented for direct use see Gui.center.open
function center._center:draw(frame)
    Gui.bar(frame,510)
    local tab_bar = frame.add{
        type='frame',
        name='tab_bar',
        style='image_frame',
        direction='vertical'
    }
    tab_bar.style.width = 510
    tab_bar.style.height = 65
    local tab_bar_scroll = tab_bar.add{
        type='scroll-pane', 
        name='tab_bar_scroll', 
        horizontal_scroll_policy='auto-and-reserve-space',
        vertical_scroll_policy='never'
    }
    tab_bar_scroll.style.vertically_squashable = false
    tab_bar_scroll.style.vertically_stretchable = true
    tab_bar_scroll.style.width = 500
    local tab_bar_scroll_flow = tab_bar_scroll.add{
        type='flow', 
        name='tab_bar_scroll_flow', 
        direction='horizontal'
    }
    Gui.bar(frame,510)
    local tab = frame.add{
        type ='frame',
        name='tab',
        direction='vertical',
        style='image_frame'
    }
    tab.style.width = 510
    tab.style.height = 305
    local tab_scroll = tab.add{
        type ='scroll-pane',
        name='tab_scroll', 
        horizontal_scroll_policy='never',
        vertical_scroll_policy='auto'
    }
    tab_scroll.style.vertically_squashable = false
    tab_scroll.style.vertically_stretchable = true
    tab_scroll.style.width = 500
    local tab_scroll_flow = tab_scroll.add{
        type='flow', 
        name='tab_scroll_flow', 
        direction='vertical'
    }
    tab_scroll_flow.style.width = 480
    Gui.bar(frame,510)
    local first_tab = nil
    for name,button in pairs(self.tabs) do
        first_tab = first_tab or name
        button:draw(tab_bar_scroll_flow).style.font_color = defines.color.white
    end
    self._tabs[self.name..'_'..first_tab](tab_scroll_flow)
    tab_bar_scroll_flow.children[1].style.font_color = defines.color.orange
    frame.parent.add{type='frame',name='temp'}.destroy()--recenter the GUI
end

--- If deafult draw is used then you can add tabs to the gui with this function
-- @usage _center:add_tab('foo','Foo','Just a tab',function)
-- @tparam string name this is the name of the tab
-- @tparam string caption this is the words that appear on the tab button
-- @tparam[opt] string tooltip the tooltip that is on the button
-- @tparam function callback this is called when button is pressed with function(root_frame)
-- @return self to allow chaining of _center:add_tab
function center._center:add_tab(name,caption,tooltip,callback)
    verbose('Created Tab: '..self.name..'/'..name)
    self._tabs[self.name..'_'..name] = callback
    self.tabs[name] = Gui.inputs.add{
        type='button',
        name=self.name..'_'..name,
        caption=caption,
        tooltip=tooltip
    }:on_event('click',function(event)
        local tab = event.element.parent.parent.parent.parent.tab.tab_scroll.tab_scroll_flow
        tab.clear()
        local frame_name = tab.parent.parent.parent.name
        local _center = Gui.data.center[frame_name]
        local _tab = _center._tabs[event.element.name]
        if is_type(_tab,'function') then
            for _,button in pairs(event.element.parent.children) do
                if button.name == event.element.name then
                    button.style.font_color = defines.color.orange
                else
                    button.style.font_color = defines.color.white
                end
            end
            local success, err = pcall(_tab,tab)
            if not success then error(err) end
        end
    end)
    return self
end

-- used so that when gui close key is pressed this will close the gui
script.on_event('on_gui_closed',function(event)
    if event.element and event.element.valid then event.element.destroy() end
end)

center.on_rank_change = center.clear
return center