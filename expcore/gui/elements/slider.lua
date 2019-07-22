--- Gui class define for sliders
--[[
>>>> Functions
    Slider.new_slider(name) --- Creates a new slider element define

    Slider._prototype:on_element_update(callback) --- Registers a handler for when an element instance updates
    Slider._prototype:on_store_update(callback) --- Registers a handler for when the stored value updates

    Slider._prototype:set_range(min,max) --- Sets the range of a slider, if not used will use default values for a slider
    Slider._prototype:draw_label(element) --- Draws a new label and links its value to the value of this slider, if no store then it will only show one value per player
    Slider._prototype:enable_auto_draw_label(state) --- Enables auto draw of the label, the label will share the same parent element as the slider

    Other functions present from expcore.gui.core
]]
local Gui = require 'expcore.gui.core' --- @dep expcore.gui.core
local Prototype = require 'expcore.gui.prototype' --- @dep expcore.gui.prototype
local Instances = require 'expcore.gui.instances' --- @dep expcore.gui.instances
local Game = require 'utils.game' --- @dep utils.game

--- Event call for on_value_changed and store update
-- @tparam table define the define that this is acting on
-- @tparam LuaGuiElement element the element that triggered the event
-- @tparam number value the new value for the slider
local function event_call(define,element,value)
    local player = Game.get_player_by_index(element.player_index)

    local min,max = element.get_slider_minimum(),element.get_slider_maximum()
    local delta = max-min
    local percent = delta == 0 and 0 or (value-min)/delta

    define:raise_event('on_element_update',player,element,value,percent)

    local category = player.name
    if define.categorize then
        category = define.categorize(element)
    end

    Instances.unregistered_get_elements(define.name..'-label',category,function(label)
        label.caption = tostring(math.round(value,2))
    end)
end

--- Store call for store update
-- @tparam table define the define that this is acting on
-- @tparam LuaGuiElement element the element that triggered the event
-- @tparam number value the new value for the slider
local function store_update(define,element,value)
    element.slider_value = value
    event_call(define,element,value)
end

local Slider = {
    _prototype=Prototype.extend{
        on_element_update = Prototype.event,
        on_store_update = Prototype.event,
        add_store = Prototype.store(false,store_update),
        add_sync_store = Prototype.store(true,store_update)
    }
}

--- Creates a new slider element define
-- @tparam[opt] string name the optional debug name that can be added
-- @treturn table the new slider element define
function Slider.new_slider(name)

    local self = Gui.new_define(Slider._prototype,name)
    self.draw_data.type = 'slider'

    self:on_draw(function(player,element)
        local min,max = element.get_slider_minimum(),element.get_slider_maximum()

        if type(self.min) == 'function' then
            min = self.min(player,element)
        end

        if type(self.max) == 'function' then
            max = self.max(player,element)
        end

        element.set_slider_minimum_maximum(min,max)

        if self.store then
            local category = self.categorize and self.categorize(element) or nil
            local value = self:get_store(category)
            if value then element.slider_value = value end
        end

        if self.auto_label then
            self:draw_label(element.parent)
        end
    end)

    Gui.on_value_changed(self.name,function(event)
        local element = event.element
        local value = element.slider_value

        if self.store then
            local category = self.categorize and self.categorize(element) or value
            self:set_store(category,value)

        else
            event_call(self,element,value)

        end

    end)

    return self
end

--- Sets the range of a slider, if not used will use default values for a slider
-- @tparam[opt] number min the minimum value that the slider can take
-- @tparam[opt] number max the maximum value that the slider can take
-- @treturn self the define to allow chaining
function Slider._prototype:set_range(min,max)
    self.min = min
    self.max = max

    if type(min) == 'number' then
        self.draw_data.minimum_value = min
    end

    if type(max) == 'number' then
        self.draw_data.maximum_value = max
    end

    return self
end

--- Draws a new label and links its value to the value of this slider, if no store then it will only show one value per player
-- @tparam LuaGuiElement element the parent element that the label will be drawn to
-- @treturn LuaGuiElement the new label element so that styles can be applied
function Slider._prototype:draw_label(element)
    local name = self.name..'-label'
    if element[name] then return end

    local value = 0
    if self.store then
        local category = self.categorize and self.categorize(element) or value
        value = self:get_store(category) or 0
    end

    local new_element = element.add{
        name=name,
        type='label',
        caption=tostring(math.round(value,2))
    }

    local categorise = self.categorise or Gui.categorize_by_player
    local category = categorise(new_element)

    Instances.unregistered_add_element(name,category,new_element)

    return new_element
end

--- Enables auto draw of the label, the label will share the same parent element as the slider
-- @tparam[opt=true] boolean state when false will disable the auto draw of the label
-- @treturn self the define to allow chaining
function Slider._prototype:enable_auto_draw_label(state)
    if state == false then
        self.auto_label = false
    else
        self.auto_label = true
    end
    return self
end

return Slider