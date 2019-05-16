local Gui = require './core'
local Game = require 'utils.game'

local function event_call(define,element,value)
    local player = Game.get_player_by_index(element.player_index)

    if define.events.on_change then
        define.events.on_change(player,element,value)
    end

end

local function store_call(self,element,value)
    element.elem_value = value
    event_call(self,element,value)
end

local ElemButton = {
    _prototype=Gui._prototype_factory{
        on_change = Gui._event_factory('on_change'),
        add_store = Gui._store_factory(store_call),
        add_sync_store = Gui._sync_store_factory(store_call)
    }
}

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

function ElemButton._prototype:set_type(type)
    self.draw_data.elem_type = type
    return self
end

function ElemButton._prototype:set_default(value)
    self.default = value
    if type(value) ~= 'function' then
        self.draw_data[self.draw_data.elem_type] = value
    end
    return self
end

return ElemButton