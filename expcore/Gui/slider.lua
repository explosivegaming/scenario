local Gui = require './core'
local Game = require 'utils.game'

local function get_instances(define,element)
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

local function update_instances(define,element)
    local instances = get_instances(define,element)
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

local Slider = {
    _prototype=Gui._extend_prototype{
        on_change = Gui._new_event_adder('on_change'),
        add_store = Gui._new_store_adder(function(self,element,value)
            element.slider_value = value
            local min,max = element.get_slider_minimum(),element.get_slider_maximum()
            local delta = max-min
            local percent = delta == 0 and 0 or (value-min)/delta
            local player = Game.get_player_by_index(element.player_index)
            if self.events.on_change then
                self.events.on_change(player,element,value,percent)
            end
            update_instances(self,element)
        end)
    }
}

function Slider.new_slider(name)

    local self = Gui._new_define(Slider._prototype)
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
        local min,max = element.get_slider_minimum(),element.get_slider_maximum()
        local delta = max-min
        local percent = delta == 0 and 0 or (value-min)/delta
        local category = self.categorize and self.categorize(element) or value

        if self.store then
            self:set_store(category,value)

        elseif self.events.on_change then
            self.events.on_change(event.player,element,value,percent)
            update_instances(self,element)
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
    local instances = get_instances(self,element)
    table.insert(instances,new_element)
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