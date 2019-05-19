--- Core gui file for making element defines and element classes (use require 'expcore.gui')
-- see utils.gui for event handlering
-- see expcore.gui.test for examples for element defines
--[[
>>>> Basic useage with no defines
    This module can be igroned if you are only wanting only event handlers as utils.gui adds the following:

    Gui.uid_name() --- Generates a unqiue name to register events to
    Gui.on_checked_state_changed(callback) --- Register a handler for the on_gui_checked_state_changed event
    Gui.on_click(callback) --- Register a handler for the on_gui_click event
    Gui.on_elem_changed(callback) --- Register a handler for the on_gui_elem_changed
    Gui.on_selection_state_changed(callback) --- Register a handler for the on_gui_selection_state_changed event
    Gui.on_text_changed(callback) --- Register a handler for the on_gui_text_changed event
    Gui.on_value_changed(callback) --- Register a handler for the on_gui_value_changed event

    Note that all event handlers will include event.player as a valid player and that if the player or the
    element is not valid then the callback will not be run.

>>>> Interal factory functions
    There are a few factory function that are used by the class definations the use of these function are important to
    know about but should only be used when making a new class deination rather than an element defination. See one of
    the existing class definations for an example of when to use these.

>>>> Basic prototype functions
    Using a class defination you can create a new element dinfation in our examples we will be using the checkbox.

    local checkbox_example = Gui.new_checkbox()

    Although all class definations are stored in Gui.classes the main function used to make new element defination are
    made aviable in the top level gui module. All functions which return a new element defination will accept a name argument
    which is a name which is used while debuging and is not required to be used (has not been used in examples)

    Every element define will accept a caption and tooltip (although some may not show) and to do this you would use the two
    set function provided for the element defines:

    checkbox_example:set_caption('Example Checkbox')
    checkbox_example:set_tooltip('Example checkbox')

    Each element define can have event handlers set, for our example checkbox we only have access to on_change which will trigger
    when the state of the checkbox changes; if we want to assign handlers using the utils.gui methods then we can get the uid by calling
    the uid function on the element define; however, each element can only have one handler (of each event) so it is not possible to use
    Gui.on_checked_state_changed and on_change at the same time in our example.

    checkbox_example:on_change(function(player,element,value)
        player.print('Example checkbox is now: '..tostring(value))
    end)

    local checkbox_example_uid = checkbox_example:uid()
    Gui.on_click(checkbox_example_uid,function(event)
        event.player.print('You clicked the example checkbox!')
    end)

    Finally you will want to draw your element defines for which you can call deirectly on the deinfe or use Gui.draw to do; when Gui.draw is
    used it can be given either the element define, the define's uid or the debug name of the define (if set):

    checkbox_example:draw_to(parent_element)
    Gui.draw(checkbox_example_uid,parent_element)

>>>> Using authenticators with draw
    When an element is drawn to its parent it can always be used but if you want to limit who can use it then you can use an authenticator. There
    are two types which can be used: post and pre; using a pre authenticator will mean that the draw function is stoped before the element is added
    to the parent element while using a post authenticator will draw the element to the parent but will disable the element from interaction. Both may
    be used if you have use for such.

    -- unless global.checkbox_example_allow_pre_auth is true then the checkbox will not be drawn
    checkbox_example:set_pre_authenticator(function(player,define_name)
        player.print('Example checkbox pre auth callback ran')
        return global.checkbox_example_allow_pre_auth
    end)

    -- unless global.checkbox_example_allow_post_auth is true then the checkbox will be drawn but deactiveated (provided pre auth returns true)
    checkbox_example:set_post_authenticator(function(player,define_name)
        player.print('Example checkbox pre auth callback ran')
        return global.checkbox_example_allow_post_auth
    end)

>>>> Using store
    A powerful assept of this gui system is allowing an automatic store for the state of a gui element, this means that when a gui is closed and re-opened
    the elements which have a store will retain they value even if the element was previously destroied. The store is not limited to only per player and can
    be catergorised by any method you want such as one that is shared between all players or by all players on a force. Using a method that is not limited to
    one player means that when one player changes the state of the element it will be automaticlly updated for all other player (even if the element is already drawn)
    and so this is a powerful and easy way to sync gui elements.

    -- note the example below is the same as checkbox_example:add_store(Gui.player_store)
    checkbox_example:add_store(function(element)
        local player = Game.get_player_by_index(element.player_index)
        return player.force.name
    end)

    Of course this tool is not limited to only player interactions; the current satate of a define can be gotten using a number of methods and the value can
    even be updated by the script and have all instances of the element define be updated. When you use a category then we must give a category to the get
    and set functions; in our case we used Gui.player_store which uses the player's name as the category which is why 'Cooldude2606' is given as a argument,
    if we did not set a function for add_store then all instances for all players have the same value and so a category is not required.

    checkbox_example:get_store('Cooldude2606')
    Gui.get_store(name,'Cooldude2606')

    checkbox_example:set_store('Cooldude2606',true)
    Gui.set_store(name,'Cooldude2606',true)

    These methods use the Store module which means that if you have the need to access these sotre location (for example if you want to add a watch function) then
    you can get the store location of any define using checkbox_example.store

    Important note about event handlers: when the store is updated it will also trigger the event handlers (such as on_element_update) for that define but only
    for the valid instances of the define which means if a player does not have the element drawn on a gui then it will not trigger the events; if you want a
    trigger for all updates then you can use on_store_update however you will be required to parse the category which may or may not be a
    player name (depends what store categorize function you use)

>>>> Example formating

    local checkbox_example =
    Gui.new_checkbox()
    :set_caption('Example Checkbox')
    :set_tooltip('Example checkbox')
    :add_store(Gui.player_store)
    :on_element_update(function(player,element,value)
        player.print('Example checkbox is now: '..tostring(value))
    end)

>>>> Functions
    Gui._prototype_factory(tbl) --- Used internally to create new prototypes for element defines
    Gui._event_factory(name) --- Used internally to create event handler adders for element defines
    Gui._store_factory(callback) --- Used internally to create store adders for element defines
    Gui._sync_store_factory(callback) --- Used internally to create synced store adders for element defines
    Gui._define_factory(prototype) --- Used internally to create new element defines from a class prototype

    Gui._prototype:uid() --- Gets the uid for the element define
    Gui._prototype:debug_name(name) --- Sets a debug alias for the define
    Gui._prototype:set_caption(caption) --- Sets the caption for the element define
    Gui._prototype:set_tooltip(tooltip) --- Sets the tooltip for the element define
    Gui._prototype:on_element_update(callback) --- Add a hander to run on the general value update event, different classes will handle this event differently

    Gui._prototype:set_pre_authenticator(callback) --- Sets an authenticator that blocks the draw function if check fails
    Gui._prototype:set_post_authenticator(callback) --- Sets an authenticator that disables the element if check fails
    Gui._prototype:draw_to(element) --- Draws the element using what is in the draw_data table, allows use of authenticator if present, registers new instances if store present
    Gui.draw(name,element) --- Draws a copy of the element define to the parent element, see draw_to

    Gui._prototype:add_store(categorize) --- Adds a store location for the define that will save the state of the element, categorize is a function that returns a string
    Gui._prototype:add_sync_store(location,categorize) --- Adds a store location for the define that will sync between games, categorize is a function that returns a string
    Gui._prototype:on_store_update(callback) --- Adds a event callback for when the store changes are other events are not gauenteted to be raised
    Gui.player_store(element) --- A categorize function to be used with add_store, each player has their own value
    Gui.force_store(element) --- A categorize function to be used with add_store, each force has its own value
    Gui.surface_store(element) --- A categorize function to be used with add_store, each surface has its own value

    Gui._prototype:get_store(category) --- Gets the value in this elements store, category needed if categorize function used
    Gui._prototype:set_store(category,value) --- Sets the value in this elements store, category needed if categorize function used
    Gui.get_store(name,category) --- Gets the value that is stored for a given element define, category needed if categorize function used
    Gui.set_store(name,category,value) --- Sets the value stored for a given element define, category needed if categorize function used

    Gui.toggle_enable(element) --- Will toggle the enabled state of an element
    Gui.toggle_visible(element) --- Will toggle the visiblity of an element
]]
local Gui = require 'utils.gui'
local Game = require 'utils.game'
local Store = require 'expcore.store'
local Instances = require 'expcore.gui.instances'

