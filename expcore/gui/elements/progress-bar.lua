--- Gui element define for progress bars
--[[
>>>> Functions
    ProgressBar.set_maximum(element,amount,count_down) --- Sets the maximum value that represents the end value of the progress bar
    ProgressBar.increment(element,amount) --- Increases the value of the progressbar, if a define is given all of its instances have incremented
    ProgressBar.decrement(element,amount) --- Decreases the value of the progressbar, if a define is given all of its instances have decremented

    ProgressBar.new_progressbar(name) --- Creates a new progressbar element define
    ProgressBar._prototype:set_maximum(amount,count_down) --- Sets the maximum value that represents the end value of the progress bar
    ProgressBar._prototype:use_count_down(state) --- Will set the progress bar to start at 1 and trigger when it hits 0
    ProgressBar._prototype:increment(amount,category) --- Increases the value of the progressbar
    ProgressBar._prototype:increment_filtered(amount,filter) --- Increases the value of the progressbar, if the filter condition is met, does not work with store
    ProgressBar._prototype:decrement(amount,category) --- Decreases the value of the progressbar
    ProgressBar._prototype:decrement_filtered(amount,filter) --- Decreases the value of the progressbar, if the filter condition is met, does not work with store
    ProgressBar._prototype:add_element(element,maximum) --- Adds an element into the list of instances that will are waiting to complete, does not work with store
    ProgressBar._prototype:reset_element(element) --- Resets an element, or its store, to be back at the start, either 1 or 0

    ProgressBar._prototype:on_complete(callback) --- Triggers when a progress bar element completes (hits 0 or 1)
    ProgressBar._prototype:on_complete(callback) --- Triggers when a store value completes (hits 0 or 1)
    ProgressBar._prototype:event_counter(filter) --- Event handler factory that counts up by 1 every time the event triggers, can filter which elements have incremented
    ProgressBar._prototype:event_countdown(filter) --- Event handler factory that counts down by 1 every time the event triggers, can filter which elements have decremented
]]
local Gui = require 'expcore.gui.core' --- @dep expcore.gui.core
local Prototype = require 'expcore.gui.prototype' --- @dep expcore.gui.prototype
local Global = require 'utils.global' --- @dep utils.global
local Game = require 'utils.game' --- @dep utils.game

--- Event call for when the value is outside the range 0-1
-- @tparam table define the define that this is acting on
-- @tparam LuaGuiElement element the element that triggered the event
local function event_call(define,element)
    local player = Game.get_player_by_index(element.player_index)
    define:raise_event('on_complete',player,element,function()
        define:add_element(element)
        define:reset_element(element)
    end)
end

--- Store call for store update
-- @tparam table define the define that this is acting on
-- @tparam LuaGuiElement element the element that triggered the event
-- @tparam number value the new value for the progress bar
local function store_update(define,element,value)
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
    independent={}, -- elements with a link to a define
    _prototype=Prototype.extend{
        on_complete = Prototype.event,
        on_store_complete = Prototype.event,
        add_store = Prototype.store(false,store_update),
        add_sync_store = Prototype.store(true,store_update)
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
-- @treturn table the element data similar to define
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
        define:set_default_maximum(amount)

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

--- Increases the value of the progressbar, if a define is given all of its instances have incremented
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

--- Decreases the value of the progressbar, if a define is given all of its instances have decremented
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
-- @treturn table the new progressbar element define
function ProgressBar.new_progressbar(name)

    local self = Gui.new_define(ProgressBar._prototype,name)
    self.draw_data.type = 'progressbar'

    self:on_draw(function(player,element,maximum)
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

    end)

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
        self:set_store(category,value)
    end

    if self.store then
        local value = self:get_store(category) or self.count_down and 1 or 0
		local maximum = self.default_maximum or 1
        local new_value = value + (amount/maximum)

        self:set_store(category,new_value)

        if self.count_down and new_value <= 0
		or not self.count_down and new_value >= 1 then
            self:clear_store(category)
            self:raise_event('on_store_complete',category,reset_store)
            return
        end

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

--- Event handler factory that counts up by 1 every time the event triggers, can filter which elements have incremented
-- @tparam[opt] function filter when given will use filtered increment
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

--- Event handler factory that counts down by 1 every time the event triggers, can filter which elements have decremented
-- @tparam[opt] function filter when given will use filtered decrement
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