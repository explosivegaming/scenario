--- This file is a breakout from core which forcues on instance management of defines
--[[
>>>> Using registered instance groups
    The main use of this module is to register a group of elements referred here as "instances of an element define" in which
    is meant that you define the name of a group of drawn elements that are really just multiple versions of a single element.
    For example this might be that you have one label in multiple places (either for one player or many) and you want to update
    the caption of all of them at once; this is where this module comes it.

    First you must register the way that the instances are stored and under what name, using Instances.register you will give the
    name of the collective group of instances followed by an optional categorise function which allows variants to be stored under one
    name (like one for each force or player)

    -- categorise works in the same way as store categorise
    -- so the function will world here but no value is stored only gui elements
    Instances.register('score',Gui.categorize_by_force)

    Then when you draw the new element to a gui you will want to add the element to the group:

    Instances.add_element('score',new_element)

    Then when you want to get the instances you have two options; Instances.get_elements or Instances.apply_to_elements when you want loop
    over the elements it is more efficient to use apply_to_elements:

    Instances.get_elements('score','player') -- returns all elements that were added with the 'player' category
    Instances.apply_to_elements('score','player',function(element) -- runs the function on every valid element
        element.caption = 0
    end)

    Note that if you don't give a categorise function then you don't need to give a category when getting the elements.

>>>> Using unregistered instance groups
    When using a registered group and the functions that go with them it is much simpler to use and more importantly includes error checking
    for valid instance group names; the down side is that the group must be registered which can only be done during start-up and not during runtime.
    To counter this there are two functions similar to those above in order to add and get instances but may lead to errors not being noticed due to
    the error internal error checking being skipped to allow it to work.

    The main difference between the two groups of functions is that the category must always be present even if is nil; example below shows how a
    instance group would work when registered vs unregistered:

    -- Registered with category
    Instances.register('score',Gui.categorize_by_force) -- force_store will return the force name of an element
    Instances.add_element('score',new_element) -- the new element is added to the category based on in force
    Instances.apply_to_elements('score','player',function(element)
        element.caption = '0'
    end) -- gets all instances from the player force and sets the caption to 0

    -- Unregistered with category
    Instances.unregistered_add_element('score','player',new_element) -- adds the new element to the player category
    Instances.unregistered_apply_to_elements('score','player',function(element)
        element.caption = '0'
    end) -- gets all instances from the player force and sets the caption to 0

    -- Registered without category; note that category can just be ignored
    Instances.register('score') -- all instances will be under one group with no categories
    Instances.add_element('score',new_element) -- adds the new element to the instance list
    Instances.apply_to_elements('score',function(element)
        element.caption = '0'
    end) -- gets all instances and sets the element caption to 0

    -- Unregistered without category; note that category must be given as nil
    Instances.unregistered_add_element('score',nil,new_element) -- adds the new element to a single group with no categories
    Instances.unregistered_apply_to_elements('score',nil,function(element)
        element.caption = '0'
    end) -- gets all instances and sets the element caption to 0

>>>> Functions
    Instances.has_categories(name) --- Returns if a instance group has a categorise function; must be registered
    Instances.is_registered(name) --- Returns if the given name is a registered instance group
    Instances.register(name,categorise) --- Registers the name of an instance group to allow for storing element instances

    Instances.add_element(name,element) --- Adds an element to the instance group under the correct category; must be registered
    Instances.get_elements_raw(name,category) --- Gets all element instances without first removing any invalid ones; used internally and must be registered
    Instances.get_valid_elements(name,category,callback) --- Gets all valid element instances and has the option of running a callback on those that are valid

    Instances.unregistered_add_element(name,category,element) --- A version of add_element that does not require the group to be registered
    Instances.unregistered_get_elements(name,category,callback) --- A version of get_elements that does not require the group to be registered
]]
local Global = require 'utils.global'

local Instances = {
    categorise={},
    data={}
}
Global.register(Instances.data,function(tbl)
    Instances.data = tbl
end)

--- Returns if a instance group has a categorise function; must be registered
-- @tparam string name the name of the instance group
-- @treturn boolean true if there is a categorise function
function Instances.has_categories(name)
    return type(Instances.categorise[name]) == 'function'
end

