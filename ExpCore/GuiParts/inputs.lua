--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]

local inputs = {}
inputs._input = {}
-- these are just so you can have short cuts to this
inputs.events = {
    error='error',
    state=defines.events.on_gui_checked_state_changed,
    click=defines.events.on_gui_click,
    elem=defines.events.on_gui_elem_changed,
    selection=defines.events.on_gui_selection_state_changed,
    text=defines.events.on_gui_text_changed,
    slider=defines.events.on_gui_value_changed
}

--- Sets the input to trigger on an certain event
-- @usage button:on_event(defines.events.on_gui_click,player_return)
-- @param event the event to raise callback on | can be number of the event | can be a key of inputs.events
-- @tparam function callback the function you want to run on the event
-- @treturn table returns self so you can chain together
function inputs._input:on_event(event,callback)
    if not is_type(callback,'function') then return self end
    if inputs.events[event] then event = inputs.events[event] end
    if event == 'error' then self._error = callback return self end
    self.events[event] = callback
    return self
end

--- Draw the input into the root element
-- @usage button:draw(frame)
-- @param root the element you want to add the input to
-- @return returns the element that was added
function inputs._input:draw(root)
    local player = Game.get_player(root.player_index)
    if is_type(self.draw_data.caption,'string') and player.gui.is_valid_sprite_path(self.draw_data.caption) then
        local data = table.deepcopy(self.draw_data)
        data.type = 'sprite-button'
        data.sprite = data.caption
        data.caption = nil
        return root.add(data)
    elseif is_type(self.draw_data.sprite,'string') and player.gui.is_valid_sprite_path(self.draw_data.sprite) then
        local data = table.deepcopy(self.draw_data)
        data.type = 'sprite-button'
        return root.add(data)
    elseif is_type(self.data._state,'function') then
        local data = table.deepcopy(self.draw_data)
        local success, err = pcall(self.data._state,player,root)
        if success then data.state = err else error(err) end
        return root.add(data)
    elseif is_type(self.data._start,'function') then
        local data = table.deepcopy(self.draw_data)
        local success, err = pcall(self.data._start,player,root)
        if success then data.value = err else error(err) end
        return root.add(data)
    elseif is_type(self.data._index,'function') then
        local data = table.deepcopy(self.draw_data)
        local success, err = pcall(self.data._index,player,root)
        if success then data.selected_index = err else error(err) end
        if is_type(self.data._items,'function') then
            local success, err = pcall(self.data._items,player,root)
            if success then data.items = err else error(err) end
        end
        return root.add(data)
    elseif is_type(self.data._items,'function') then
        local data = table.deepcopy(self.draw_data)
        local success, err = pcall(self.data._items,player,root)
        if success then data.items = err else error(err) end
        if is_type(self.data._index,'function') then
            local success, err = pcall(self.data._index,player,root)
            if success then data.selected_index = err else error(err) end
        end
        return root.add(data)
    else
        return root.add(self.draw_data)
    end
end

--- Add a new input, this is the same as doing frame.add{} but returns a diffrent object
-- @usage Gui.inputs.add{type='button',name='test',caption='Test'}
-- @tparam table obj the new element to add if caption is a sprite path then sprite is used
-- @treturn table the custom input object
function inputs.add(obj)
    if not is_type(obj,'table') then return end
    if not is_type(obj.type,'string') then return end
    local type = obj.type
    if type == 'button' or 
        type == 'sprite-button' or 
        type == 'choose-elem-button' or
        type == 'checkbox' or 
        type == 'radiobutton' or
        type == 'textfield' or
        type == 'text-box'  or
        type == 'slider' or
        type == 'drop-down'
    then else return end
    if obj.type == 'button' or obj.type == 'sprite-button' then obj.style = mod_gui.button_style end
    obj.draw_data = table.deepcopy(obj)
    obj.data = {}
    obj.events = {}
    setmetatable(obj,{__index=inputs._input})
    Gui._add_data('inputs_'..type,obj.name,obj)
    return obj
end

-- this just runs the events given to inputs
function inputs._event_handler(event)
    if not event.element then return end
    local elements = Gui._get_data('inputs_'..event.element.type) or {}
    local element = elements[event.element.name]
    if not element and event.element.type == 'sprite-button' then 
        elements = Gui._get_data('inputs_button') or {}
        element = elements[event.element.name]
    end
    if element then
        if not is_type(element.events[event.name],'function') then return end
        local success, err = pcall(element.events[event.name],event)
        if not success then
            if is_type(element._error,'function') then pcall(element._error) 
            else error(err) end
        end
    end
end

