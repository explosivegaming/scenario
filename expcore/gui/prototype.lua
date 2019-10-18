--[[-- Core Module - Gui
    @module Gui
    @alias Prototype
]]

--- Prototype.
-- Used to create new gui prototypes see elements and concepts
-- @section prototype

--[[
    >>>> Functions
    Constructor.event(event_name) --- Creates a new function to add functions to an event handler
    Constructor.extend(new_prototype) --- Extents a prototype with the base functions of all gui prototypes, no metatables
    Constructor.store(sync,callback) --- Creates a new function which adds a store to a gui define
    Constructor.setter(value_type,key,second_key) --- Creates a setter function that checks the type when a value is set

    Prototype:uid() --- Gets the uid for the element define
    Prototype:debug_name(value) ---  Sets a debug alias for the define
    Prototype:set_caption(value) --- Sets the caption for the element define
    Prototype:set_tooltip(value) --- Sets the tooltip for the element define
    Prototype:set_style(style,callback) --- Sets the style for the element define
    Prototype:set_embedded_flow(state) --- Sets the element to be drawn inside a nameless flow, can be given a name using a function

    Prototype:set_pre_authenticator --- Sets an authenticator that blocks the draw function if check fails
    Prototype:set_post_authenticator --- Sets an authenticator that disables the element if check fails

    Prototype:raise_event(event_name,...) --- Raises a custom event for this define, any number of params can be given
    Prototype:draw_to(element,...) --- The main function for defines, when called will draw an instance of this define to the given element

    Prototype:get_store(category) --- Gets the value in this elements store, category needed if serializer function used
    Prototype:set_store(category,value) --- Sets the value in this elements store, category needed if serializer function used
    Prototype:clear_store(category) --- Sets the value in this elements store to nil, category needed if serializer function used
]]
local Game = require 'utils.game' --- @dep utils.game
local Store = require 'expcore.store' --- @dep expcore.store
local Instances = require 'expcore.gui.instances' --- @dep expcore.gui.instances

local Constructor = {}
local Prototype = {}

