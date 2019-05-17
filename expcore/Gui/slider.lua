--- Gui class define for silders
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
local Gui = require './core'
local Game = require 'utils.game'

--- Gets the active lables for a define
-- @tparam define table the define to get the labels for
-- @tparam element LuaGuiElement the element that will be used to get the category
-- @treturn table the table of active instances for the slider lables
local function get_labels(define,element)
    local function cat(e)
        return e.player_index
    end

    local name = define.name..'-label'
    if not Gui.instances[name] then return end

    local categorize = define.categorize or not define.store and cat
    local category = categorize and categorize(element) or nil
    local instances = Gui.get_instances({
        name=name,
        categorize=categorize
    },category)

    return instances
end

--- Gets and updates the label values
-- @tparam define table the define to get the labels for
-- @tparam element LuaGuiElement the element that will be used to get the category
local function update_lables(define,element)
    local instances = get_labels(define,element)
    local value = element.slider_value
    if instances then
        for k,instance in pairs(instances) do
            if instance and instance.valid then
                instance.caption = tostring(math.round(value,2))
            else
                instances[k]=nil
            end
        end
    end
end

--- Event call for on_value_changed and store update
-- @tparam define table the define that this is acting on
-- @tparam element LuaGuiElement the element that triggered the event
-- @tparam value number the new value for the slider
local function event_call(define,element,value)
    local player = Game.get_player_by_index(element.player_index)

    local min,max = element.get_slider_minimum(),element.get_slider_maximum()
    local delta = max-min
    local percent = delta == 0 and 0 or (value-min)/delta

    if define.events.on_element_update then
        define.events.on_element_update(player,element,value,percent)
    end

    update_lables(define,element)
end

--- Store call for store update
-- @tparam define table the define that this is acting on
-- @tparam element LuaGuiElement the element that triggered the event
-- @tparam value number the new value for the slider
local function store_call(define,element,value)
    element.slider_value = value
    event_call(define,element,value)
end

local Slider = {
    _prototype=Gui._prototype_factory{
        on_element_update = Gui._event_factory('on_element_update'),
        on_store_update = Gui._event_factory('on_store_update'),
        add_store = Gui._store_factory(store_call),
        add_sync_store = Gui._sync_store_factory(store_call)
    }
}

--- Creates a new slider element define
-- @tparam[opt] name string the optional debug name that can be added
-- @treturn table the new slider element define
function Slider.new_slider(name)

    local self = Gui._define_factory(Slider._prototype)
    self.draw_data.type = 'slider'

    if name then
        self:debug_name(name)
    end

    self.post_draw = function(element)
        local player = Game.get_player_by_index(element.player_index)
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
    end

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
-- @tparam[opt] min number the minimum value that the slider can take
-- @tparam[opt] max number the maximum value that the slider can take
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
-- @tparam element LuaGuiElement the parent element that the lable will be drawn to
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

    if not Gui.instances[name] then Gui.instances[name] = {} end

    local labels = get_labels(self,element)
    table.insert(labels,new_element)

    return new_element
end

--- Enables auto draw of the label, the label will share the same parent element as the slider
-- @tparam[opt=true] state boolean when false will disable the auto draw of the label
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