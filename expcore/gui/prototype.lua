--[[-- Core Module - Gui
    @module Gui
    @alias Prototype

    readme define

    local button =
    -- starts the defination of a new concept
    Gui.new_concept('button')
    -- event linked to a factorio event
    :new_event('on_click',defines.events.on_gui_click)
    -- event linked conditionaly to a factorio event
    :new_event('on_admin_click',defines.events.on_gui_click,function(event)
        return event.player.admin
    end)
    -- a property which can be set
    :new_property('caption',function(concept,value,...)
        concept.draw_data.caption = value
    end,"Change Me")
    -- the draw function for this concept
    :define_draw(function(concept,parent,element,...)
        element =
        parent.draw{
            name=concept.name,
            type='button',
            caption=concept.caption
        }

        return element
    end)

    local toggle_cheat_mode =
    -- starts the defination of a new concept based on "button"
    button:clone('toggle_cheat_mode')
    -- sets the already existing property of "caption"
    :set_caption('Toggle Cheat Mode')
    -- using the admin click event toggle cheat mode
    :on_admin_click(function(event)
        event.player.cheat_mode = not event.player.cheat_mode
    end)
    -- adds a draw event on top of the button draw event, element is now defined
    :define_draw(function(concept,parent,element,...)
        element.style.font_color = {r=1,g=0,b=0}
    end)

    -- draws the toggle cheat mode button, extra arguments can be passed
    toggle_cheat_mode:draw(game.player.gui.left,...)
]]

local Event = require 'utils.event' -- @dep utils.event
local Game = require 'utils.game' -- @dep utils.game

local Factorio_Events = {}
local Prototype = {
    draw_callbacks = {},
    properties = {},
    events = {}
}

local function factorio_event_handler(event)
    local element = event.element
    if element then
        if not element.valid then return end
        local concept_name = element.name
        local concept_event = Factorio_Events[event.name][concept_name]
        concept_event[1]:raise_event(concept_event[2],event,true)
    else
        local events_handlers = Factorio_Events[event.name]
        for _,concept_event in pairs(events_handlers) do
            concept_event[1]:raise_event(concept_event[2],event,true)
        end
    end
end

function Prototype:clone(concept_name)
    local concept = {
        name = concept_name,
        events = {}
    }

    for event_name,_ in pairs(self.events) do
        concept.events[event_name] = {}
    end

    for key,value in pairs(self) do
        if not concept[key] then
            concept[key] = table.deep_copy(value)
        end
    end

    return concept

end

function Prototype:new_event(event_name,factorio_event,event_condition)
    if self.events[event_name] then
        error('Event is already defined',2)
    end

    local handlers = {}
    self.events[event_name] = handlers
    self[event_name] = function(handler)
        if type(handler) ~= 'function' then
            error('Event handler must be a function',2)
        end

        handlers[#handlers] = handler

        return self
    end

    if factorio_event then
        handlers.factorio_handler = event_condition
        if not Factorio_Events[factorio_event] then
            Factorio_Events[factorio_event] = {}
            Event.add(factorio_event,factorio_event_handler)
        end
        Factorio_Events[factorio_event][self.name] = {self,event_name}
    end

    return self

end

function Prototype:raise_event(event_name,event,from_factorio)
    if not self.events[event_name] then
        error('Event is not defined',2)
    end

    event.concept = self
    event.name = event.name or event_name
    event.tick = event.tick or game.tick
    event.player = event.player_index and Game.get_player_by_index(event.player_index) or nil
    if event.element and not event.element.valid then return end

    local handlers = self.events[event_name]

    if from_factorio and handlers.factorio_handler and not handlers.factorio_handler(event) then
        return
    end

    for _,handler in ipairs(handlers) do
        local success, err = pcall(handler,event)
        if not success then
            print('Gui event handler error with '..self.name..'/'..event_name..': '..err)
        end
    end
end

function Prototype:new_property(property_name,default,setter_callback)
    if self.properties[property_name] then
        error('Property is already defined',2)
    end

    self.properties[property_name] = default

    self['set_'..property_name] = function(value,...)
        if setter_callback then
            local success, err = pcall(setter_callback,value,...)
            if not success then
                print('Gui property handler error with '..self.name..'/'..property_name..': '..err)
            end
        else
            self.properties[property_name] = value
        end

        return self
    end

    return self

end

function Prototype:define_draw(draw_callback)
    if type(draw_callback) ~= 'function' then
        error('Draw define must be a function',2)
    end

    self.draw_callbacks[#self.draw_callbacks+1] = draw_callback

    return self
end

function Prototype:draw(parent_element,...)
    local element
    for _,draw_callback in pairs(self.draw_callbacks) do
        local success, rtn = pcall(draw_callback,concept,parent_element,element,...)
        if success and rtn then
            element = rtn
        elseif not success then
            print('Gui draw handler error with '..self.name..': '..rtn)
        end
    end
end

return Prototype