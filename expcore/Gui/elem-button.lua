--- Gui class defines for elem buttons
--[[
>>>> Functions
    ElemButton.new_elem_button(name) --- Creates a new elem button element define

    ElemButton._prototype:on_element_update(callback) --- Registers a handler for when an element instance updates
    ElemButton._prototype:on_store_update(callback) --- Registers a handler for when the stored value updates

    ElemButton._prototype:set_type(type) --- Sets the type of the elem button, the type is required so this must be called at least once
    ElemButton._prototype:set_default(value) --- Sets the default value for the elem button, this may be a function or a string

    Other functions present from expcore.gui.core
]]
local Gui = require './core'
local Game = require 'utils.game'

--- Event call for on_elem_changed and store update
-- @tparam define table the define that this is acting on
-- @tparam element LuaGuiElement the element that triggered the event
-- @tparam value string the new value for the elem button
local function event_call(define,element,value)
    local player = Game.get_player_by_index(element.player_index)

    if define.events.on_element_update then
        define.events.on_element_update(player,element,value)
    end

end

--- Store call for store update
-- @tparam define table the define that this is acting on
-- @tparam element LuaGuiElement the element that triggered the event
-- @tparam value string the new value for the elem button
local function store_call(self,element,value)
    element.elem_value = value
    event_call(self,element,value)
end

local ElemButton = {
    _prototype=Gui._prototype_factory{
        on_element_update = Gui._event_factory('on_element_update'),
        on_store_update = Gui._event_factory('on_store_update'),
        add_store = Gui._store_factory(store_call),
        add_sync_store = Gui._sync_store_factory(store_call)
    }
}

--- Creates a new elem button element define
-- @tparam[opt] name string the optional debug name that can be added
-- @treturn table the new elem button element define
function ElemButton.new_elem_button(name)

    local self = Gui._define_factory(ElemButton._prototype)
    self.draw_data.type = 'choose-elem-button'

    if name then
        self:debug_name(name)
    end

    self.post_draw = function(element)
        local player = Game.get_player_by_index(element.player_index)

        if type(self.default) == 'function' then
            element.elem_value = self.default(player,element)
        end

        if self.store then
            local category = self.categorize and self.categorize(element) or nil
            local value = self:get_store(category)
            if value then element.elem_value = value end
        end
    end

    Gui.on_elem_changed(self.name,function(event)
        local element = event.element
        local value = element.elem_value

        if self.store then
            local category = self.categorize and self.categorize(element) or value
            self:set_store(category,value)

        else
            event_call(self,element,value)

        end

    end)

    return self
end

--- Sets the type of the elem button, the type is required so this must be called at least once
-- @tparam type string the type that this elem button is see factorio api
-- @treturn the element define to allow for chaining
function ElemButton._prototype:set_type(type)
    self.draw_data.elem_type = type
    return self
end

--- Sets the default value for the elem button, this may be a function or a string
-- @tparam value ?string|function a string will be a static default and a function will be called when drawn to get the default
-- @treturn the element define to allow for chaining
function ElemButton._prototype:set_default(value)
    self.default = value
    if type(value) ~= 'function' then
        self.draw_data[self.draw_data.elem_type] = value
    end
    return self
end

return ElemButton