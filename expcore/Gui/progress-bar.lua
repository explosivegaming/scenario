--- Gui element define for progess bars
--[[
>>>> Functions
    ProgressBar.set_maximum(element,amount,start_full) --- Sets the maximum value that represents the end value of the progress bar
    ProgressBar.increment(element,amount) --- Increases the value of the progressbar, if a define is given all of its instances are incremented
    ProgressBar.decrement(element,amount) --- Decreases the value of the progressbar, if a define is given all of its instances are decresed

    ProgressBar.new_progressbar(name) --- Creates a new progressbar element define
    ProgressBar._prototype:set_maximum(amount,start_full) --- Sets the maximum value that represents the end value of the progress bar
    ProgressBar._prototype:increment(amount,category) --- Increases the value of the progressbar
    ProgressBar._prototype:decrement(amount,category) --- Decreases the value of the progressbar
    ProgressBar._prototype:add_element(element) --- Adds an element into the list of instances that will are waiting to complete, does not work with store
    ProgressBar._prototype:reset_element(element) --- Resets an element, or its store, to be back at the start, either 1 or 0

    ProgressBar._prototype:on_complete() --- Triggers when a progress bar element compeltes (hits 0 or 1)
    ProgressBar._prototype:on_complete() --- Triggers when a store value completes (hits 0 or 1)
    ProgressBar._prototype:event_counter() --- Event handler factory that counts up by 1 every time the event triggeres
    ProgressBar._prototype:event_countdown() --- Event handler factory that counts down by 1 every time the event triggeres
]]
local Gui = require 'expcore.gui.core'
local Global = require 'utils.global'
local Game = require 'utils.game'

--- Event call for when the value is outside the range 0-1
-- @tparam define table the define that this is acting on
-- @tparam element LuaGuiElement the element that triggered the event
local function event_call(define,element)
    local player = Game.get_player_by_index(element.player_index)

    if define.events.on_complete then
        define.events.on_complete(player,element,function()
            define:add_element(element)
            define:reset_element(element)
        end)
    end
end

--- Store call for store update
-- @tparam define table the define that this is acting on
-- @tparam element LuaGuiElement the element that triggered the event
local function store_call(define,element,value)
    element.value = value
    if define.start_full and value <= 0 or not define.start_full and value >= 1 then
        event_call(define,element)
    end
end

local ProgressBar = {
    unregistered={},
    independent={},
    _prototype=Gui._prototype_factory{
        -- note both events will recive a reset function that can be used to reset the progress of the element/store
        on_complete = Gui._event_factory('on_complete'),
        on_store_complete = Gui._event_factory('on_store_complete'),
        add_store = Gui._store_factory(store_call),
        add_sync_store = Gui._sync_store_factory(store_call)
    }
}
Global.register({
    ProgressBar.unregistered,
    ProgressBar.independent
},function(tbl)
    ProgressBar.unregistered = tbl[1]
    ProgressBar.independent = tbl[2]
end)

--- Gets the define data, cant use Gui.get_define as it would error
-- @tparam define ?table|string the define to get
-- @treturn table the define or nil
local function get_define(define)
    if type(define) == 'table' then
        if define.name and Gui.defines[define.name] then
            return Gui.defines[define.name]
        end
    end

    return Gui.defines[define]
end

--- Gets the element data, used when there is no define
-- @tparam element LuaGuiElement
-- @treturn table the element data simialr to define
local function get_element(element)
    if not element.valid then return end
    local name = element.player_index..':'..element.index

    if ProgressBar.unregistered[name] then
        return ProgressBar.unregistered[name]

    else
        ProgressBar.unregistered[name] = {
            element=element,
            maximum=1
        }
        return ProgressBar.unregistered[name]

    end
end

--- Sets the maximum value that represents the end value of the progress bar
-- @tparam element ?LuaGuiElement|string either a gui element or a registered define
-- @tparam amount number the amount to have set as the maximum
-- @tparam[opt=false] start_full boolean when true the bar will start filled, to be used with decrease
function ProgressBar.set_maximum(element,amount,start_full)
    amount = amount > 0 and amount or error('amount must be greater than 0')

    local define = get_define(element)
    if define then
        define:set_maximum(amount,start_full)

    else
        local element_data = get_element(element)

        if element_data then
            element_data.maximum = amount
            if start_full then
                element.value = 1
            end
        end

    end
end

--- Increases the value of the progressbar, if a define is given all of its instances are incremented
-- @tapram element ?LuaGuiElement|string either a gui element or a registered define
-- @tparam[opt=1] amount number the amount to increase the progressbar by
function ProgressBar.increment(element,amount)
    amount = type(amount) == 'number' and amount or 1

    local define = get_define(element)
    if define then
        define:increment(amount)

    else
        local element_data = get_element(element)

        if element_data then
            local max = element_data.maximum > 0 and element_data.maximum or 1
            local real_amount = amount/max
            element.value = element.value + real_amount

            if element.value >= 1 then
                return true
            end
        end

    end
end

