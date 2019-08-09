--[[-- Core Module - Gui
    @module Gui
    @alias Prototype
]]

--- Elem Buttons.
-- Gui class defines for elem buttons
-- @section elem-buttons

--[[
>>>> Functions
    ElemButton.new_elem_button(name) --- Creates a new elem button element define

    ElemButton._prototype:on_element_update(callback) --- Registers a handler for when an element instance updates
    ElemButton._prototype:on_store_update(callback) --- Registers a handler for when the stored value updates

    ElemButton._prototype:set_type(type) --- Sets the type of the elem button, the type is required so this must be called at least once
    ElemButton._prototype:set_default(value) --- Sets the default value for the elem button, this may be a function or a string

    Other functions present from expcore.gui.core
]]
local Gui = require 'expcore.gui.core' --- @dep expcore.gui.core
local Prototype = require 'expcore.gui.prototype' --- @dep expcore.gui.prototype
local Game = require 'utils.game' --- @dep utils.game

--- Store call for store update
-- @tparam table define the define that this is acting on
-- @tparam LuaGuiElement element the element that triggered the event
-- @tparam string value the new value for the elem button
local function store_update(define,element,value)
    element.elem_value = value
    local player = Game.get_player_by_index(element.player_index)
    define:raise_event('on_element_update',player,element,value)
end

local ElemButton = {
    _prototype=Prototype.extend{
        on_element_update = Prototype.event,
        on_store_update = Prototype.event,
        add_store = Prototype.store(false,store_update),
        add_sync_store = Prototype.store(true,store_update)
    }
}

--- Creates a new elem button element define
-- @tparam[opt] string name the optional debug name that can be added
-- @treturn table the new elem button element define
function ElemButton.new_elem_button(name)

    local self = Gui.new_define(ElemButton._prototype,name)
    self.draw_data.type = 'choose-elem-button'

    self:on_draw(function(player,element)
        if type(self.default) == 'function' then
            element.elem_value = self.default(player,element)
        end

        if self.store then
            local category = self.categorize and self.categorize(element) or nil
            local value = self:get_store(category)
            if value then element.elem_value = value end
        end
    end)

    Gui.on_elem_changed(self.name,function(event)
        local element = event.element
        local value = element.elem_value

        if self.store then
            local category = self.categorize and self.categorize(element) or value
            self:set_store(category,value)

        else
            self:raise_event('on_element_update',event.player,element,value)

        end

    end)

    return self
end

--- Sets the type of the elem button, the type is required so this must be called at least once
-- @tparam string type the type that this elem button is see factorio api
-- @treturn the element define to allow for chaining
ElemButton._prototype.set_type = Prototype.setter('string','draw_data','elem_type')

--- Sets the default value for the elem button, this may be a function or a string
-- @tparam ?string|function value string a will be a static default and a function will be called when drawn to get the default
-- @treturn the element define to allow for chaining
function ElemButton._prototype:set_default(value)
    self.default = value
    if type(value) ~= 'function' then
        self.draw_data[self.draw_data.elem_type] = value
    end
    return self
end

return ElemButton