Event.register(inputs.events.state,inputs._event_handler)
Event.register(inputs.events.click,inputs._event_handler)
Event.register(inputs.events.elem,inputs._event_handler)
Event.register(inputs.events.state,inputs._event_handler)
Event.register(inputs.events.text,inputs._event_handler)
Event.register(inputs.events.slider,inputs._event_handler)
Event.register(inputs.events.selection,inputs._event_handler)

-- the folwing functions are just to make inputs easier but if what you want is not include use inputs.add(obj)
--- Used to define a button, can have many function
-- @usage Gui.inputs.add_button('test','Test','Just for testing',{{condition,callback},...})
-- @tparam string name the name of this button
-- @tparam string the display for this button, either text or sprite path
-- @tparam string tooltip the tooltip to show on the button
-- @param callbacks can either be a single function or a list of function pairs see exaplmes at bottom
-- @treturn table the button object that was made, to allow a custom error event if wanted
function inputs.add_button(name,display,tooltip,callbacks)
    local button = inputs.add{
        type='button',
        name=name,
        caption=display,
        tooltip=tooltip
    }
    button.data._callbacks = callbacks
    button:on_event('click',function(event)
        local elements = Gui._get_data('inputs_'..event.element.type) or {}
        local button = elements[event.element.name]
        if not button and event.element.type == 'sprite-button' then 
            elements = Gui._get_data('inputs_button') or {}
            button = elements[event.element.name]
        end
        local player = Game.get_player(event)
        local mouse = event.button
        local keys = {alt=event.alt,ctrl=event.control,shift=event.shift}
        local element = event.element
        local callbacks = button.data._callbacks
        if is_type(callbacks,'function') then callbacks = {{function(...) return true end,callbacks}} end
        for _,data in pairs(callbacks) do
            if is_type(data[1],'function') and is_type(data[2],'function') then
                local success, err = pcall(data[1],player,mouse,keys,event)
                if success and err == true then
                    local success, err = pcall(data[2],player,element,event)
                    if not success then error(err) end
                elseif not success then error(err) end
            else error('Invalid Callback Condition Format') end
        end 
    end)
    return button
end

--- Used to define a choose-elem-button callback only on elem_changed
-- @usage Gui.inputs.add_elem_button('test','Test','Just for testing',function)
-- @tparam string name the name of this button
-- @tparam string the display for this button, either text or sprite path
-- @tparam string tooltip the tooltip to show on the button
-- @tparam function the callback to call on change function(player,element,elem)
-- @treturn table the button object that was made, to allow a custom error event if wanted
function inputs.add_elem_button(name,elem_type,tooltip,callback)
    local button = inputs.add{
        type='choose-elem-button',
        name=name,
        elem_type=elem_type,
        tooltip=tooltip
    }
    button.data._callback = callback
    button:on_event('elem',function(event)
        local button = Gui._get_data('inputs_'..event.element.type)[event.element.name]
        local player = Game.get_player(event)
        local element = event.element or {elem_type=nil,elem_value=nil}
        local elem = {type=element.elem_type,value=element.elem_value}
        if is_type(button.data._callback,'function') then
            local success, err = pcall(button.data._callback,player,element,elem)
            if not success then error(err) end
        else error('Invalid Callback') end
    end)
    return button
end

--- Used to define a checkbox callback only on state_changed
-- @usage Gui.inputs.add_checkbox('test',false,'Just for testing',function,function,funvtion)
-- @tparam string name the name of this button
-- @tparam string the display for this button, either text or sprite path
-- @tparam string tooltip the tooltip to show on the button
-- @tparam function the callback to call on change function(player,element,elem)
-- @treturn table the button object that was made, to allow a custom error event if wanted
function inputs.add_checkbox(name,radio,display,default,callback_true,callback_false)
    local type = 'checkbox'; if radio then type='radiobutton' end
    local state = false; if is_type(default,'boolean') then state = default end
    local checkbox = inputs.add{
        type=type,
        name=name,
        caption=display,
        state=state
    }
    if is_type(default,'function') then checkbox.data._state = default end
    checkbox.data._true = callback_true
    checkbox.data._false = callback_false
    checkbox:on_event('state',function(event)
        local checkbox = Gui._get_data('inputs_'..event.element.type)[event.element.name]
        local player = Game.get_player(event)
        local state = event.element.state
        if state then
            if is_type(checkbox.data._true,'function') then
                local success, err = pcall(checkbox.data._true,player,event.element)
                if not success then error(err) end
            else error('Invalid Callback') end
        else
            if is_type(checkbox.data._false,'function') then
                local success, err = pcall(checkbox.data._false,player,event.element)
                if not success then error(err) end
            else error('Invalid Callback') end
        end
    end)
    return checkbox