--- Decreases the value of the progressbar, if a define is given all of its instances are decresed
-- @tapram element ?LuaGuiElement|string either a gui element or a registered define
-- @tparam[opt=1] amount number the amount to decrease the progressbar by
function ProgressBar.decrement(element,amount)
    amount = type(amount) == 'number' and amount or 1

    local define = get_define(element)
    if define then
        define:decrement(amount)

    else
        local element_data = get_element(element)

        if element_data then
            local max = element_data.maximum > 0 and element_data.maximum or 1
            local real_amount = amount/max
            element.value = element.value - real_amount

            if element.value <= 0 then
                return true
            end
        end

    end
end

--- Creates a new progressbar element define
-- @tparam[opt] name string the optional debug name that can be added
-- @treturn table the new progressbar elemente define
function ProgressBar.new_progressbar(name)
    local self = Gui._define_factory(ProgressBar._prototype)
    self.draw_data.type = 'progressbar'

    if name then
        self:debug_name(name)
    end

    self.post_draw = function(element)
        if self.store then
            local category = self.categorize and self.categorize(element) or nil
            local value = self:get_store(category)
            if not value then
                value = self.start_full and 1 or 0
                self:set_store(category,value)
            end
            element.value = value

        else
            if self.start_full then
                self.value = 1
            end

            if not ProgressBar.independent[self.name] then
                ProgressBar.independent[self.name] = {}
            end

            table.insert(ProgressBar.independent[self.name],element)

        end

    end

    return self
end

--- Sets the maximum value that represents the end value of the progress bar
-- @tparam amount number the amount to have set as the maximum
-- @tparam[opt=false] start_full boolean when true the bar will start filled, to be used with decrease
function ProgressBar._prototype:set_maximum(amount,start_full)
    amount = amount > 0 and amount or error('amount must be greater than 0')
    self.maximum = amount
    if start_full then
        self.start_full = true
    else
        self.start_full = false
    end
    return self
end

--- Main logic for changing the value of a progress bar, this only applies when its a registered define
-- @tparam self table the define that is being changed
-- @tparam amount number the amount which it is being changed by, may be negative
-- @tparam[opt] category string the category to use with store
local function change_value_prototype(self,amount,category)

    local function reset_store()
        local value = self.start_full and 1 or 0
        local _category = category or value
        self:set_store(_category,value)
    end

    if self.store then
        local value = self:get_store(category) or self.start_full and 1 or 0
        local new_value = value + amount

        if self.start_full and value <= 0 or not self.start_full and value >= 1 then
            self:set_store(category)
            if self.events.on_store_complete then
                category = category or reset_store
                self.events.on_store_complete(category,reset_store)
            end
        end

        category = category or new_value
        self:set_store(category,new_value)
    end

    if ProgressBar.independent[self.name] then
        for key,element in pairs(ProgressBar.independent[self.name]) do
            if not element or not element.valid then
                ProgressBar.independent[self.name][key] = nil
            else
                element.value = element.value + amount

                if self.start_full and element.value <= 0 or not self.start_full and element.value >= 1 then
                    ProgressBar.independent[self.name][key] = nil
                    event_call(self,element)
                end
            end
        end
    end

end

--- Increases the value of the progressbar
-- @tparam[opt=1] amount number the amount to increase the progressbar by
-- @tparam[opt] category string the category that is used with a store
function ProgressBar._prototype:increment(amount,category)
    amount = type(amount) == 'number' and amount or 1
    local max = self.maximum > 0 and self.maximum or 1
    local real_amount = amount/max

    change_value_prototype(self,real_amount,category)
end

--- Decreases the value of the progressbar
-- @tparam[opt=1] amount number the amount to decrease the progressbar by
-- @tparam[opt] category string the category that is used with a store
function ProgressBar._prototype:decrement(amount,category)
    amount = type(amount) == 'number' and amount or 1
    local max = self.maximum > 0 and self.maximum or 1
    local real_amount = amount/max

    change_value_prototype(self,-real_amount,category)
end

--- Adds an element into the list of instances that will are waiting to complete, does not work with store
-- note use store if you want persistent data, this only stores the elements not the values which they have
-- @tparam element LuaGuiElement the element that you want to add into the waiting to complete list
function ProgressBar._prototype:add_element(element)
    if self.store then return end
    if not ProgressBar.independent[self.name] then
        ProgressBar.independent[self.name] = {}
    end
    table.insert(ProgressBar.independent[self.name],element)
end

--- Resets an element, or its store, to be back at the start, either 1 or 0
-- @tparam element LuaGuiElement the element that you want to reset the progress of
function ProgressBar._prototype:reset_element(element)
    if not element or not element.valid then return end
    local value = self.start_full and 1 or 0
    if self.store then
        local category = self.categorize and self.categorize(element) or value
        self:set_store(category,value)
    else
        element.value = value
    end
end

--- Event handler factory that counts up by 1 every time the event triggeres
-- @treturn function the event handler
function ProgressBar._prototype:event_counter()
    return function()
        self:increment()
    end
end

--- Event handler factory that counts down by 1 every time the event triggeres
-- @treturn function the event handler
function ProgressBar._prototype:event_countdown()
    return function()
        self:decrement()
    end
end

return ProgressBar