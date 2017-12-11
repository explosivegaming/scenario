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
    text=defines.events.on_gui_text_changed
}

--- Sets the input to trigger on an certain event
-- @usage button:on_event(defines.events.on_gui_click,player_return)
-- @param event the event to raise callback on | can be number of the event | can be a key of inputs.events
-- @tparam function callback the function you want to run on the event
function inputs._input:on_event(event,callback)
    if not is_type(callback,'function') then return end
    if inputs.events[event] then event = inputs.events[event] end
    if event == 'error' then self._error = callback return end
    self.events[event] = callback
end

--- Draw the input into the root element
-- @usage button:draw(frame)
-- @param root the element you want to add the input to
-- @return returns the element that was added
function inputs._input:draw(root)
    return root.add(self.draw_data)
end

--- Add a new input, this is the same as doing frame.add{} but returns a diffrent object
-- @usage inputs.add{type='button',name='test',caption='Test'}
-- @tparam table obj the new element to add
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
        type == 'text-box' 
    then else return end
    obj.draw_data = table.deepcopy(obj)
    obj.events = {}
    setmetatable(obj,{__index=inputs._input})
    Gui._add_data('inputs_'..type,obj.name,obj)
    return obj
end

-- this just runs the events given to inputs
function inputs._event_handler(event)
    local elements = Gui._get_data('inputs_'..event.element.type)
    local element = elements[event.element.name]
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

return inputs
--[[

Input Example

-- button test
local test = Gui.inputs.add{
    name='test-button',
    type='button',
    caption='Test'
}
test:on_event(inputs.events.click,function(event) game.print('test') end)

-- then later in code
local frame = player.gui.top.add{name='test',type='frame'}
test:draw(frame)
]]