--- Creates a new function to add functions to an event handler
-- @tparam string event_name the name of the event that callbacks will be added to
-- @treturn function the function used to register handlers
function Constructor.event(event_name)
    --- Adds a callback as a handler for an event
    -- @tparam table self the gui define being acted on
    -- @tparam function callback the function that will be added as a handler for the event
    -- @treturn table self returned to allowing chaining of functions
    return function(self,callback)
        if type(callback) ~= 'function' then
            return error('Event callback for '..event_name..' must be a function',2)
        end

        local handlers = self.events[event_name]
        if not handlers then
            handlers = {}
            self.events[event_name] = handlers
        end

        handlers[#handlers+1] = callback
        return self
    end
end

--- Extents a prototype with the base functions of all gui prototypes, no metatables
-- @tparam table new_prototype the prototype that you want to add the functions to
-- @treturn table the same prototype but with the new functions added
function Constructor.extend(new_prototype)
    for key,value in pairs(Prototype) do
        if type(value) == 'table' then
            new_prototype[key] = table.deepcopy(value)
        else
            new_prototype[key] = value
        end
    end
    for key,value in pairs(new_prototype) do
        if value == Constructor.event then
            new_prototype[key] = Constructor.event(key)
        end
    end
    return new_prototype
end

--- Creates a new function which adds a store to a gui define
-- @tparam function callback the function called when needing to update the value of an element
-- @treturn function the function that will add a store for this define
function Constructor.store(callback)
    --- Adds a store for the define that is shared between all instances of the define in the same category, serializer is a function that returns a string
    -- @tparam self table the gui define being acted on
    -- @tparam[opt] function serializer function used to determine the category of a LuaGuiElement, when omitted all share one single category
    -- serializer param - LuaGuiElement element - the element that needs to be converted
    -- serializer return - string - a deterministic string that references to a category such as player name or force name
    -- @treturn self the element define to allow chaining
    return function(self,serializer)
        if self.store then return end
        serializer = serializer or function() return '' end

        self.store = Store.register(serializer)

        Instances.register(self.name,serializer)

        Store.watch(self.store,function(value,category)
            self:raise_event('on_store_update',value,category)

            if Instances.is_registered(self.name) then
                Instances.apply_to_elements(self.name,category,function(element)
                    callback(self,element,value)
                end)
            end
        end)

        return self
    end
end

--- Creates a setter function that checks the type when a value is set
-- @tparam string value_type the type that the value should be when it is set
-- @tparam string key the key of the define that will be set
-- @tparam[opt] string second_key allows for setting of a key in a sub table
-- @treturn function the function that will check the type and set the value
function Constructor.setter(value_type,key,second_key)
    local display_message = 'Gui define '..key..' must be of type '..value_type
    if second_key then
        display_message = 'Gui define '..second_key..' must be of type '..value_type
    end

    local locale = false
    if value_type == 'locale-string' then
        locale = true
        value_type = 'table'
    end

    return function(self,value)
        local v_type = type(value)
        if v_type ~= value_type and (not locale or v_type ~= 'string') then
            error(display_message,2)
        end

        if second_key then
            self[key][second_key] = value
        else
            self[key] = value
        end

        return self
    end
end

--- Gets the uid for the element define
-- @treturn string the uid of this element define
function Prototype:uid()
    return self.name
end

--- Sets a debug alias for the define
-- @tparam string name the debug name for the element define that can be used to get this element define
-- @treturn self the element define to allow chaining
Prototype.debug_name = Constructor.setter('string','debug_name')

--- Sets the caption for the element define
-- @tparam string caption the caption that will be drawn with the element
-- @treturn self the element define to allow chaining
Prototype.set_caption = Constructor.setter('locale-string','draw_data','caption')

--- Sets the tooltip for the element define
-- @tparam string tooltip the tooltip that will be displayed for this element when drawn
-- @treturn self the element define to allow chaining
Prototype.set_tooltip = Constructor.setter('locale-string','draw_data','tooltip')

--- Sets an authenticator that blocks the draw function if check fails
-- @tparam function callback the function that will be ran to test if the element should be drawn or not
-- callback param - LuaPlayer player - the player that the element is being drawn to
-- callback param - string define_name - the name of the define that is being drawn
-- callback return - boolean - false will stop the element from being drawn
-- @treturn self the element define to allow chaining
Prototype.set_pre_authenticator = Constructor.setter('function','pre_authenticator')

--- Sets an authenticator that disables the element if check fails
-- @tparam function callback the function that will be ran to test if the element should be enabled or not
-- callback param - LuaPlayer player - the player that the element is being drawn to
-- callback param - string define_name - the name of the define that is being drawn
-- callback return - boolean - false will disable the element
-- @treturn self the element define to allow chaining
Prototype.set_post_authenticator = Constructor.setter('function','post_authenticator')

--- Registers a callback to the on_draw event
-- @tparam function callback
-- callback param - LuaPlayer player - the player that the element was drawn to
-- callback param - LuaGuiElement element - the element that was drawn
-- callback param - any ... - any other params passed by the draw_to function
Prototype.on_draw = Constructor.event('on_draw')

--- Registers a callback to the on_style_update event
-- @tparam function callback
-- callback param - LuaStyle style - the style that was changed and/or needs changing
Prototype.on_style_update = Constructor.event('on_style_update')

--- Sets the style for the element define
-- @tparam string style the style that will be used for this element when drawn
-- @tparam[opt] function callback function is called when element is drawn to alter its style
-- @treturn self the element define to allow chaining
function Prototype:set_style(style,callback)
    self.draw_data.style = style
    if callback then
        self:on_style_update(callback)
    end
    return self
end

--- Sets the element to be drawn inside a nameless flow, can be given a name using a function
-- @tparam ?boolean|function state when true a padless flow is created to contain the element
-- @treturn self the element define to allow chaining
function Prototype:set_embedded_flow(state)
    if state == false or type(state) == 'function' then
        self.embedded_flow = state
    else
        self.embedded_flow = true
    end
    return self
end

--- Raises a custom event for this define, any number of params can be given
-- @tparam string event_name the name of the event that you want to raise
-- @tparam any ... any params that you want to pass to the event
-- @treturn number the number of handlers that were registered
function Prototype:raise_event(event_name,...)
    local handlers = self.events[event_name]
    if handlers then
        for _,handler in pairs(handlers) do
            handler(...)
        end
    end
    return handlers and #handlers or 0
end

--- The main function for defines, when called will draw an instance of this define to the given element
-- what is drawn is based on the data in draw_data which is set using other functions
-- @tparam LuaGuiElement element the element that the define will draw a instance of its self onto
-- @treturn LuaGuiElement the new element that was drawn
function Prototype:draw_to(element,...)
    local name = self.name
    if element[name] then return end
    local player = Game.get_player_by_index(element.player_index)

    if self.pre_authenticator then
        if not self.pre_authenticator(player,self.name) then return end
    end

    if self.embedded_flow then
        local embedded_name
        if type(self.embedded_flow) == 'function' then
            embedded_name = self.embedded_flow(element,...)
        end
        element = element.add{type='flow',name=embedded_name}
        element.style.padding = 0
    end

    local new_element = element.add(self.draw_data)

    self:raise_event('on_style_update',new_element.style)

    if self.post_authenticator then
        new_element.enabled = self.post_authenticator(player,self.name)
    end

    if Instances.is_registered(self.name) then
        Instances.add_element(self.name,new_element)
    end

    self:raise_event('on_draw',player,new_element,...)

    return new_element
end

--- Gets the value in this elements store, category needed if serializer function used
-- @tparam string category[opt] the category to get such as player name or force name
-- @treturn any the value that is stored for this define
function Prototype:get_store(category)
    if not self.store then return end
    return Store.get(self.store,category)
end

--- Sets the value in this elements store, category needed if serializer function used
-- @tparam string category[opt] the category to get such as player name or force name
-- @tparam any value the value to set for this define, must be valid for its type ie for checkbox etc
-- @treturn boolean true if the value was set
function Prototype:set_store(category,value)
    if not self.store then return end
    return Store.set(self.store,category,value)
end

--- Sets the value in this elements store to nil, category needed if serializer function used
-- @tparam[opt] string category the category to get such as player name or force name
-- @treturn boolean true if the value was set
function Prototype:clear_store(category)
    if not self.store then return end
    return Store.clear(self.store,category)
end

return Constructor