end

--- Used to reset the state of radio buttons, recomened to be called on_state_change to reset any radio buttons it is ment to work with.
-- @usage Gui.inputs.reset_radio{radio1,radio2,...}
-- @param elements can be a list of elements or a single element
function inputs.reset_radio(elements)
    if #elements > 0 then
        for _,element in pairs(elements) do
            if element.valid then
                local _elements = Gui._get_data('inputs_'..element.type) or {}
                local _element = _elements[element.name]
                local player = Game.get_player(element.player_index)
                local state = false
                local success, err = pcall(_element.data._state,player,element.parent)
                if success then state = err else error(err) end
                element.state = state
            end
        end
    else
        if elements.valid then
            local _elements = Gui._get_data('inputs_'..elements.type) or {}
            local _element = _elements[elements.name]
            local player = Game.get_player(elements.player_index)
            local state = false
            local success, err = pcall(_element.data._state,player,elements.parent)
            if success then state = err else error(err) end
            elements.state = state
        end
    end
end

--- Used to define a text callback only on text_changed
-- @usage Gui.inputs.add_text('test',false,'Just for testing',function)
-- @tparam string name the name of this button
-- @tparam boolean box is it a text box rather than a text field
-- @tparam string text the starting text
-- @tparam function the callback to call on change function(player,text,element)
-- @treturn table the text object that was made, to allow a custom error event if wanted
function inputs.add_text(name,box,text,callback)
    local type = 'textfield'; if box then type='text-box' end
    local textbox = inputs.add{
        type=type,
        name=name,
        text=text
    }
    textbox.data._callback = callback
    textbox:on_event('text',function(event)
        local textbox = Gui._get_data('inputs_'..event.element.type)[event.element.name]
        local player = Game.get_player(event)
        local element = event.element
        local callback = textbox.data._callback
        if is_type(callback,'function') then
            local success, err = pcall(callback,player,element.text,element)
            if not success then error(err) end
        else error('Invalid Callback Condition Format') end
    end)
    return textbox
end

--- Used to define a slider callback only on value_changed
-- @usage Gui.inputs.add_slider('test','horizontal',1,10,5,function)
-- @tparam string name the name of this button
-- @tapram string text the caption to go with the slider
-- @tparam number min the lowest number
-- @tparam number max the highest number
-- @param start_callback either a number or a function to return a number
-- @tparam function callback the function to be called on value_changed function(player,value,percent,element)
-- @treturn table the slider object that was made, to allow a custom error event if wanted
function inputs.add_slider(name,orientation,min,max,start_callback,callback)
    local slider = inputs.add{
        type='slider',
        name=name,
        orientation=orientation,
        minimum_value=min,
        maximum_value=max,
        value=start_callback
    }
    slider.data._start = start_callback
    slider.data._callback = callback
    slider:on_event('slider',function(event)
        local slider = Gui._get_data('inputs_'..event.element.type)[event.element.name]
        local player = Game.get_player(event)
        local value = event.element.slider_value
        local data = slider.data
        local percent = value/event.element.get_slider_maximum()
        if is_type(data._callback,'function') then
            local success, err = pcall(data._callback,player,value,percent,event.element)
            if not success then error(err) end
        else error('Invalid Callback Condition Format') end
    end)
    return slider
end

--- Used to define a drop down callback only on value_changed
-- @usage Gui.inputs.add_drop_down('test',{1,2,3},1,function)
-- @param items either a list or a function which returns a list
-- @param index either a number or a function which returns a number
-- @tparam function callback the callback which is called when a new index is selected function(player,selected,items,element)
-- @treturn table the drop-down object that was made, to allow a custom error event if wanted
function inputs.add_drop_down(name,items,index,callback)
    local drop_down = inputs.add{
        type='drop-down',
        name=name,
        items=items,
        selected_index=index
    }
    drop_down.data._items = items
    drop_down.data._index = index
    drop_down.data._callback = callback
    drop_down:on_event('selection',function(event)
        local drop_down = Gui._get_data('inputs_'..event.element.type)[event.element.name]
        local player = Game.get_player(event)
        local element = event.element
        local items = element.items
        local selected = items[element.selected_index]
        local callback = drop_down.data._callback
        if is_type(callback,'function') then
            local success, err = pcall(callback,player,selected,items,element)
            if not success then error(err) end
        else error('Invalid Callback Condition Format') end
    end)
    return drop_down
end

return inputs

-- to see examples look at GuiParts/test.lua
