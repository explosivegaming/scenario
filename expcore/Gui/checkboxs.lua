local Gui = require './core'
local Store = require 'expcore.store'
local Game = require 'utils.game'

local function event_call(self,element,value)
    if self.events.on_change then
        local player = Game.get_player_by_index(element.player_index)
        self.events.on_change(player,element,value)
    end
end

local function store_call(self,element,value)
    element.state = value
    event_call(self,element,value)
end

local Checkbox = {
    option_sets={},
    option_categorize={},
    _prototype_checkbox=Gui._prototype_factory{
        on_change = Gui._event_factory('on_change'),
        add_store = Gui._store_factory(store_call),
        add_sync_store = Gui._sync_store_factory(store_call)
    },
    _prototype_radiobutton=Gui._prototype_factory{
        on_change = Gui._event_factory('on_change'),
        add_store = Gui._store_factory(store_call),
        add_sync_store = Gui._sync_store_factory(store_call)
    }
}

function Checkbox.new_checkbox(name)

    local self = Gui._define_factory(Checkbox._prototype_checkbox)
    self.draw_data.type = 'checkbox'
    self.draw_data.state = false

    if name then
        self:debug_name(name)
    end

    self.post_draw = function(element)
        if self.store then
            local category = self.categorize and self.categorize(element) or nil
            local state = self:get_store(category,true)
            if state then element.state = true end
        end
    end

    Gui.on_checked_state_changed(self.name,function(event)
        local element = event.element

        if self.option_set then
            local value = Checkbox.option_sets[self.option_set][element.name]
            local category = self.categorize and self.categorize(element) or value
            self:set_store(category,value)

        elseif self.store then
            local value = element.state
            local category = self.categorize and self.categorize(element) or value
            self:set_store(category,value)

        else
            local value = element.state
            event_call(self,element,value)

        end
    end)

    return self
end

function Checkbox.reset_radiobutton(element,exclude,recursive)
    if not element or not element.valid then return end
    exclude = type(exclude) == 'table' and exclude or exclude ~= nil and {[exclude]=true} or {}

    for _,child in pairs(element.children) do
        if child and child.valid and child.type == 'radiobutton' then
            local state = exclude[child.name] or false
            local define = Gui.defines[child.name]

            if define then
                local category = define.categorize and define.categorize(child) or state
                define:set_store(category,state)

            else
                child.state = state

            end

        elseif child.children and (type(recursive) == 'number' and recursive > 0 or recursive == true) then
            Checkbox.reset_radiobutton(child,exclude,recursive)

        end
    end

    return true
end

function Checkbox.new_radiobutton(name)
    local self = Checkbox.new_checkbox(name)
    self.draw_data.type = 'radiobutton'

    local mt = getmetatable(self)
    mt.__index = Checkbox._prototype_radiobutton

    return self
end

function Checkbox._prototype_radiobutton:add_as_option(option_set,option_name)
    self.option_set = option_set
    self.option_name = option_name or self.clean_name or self.name

    Checkbox.option_sets[option_set][self.option_name] = self.name
    Checkbox.option_sets[option_set][self.name] = self.option_name

    self:add_store(Checkbox.option_categorize[option_set])

    return self
end

function Checkbox._prototype_radiobutton:get_store(category,internal)
    if not self.store then return end
    local location = not internal and self.option_set or self.store

    if self.categorize then
        return Store.get_child(location,category)
    else
        return Store.get(location)
    end
end

function Checkbox._prototype_radiobutton:set_store(category,value,internal)
    if not self.store then return end
    local location = not internal and self.option_set or self.store

    if self.categorize then
        return Store.set_child(location,category,value)
    else
        return Store.set(location,category)
    end
end

function Checkbox.new_option_set(name,callback,categorize)

    Store.register(name,function(value,category)
        local options = Checkbox.option_sets[name]
        for opt_name,define_name in pairs(options) do
            if Gui.defines[define_name] then
                local define = Gui.get_define(define_name)
                local state = opt_name == value
                define:set_store(category,state,true)
            end
        end
        callback(value,category)
    end)

    Checkbox.option_categorize[name] = categorize
    Checkbox.option_sets[name] = {}

    return name
end

function Checkbox.draw_option_set(name,element)
    if not Checkbox.option_sets[name] then return end
    local options = Checkbox.option_sets[name]

    for _,option in pairs(options) do
        if Gui.defines[option] then
            Gui.defines[option]:draw_to(element)
        end
    end

end

return Checkbox