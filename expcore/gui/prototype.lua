--[[-- Core Module - Gui
    @module Gui
    @alias Prototype

@usage DX note - chaning this doc string has no effect on the docs

local button =
Gui.new_concept('Button')
:new_event('on_click',defines.events.on_gui_click)
:new_property('tooltip')
:new_property('caption',nil,function(properties,value)
    properties.caption = value
    properties.sprite = nil
    properties.type = 'button'
end)
:new_property('sprite',nil,function(properties,value)
    properties.image = value
    properties.caption = nil
    properties.type = 'sprite-button'
end)
:define_draw(function(properties,parent,element)
    -- Note that element might be nil if this is the first draw function
    -- in this case button is a new concept so we know this is the first function and element is nil
    if properties.type == 'button' then
        element = parent.draw{
            type = properties.type,
            name = properties.name,
            caption = properties.caption,
            tooltip = properties.tooltip
        }

    else
        element = parent.draw{
            type = properties.type,
            name = properties.name,
            sprite = properties.sprite,
            tooltip = properties.tooltip
        }

    end

    -- We must return the element or what we want to be seen as the instance, this is so other draw functions have access to it
    -- for example if our custom button defined a draw function to change the font color to red
    return element
end)

local custom_button =
button:clone('CustomButton')
:new_event('on_admin_clicked',defines.events.on_gui_click,function(event)
    return event.player.admin -- only raise custom event when an admin clicks the button
end)
:set_caption('Custom Button')
:set_tooltip('Only admins can press this button')
:on_click(function(event)
    if not event.player.admin then
        event.player.print('You must be admin to use this button')
    end
end)
:on_admin_clicked(function(event)
    -- Yes i know this can just be an if else but its an example
    game.print(event.player.name..' pressed my admin button')
end)

custom_button:draw(game.player.gui.left)
]]

--- Concept Base.
-- Functions that are used to make concepts
-- @section concept-base

local Event = require 'utils.event' -- @dep utils.event
local Store = require 'expcore.store' -- @dep expcore.store
local Game = require 'utils.game' -- @dep utils.game

local Factorio_Events = {}
local Prototype = {
    draw_callbacks = {},
    clone_callbacks = {},
    properties = {},
    factorio_events = {},
    events = {}
}

--- Acts as a gernal handler for any factorio event
local function factorio_event_handler(event)
    local element = event.element
    local rasied_event = event.name
    local factorio_event_concepts = Factorio_Events[rasied_event]
    if element then
        if not element.valid then return end
        local concept = factorio_event_concepts[element.name]
        if concept then
            for event_name, factorio_event in pairs(concept.factorio_events) do
                if rasied_event == factorio_event then
                    concept:raise_event(event_name,event,true)
                end
            end
        end

    else
        for _,concept in pairs(factorio_event_concepts) do
            for event_name, factorio_event in pairs(concept.factorio_events) do
                if rasied_event == factorio_event then
                    concept:raise_event(event_name,event,true)
                end
            end
        end

    end
end

--[[-- Used to copy all the settings from one concept to another and removing links to the orginal
@tparam string concept_name the name of the new concept; must be unique
@treturn GuiConcept the base for building a custom gui
@usage-- Clones the base Button concept to make a alternative button
local custom_button =
Gui.get_concept('Button'):clone('CustomButton')
]]
function Prototype:clone(concept_name)
    local concept = table.deep_copy(self)

    -- Replace name of the concept
    concept.name = concept_name
    concept.properties.name = concept_name
    concept:change_name()

    -- Remove all event handlers that were copied
    concept.events = {}
    for event_name,_ in pairs(self.events) do
        concept.events[event_name] = {}
    end

    -- Remakes even handlers for factorio
    for _,factorio_event in pairs(concept.factorio_events) do
        Factorio_Events[factorio_event][concept.name] = concept
    end

    -- Remove all refrences to an instance store
    if concept.instance_store then
        concept.instance_store = nil
        concept.get_instances = nil
        concept.add_instance = nil
        concept.update_instances = nil
    end

    -- Remove all refrences to a data store
    if concept.data_store then
        concept.data_store = nil
        concept.get_data = nil
        concept.set_data = nil
        concept.clear_data = nil
        concept.update_data = nil
        concept.on_data_store_update = nil
        concept.events.on_data_store_update = nil
    end

    -- Remove all refrences to a combined store
    if concept.sync_instance then
        concept.sync_instance = nil
        concept.set_store_from_instance = nil
    end

    -- Loop over all the clone defines, element is updated when a value is returned
    for _,clone_callback in pairs(concept.clone_callbacks) do
        local success, rtn = pcall(clone_callback,concept)
        if not success then
            error('Gui clone handler error with '..concept.name..':\n\t'..rtn)
        end
    end

    return concept
