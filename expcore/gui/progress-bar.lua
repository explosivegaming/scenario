--- Gui element define for progess bars
--[[
>>>> Functions
    ProgressBar.set_maximum(element,amount,count_down) --- Sets the maximum value that represents the end value of the progress bar
    ProgressBar.increment(element,amount) --- Increases the value of the progressbar, if a define is given all of its instances are incremented
    ProgressBar.decrement(element,amount) --- Decreases the value of the progressbar, if a define is given all of its instances are decresed

    ProgressBar.new_progressbar(name) --- Creates a new progressbar element define
    ProgressBar._prototype:set_maximum(amount,count_down) --- Sets the maximum value that represents the end value of the progress bar
    ProgressBar._prototype:use_count_down(state) --- Will set the progress bar to start at 1 and trigger when it hits 0
    ProgressBar._prototype:increment(amount,category) --- Increases the value of the progressbar
    ProgressBar._prototype:increment_filtered(amount,filter) --- Increases the value of the progressbar, if the filter condition is met, does not work with store
    ProgressBar._prototype:decrement(amount,category) --- Decreases the value of the progressbar
    ProgressBar._prototype:decrement_filtered(amount,filter) --- Decreases the value of the progressbar, if the filter condition is met, does not work with store
    ProgressBar._prototype:add_element(element,maximum) --- Adds an element into the list of instances that will are waiting to complete, does not work with store
    ProgressBar._prototype:reset_element(element) --- Resets an element, or its store, to be back at the start, either 1 or 0

    ProgressBar._prototype:on_complete(callback) --- Triggers when a progress bar element compeltes (hits 0 or 1)
    ProgressBar._prototype:on_complete(callback) --- Triggers when a store value completes (hits 0 or 1)
    ProgressBar._prototype:event_counter(filter) --- Event handler factory that counts up by 1 every time the event triggeres, can filter which elements are incremented
    ProgressBar._prototype:event_countdown(filter) --- Event handler factory that counts down by 1 every time the event triggeres, can filter which elements are decremented
]]
local Gui = require 'expcore.gui.core'
local Global = require 'utils.global'
local Game = require 'utils.game'

--- Event call for when the value is outside the range 0-1
-- @tparam table define the define that this is acting on
-- @tparam LuaGuiElement element the element that triggered the event
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
-- @tparam table define the define that this is acting on
-- @tparam LuaGuiElement element the element that triggered the event
-- @tparam number value the new value for the progress bar
local function store_call(define,element,value)
    if value then
        element.value = value
        if define.count_down and value <= 0
        or not define.count_down and value >= 1 then
            event_call(define,element)
        end
    end
end

local ProgressBar = {
    unregistered={}, -- elements with no callbacks
    independent={}, -- elements with a link to a deinfe
    _prototype=Gui._prototype_factory{
        -- note both events will recive a reset function that can be used to reset the progress of the element/store
        on_complete = Gui._event_factory('on_complete'),
        on_store_complete = Gui._event_factory('on_store_complete'),
        add_store = Gui._store_factory(store_call),
        add_sync_store = Gui._sync_store_factory(store_call)
    }
}
Global.register({
    unregistered = ProgressBar.unregistered,
    independent = ProgressBar.independent
},function(tbl)
    ProgressBar.unregistered = tbl.unregistered
    ProgressBar.independent = tbl.independent
end)

--- Gets the define data, cant use Gui.get_define as it would error
-- @tparam ?table|string define the define to get
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
-- @tparam LuaGuiElement element the element to get the data of
-- @treturn table the element data simialr to define
local function get_element(element)
    if not element.valid then return end
    local name = element.player_index..':'..element.index

    if ProgressBar.unregistered[name] then
        return ProgressBar.unregistered[name]
    end
end

