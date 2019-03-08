--- Adds a uniform preset for guis in the center of the screen which allow for different tabs to be opened
-- @module ExpGamingCore.Gui.center
-- @alias center
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Game = require('FactorioStdLib.Game')
local Color = require('FactorioStdLib.Color')
local Gui = require('ExpGamingCore.Gui')
local mod_gui = require('mod-gui')

local center = {}
center._prototype = {}

--- Adds a new obj to the center gui
-- @usage Gui.center.add{name='foo',caption='Foo',tooltip='Testing',draw=function}
-- @usage return_value(player) -- opens the center gui for that player
-- @param obj contains the new object, needs name, frame is opt and is function(root_frame)
-- @return the object made, used to add tabs, calling the returned value will open the center for the given player
function center.add(obj)
    if not is_type(obj,'table') then return end
    if not is_type(obj.name,'string') then return end
    verbose('Created Center Gui: '..obj.name)
    setmetatable(obj,{__index=center._prototype,__call=function(self,player,...) return center.open(player,self.name,...) end})
    obj.tabs = {}
    obj._tabs = {}
    Gui.data('center',obj.name,obj)
    if Gui.toolbar then Gui.toolbar(obj.name,obj.caption,obj.tooltip,function(event) return obj:open(event.player_index) end) end
    return obj
end

--- Used to get the center frame of the player, used mainly in script
-- @usage Gui.center.get_flow(player) -- returns gui element
-- @param player a player identifier to get the flow for
-- @treturn table the gui element flow
function center.get_flow(player)
    player = Game.get_player(player)
    if not player then error('Invalid player',2) end
    return player.gui.center.exp_center or player.gui.center.add{name='exp_center',type='flow'}
end

--- Used to open a center frame for a player, extra params are sent to open event
-- @usage Gui.center.open(player,'server-info') -- return true
-- @param player a player identifier to get the flow for
-- @tparam string center_name the name of the center frame to open
-- @treturn boolean based on if it succeeded or not
function center.open(player,center_name,...)
    player = Game.get_player(player)
    if not player then error('Invalid player',2) return false end
    Gui.center.clear(player)
    if not Gui.data.center[center_name] then return false end
    local self = Gui.data.center[center_name]
    -- this function is the draw function passed to the open event
    self:open(player,function(...) Gui.center._draw(self,...) end,...)
    return true
end

-- used as a piece of middle ware for the open event
function center._draw(self,frame,...)
    game.players[frame.player_index].opened=frame
    if is_type(self.draw,'function') then
        local success, err = pcall(self.draw,self,frame,...)
        if not success then error(err) end
    else error('No Callback on center frame '..self.name) end 
end

--- Used to open a center frame for a player
-- @usage Gui.center.open_tab(player,'readme','rules') -- return true
-- @param player a player identifier to get the flow for
-- @tparam string center the name of the center frame to open
-- @tparam string tab the name of the tab to open
-- @treturn boolean based on if it succeeded or not
function center.open_tab(player,center_name,tab)
    player = Game.get_player(player)
    if not player then error('Invalid player',2) end
    if not Gui.center.open(player,center_name) then return false end
    local name = center_name..'_'..tab
    if not Gui.data.inputs_button[name] then return false end
    Gui.data.inputs_button[name].events[defines.events.on_gui_click]{
        element=Gui.center.get_flow(player)[center_name].tab_bar.tab_bar_scroll.tab_bar_scroll_flow[name],
    }
    return true
end

--- Used to clear the center frame of the player, used mainly in script
-- @usage Gui.center.clear(player)
-- @param player a player identifier to get the flow for
function center.clear(player)
    player = Game.get_player(player)
    center.get_flow(player).clear()
end

-- opens this gui for this player, draw is the draw function when event is called from center.open
-- this is the default function it can be overridden when the gui is defined, simply call draw on the frame you create
-- extra values passed to draw will also be passed to the draw event
-- extra values from center.draw and passed to the open event
function center._prototype:open(player,draw,...)
    player = Game.get_player(player)
    draw = draw or function(...) center._draw(self,...) end
    local center_flow = center.get_flow(player)
    if center_flow[self.name] then Gui.center.clear(player) return end
    local center_frame = center_flow.add{
        name=self.name,
        type='frame',
        caption=self.caption,
        direction='vertical',
        style=mod_gui.frame_style
    }
    if is_type(center_frame.caption,'string') and player.gui.is_valid_sprite_path(center_frame.caption) then center_frame.caption = '' end
    draw(center_frame,...)
end

-- this is the default draw function if one is not provided, can be overridden
-- not recommended for direct use see Gui.center.open
function center._prototype:draw(frame)
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
        button(tab_bar_scroll_flow).style.font_color = defines.color.white
    end
    self._tabs[self.name..'_'..first_tab](tab_scroll_flow)
    tab_bar_scroll_flow.children[1].style.font_color = defines.color.orange
    frame.parent.add{type='frame',name='temp'}.destroy()--recenter the GUI
end

--- If default draw is used then you can add tabs to the gui with this function
-- @usage _center:add_tab('foo','Foo','Just a tab',function)
-- @tparam string name this is the name of the tab
-- @tparam string caption this is the words that appear on the tab button
-- @tparam[opt] string tooltip the tooltip that is on the button
-- @tparam function callback this is called when button is pressed with function(root_frame)
-- @return self to allow chaining of _center:add_tab
function center._prototype:add_tab(name,caption,tooltip,callback)
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
Event.add(defines.events.on_gui_closed,function(event)
    if event.element and event.element.valid then event.element.destroy() end
end)

Event.add(defines.events.on_player_respawned,center.clear)

function center.on_init()
    if loaded_modules['ExpGamingCore.Role'] then Event.add(defines.events.on_role_change,center.clear) end
end
-- calling will attempt to add a new gui
return setmetatable(center,{__call=function(self,...) return self.add(...) end})