Gui._prototype = {} -- Stores the base prototype of all element defines
Gui.classes = {} -- Stores the class definations used to create element defines
Gui.defines = {} -- Stores the indivdual element definations
Gui.names = {} -- Stores debug names to link to gui uids

--- Used internally to create new prototypes for element defines
-- @tparam tbl table a table that will have functions added to it
-- @treturn table the new table with the keys added to it
function Gui._prototype_factory(tbl)
    for k,v in pairs(Gui._prototype) do
        if not tbl[k] then tbl[k] = v end
    end
    return tbl
end

--- Used internally to create event handler adders for element defines
-- @tparam name string the key that the event will be stored under, should be the same as the event name
-- @treturn function the function that can be used to add an event handler
function Gui._event_factory(name)
    --- Gui._prototype:on_event(callback)
    --- Add a hander to run on this event, replace event with the event, different classes have different events
    -- @tparam callback function the function that will be called on the event
    -- callback param - player LuaPlayer - the player who owns the gui element
    -- callback param - element LuaGuiElement - the element that caused the event
    -- callback param - value any - (not always present) the updated value for the element
    -- callback param - ... any - other class defines may add more params
    -- @treturn self the element define to allow chaining
    return function(self,callback)
        if type(callback) ~= 'function' then
            return error('Event callback must be a function',2)
        end

        self.events[name] = callback
        return self
    end
