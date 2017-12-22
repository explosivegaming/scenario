--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]

local center = {}
center._center = {}

--- Adds a new obj to the center gui
-- @usage center.add{name='foo',caption='Foo',tooltip='Testing',draw=function}
-- @param obj contains the new object, needs name, fraw is opt and is function(root_frame)
-- @return the object made, used to add tabs
function center.add(obj)
    if not is_type(obj,'table') then return end    
    if not is_type(obj.name,'string') then return end 
    setmetatable(obj,{__index=center._center})
    obj.tabs = {}
    obj._tabs = {}
    Gui._add_data('center',obj.name,obj)
    Gui.toolbar.add(obj.name,obj.caption,obj.tooltip,obj.open)
    return obj
end

-- used to get the center frame of the player, used mainly in script
function center.get_flow(player)
    local player = Game.get_player(player)
    return player.gui.center.exp_center or player.gui.center.add{name='exp_center',type='flow'}
end

-- used to clear the center frame of the player, used mainly in script
function center.clear(player)
    local player = Game.get_player(player)
    center.get_flow(player).clear()
end

-- used on the button press when the toolbar button is press, can be overriden
function center._center.open(event)
    local player = Game.get_player(event)
    local _center = Gui._get_data('center')[event.element.name]
    local center_flow = center.get_flow(player)
    if center_flow[_center.name] then center.clear(player) return end
    local center_frame = center_flow.add{
        name=_center.name,
        type='frame',
        caption=_center.caption,
        direction='vertical',
        style=mod_gui.frame_style
    }
    if is_type(_center.draw,'function') then
        local success, err = pcall(_center.draw,_center,center_frame)
        if not success then error(err) end
    else error('No Callback on center frame '.._center.name)
    end
    player.opened=center_frame
end

-- this is the default draw function if one is not provided
function center._center:draw(frame)
    local tab_bar = frame.add{
        type='frame',
        name='tab_bar'
    }
    local tab_bar_scroll = tab_bar.add{
        type='scroll-pane', 
        name='tab_bar_scroll', 
        horizontal_scroll_policy='auto-and-reserve-space',
        vertical_scroll_policy='never'
    }
    local tab_bar_scroll_flow = tab_bar_scroll.add{
        type='flow', 
        name='tab_bar_scroll_flow', 
        direction='horizontal'
    }
    local tab = frame.add{
        type ='frame',
        name='tab',
        direction='vertical'
    }
    local tab_scroll = tab.add{
        type ='scroll-pane',
        name='tab_scroll', 
        horizontal_scroll_policy='never',
        vertical_scroll_policy='auto'
    }
    local first_tab = nil
    for name,button in pairs(self.tabs) do
        first_tab = first_tab or name
        button:draw(tab_bar_scroll_flow)
    end
    self._tabs[self.name..'_'..first_tab](tab_scroll)
    tab_scroll.style.height = 300
    tab_scroll.style.width = 500
    tab_bar_scroll.style.minimal_height = 40
    tab_bar_scroll.style.width = 500
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
    self._tabs[self.name..'_'..name] = callback
    self.tabs[name] = Gui.inputs.add{
        type='button',
        name=self.name..'_'..name,
        caption=caption,
        tooltip=tooltip
    }:on_event('click',function(event)
        local tab = event.element.parent.parent.parent.parent.tab.tab_scroll
        tab.clear()
        local frame_name = tab.parent.parent.name
        local _center = Gui._get_data('center')[frame_name]
        local _tab = _center._tabs[event.element.name]
        if is_type(_tab,'function') then
            local success, err = pcall(_tab,tab)
            if not success then error(err) end
        end
    end)
    return self
end

-- used so that when gui close key is pressed this will close the gui
Event.register(defines.events.on_gui_closed,function(event)
    if event.element and event.element.valid then event.element.destroy() end
end)

-- when the player rank is changed it closses the center guis
if defines.events.rank_change then
    Event.register(defines.events.rank_change,center.clear)
end

return center