--- Returns if the given name is a registered instance group
-- @tparam string name the name of the instance group you are testing
-- @treturn boolean true if the name is registered
function Instances.is_registered(name)
    return Instances.categorise[name] ~= nil
end

--- Registers the name of an instance group to allow for storing element instances
-- @tparam string name the name of the instance group; must to unique
-- @tparam[opt] function categorise function used to turn the element into a string
-- categorise param - element LuaGuiElement - the gui element to be turned into a string
-- categorise return - string - the category that the element will be added to like the player's name or force's name
-- @treturn string the name that was added so it can be used as a variable
function Instances.register(name,categorise)
    if _LIFECYCLE ~= _STAGE.control then
        return error('Can only be called during the control stage', 2)
    end

    if Instances.categorise[name] then
        return error('Instances for '..name..' already exist.',2)
    end

    categorise = type(categorise) == 'function' and categorise or true

    Instances.data[name] = {}
    Instances.categorise[name] = categorise

    return name
end

--- Adds an element to the instance group under the correct category; must be registered
-- @tparam string name the name of the instance group to add the element to
-- @tparam LuaGuiElement element the element to add the the instance group
function Instances.add_element(name,element)
    if not Instances.categorise[name] then
        return error('Invalid name for instance group: '..name,2)
    end

    if Instances.has_categories(name) then
        local category = Instances.categorise[name](element)
        if not Instances.data[name][category] then Instances.data[name][category] = {} end
        table.insert(Instances.data[name][category],element)
    else
        table.insert(Instances.data[name],element)
    end
end

--- Gets all element instances without first removing any invalid ones; used internally and must be registered
-- @tparam string name the name of the instance group to get the instances of
-- @tparam[opt] string category the category to get the instance from, not needed when no categorise function
-- @treturn table the table of element instances of which some may be invalid
function Instances.get_elements_raw(name,category)
    if not Instances.categorise[name] then
        return error('Invalid name for instance group: '..name,2)
    end

    if Instances.has_categories(name) then
        return Instances.data[name][category] or {}
    else
        return Instances.data[name]
    end
end

--- Gets all valid element instances and has the option of running a callback on those that are valid
-- @tparam string name the name of the instance group to get the instances of
-- @tparam[opt] string category the category to get the instances of, not needed when no categorise function
-- @tparam[opt] callback function when given the callback will be ran on all valid elements
-- callback param - element LuaGuiElement - the current valid element
-- @treturn table the table of element instances with all invalid ones removed
function Instances.get_valid_elements(name,category,callback)
    if not Instances.categorise[name] then
        return error('Invalid name for instance group: '..name,2)
    end

    category = category or callback
    local elements = Instances.get_elements_raw(name,category)
    local categorise = Instances.has_categories(name)

    for key,element in pairs(elements) do
        if not element or not element.valid then
            elements[key] = nil
        else
            if categorise and callback then callback(element)
            elseif category then category(element) end
        end
    end

    return elements
end
Instances.get_elements = Instances.get_valid_elements
Instances.apply_to_elements = Instances.get_valid_elements

--- A version of add_element that does not require the group to be registered
-- @tparam string name the name of the instance group to add the element to
-- @tparam category ?string|nil the category to add the element to, can be nil but must still be given
-- @tparam LuaGuiElement element the element to add to the instance group
function Instances.unregistered_add_element(name,category,element)
    if not Instances.data[name] then Instances.data[name] = {} end
    if category then
        if not Instances.data[name][category] then Instances.data[name][category] = {} end
        table.insert(Instances.data[name][category],element)
    else
        table.insert(Instances.data[name],element)
    end
end

--- A version of get_elements that does not require the group to be registered
-- @tparam string name the name of the instance group to get the instances of
-- @tparam category ?string|nil the category to get the instances of, can be nil but must still be given
-- @tparam[opt] function callback when given will be called on all valid instances
-- callback param - element LuaGuiElement - the current valid element
-- @treturn table the table of element instances with all invalid ones removed
function Instances.unregistered_get_elements(name,category,callback)
    local elements = Instances.data[name]
    if elements and category then
        elements = elements[category]
    end

    if not elements then return {} end

    for key,element in pairs(elements) do
        if not element or not element.valid then
            elements[key] = nil
        else
            if callback then callback(element) end
        end
    end

    return elements
end
Instances.unregistered_apply_to_elements = Instances.runtime_get_elements

return Instances