end

--- Used internally to create store adders for element defines
-- @tparam callback a callback is called when there is an update to the stored value and stould set the state of the element
-- @treturn function the function that can be used to add a store the the define
function Gui._store_factory(callback)
    --- Gui._prototype:add_store(categorize)
    --- Adds a store location for the define that will save the state of the element, categorize is a function that returns a string
    -- @tparam[opt] categorize function if present will be called to convert an element into a category string
    -- categorize param - element LuaGuiElement - the element that needs to be converted
    -- categorize return - string - a determistic string that referses to a category such as player name or force name
    -- @treturn self the element define to allow chaining
    return function(self,categorize)
        if self.store then return end

        self.store = Store.uid_location()
        self.categorize = categorize

        Instances.register(self.name,self.categorize)

        Store.register(self.store,function(value,category)
            if self.events.on_store_update then
                self.events.on_store_update(value,category)
            end

            if Instances.is_registered(self.name) then
                Instances.apply_to_elements(self.name,category,function(element)
                    callback(self,element,value)
                end)
            end
        end)

        return self
    end
end

--- Used internally to create synced store adders for element defines
-- @tparam callback a callback is called when there is an update to the stored value and stould set the state of the element
-- @treturn function the function that can be used to add a sync store the the define
function Gui._sync_store_factory(callback)
    --- Gui._prototype:add_sync_store(location,categorize)
    --- Adds a store location for the define that will sync between games, categorize is a function that returns a string
    -- @tparam location string a unique string location, unlike add_store a uid location should not be used to avoid migration problems
    -- @tparam[opt] categorize function if present will be called to convert an element into a category string
    -- categorize param - element LuaGuiElement - the element that needs to be converted
    -- categorize return - string - a determistic string that referses to a category such as player name or force name
    -- @treturn self the element define to allow chaining
    return function(self,location,categorize)
        if self.store then return end

        if Store.is_registered(location) then
            return error('Location for store is already registered: '..location,2)
        end

        self.store = location
        self.categorize = categorize

        Instances.register(self.name,self.categorize)

        Store.register_synced(self.store,function(value,category)
            if self.events.on_store_update then
                self.events.on_store_update(value,category)
            end

            if Instances.is_registered(self.name) then
                Instances.apply_to_elements(self,category,function(element)
                    callback(self,element,value)
                end)
            end
        end)

        return self
    end