--- Sets the maximum value that represents the end value of the progress bar
-- @tparam ?LuaGuiElement|string element either a gui element or a registered define
-- @tparam number amount the amount to have set as the maximum
function ProgressBar.set_maximum(element,amount)
    amount = amount > 0 and amount or error('amount must be greater than 0')

    local define = get_define(element)
    if define then
        define:set_deafult_maximum(amount)

    else
        local element_data = get_element(element)

        if element_data then
            element_data.maximum = amount

		else
			local name = element.player_index..':'..element.index
			ProgressBar.unregistered[name] = {
				element=element,
				maximum=amount or 1
			}

        end

    end
end

--- Increases the value of the progressbar, if a define is given all of its instances are incremented
-- @tparam ?LuaGuiElement|string element either a gui element or a registered define
-- @tparam[opt=1] number amount the amount to increase the progressbar by
function ProgressBar.increment(element,amount)
    amount = type(amount) == 'number' and amount or 1

    local define = get_define(element)
    if define then
        define:increment(amount)

    else
        local element_data = get_element(element)

        if element_data then
            local real_amount = amount/element_data.maximum
            element.value = element.value + real_amount

            if element.value >= 1 then
                local name = element.player_index..':'..element.index
                ProgressBar.unregistered[name] = nil
                return true
            end
        end

    end
end

--- Decreases the value of the progressbar, if a define is given all of its instances are decresed
-- @tparam ?LuaGuiElement|string element either a gui element or a registered define
-- @tparam[opt=1] number amount the amount to decrease the progressbar by
function ProgressBar.decrement(element,amount)
    amount = type(amount) == 'number' and amount or 1

    local define = get_define(element)
    if define then
        define:decrement(amount)

    else
        local element_data = get_element(element)

        if element_data then
            local real_amount = amount/element_data.maximum
            element.value = element.value - real_amount

            if element.value <= 0 then
                local name = element.player_index..':'..element.index
                ProgressBar.unregistered[name] = nil
                return true
            end
        end

    end
end

--- Creates a new progressbar element define
-- @tparam[opt] string name the optional debug name that can be added
-- @treturn table the new progressbar elemente define
function ProgressBar.new_progressbar(name)
    local self = Gui._define_factory(ProgressBar._prototype)
    self.draw_data.type = 'progressbar'

    if name then
        self:debug_name(name)
    end

    self.post_draw = function(element,maximum)
        if self.store then
            local category = self.categorize and self.categorize(element) or nil
            local value = self:get_store(category)
            if not value then
                value = self.count_down and 1 or 0
                self:set_store(category,value)
            end
            element.value = value

        else
            if self.count_down then
                element.value = 1
            end

            if not ProgressBar.independent[self.name] then
                ProgressBar.independent[self.name] = {}
            end

            table.insert(ProgressBar.independent[self.name],{
                element = element,
                maximum = maximum
			})

        end

    end

    return self
end

--- Sets the maximum value that represents the end value of the progress bar
-- @tparam number amount the amount to have set as the maximum
-- @treturn table the define to allow chaining
function ProgressBar._prototype:set_default_maximum(amount)
    amount = amount > 0 and amount or error('amount must be greater than 0')
    self.default_maximum = amount
    return self
end

--- Will set the progress bar to start at 1 and trigger when it hits 0
-- @tparam[opt=true] boolean state when true the bar will start filled, to be used with decrease
-- @treturn table the define to allow chaining
function ProgressBar._prototype:use_count_down(state)
	if state == false then
        self.count_down = false
    else
        self.count_down = true
    end
	return self
end

