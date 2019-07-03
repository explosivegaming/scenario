--- Gui class define for checkbox and radiobuttons
--[[
>>>> Using an option set
    An option set is a set of radio buttons where only one of them can be active at a time, this means that when one
    is clicked all the other ones are set to false, an option set must be defined before hand and will always store
    its state but is not limited by how it can categorize the store.

    First you must register the store with a name and a update callback, and an optional function for categorize:

    local example_option_set =
    Gui.new_option_set('example-option-set',function(value,category)
        game.print('Example options set '..category..' is now: '..tostring(value))
    end,Gui.categorize_by_player)

    Then you must register some radiobutton defines and include them in the option set:

    local example_option_one =
    Gui.new_radiobutton()
    :set_caption('Option One')
    :add_as_option(example_option_set,'One')

    local example_option_two =
    Gui.new_radiobutton()
    :set_caption('Option Two')
    :add_as_option(example_option_set,'Two')

    Note that these radiobuttons can still have on_element_update events but this may result in a double trigger of events as
    the option set update is always triggered; also add_store cant be used as the option set acts as the store however get
    and set store will still work but will effect the option set rather than the individual radiobuttons.

>>>> Functions
    Checkbox.new_checkbox(name) --- Creates a new checkbox element define
    Checkbox._prototype_checkbox:on_element_update(callback) --- Registers a handler for when an element instance updates
    Checkbox._prototype_checkbox:on_store_update(callback) --- Registers a handler for when the stored value updates

    Checkbox.new_radiobutton(name) --- Creates a new radiobutton element define
    Checkbox._prototype_radiobutton:on_element_update(callback) --- Registers a handler for when an element instance updates
    Checkbox._prototype_radiobutton:on_store_update(callback) --- Registers a handler for when the stored value updates
    Checkbox._prototype_radiobutton:add_as_option(option_set,option_name) --- Adds this radiobutton to be an option in the given option set (only one can be true at a time)

    Checkbox.new_option_set(name,callback,categorize) --- Registers a new option set that can be linked to radiobutton (only one can be true at a time)
    Checkbox.draw_option_set(name,element) --- Draws all radiobuttons that are part of an option set at once (Gui.draw will not work)

    Checkbox.reset_radiobutton(element,exclude,recursive) --- Sets all radiobutton in a element to false (unless excluded) and can act recursively

    Other functions present from expcore.gui.core
]]
local Gui = require 'expcore.gui.core'
local Prototype = require 'expcore.gui.prototype'
local Store = require 'expcore.store'
local Game = require 'utils.game'

--- Store call for store update
-- @tparam table define the define that this is acting on
-- @tparam LuaGuiElement element the element that triggered the event
-- @tparam boolean value the new state of the checkbox
local function store_update(define,element,value)
    element.state = value
    local player = Game.get_player_by_index(element.player_index)
    define:raise_event('on_element_update',player,element,value)
end

local Checkbox = {
    option_sets={},
    option_categorize={},
    _prototype_checkbox=Prototype.extend{
        on_element_update = Prototype.event,
        on_store_update = Prototype.event,
        add_store = Prototype.store(false,store_update),
        add_sync_store = Prototype.store(true,store_update)
    },
    _prototype_radiobutton=Prototype.extend{
        on_element_update = Prototype.event,
        on_store_update = Prototype.event,
        add_store = Prototype.store(false,store_update),
        add_sync_store = Prototype.store(true,store_update)
    }
}

--- Creates a new checkbox element define
-- @tparam[opt] string name the optional debug name that can be added
-- @treturn table the new checkbox element define
function Checkbox.new_checkbox(name)

    local self = Gui.new_define(Checkbox._prototype_checkbox,name)
    self.draw_data.type = 'checkbox'
    self.draw_data.state = false

    self:on_draw(function(player,element)
        if self.store then
            local category = self.categorize and self.categorize(element) or nil
            local state = self:get_store(category,true)
            if state then element.state = true end
        end
    end)

    Gui.on_checked_state_changed(self.name,function(event)
        local element = event.element

        if self.option_set then
            local value = Checkbox.option_sets[self.option_set][element.name]
            local category = self.categorize and self.categorize(element)
            self:set_store(category,value)

        elseif self.store then
            local value = element.state
            local category = self.categorize and self.categorize(element)
            self:set_store(category,value)

        else
            self:raise_event('on_element_update',event.player,element,element.state)

        end
    end)

    return self
end