end

--- Used internally to create new element defines from a class prototype
-- @tparam prototype table the class prototype that will be used for the element define
-- @treturn table the new element define with all functions accessed via __index metamethod
function Gui._define_factory(prototype)
    local uid = Gui.uid_name()
    local define = setmetatable({
        name=uid,
        events={},
        draw_data={
            name=uid
        }
    },{
        __index=prototype,
        __call=function(self,element)
            return self:draw_to(element)
        end
    })
    Gui.defines[define.name] = define
    return define
end

--- Gets the uid for the element define
-- @treturn string the uid of this element define
function Gui._prototype:uid()
    return self.name
end

--- Sets a debug alias for the define
-- @tparam name string the debug name for the element define that can be used to get this element define
-- @treturn self the element define to allow chaining
function Gui._prototype:debug_name(name)
    self.debug_name = name
    return self
end

--- Sets the caption for the element define
-- @tparam caption string the caption that will be drawn with the element
-- @treturn self the element define to allow chaining
function Gui._prototype:set_caption(caption)
    self.draw_data.caption = caption
    return self
end

--- Sets the tooltip for the element define
-- @tparam tooltip string the tooltip that will be displayed for this element when drawn
-- @treturn self the element define to allow chaining
function Gui._prototype:set_tooltip(tooltip)
    self.draw_data.tooltip = tooltip
    return self
end

--- Sets an authenticator that blocks the draw function if check fails
-- @tparam callback function the function that will be ran to test if the element should be drawn or not
-- callback param - player LuaPlayer - the player that the element is being drawn to
-- callback param - define_name string - the name of the define that is being drawn
-- callback return - boolean - false will stop the element from being drawn
-- @treturn self the element define to allow chaining
function Gui._prototype:set_pre_authenticator(callback)
    if type(callback) ~= 'function' then
        return error('Pre authenticator callback must be a function')
    end

    self.pre_authenticator = callback
    return self
end

--- Sets an authenticator that disables the element if check fails
-- @tparam callback function the function that will be ran to test if the element should be enabled or not
-- callback param - player LuaPlayer - the player that the element is being drawn to
-- callback param - define_name string - the name of the define that is being drawn
-- callback return - boolean - false will disable the element
-- @treturn self the element define to allow chaining
function Gui._prototype:set_post_authenticator(callback)
    if type(callback) ~= 'function' then
        return error('Authenicater callback must be a function')
    end

    self.post_authenticator = callback
    return self
end

--- Draws the element using what is in the draw_data table, allows use of authenticator if present, registers new instances if store present
-- the data with in the draw_data is set up through the use of all the other functions
-- @tparam element LuaGuiElement the element that the define will draw a copy of its self onto
-- @treturn LuaGuiElement the new element that was drawn so styles can be applied
function Gui._prototype:draw_to(element)
    if element[self.name] then return end
    local player = Game.get_player_by_index(element.player_index)

    if self.pre_authenticator then
        if not self.pre_authenticator(player,self.name) then return end
    end

    local new_element = element.add(self.draw_data)

    if self.post_authenticator then
        new_element.enabled = self.post_authenticator(player,self.name)
    end

    if Instances.is_registered(self.name) then
        Instances.add_element(self.name,new_element)
    end

    if self.post_draw then self.post_draw(new_element) end

    return new_element
end

