local Gui = require './core'
local Game = require 'utils.game'

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

local function event_call(define,element,value)
    local player = Game.get_player_by_index(element.player_index)

    local min,max = element.get_slider_minimum(),element.get_slider_maximum()
    local delta = max-min
    local percent = delta == 0 and 0 or (value-min)/delta

    if define.events.on_change then
        define.events.on_change(player,element,value,percent)
    end

    update_lables(define,element)
end

local function store_call(self,element,value)
    element.slider_value = value
    event_call(self,element,value)
end

local Slider = {
    _prototype=Gui._prototype_factory{
        on_change = Gui._event_factory('on_change'),
        add_store = Gui._store_factory(store_call),
        add_sync_store = Gui._sync_store_factory(store_call)
    }
}

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

function Slider._prototype:enable_auto_draw_label(state)
    if state == false then
        self.auto_label = false
    else
        self.auto_label = true
    end
    return self
end

return Slider