end

--[[-- Use to add your own callbacks to the clone function, for example adding to a local table
@tparam function clone_callback the function which is called with the concept to have something done to it
@treturn table self to allow chaining
@usage-- Adding concept to a local table
local buttons = {}
local button =
Gui.get_concept('Button')
:define_clone(function(concept)
    buttons[concept.name] = concept
end)
]]
function Prototype:define_clone(clone_callback)
    -- Check that it is a function that is being added
    if type(clone_callback) ~= 'function' then
        error('Draw define must be a function',2)
    end

    -- Add the draw function
    self.clone_callbacks[#self.clone_callbacks+1] = clone_callback

    return self
end

--[[-- Used internally to save concept names to the core gui module
@function Prototype:change_name
@tparam[opt=self.name] string new_name the new name of the concept
@usage-- Internal Saving
-- this is never needed to be done, internal use only!
local button = Gui.get_concept('Button')
button:change_name('Not Button')
]]
function Prototype:change_name(new_name)
    -- over writen in core file
    self.name = new_name or self.name
    self.properties.name = self.name
    return self
end

--[[-- Adds a new event trigger to the concept which can be linked to a factorio event
@tparam string event_name the name of the event to add, must be unique, recomented to start with "on_"
@tparam[opt] defines.events factorio_event when given will fire the custom event when the factorio event is raised
@tparam[opt] function event_condition used to filter when a factorio event triggers the custom event; if the event contains a reference to an element then names are automatically filtered
@treturn GuiConcept to allow chaining of functions
@usage-- Adds an on_admin_clicked event to fire when ever an admin clicks the button
local custom_button =
Gui.get_concept('Button'):clone('CustomButton')
:new_event('on_admin_clicked',defines.events.on_gui_click,function(event)
    return event.player.admin -- only raise custom event when an admin clicks the button
end)
]]
function Prototype:new_event(event_name,factorio_event,event_condition)
    -- Check the event does not already exist
    if self.events[event_name] then
        error('Event is already defined',2)
    end

--[[-- Adds a custom event handler, replace with the name of the event
@function Prototype:on_custom_event
@tparam function handler the function which will recive the event
@treturn GuiConcept to allow chaining of functions
@usage-- When an admin clicks the button a message is printed
local custom_button =
Gui.get_concept('CustomButton')
:on_admin_clicked(function(event)
    game.print(event.player.name..' pressed my admin button')
end)
]]

    -- Adds a handler table and the event handler adder, comment above not indented to look better in docs
    self.events[event_name] = {}
    self[event_name] = function(concept,handler)
        if type(handler) ~= 'function' then
            error('Event handler must be a function',2)
        end

        local handlers = concept.events[event_name]
        handlers[#handlers+1] = handler

        return concept
    end

    -- Adds the factorio event handler if this event is linked to one
    if factorio_event then
        self.factorio_events[event_name] = factorio_event
        self.events[event_name].factorio_event_condition = event_condition

        local factorio_event_concepts = Factorio_Events[factorio_event]
        if not factorio_event_concepts then
            factorio_event_concepts = {}
            Factorio_Events[factorio_event] = factorio_event_concepts
            Event.add(factorio_event,factorio_event_handler)
        end

        if not factorio_event_concepts[self.name] then
            factorio_event_concepts[self.name] = self
        end
    end

    return self
end

--[[-- Raises a custom event, folowing keys included automaticlly: concept, event name, game tick, player from player_index, element if valid
@tparam string event_name the name of the event that you want to raise
@tparam[opt={}] table event table containg data you want to send with the event, some keys already included
@tparam[opt=false] boolean from_factorio internal use, if the raise came from the factorio event handler
@usage-- Raising the custom event on_admin_clicked
local custom_button =
Gui.get_concept('CustomButton')

-- Note that this is an example and would not work due it expecting a valid element for event.element
-- this will however work fine if you can provide all expected keys, or its not linked to any factorio event
custom_button:raise_event('on_admin_clicked',{
    player_index = game.player.index
})
]]
function Prototype:raise_event(event_name,event,from_factorio)
    -- Check that the event exists
    if not self.events[event_name] then
        error('Event is not defined',2)
    end

    -- Setup the event table with automatic keys
    event = event or {}
    event.concept = self
    event.name = event.name or event_name
    event.tick = event.tick or game.tick
    event.player = event.player_index and Game.get_player_by_index(event.player_index) or nil
    if event.element and not event.element.valid then return end

    -- Get the event handlers
    local handlers = self.events[event_name]

    -- If it is from factorio and the filter fails
    if from_factorio and handlers.factorio_event_condition and not handlers.factorio_event_condition(event) then
        return
    end

    -- Trigger every handler
    for _,handler in ipairs(handlers) do
        local success, err = pcall(handler,event)
        if not success then
            error('Gui event handler error with '..self.name..'/'..event_name..':\n\t'..err)
        end
    end
end

--[[-- Adds a new property to the concept, such as caption, tooltip, or some custom property you want to control
@tparam string property_name the name of the new property, must be unique
@tparam any default the default value for this property, although not strictly required is is strongly recomented
@tparam[opt] function setter_callback this function is called when set is called, if not provided then key in concept.properties is updated to new value
@treturn GuiConcept to allow chaining of functions
@usage-- Adding caption, sprite, and tooltip to the base button concept
local button =
Gui.get_concept('Button')
:new_property('tooltip')
:new_property('caption',nil,function(properties,value)
    properties.caption = value
    properties.sprite = nil
    properties.type = 'button'
end)
:new_property('sprite',nil,function(properties,value)
    properties.image = value
    properties.caption = nil
    properties.type = 'sprite-button'
end)
]]
function Prototype:new_property(property_name,default,setter_callback)
    -- Check that the property does not already exist
    if self.properties[property_name] then
        error('Property is already defined',2)
    end

    -- Set the property to its default
    self.properties[property_name] = default

--[[-- Sets a new value for a property, triggers setter method if provided, replace with property name
@function Prototype:set_custom_property
@tparam any value the value that you want to set for this property
@treturn GuiConcept to allow chaining of functions
@usage-- Setting the caption on the base button concept after a cloning
local custom_button =
Gui.get_concept('Button')
:set_caption('Default Button')

@usage-- In our examples CustomButton is cloned from Button, this means the caption property already exists
-- note that what ever values that properties have at the time of cloning are also copied
local custom_button =
Gui.get_concept('CustomButton')
:set_caption('Custom Button')
]]

    self['set_'..property_name] = function(concept,value,...)
        if setter_callback then
            -- Call the setter method to update values if present
            local success, err = pcall(setter_callback,concept.properties,value,...)
            if not success then
                error('Gui property handler error with '..concept.name..'/'..property_name..':\n\t'..err)
            end
        else
            -- Otherwise just update the key
            concept.properties[property_name] = value
        end

        return concept
    end

    return self
end

--[[-- Used to define how the concept is turned into an ingame element or "instance" as we may refer to them
@tparam function draw_callback the function that will be called to draw/update the instance; this function must return the instance or the new acting instance
@treturn GuiConcept to allow chaining of functions
@usage-- Adding the draw define for the base button concept, we then return the element
local button =
Gui.get_concept('Button')
:define_draw(function(properties,parent,element)
    -- Note that element might be nil if this is the first draw function
    -- for this example we assume button was cloned from Prototype and so has no other draw functions defined
    -- this means that there is no element yet and what we return will be the first time the element is returned
    -- although not shown here you also can recive any extra arguments here from the call to draw
    if properties.type == 'button' then
        element = parent.draw{
            type = properties.type,
            name = properties.name,
            caption = properties.caption,
            tooltip = properties.tooltip
        }

    else
        element = parent.draw{
            type = properties.type,
            name = properties.name,
            sprite = properties.sprite,
            tooltip = properties.tooltip
        }

    end

    -- We must return the element or what we want to be seen as the instance, this is so other draw functions have access to it
    -- for example if our custom button defined a draw function to change the font color to red
    return element
end)
]]
function Prototype:define_draw(draw_callback)
    -- Check that it is a function that is being added
    if type(draw_callback) ~= 'function' then
        error('Draw define must be a function',2)
    end

    -- Add the draw function
    self.draw_callbacks[#self.draw_callbacks+1] = draw_callback

    return self
end

--[[ Used to define a draw callback that is ran before any other draw callbacks, see define_draw
@tparam function draw_callback the function that will be called to draw/update the instance; this function must return the instance or the new acting instance
@treturn GuiConcept to allow chaining of functions
@usage-- Placing a button into a flow
local button =
Gui.get_concept('Button')
:define_pre_draw(function(properties,parent,element)
    -- Here we set the lcoal parent to a new flow, to set this as the new parent we must return it below
    parent = parent.add{
        type = 'flow'
    }

    -- We must return the element here but we can also return a new parent instance that all other draw functions will see as the parent
    return element, parent
end)
]]
function Prototype:define_pre_draw(draw_callback)
    -- Check that it is a function that is being added
    if type(draw_callback) ~= 'function' then
        error('Draw define must be a function',2)
    end

    -- Add the draw function
    table.insert(self.draw_callbacks,1,draw_callback)

    return self
end

--[[-- Calls all the draw functions in order to create this concept in game; will also store and sync the instance if stores are used
@tparam LuaGuiElement parent_element the element that the concept will use as a base
@treturn LuaGuiElement the element that was created and then passed though and returned by the draw functions
@usage-- Drawing the custom button concept
local custom_button =
Gui.get_concept('CustomButton')

-- Note that the draw function from button was cloned, so unless we want to alter the base button we dont need a new draw define
custom_button:draw(game.player.gui.left)
]]
function Prototype:draw(parent_element,...)
    local parent = parent_element
    local element

    -- Loop over all the draw defines, element is updated when a value is returned
    for _,draw_callback in pairs(self.draw_callbacks) do
        local success, _element, _parent = pcall(draw_callback,self.properties,parent,element,...)
        if success then
            if _element then element = _element end
            if _parent then parent = _parent end
        elseif not success then
            error('Gui draw handler error with '..self.name..':\n\t'.._element)
        end
    end

    -- Adds the instance if instance store is used
    if self.add_instance then
        self.add_instance(element)
    end

    -- Syncs the instance if there is a combined store
    if self.sync_instance then
        self.sync_instance(element)
    end

    return element
end

--- Concept Instances.
-- Functions that are used to make store concept instances
-- @section concept-instances

--[[-- Adds an instance store to the concept; when a new instance is made it is stored so you can access it later
@tparam[opt] function category_callback when given will act as a way to turn an element into a string to act as a key; keys returned can over lap
@treturn GuiConcept to allow chaining of functions
@usage-- Allowing storing instances of the custom button; stored by the players index
-- Note even thou this is a copy of Button; if Button had an instance store it would not be cloned over
local custom_button =
Gui.get_concept('CustomButton')
:define_instance_store(function(element)
    return element.player_index -- The instances are stored based on player id
end)
]]
function Prototype:define_instance_store(category_callback)
    self.instance_store = Store.register('gui_instances_'..self.name)

    local valid_category = category_callback and type(category_callback) == 'function'
    local function get_category(category)
        if type(category) == 'table' and type(category.__self) == 'userdata' then
            return valid_category and category_callback(category) or nil
        else
            return category
        end
    end

--[[-- Gets all insatnces in a category, category may be nil to return all
@function Prototype.get_instances
@tparam[opt] ?string|LuaGuiElement category the category to get, can only be nil if categories are not used
@treturn table a table which contains all the instances
@usage-- Getting all the instances of the player with index 1
local custom_button =
Gui.get_concept('CustomButton')

custom_button.get_instances(1) -- player index 1
]]
    function self.get_instances(category)
        return Store.get(self.instance_store,get_category(category))
    end

--[[-- Adds an instance to this concept, used automatically during concept:draw
@function Prototype.add_instance
@tparam LuaGuiElement element the element that will be added as an instance
@tparam[opt] string category the category to add this element under, if nil the category callback is used to assign one
@usage-- Adding an element as a instance for this concept, mostly for internal use
local custom_button =
Gui.get_concept('CustomButton')

custom_button.add_instance(element) -- normally not needed due to use in concept:draw
]]
    function self.add_instance(element,category)
        category = category or get_category(element)
        if not valid_category then category = nil end
        return Store.update(self.instance_store,category,function(tbl)
            if type(tbl) ~= 'table' then
                return {element}
            else
                table.insert(tbl,element)
            end
        end)
    end

--[[-- Applies an update function to all instances, simialr use to what table.forEach would be
@function Prototype.update_instances
@tparam[opt] ?string|LuaGuiElement category the category to get, can only be nil if categories are not used
@tparam function update_callback the function which is called on each instance, recives other args passed to update_instances
@usage-- Changing the font color of all instances for player 1
local custom_button =
Gui.get_concept('CustomButton')

custom_button.update_instances(1,function(element)
    element.style.font_color = {r=1,g=0,b=0}
end)
]]
    function self.update_instances(category,update_callback,...)
        local args
        if type(category) == 'function' then
            args = {update_callback,...}
            update_callback = category
            category = nil
        end

        local instances = Store.get(self.instance_store,get_category(category)) or {}
        for key,instance in pairs(instances) do
            if not instance or not instance.valid then
                instances[key] = nil

            else
                if args then
                    update_callback(instance,unpack(args))
                else
                    update_callback(instance,...)
                end
            end
        end
    end

    return self
end

--- Concept Data.
-- Functions that are used to store concept data
-- @section concept-data

--[[-- Adds a data store to this concept which allows you to store synced/percistent data between instances
@tparam[opt] function category_callback when given will act as a way to turn an element into a string to act as a key; keys returned can over lap
@treturn GuiConcept to allow chaining of functions
@usage-- Adding a way to store data for this concept; each player has their own store
-- Note even thou this is a copy of Button; if Button had an data store it would not be cloned over
local custom_button =
Gui.get_concept('CustomButton')
:define_data_store(function(element)
    return element.player_index -- The data is stored based on player id
end)
]]
function Prototype:define_data_store(category_callback)
    self:new_event('on_data_store_update')
    self.data_store = Store.register('gui_data_'..self.name,function(value,key)
        self:raise_event('on_data_store_update',{
            category = key,
            value = value
        })
    end)

    local valid_category = category_callback and type(category_callback) == 'function'
    local function get_category(category)
        if type(category) == 'table' and type(category.__self) == 'userdata' then
            return valid_category and category_callback(category) or nil
        else
            return category
        end
    end

--[[-- Gets the data that is stored for this category
@function Prototype.get_data
@tparam[opt] ?string|LuaGuiElement category the category to get, can only be nil if categories are not used
@treturn any the data that you had stored in this location
@usage-- Getting the stored data for player 1
local custom_button =
Gui.get_concept('CustomButton')

custom_button.get_data(1) -- player index 1
]]
    function self.get_data(category)
        return Store.get(self.data_store,get_category(category))
    end

--[[-- Sets the data that is stored for this category
@function Prototype.set_data
@tparam[opt] ?string|LuaGuiElement category the category to set, can only be nil if categories are not used
@tparam any value the data that you want to stored in this location
@usage-- Setting the data for player 1 to a table with two keys
local custom_button =
Gui.get_concept('CustomButton')

-- A table is used to show correct way to use a table with self.update_data
-- but a table is not required and can be any data, however upvalues may cause desyncs
custom_button.set_data(1,{
    clicks = 0,
    required_clicks = 100
}) -- player index 1
]]
    function self.set_data(category,value)
        return Store.set(self.data_store,get_category(category),value)
    end

--[[-- Clears the data that is stored for this category
@function Prototype.clear_data
@tparam[opt] ?string|LuaGuiElement category the category to clear, can only be nil if categories are not used
@usage-- Clearing the data for player 1
local custom_button =
Gui.get_concept('CustomButton')

custom_button.clear_data(1) -- player index 1
]]
    function self.clear_data(category)
        return Store.clear(self.data_store,get_category(category))
    end

--[[-- Updates the data that is stored for this category
@function Prototype.update_data
@tparam[opt] ?string|LuaGuiElement category the category to clear, can only be nil if categories are not used
@tparam function update_callback the function which is called to update the data
@usage-- Updating the clicks key in the concept data for player 1
local custom_button =
Gui.get_concept('CustomButton')

custom_button.update_data(1,function(tbl)
    tbl.clicks = tbl.clicks + 1 -- here we are incrementing the clicks by 1
end) -- player index 1

@usage-- Updating a value when a table is not used, alterative to get set
-- so for this example assume that we did custom_button.set_data(1,0)
custom_button.update_data(1,function(value)
    return value + 1 -- here we are incrementing the value by 1, we may only be tracking clicks
end) -- player index 1
]]
    function self.update_data(category,update_callback,...)
        return Store.update(self.data_store,get_category(category),update_callback,...)
    end

    return self
end

--- Concept Combined Instances.
-- Functions that are used to make store concept instances and data
-- @section concept-instances

--[[-- Used to add a both instance and data store which are linked together, new instances are synced to the current value, changing the stored value will change all instances
@tparam[opt] function category_callback when given will act as a way to turn an element into a string to act as a key; keys returned can over lap
@tparam function sync_callback the function which is called to update an instance to match the store, this is called on all instances when concept.set_data or update_data is used
@treturn GuiConcept to allow chaining of functions
@usage-- Adding a check box which is a "global setting" synced between all players
local custom_button =
Gui.get_concept('checkbox'):clone('my_checkbox')
:set_caption('My Checkbox')
:set_tooltip('Clicking this check box will change it for everyone')
:on_state_changed(function(event)
    local element = event.element
    event.concept.set_data(element,element.state) -- Update the stored data to trigger an update of all other instances
end)
:define_combined_store(function(element,state) -- We could add a category function here if we wanted to
    element.state = state or false -- Note that the value passed may be nil if there is no stored value and no default set
end)
]]
function Prototype:define_combined_store(category_callback,sync_callback)
    if sync_callback == nil then
        sync_callback = category_callback
        category_callback = nil
    end

    self:define_data_store(category_callback)
    self:define_instance_store(category_callback)

    -- Will update all instances when the data store updates
    self:on_data_store_update(function(event)
        self.update_instances(event.category,sync_callback,event.value)
    end)

--[[-- Will sync an instance to match the stored value based on the given sync callback
@function Prototype.sync_instance
@tparam LuaGuiElement element the element that you want to have update
@usage-- Setting the caption of this element to be the same as the stored value
local custom_button =
Gui.get_concept('CustomButton')

-- Used internally when first draw and automatically when the store updates
custom_button.sync_instance(element)
]]
    local properties = self.properties
    function self.sync_instance(element)
        local default = properties.default
        local value = self.get_data(element) or type(default) == 'function' and default(element) or default
        sync_callback(element,value)
    end

    return self
end

return Prototype