--- Gets the value in this elements store, category needed if categorize function used
-- @tparam category[opt] string the category to get such as player name or force name
-- @treturn any the value that is stored for this define
function Gui._prototype:get_store(category)
    if not self.store then return end
    if self.categorize then
        return Store.get_child(self.store,category)
    else
        return Store.get(self.store)
    end
end

--- Sets the value in this elements store, category needed if categorize function used
-- @tparam category[opt] string the category to get such as player name or force name
-- @tparam value any the value to set for this define, must be valid for its type ie boolean for checkbox etc
-- @treturn boolean true if the value was set
function Gui._prototype:set_store(category,value)
    if not self.store then return end
    if self.categorize then
        return Store.set_child(self.store,category,value)
    else
        return Store.set(self.store,category)
    end
end

--- Gets an element define give the uid, debug name or a copy of the element define
-- @tparam name ?string|table the uid, debug name or define for the element define to get
-- @tparam[opt] internal boolean when true the error trace is one level higher (used internally)
-- @treturn table the element define that was found or an error
function Gui.get_define(name,internal)
    if type(name) == 'table' then
        if name.name and Gui.defines[name.name] then
            return Gui.defines[name.name]
        end
    end

    local define = Gui.defines[name]

    if not define and Gui.names[name] then
        return Gui.defines[Gui.names[name]]

    elseif not define then
        return error('Invalid name for checkbox, name not found.',internal and 3 or 2) or nil

    end

    return define
end

--- Gets the value that is stored for a given element define, category needed if categorize function used
-- @tparam name ?string|table the uid, debug name or define for the element define to get
-- @tparam[opt] category string the category to get the value for
-- @treturn any the value that is stored for this define
function Gui.get_store(name,category)
    local define = Gui.get_define(name,true)
    return define:get_store(category)
end

--- Sets the value stored for a given element define, category needed if categorize function used
-- @tparam name ?string|table the uid, debug name or define for the element define to set
-- @tparam[opt] category string the category to set the value for
-- @tparam value any the value to set for the define, must be valid for its type ie boolean for a checkbox
-- @treturn boolean true if the value was set
function Gui.set_store(name,category,value)
    local define = Gui.get_define(name,true)
    return define:get_store(category,value)
end

--- A categorize function to be used with add_store, each player has their own value
-- @tparam element LuaGuiElement the element that will be converted to a string
-- @treturn string the player's name who owns this element
function Gui.player_store(element)
    local player = Game.get_player_by_index(element.player_index)
    return player.name
end

--- A categorize function to be used with add_store, each force has its own value
-- @tparam element LuaGuiElement the element that will be converted to a string
-- @treturn string the player's force name who owns this element
function Gui.force_store(element)
    local player = Game.get_player_by_index(element.player_index)
    return player.force.name
end

--- A categorize function to be used with add_store, each surface has its own value
-- @tparam element LuaGuiElement the element that will be converted to a string
-- @treturn string the player's surface name who owns this element
function Gui.surface_store(element)
    local player = Game.get_player_by_index(element.player_index)
    return player.surface.name
end

--- Draws a copy of the element define to the parent element, see draw_to
-- @tparam name ?string|table the uid, debug name or define for the element define to draw
-- @tparam element LuaGuiEelement the parent element that it the define will be drawn to
-- @treturn LuaGuiElement the new element that was created
function Gui.draw(name,element)
    local define = Gui.get_define(name,true)
    return define:draw_to(element)
end

--- Will toggle the enabled state of an element
-- @tparam element LuaGuiElement the gui element to toggle
function Gui.toggle_enable(element)
    if not element or not element.valid then return end
    if not element.enabled then
        element.enabled = true
    else
        element.enabled = false
    end
end

--- Will toggle the visiblity of an element
-- @tparam element LuaGuiElement the gui element to toggle
function Gui.toggle_visible(element)
    if not element or not element.valid then return end
    if not element.visible then
        element.visible = true
    else
        element.visible = false
    end
end

return Gui