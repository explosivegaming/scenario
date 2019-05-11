local Gui = require './core'
local Store = require 'expcore.store'
local Global = require 'utils.global'
local Game = require 'utils.game'

local Checkbox = {
    config={},
    clean_names={},
    instances={},
    option_sets={},
    option_categorize={},
    _prototype_checkbox=Gui._extend_prototype{
        on_state_change = Gui._new_event_adder('on_state_change')
    },
    _prototype_radiobutton=Gui._extend_prototype{
        on_state_change = Gui._new_event_adder('on_state_change')
    }
}
setmetatable(Checkbox._prototype_radiobutton,{__index=Checkbox._prototype_checkbox})
Global.register(Checkbox.instances,function(tbl)
    Checkbox.instances = tbl
end)

local function get_config(name)
    local config = Checkbox.config[name]
    if not config and Checkbox.clean_names[name] then
        return Checkbox.config[Checkbox.clean_names[name]]
    elseif not config then
        return error('Invalid name for checkbox, name not found.',3) or nil
    end
    return config
end

local function get_instances(checkbox,category)
    if not Checkbox.instances[checkbox.name] then return end
    local instances = Checkbox.instances[checkbox.name]
    if checkbox.categorize then
        if not instances[category] then instances[category] = {} end
        return instances[category]
    end
    return instances
end

local function set_store(config,location,element,value)
    if config.categorize then
        local child = type(element) == 'string' and element or config.categorize(element)
        Store.set_child(location,child,value)
    else
        Store.set(location,value)
    end
end

function Checkbox.new_checkbox(name)

    local uid = Gui.uid_name()
    local self = setmetatable({
        name=uid,
        clean_name=name,
        events={},
        draw_data={
            name=uid,
            type='checkbox',
            state=false
        }
    },{
        __index=Checkbox._prototype_checkbox,
        __call=function(element) return Checkbox.config[uid]:draw_to(element) end
    })

    self._post_draw = function(element)
        local category = self.categorize and self.categorize(element) or nil
        local instances = get_instances(self,category)
        if instances then
            table.insert(instances,element)
        end
        local state = self:get_store_state(category)
        if state then element.state = true end
    end

    Checkbox.config[uid] = self

    if name then
        Checkbox.clean_names[uid]=name
        Checkbox.clean_names[name]=uid
    end

    Gui.on_checked_state_changed(self.name,function(event)
        local element = event.element
        if self.option_set then
            set_store(self,self.option_set,element,Checkbox.option_sets[self.option_set][element.name])
        elseif self.store then
            set_store(self,self.store,element,element.state)
        elseif self.events.on_state_change then
            self.events.on_state_change(event.player,element)
        end
    end)

    return Checkbox.config[uid]
end

function Checkbox.draw_checkbox(name,element)
    local config = get_config(name)
    return config:draw_to(element)
end

function Checkbox._prototype_checkbox:add_store(categorize)
    if self.store then return end

    self.store = Store.uid_location()
    self.categorize = categorize
    Checkbox.instances[self.name]={}

    Store.register(self.store,function(value,category)
        local instances = get_instances(self,category)
        if instances then

            for k,element in pairs(instances) do
                if element and element.valid then
                    element.state = value
                    if self.events.on_state_change then
                        local player = Game.get_player_by_index(element.player_index)
                        self.events.on_state_change(player,element)
                    end
                else
                    instances[k] = nil
                end
            end

        end
    end)

    return self
end

function Checkbox._prototype_checkbox:get_store_state(category)
    if not self.store then return end
    if self.categorize then
        return Store.get_child(self.store,category)
    else
        return Store.get(self.store)
    end
end

function Checkbox._prototype_checkbox:set_store_state(category,state)
    if not self.store then return end
    set_store(self,self.store,category,not not state)
end

function Checkbox.reset_radiobutton(element,exclude,recursive)
    if not element or not element.valid then return end
    exclude = type(exclude) == 'table' and exclude or exclude ~= nil and {[exclude]=true} or {}

    for _,child in pairs(element.children) do
        if child and child.valid and child.type == 'radiobutton' then
            child.state = exclude[child.name] or false
            local config = Checkbox.config[child.name]
            if config then
                set_store(config,config.store,child,exclude[child.name] or false)
            end
        elseif child.children and (type(recursive) == 'number' and recursive > 0 or recursive == true) then
            Checkbox.reset_radiobutton(child,exclude,recursive)
        end
    end

    return true
end

function Checkbox.new_radiobutton(name)
    local self = Checkbox.new_checkbox(name)
    local uid = self.name
    self.draw_data.type = 'radiobutton'

    setmetatable(self,{
        __index=Checkbox._prototype_radiobutton,
        __call=function(element) return Checkbox.config[uid]:draw_to(element) end
    })

    return self
end

Checkbox.draw_radiobutton = Checkbox.draw_checkbox

function Checkbox._prototype_radiobutton:add_as_option(option_set,option_name)
    self.option_set = option_set
    self.option_name = option_name or self.clean_name or self.name

    Checkbox.option_sets[option_set][self.option_name] = self.name
    Checkbox.option_sets[option_set][self.name] = self.option_name

    self:add_store(Checkbox.option_categorize[option_set])

    return self
end

function Checkbox.new_option_set(name,callback,categorize)

    Store.register(name,function(value,category)
        local options = Checkbox.option_sets[name]
        for opt_name,config_name in pairs(options) do
            if Checkbox.config[config_name] then
                get_config(config_name):set_store_state(category,opt_name == value)
            end
        end
        callback(value,category)
    end)

    Checkbox.option_categorize[name] = categorize
    Checkbox.option_sets[name] = {}

    return name
end

function Checkbox.get_stored_state(name,category)
    local config = get_config(name)

    if config.option_set then
        if config.categorize then
            return Store.get_child(config.option_set,category)
        else
            return Store.get(config.option_set)
        end
    end

    return config:get_store_state(category)
end

function Checkbox.set_stored_state(name,category,value)
    local config = get_config(name)
    local location = config.option_set or config.store
    set_store(config,location,category,value)
end

return Checkbox