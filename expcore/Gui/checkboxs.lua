local Gui = require './core'
local Store = require 'expcore.store'
local Global = require 'utils.global'
local Game = require 'utils.game'

local Checkbox = {
    config={},
    clean_names={},
    instances={},
    _prototype_checkbox=Gui._extend_prototype{},
    _prototype_radiobutton=Gui._extend_prototype{}
}
Global.register(Checkbox.instances,function(tbl)
    Checkbox.instances = tbl
end)

local function get_config(name)
    local config = Checkbox.config[name]
    if not config and Checkbox.clean_names[name] then
        return Checkbox.config[Checkbox.clean_names[name]]
    elseif not config then
        return error('Invalid name for checkbox, name not found.',3)
    end
    return config
end

local function get_store_location(checkbox)
    return 'gui.inputs.checkbox.'..(checkbox.clean_name or checkbox.name)
end

local function get_instances(checkbox,category)
    if not Checkbox.instances[checkbox.name] then return end
    local instances = Checkbox.instances
    if checkbox.categorize then
        instances = instances[category]
    end
    return instances
end

function Checkbox.new_checkbox(name)

    local uid = Gui.uid_name()
    local self = setmetatable({
        name=uid,
        clean_name=name,
    },{__index=Checkbox._prototype_checkbox})
    self._draw.name = uid
    self._draw.type = 'checkbox'

    self._post_draw = function(element)
        local category = self.categorize and self.categorize(element) or nil
        local instances = get_instances(self,category)
        if instances then
            table.insert(instances,element)
        end
    end

    Checkbox.config[uid] = self

    if name then
        Checkbox.clean_names[uid]=name
        Checkbox.clean_names[name]=uid
    end

    Gui.on_checked_state_changed(self.name,function(event)
        local element = event.element
        if self.store then
            if self.categorize then
                Store.set_chlid(self.store,self.categorize(element),element.state)
            else
                Store.set(self.store,element.state)
            end
        elseif self._on_state_change then
            self._on_state_change(event.player,element)
        end
    end)

    return Checkbox.config[uid]
end

function Checkbox.draw_checkbox(name,element)
    local checkbox = get_config(name)
    return checkbox:draw_to(element)
end

function Checkbox._prototype_checkbox:add_store(categorize)
    if self.store then return end
    self.store = get_store_location(self)
    self.categorize = categorize
    Store.register(self.store,function(value,category)
        local instances = get_instances(self,category)
        if instances then
            for k,element in pairs(instances) do
                if element.valid then
                    element.state = value
                    if self._on_state_change then
                        local player = Game.get_player_by_index(element.player_index)
                        self._on_state_change(player,element)
                    end
                else
                    table.remove(instances,k)
                end
            end
        end
    end)
    return self
end

function Checkbox._prototype_checkbox:get_store_state(category)
    if not self.store then return end
    if self.categorize then
        return Store.get_chlid(self.store,category)
    else
        return Store.get(self.store)
    end
end

function Checkbox._prototype_checkbox:set_store_state(category,state)
    if not self.store then return end
    state = not not state
    if self.categorize then
        return Store.set_chlid(self.store,category,state)
    else
        return Store.set(self.store,state)
    end
end

function Checkbox._prototype_checkbox:on_state_change(callback)
    if type(callback) ~= 'function' then
        return error('Event callback must be a function')
    end
    self._on_state_change = callback
    return self
end

function Checkbox.reset_radiobutton(element,exclude)

end

function Checkbox.new_radiobutton(name)

end

Checkbox.draw_radiobutton = Checkbox.draw_checkbox

function Checkbox._prototype_radiobutton:draw_to(element)

end

function Checkbox._prototype_radiobutton:add_store(categorize)

end

function Checkbox._prototype_radiobutton:get_store_value(category)

end

function Checkbox._prototype_radiobutton:set_store_value(category,value)

end

function Checkbox._prototype_radiobutton:enable_single_select(state)

end

function Checkbox._prototype_radiobutton:add_option(name)

end

function Checkbox._prototype_radiobutton:on_state_change(callback)

end

function Checkbox.get_stored_value(name,category)

end

function Checkbox.set_stored_value(name,category,value)

end

return Checkbox