--- Creates a new radiobutton element define, has all functions checkbox has
-- @tparam[opt] string name the optional debug name that can be added
-- @treturn table the new button element define
function Checkbox.new_radiobutton(name)
    local self = Checkbox.new_checkbox(name)
    self.draw_data.type = 'radiobutton'

    local mt = getmetatable(self)
    mt.__index = Checkbox._prototype_radiobutton

    return self
end

--- Adds this radiobutton to be an option in the given option set (only one can be true at a time)
-- @tparam string option_set the name of the option set to add this element to
-- @tparam string option_name the name of this option that will be used to identify it
-- @treturn self the define to allow chaining
function Checkbox._prototype_radiobutton:add_as_option(option_set,option_name)
    self.option_set = option_set
    self.option_name = option_name or self.name

    Checkbox.option_sets[option_set][self.option_name] = self.name
    Checkbox.option_sets[option_set][self.name] = self.option_name

    self:add_store(Checkbox.option_categorize[option_set])

    return self
end

--- Gets the stored value of the radiobutton or the option set if present
-- @tparam string category[opt] the category to get such as player name or force name
-- @tparam boolean internal used to prevent stackover flow
-- @treturn any the value that is stored for this define
function Checkbox._prototype_radiobutton:get_store(category,internal)
    if not self.store then return end
    local location = not internal and self.option_set or self.store
    return Store.get(location,category)
end

--- Sets the stored value of the radiobutton or the option set if present
-- @tparam string category[opt] the category to get such as player name or force name
-- @tparam boolean value the value to set for this define, must be valid for its type ie for checkbox etc
-- @tparam boolean internal used to prevent stackover flow
-- @treturn boolean true if the value was set
function Checkbox._prototype_radiobutton:set_store(category,value,internal)
    if not self.store then return end
    local location = not internal and self.option_set or self.store
    return Store.set(location,category,value)
end

--- Registers a new option set that can be linked to radiobuttons (only one can be true at a time)
-- @tparam string name the name of the option set, must be unique
-- @tparam function callback the update callback when the value of the option set changes
-- callback param - value string - the new selected option for this option set
-- callback param - category string - the category that updated if categorize was used
-- @tparam function categorize the function used to convert an element into a string
-- @treturn string the name of this option set to be passed to add_as_option
function Checkbox.new_option_set(name,callback,categorize)

    Store.register(name,function(value,category)
        local options = Checkbox.option_sets[name]
        for opt_name,define_name in pairs(options) do
            if Gui.defines[define_name] then
                local define = Gui.get_define(define_name)
                local state = opt_name == value
                define:set_store(category,state,true)
            end
        end
        callback(value,category)
    end)

    Checkbox.option_categorize[name] = categorize
    Checkbox.option_sets[name] = {}

    return name
end

--- Draws all radiobuttons that are part of an option set at once (Gui.draw will not work)
-- @tparam string name the name of the option set to draw the radiobuttons of
-- @tparam LuaGuiElement element the parent element that the radiobuttons will be drawn to
function Checkbox.draw_option_set(name,element)
    if not Checkbox.option_sets[name] then return end
    local options = Checkbox.option_sets[name]

    for _,option in pairs(options) do
        if Gui.defines[option] then
            Gui.defines[option]:draw_to(element)
        end
    end

end

--- Sets all radiobutton in a element to false (unless excluded) and can act recursively
-- @tparam LuaGuiElement element the root gui element to start setting radio buttons from
-- @tparam[opt] table exclude ?string|table the name of the radiobutton to exclude or a of radiobuttons where true will set the state true
-- @tparam[opt=false] ?number|boolean recursive if true will recur as much as possible, if a will recur that number of times
-- @treturn boolean true if successful
function Checkbox.reset_radiobuttons(element,exclude,recursive)
    if not element or not element.valid then return end
    exclude = type(exclude) == 'table' and exclude or exclude ~= nil and {[exclude]=true} or {}
    recursive = type(recursive) == 'number' and recursive-1 or recursive

    for _,child in pairs(element.children) do
        if child and child.valid and child.type == 'radiobutton' then
            local state = exclude[child.name] or false
            local define = Gui.defines[child.name]

            if define then
                local category = define.categorize and define.categorize(child) or state
                define:set_store(category,state)

            else
                child.state = state

            end

        elseif child.children and (type(recursive) == 'number' and recursive >= 0 or recursive == true) then
            Checkbox.reset_radiobutton(child,exclude,recursive)

        end
    end

    return true
end

return Checkbox