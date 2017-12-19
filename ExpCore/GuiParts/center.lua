--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]

center = {}
center._center = {}

function center.add(obj)
    if not is_type(obj,'table') then return end    
    if not is_type(obj.name,'string') then return end 
    setmetatable(obj,{__index=center._center})
    self.tabs = {}
    Gui._add_data('center',obj.name,obj)
    toolbar.add(obj.name,obj.caption,obj.tooltip,obj.open)
    return obj
end

function center.get_flow(player)
    return player.gui.center.exp_center or player.gui.center.add{name='exp_center',type='flow'}
end

function center.clear(player)
    center.get_flow(player).clear()
end

function center._center.open(event)
    local player = Game.get_player(player)
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
    if is_type(_center.callback,'function') then
        local success, err = pcall(_center.callback,_center,center_frame)
        if not success then error(err) end
    else error('No Callback on center frame '.._center.name)
    end
end

function center._center:callback(frame)
    frame.focus()
    local tabs = self.tabs
    local tab_bar_scroll = frame.add{
        type='scroll-pane', 
        name='tab_bar_scroll', 
        vertical_scroll_policy='never', 
        horizontal_scroll_policy='always'
    }
    local tab_bar = tab_bar_scroll.add{
        type='flow',
        direction='horizontal',
        name='tab_bar'
    }
    local tab = frame.add{
        type ='scroll-pane',
        name='tab', 
        vertical_scroll_policy='auto',
        horizontal_scroll_policy='never'
    }
    local first_tab = nil
    for name,button in pairs(tabs) do
        local first_tab = first_tab or name
        button:draw(tab_bar)
    end
    self.tabs[first_tab](tab)
    tab.style.minimal_height = 300; tab.style.maximal_height = 300
    tab.style.minimal_width = 500; tab.style.maximal_width = 500
    tab_bar_scroll.style.minimal_height = 60; tab_bar_scroll.style.maximal_height = 60
    tab_bar_scroll.style.minimal_width = 500; tab_bar_scroll.style.maximal_width = 500
    frame.parent.add{type='frame',name='temp'}.destroy()--recenter the GUI
end

function center._center:add_tab(name,caption,tooltip,callback)
    self._tabs[self.name..'_'..name] = callback
    self.tabs[name] = Gui.inputs.inputs.add{
        type='button',
        name=self.name..'_'..name,
        caption=caption,
        tooltip=tooltip
    }.on_event('click',function(event)
        local tab = event.element.parent.parent.parent.tab
        tab.clear()
        local frame_name = tab.parent.name
        local _center = Gui._get_data('center')[frame_name]
        local _tab = _center._tabs[event.element.name]
        if is_type(_tab,'function') then
            local success, err = pcall(_tab,tab)
            if not success then error(err) end
        end
    end)
end

return center