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
    if not is_type(callback,'function') then return end
    if inputs.events[event] then event = inputs.events[event] end
    if event == 'error' then self._error = callback return end
    self.events[event] = callback
    return self
end

--- Draw the input into the root element
-- @usage button:draw(frame)
-- @param root the element you want to add the input to
-- @return returns the element that was added
function inputs._input:draw(root)
    if is_type(self.draw_data.caption,'string') and game.player.gui.is_valid_sprite_path(self.draw_data.caption) then
        return root.add{type='sprite-button',name=self.draw_data.name,sprite=self.draw_data.caption,tooltip=self.draw_data.tooltip,style=mod_gui.button_style}
    elseif is_type(self.draw_data.sprite,'string') and game.player.gui.is_valid_sprite_path(self.draw_data.sprite) then
        return root.add{type='sprite-button',name=self.draw_data.name,sprite=self.draw_data.sprite,tooltip=self.draw_data.tooltip,style=mod_gui.button_style}
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
        type == 'slider'
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
    local elements = Gui._get_data('inputs_'..event.element.type) or {}
    local element = elements[event.element.name]
    if not element and event.element.type == 'sprite-button' then 
        elements = Gui._get_data('inputs_button') or {}
        element = elements[event.element.name]
    end
    if element then
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
        type='button'
        name=name,
        caption=display,
        tooltip=tooltip
    }
    button.data._callbacks = callbacks
    button:on_event('click',function(event)
        local mouse = event.button
        local keys = {alt=event.alt,ctrl=event.control,shift=event.shift}
        local player = Game.get_player(event)
        local element = event.element
        local callbacks = button.data._callback = callbacks
        if is_type(callbacks,'function') then callbacks = {function(...) return true end,callbacks}
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

return inputs
--[[

Input Example

-- Basic Button Using Gui.inputs.add
local test = Gui.inputs.add{
    name='test-button',
    type='button',
    caption='Test'
}
test:on_event(Gui.inputs.events.click,function(event) game.print('test') end)

-- then later in code
local frame = player.gui.top.add{name='test',type='frame'}
test:draw(frame)

-- Mutly Function Button Using Gui.inputs.add_button
Gui.inputs.add_button('test-inputs','Try RMB','alt,ctrl,shift and mouse buttons',{
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.left and keys.alt end,
        function(player,element) player_return('Left: Alt',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.left and keys.ctrl end,
        function(player,element) player_return('Left: Ctrl',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.left and keys.shift end,
        function(player,element) player_return('Left: Shift',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.right and keys.alt end,
        function(player,element) player_return('Right: Alt',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.right and keys.ctrl end,
        function(player,element) player_return('Right: Ctrl',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.right and keys.shift end,
        function(player,element) player_return('Right: Shift',nil,player) end
    }
}):on_event('error',function(err) game.print('this is error handliling') end)
]]
