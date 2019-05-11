local Gui = require './core'
local Store = require 'expcore.store'
local Global = require 'utils.global'
local Game = require 'utils.game'

local Checkbox = {
    config={},
    clean_names={},
    instances={},
    option_mapping={},
    option_categorize={},
    _prototype_checkbox=Gui._extend_prototype{},
    _prototype_radiobutton=Gui._extend_prototype{}
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

local function get_store_location(checkbox)
    return 'gui.inputs.checkbox.'..(checkbox.clean_name or checkbox.name)
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
        _draw={
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
        if self.share_store_location then
            set_store(self,self.share_store_location,element,Checkbox.option_mapping[self.share_store_location][element.name])
        elseif self.store then
            set_store(self,self.store,element,element.state)
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
    Checkbox.instances[self.name]={}
    Store.register(self.store,function(value,category)
        local instances = get_instances(self,category)
        if instances then
            for k,element in pairs(instances) do
                if element and element.valid then
                    element.state = value
                    if self._on_state_change then
                        local player = Game.get_player_by_index(element.player_index)
                        self._on_state_change(player,element)
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
    state = not not state
    set_store(self,self.store,category,state)
end

function Checkbox._prototype_checkbox:on_state_change(callback)
    if type(callback) ~= 'function' then
        return error('Event callback must be a function')
    end
    self._on_state_change = callback
    return self
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
    self._draw.type = 'radiobutton'

    setmetatable(self,{
        __index=Checkbox._prototype_radiobutton,
        __call=function(element) return Checkbox.config[uid]:draw_to(element) end
    })

    return self
end

function Checkbox.new_share_store(location,callback,categorize)
    Store.register(location,function(value,category)
        local options = Checkbox.option_mapping[location]
        for opt_name,name in pairs(options) do
            if Checkbox.config[name] then
                get_config(name):set_store_state(category,opt_name == value)
            end
        end
        callback(value,category)
    end)
    Checkbox.option_categorize[location] = categorize
    Checkbox.option_mapping[location] = {}
    return location
end

Checkbox.draw_radiobutton = Checkbox.draw_checkbox

function Checkbox._prototype_radiobutton:share_store(location,option_name)
    self.share_store_location = location
    self.option_name = option_name or self.clean_name or self.name

    Checkbox.option_mapping[location][self.option_name] = self.name
    Checkbox.option_mapping[location][self.name] = self.option_name

    self:add_store(Checkbox.option_categorize[location])

    return self
end

function Checkbox.get_stored_state(name,category)
    local checkbox = get_config(name)
    if checkbox.share_store_location then
        if checkbox.categorize then
            return Store.get_child(checkbox.share_store_location,category)
        else
            return Store.get(checkbox.share_store_location)
        end
    end
    return checkbox:get_store_state(category)
end

function Checkbox.set_stored_state(name,category,value)
    local checkbox = get_config(name)
    if checkbox.share_store_location then
        set_store(checkbox,checkbox.share_store_location,category,value)
    end
    return checkbox:set_store_state(category,value)
end

return Checkbox