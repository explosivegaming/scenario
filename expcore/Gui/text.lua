local Gui = require './core'
local Game = require 'utils.game'

local function event_call(define,element,value)
    local player = Game.get_player_by_index(element.player_index)

    if define.events.on_change then
        define.events.on_change(player,element,value)
    end

end

local function store_call(self,element,value)
    element.text = value
    event_call(self,element,value)
end

local Text = {
    _prototype_field=Gui._prototype_factory{
        on_change = Gui._event_factory('on_change'),
        add_store = Gui._store_factory(store_call),
        add_sync_store = Gui._sync_store_factory(store_call)
    },
    _prototype_box=Gui._prototype_factory{
        on_change = Gui._event_factory('on_change'),
        add_store = Gui._store_factory(store_call),
        add_sync_store = Gui._sync_store_factory(store_call)
    }
}

function Text.new_text_field(name)

    local self = Gui._define_factory(Text._prototype_field)
    self.draw_data.type = 'textfield'

    if name then
        self:debug_name(name)
    end

    self.post_draw = function(element)
        if self.selectable then
            element.selectable = true
        end

        if self.word_wrap then
            element.word_wrap = true
        end

        if self.read_only then
            element.read_only = true
        end

        if self.store then
            local category = self.categorize and self.categorize(element) or nil
            local value = self:get_store(category)
            if value then element.text = value end
        end
    end

    Gui.on_text_changed(self.name,function(event)
        local element = event.element
        local value = element.text

        if self.store then
            local category = self.categorize and self.categorize(element) or value
            self:set_store(category,value)

        else
            event_call(self,element,value)

        end

    end)

    return self
end

function Text.new_text_box(name)
    local self = Text.new_text_field(name)
    self.draw_data.type = 'text-box'

    local mt = getmetatable(self)
    mt.__index = Text._prototype_box

    return self
end

function Text._prototype_box:set_selectable(state)
    if state == false then
        self.selectable = false
    else
        self.selectable = true
    end
    return self
end

function Text._prototype_box:set_word_wrap(state)
    if state == false then
        self.word_wrap = false
    else
        self.word_wrap = true
    end
    return self
end

function Text._prototype_box:set_read_only(state)
    if state == false then
        self.read_only = false
    else
        self.read_only = true
    end
    return self
end

return Text