--- Main logic for changing the value of a progress bar, this only applies when its a registered define
-- @tparam table self the define that is being changed
-- @tparam number amount the amount which it is being changed by, may be negative
-- @tparam[opt] string category the category to use with store
-- @tparam[opt] function filter when given the filter must return true for the value of the element to be changed
local function change_value_prototype(self,amount,category,filter)

    local function reset_store()
        local value = self.count_down and 1 or 0
        local _category = category or value
        self:set_store(_category,value)
    end

    if self.store then
        local value = self:get_store(category) or self.count_down and 1 or 0
		local maximum = self.default_maximum or 1
        local new_value = value + (amount/maximum)

        if self.count_down and new_value <= 0
		or not self.count_down and new_value >= 1 then
            self:set_store(category)

            if self.events.on_store_complete then
                category = category or reset_store
                self.events.on_store_complete(category,reset_store)
            end
        end

        category = category or new_value
        self:set_store(category,new_value)

        return
    end

    if ProgressBar.independent[self.name] then
        for key,element_data in pairs(ProgressBar.independent[self.name]) do
			local element = element_data.element
            if not element or not element.valid then
                ProgressBar.independent[self.name][key] = nil

            else
                if not filter or filter(element) then
                    local maximum = element_data.maximum or self.default_maximum or 1
                    element.value = element.value + (amount/maximum)

                    if self.count_down and element.value <= 0
                    or not self.count_down and element.value >= 1 then
                        ProgressBar.independent[self.name][key] = nil
                        event_call(self,element)
                    end
                end

            end
        end
    end

end

--- Increases the value of the progressbar
-- @tparam[opt=1] number amount the amount to increase the progressbar by
-- @tparam[opt] string category the category that is used with a store
function ProgressBar._prototype:increment(amount,category)
    amount = type(amount) == 'number' and amount or 1
    change_value_prototype(self,amount,category)
end

--- Increases the value of the progressbar, if the filter condition is met, does not work with store
-- @tparam[opt=1] number amount the amount to increase the progressbar by
-- @tparam function filter the filter to be used
function ProgressBar._prototype:increment_filtered(amount,filter)
    amount = type(amount) == 'number' and amount or 1
    change_value_prototype(self,amount,nil,filter)
end

--- Decreases the value of the progressbar
-- @tparam[opt=1] number amount the amount to decrease the progressbar by
-- @tparam[opt] string category the category that is used with a store
function ProgressBar._prototype:decrement(amount,category)
    amount = type(amount) == 'number' and amount or 1
    change_value_prototype(self,-amount,category)
end

--- Decreases the value of the progressbar, if the filter condition is met, does not work with store
-- @tparam[opt=1] number amount the amount to decrease the progressbar by
-- @tparam function filter the filter to be used
function ProgressBar._prototype:decrement_filtered(amount,filter)
    amount = type(amount) == 'number' and amount or 1
    change_value_prototype(self,-amount,nil,filter)
end

--- Adds an element into the list of instances that will are waiting to complete, does not work with store
-- note use store if you want persistent data, this only stores the elements not the values which they have
-- @tparam LuaGuiElement element the element that you want to add into the waiting to complete list
-- @tparam[opt] number maximum the maximum for this element if not given the default for this define is used
function ProgressBar._prototype:add_element(element,maximum)
    if self.store then return end
    if not ProgressBar.independent[self.name] then
        ProgressBar.independent[self.name] = {}
    end
    table.insert(ProgressBar.independent[self.name],{
		element = element,
		maximum = maximum
	})
end

--- Resets an element, or its store, to be back at the start, either 1 or 0
-- @tparam LuaGuiElement element the element that you want to reset the progress of
function ProgressBar._prototype:reset_element(element)
    if not element or not element.valid then return end
    local value = self.count_down and 1 or 0
    if self.store then
        local category = self.categorize and self.categorize(element) or value
        self:set_store(category,value)
    else
        element.value = value
    end
end

--- Event handler factory that counts up by 1 every time the event triggeres, can filter which elements are incremented
-- @tparam[opt] function filter when given will use filtered incerement
-- @treturn function the event handler
function ProgressBar._prototype:event_counter(filter)
    if type(filter) == 'function' then
        return function()
            self:increment_filtered(1,filter)
        end
    else
        return function()
            self:increment()
        end
    end
end

--- Event handler factory that counts down by 1 every time the event triggeres, can filter which elements are decremented
-- @tparam[opt] function filter when given will use filtered decerement
-- @treturn function the event handler
function ProgressBar._prototype:event_countdown(filter)
    if type(filter) == 'function' then
        return function()
            self:decrement_filtered(1,filter)
        end
    else
        return function()
            self:decrement()
        end
    end
end

return ProgressBar