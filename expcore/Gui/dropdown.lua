local Gui = require './core'
local Game = require 'utils.game'

local function event_call(define,element,value)
    local player = Game.get_player_by_index(element.player_index)

    if define.events.on_change then
        define.events.on_change(player,element,value)
    end

    if define.option_callbacks and define.option_callbacks[value] then
        define.option_callbacks[value](player,element,value)
    end
end

local _select_value
local function store_call(self,element,value)
    _select_value(element,value)
    event_call(self,element,value)
end

local Dropdown = {
    _prototype=Gui._prototype_factory{
        on_change = Gui._event_factory('on_change'),
        add_store = Gui._store_factory(store_call),
        add_sync_store = Gui._sync_store_factory(store_call)
    }
}

function Dropdown.new_dropdown(name)

    local self = Gui._define_factory(Dropdown._prototype)
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

        else
            event_call(self,element,value)

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