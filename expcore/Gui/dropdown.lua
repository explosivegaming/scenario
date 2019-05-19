--- Gui class define for dropdowns and list boxs
--[[
>>>> Functions
    Dropdown.new_dropdown(name) --- Creates a new dropdown element define
    Dropdown.new_list_box(name) --- Creates a new list box element define

    Dropdown._prototype:on_element_update(callback) --- Registers a handler for when an element instance updates
    Dropdown._prototype:on_store_update(callback) --- Registers a handler for when the stored value updates

    Dropdown._prototype:new_static_options(options,...) --- Adds new static options to the dropdown which will trigger the general callback
    Dropdown._prototype:new_dynamic_options(callback) --- Adds a callback which should return a table of values to be added as options for the dropdown (appended after static options)
    Dropdown._prototype:add_option_callback(option,callback) --- Adds a case specific callback which will only run when that option is selected (general case still triggered)

    Dropdown.select_value(element,value) --- Selects the option from a dropdown or list box given the value rather than key
    Dropdown.get_selected_value(element) --- Returns the currently selected value rather than index

    Other functions present from expcore.gui.core
]]
local Gui = require './core'
local Game = require 'utils.game'

--- Event call for on_selection_state_changed and store update
-- @tparam define table the define that this is acting on
-- @tparam element LuaGuiElement the element that triggered the event
-- @tparam value string the new option for the dropdown
local function event_call(define,element,value)
    local player = Game.get_player_by_index(element.player_index)

    if define.events.on_element_update then
        define.events.on_element_update(player,element,value)
    end

    if define.option_callbacks and define.option_callbacks[value] then
        define.option_callbacks[value](player,element,value)
    end
end

--- Store call for store update
-- @tparam define table the define that this is acting on
-- @tparam element LuaGuiElement the element that triggered the event
-- @tparam value string the new option for the dropdown
local _select_value
local function store_call(define,element,value)
    _select_value(element,value)
    event_call(define,element,value)
end

local Dropdown = {
    _prototype=Gui._prototype_factory{
        on_element_update = Gui._event_factory('on_element_update'),
        on_store_update = Gui._event_factory('on_store_update'),
        add_store = Gui._store_factory(store_call),
        add_sync_store = Gui._sync_store_factory(store_call)
    }
}

--- Creates a new dropdown element define
-- @tparam[opt] name string the optional debug name that can be added
-- @treturn table the new dropdown element define
function Dropdown.new_dropdown(name)

    local self = Gui._define_factory(Dropdown._prototype)
    self.draw_data.type = 'drop-down'

    if name then
        self:debug_name(name)
    end

    self.post_draw = function(element)
        if self.dynamic_options then
            local player = Game.get_player_by_index(element.player_index)
            local dynamic_options = self.dynamic_options(player,element)
            local items = element.items
            for _,v in pairs(dynamic_options) do
                table.insert(items,v)
            end
            element.items = items
        end

        if self.store then
            local category = self.categorize and self.categorize(element) or nil
            local value = self:get_store(category)
            if value then Dropdown.select_value(element,value) end
        end
    end

    Gui.on_selection_state_changed(self.name,function(event)
        local element = event.element
        local value = Dropdown.get_selected_value(element)

        if self.store then
            local category = self.categorize and self.categorize(element) or value
            self:set_store(category,value)

        else
            event_call(self,element,value)

        end

    end)

    return self
end

--- Creates a new list box element define
-- @tparam[opt] name string the optional debug name that can be added
-- @treturn table the new list box element define
function Dropdown.new_list_box(name)
    local self = Dropdown.new_dropdown(name)
    self.draw_data.type = 'list-box'

    return self
end

--- Adds new static options to the dropdown which will trigger the general callback
-- @tparam options ?string|table either a table of option strings or the first option string, with a table values are the options
-- @tparam[opt] ... when options is not a table you can add the options one after each other
-- @tparam self the define to allow chaining
function Dropdown._prototype:new_static_options(options,...)
    if type(options) == 'string' then
        options = {options}
        for _,v in pairs({...}) do
            table.insert(options,v)
        end
    end

    self.options = options
    self.draw_data.items = options
    return self
end
Dropdown._prototype.add_options = Dropdown._prototype.new_static_options

--- Adds a callback which should return a table of values to be added as options for the dropdown (appended after static options)
-- @tparam callback function the function that will run to get the options for the dropdown
-- callback param - player LuaPlayer - the player that the element is being drawn to
-- callback param - element LuaGuiElement - the element that is being drawn
-- callback return - table - the values of this table will be appended to the static options of the dropdown
-- @tparam self the define to allow chaining
function Dropdown._prototype:new_dynamic_options(callback)
    if type(callback) ~= 'function' then
        return error('Dynamic options callback must be a function',2)
    end
    self.dynamic_options = callback
    return self
end
Dropdown._prototype.add_dynamic = Dropdown._prototype.new_dynamic_options

--- Adds a case specific callback which will only run when that option is selected (general case still triggered)
-- @tparam option string the name of the option to trigger the callback on; if not already added then will be added as an option
-- @tparam callback function the function that will be called when that option is selected
-- callback param - player LuaPlayer - the player who owns the gui element
-- callback param - element LuaGuiElement - the element which is being effected
-- callback param - value string - the new option that has been selected
-- @tparam self the define to allow chaining
function Dropdown._prototype:add_option_callback(option,callback)
    if not self.option_callbacks then self.option_callbacks = {} end
    if not self.options then self.options = {} end

    self.option_callbacks[option] = callback
    if not table.contains(self.options,option) then
        table.insert(self.options,option)
    end

    return self
end

--- Selects the option from a dropdown or list box given the value rather than key
-- @tparam element LuaGuiElement the element that contains the option
-- @tparam value string the option to select from the dropdown
-- @treturn number the key where the value was
function Dropdown.select_value(element,value)
    for k,item in pairs(element.items) do
        if item == value then
            element.selected_index = k
            return k
        end
    end
end
_select_value = Dropdown.select_value

--- Returns the currently selected value rather than index
-- @tparam element LuaGuiElement the gui element that you want to get the value of
-- @treturn string the value that is currently selected
function Dropdown.get_selected_value(element)
    local index = element.selected_index
    return element.items[index]
end

return Dropdown