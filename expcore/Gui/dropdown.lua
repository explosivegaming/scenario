local Gui = require './core'
local Game = require 'utils.game'

local _select_value
local Dropdown = {
    _prototype=Gui._extend_prototype{
        on_selection = Gui._new_event_adder('on_selection'),
        add_store = Gui._new_store_adder(function(self,element,value)
            _select_value(element,value)
            local player = Game.get_player_by_index(element.player_index)
            if self.events.on_selection then
                self.events.on_selection(player,element,value)
            end
            if self.option_callbacks and self.option_callbacks[value] then
                self.option_callbacks[value](player,element,value)
            end
        end)
    }
}

function Dropdown.new_dropdown(name)

    local self = Gui._new_define(Dropdown._prototype)
    self.draw_data.type = 'drop-down'

    if name then
        self:debug_name(name)
    end

    self.post_draw = function(element)
        if self.dynamic_options then
            local player = Game.get_player_by_index(element.player_index)
            local dynamic_options = self.dynamic_options(player,element)
            local items = element.items
            for _,v in pairs(dynamic_options) do
                table.insert(items,v)
            end
            element.items = items
        end
        if self.store then
            local category = self.categorize and self.categorize(element) or nil
            local value = self:get_store(category)
            if value then Dropdown.select_value(element,value) end
        end
    end

    Gui.on_selection_state_changed(self.name,function(event)
        local element = event.element
        local value = Dropdown.get_selected_value(element)

        if self.store then
            local category = self.categorize and self.categorize(element) or value
            self:set_store(category,value)
            return
        end

        if self.events.on_selection then
            self.events.on_selection(event.player,element,value)
        end

        if self.option_callbacks and self.option_callbacks[value] then
            self.option_callbacks[value](event.player,element,value)
        end

    end)

    return self
end

function Dropdown._prototype:new_static_options(options,...)
    if type(options) == 'string' then
        options = {options}
        for _,v in pairs({...}) do
            table.insert(options,v)
        end
    end
    self.options = options
    self.draw_data.items = options
    return self
end
Dropdown._prototype.add_options = Dropdown._prototype.new_static_options

function Dropdown._prototype:new_dynamic_options(callback)
    if type(callback) ~= 'function' then
        return error('Dynamic options callback must be a function',2)
    end
    self.dynamic_options = callback
    return self
end
Dropdown._prototype.add_dynamic = Dropdown._prototype.new_dynamic_options

function Dropdown._prototype:add_option_callback(option,callback)
    if not self.option_callbacks then self.option_callbacks = {} end
    if not self.options then self.options = {} end
    self.option_callbacks[option] = callback
    if not table.contains(self.options,option) then
        table.insert(self.options,option)
    end
    return self
end

function Dropdown.select_value(element,value)
    for k,item in pairs(element.items) do
        if item == value then
            element.selected_index = k
            return k
        end
    end
end
_select_value = Dropdown.select_value

function Dropdown.get_selected_value(element)
    local index = element.selected_index
    return element.items[index]
end

function Dropdown.new_list_box(name)
    local self = Dropdown.new_dropdown(name)
    self.draw_data.type = 'list-box'

    return self
end

return Dropdown