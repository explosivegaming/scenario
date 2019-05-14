local Gui = require 'utils.gui'
local Game = require 'utils.game'
local Global = require 'utils.global'
local Store = require 'expcore.store'

Gui._prototype = {} -- Stores the base prototype of all gui defines
Gui.classes = {} -- Stores the class types of gui defines
Gui.defines = {} -- Stores the indivdual gui element definations
Gui.names = {} -- Stores debug names to link to gui uids
Gui.instances = {} -- Stores runtime data of all active instances of each define
Global.register(Gui.instances,function(tbl)
    Gui.instances = tbl
end)

function Gui._extend_prototype(tbl)
    for k,v in pairs(Gui._prototype) do
        if not tbl[k] then tbl[k] = v end
    end
    return tbl
end

function Gui._new_event_adder(name)
    return function(self,callback)
        if type(callback) ~= 'function' then
            return error('Event callback must be a function',2)
        end

        self.events[name] = callback
        return self
    end
end

function Gui._new_store_adder(callback)
    return function(self,categorize)
        if self.store then return end

        self.store = Store.uid_location()
        self.categorize = categorize
        Gui.instances[self.name]={}

        Store.register(self.store,function(value,category)
            local instances = Gui.get_instances(self,category)
            if instances then

                for k,element in pairs(instances) do
                    if element and element.valid then
                        callback(self,element,value)
                    else
                        instances[k] = nil
                    end
                end

            end
        end)

        return self
    end
end

function Gui._new_sync_store_adder(callback)
    return function(self,location,categorize)
        if self.store then return end

        if Store.is_registered(location) then
            return error('Location for store is already registered: '..location,2)
        end

        self.store = location
        self.categorize = categorize
        Gui.instances[self.name]={}

        Store.register_synced(self.store,function(value,category)
            local instances = Gui.get_instances(self,category)
            if instances then

                for k,element in pairs(instances) do
                    if element and element.valid then
                        callback(self,element,value)
                    else
                        instances[k] = nil
                    end
                end

            end
        end)

        return self
    end
end

function Gui._new_define(prototype)
    local uid = Gui.uid_name()
    local define = setmetatable({
        name=uid,
        events={},
        draw_data={
            name=uid
        }
    },{
        __index=prototype,
        __call=function(self,element)
            return self:draw_to(element)
        end
    })
    Gui.defines[define.name] = define
    return define
end

--- Gets the uid for the config
function Gui._prototype:uid()
    return self.name
end

--- Sets an alias to the uid
function Gui._prototype:debug_name(name)
    self.debug_name = name
    Gui.names[name] = self.name
    Gui.names[self.name] = name
    return self
end

--- Sets the caption for the element config
function Gui._prototype:set_caption(caption)
    self.draw_data.caption = caption
    return self
end

--- Sets the tooltip for the element config
function Gui._prototype:set_tooltip(tooltip)
    self.draw_data.tooltip = tooltip
    return self
end

--- Sets an authenticator that blocks the draw function if check fails
function Gui._prototype:set_pre_authenticator(callback)
    if type(callback) ~= 'function' then
        return error('Pre authenticator callback must be a function')
    end

    self.pre_authenticator = callback
    return self
end

--- Sets an authenticator that disables the element if check fails
function Gui._prototype:set_post_authenticator(callback)
    if type(callback) ~= 'function' then
        return error('Authenicater callback must be a function')
    end

    self.post_authenticator = callback
    return self
end

--- Draws the element using what is in the draw_data table, allows use of authenticator if present
function Gui._prototype:draw_to(element)
    if element[self.name] then return end
    local player = Game.get_player_by_index(element.player_index)

    if self.pre_authenticator then
        if not self.pre_authenticator(player,self.clean_name or self.name) then return end
    end

    local new_element = element.add(self.draw_data)

    if self.post_authenticator then
        new_element.enabled = self.post_authenticator(player,self.clean_name or self.name)
    end

    if self.store then
        local category = self.categorize and self.categorize(element) or nil
        local instances = Gui.get_instances(self,category)
        if instances then
            table.insert(instances,new_element)
        end
    end

    if self.post_draw then self.post_draw(new_element) end

    return new_element
end

--- Gets the value in this elements store
function Gui._prototype:get_store(category)
    if not self.store then return end
    if self.categorize then
        return Store.get_child(self.store,category)
    else
        return Store.get(self.store)
    end
end

--- Sets the value in this elements store
function Gui._prototype:set_store(category,value)
    if not self.store then return end
    if self.categorize then
        return Store.set_child(self.store,category,value)
    else
        return Store.set(self.store,category)
    end
end

function Gui.get_define(name,internal)
    local define = Gui.defines[name]

    if not define and Gui.names[name] then
        return Gui.defines[Gui.names[name]]

    elseif not define then
        return error('Invalid name for checkbox, name not found.',internal and 3 or 2) or nil

    end

    return define
end

function Gui.get_instances(self,category)
    if not Gui.instances[self.name] then return end

    local instances = Gui.instances[self.name]
    if self.categorize then
        if not instances[category] then instances[category] = {} end
        return instances[category]

    end

    return instances
end

function Gui.get_store(name,category)
    local define = Gui.get_define(name,true)
    return define:get_store(category)
end

function Gui.set_store(name,category,value)
    local define = Gui.get_define(name,true)
    return define:get_store(category,value)
end

function Gui.draw(name,element)
    local define = Gui.get_define(name,true)
    return define:draw_to(element)
end

function Gui.toggle_enable(element)
    if not element or not element.valid then return end
    if not element.enabled then
        element.enabled = true
    else
        element.enabled = false
    end
end

function Gui.toggle_visible(element)
    if not element or not element.valid then return end
    if not element.visible then
        element.visible = true
    else
        element.visible = false
    end
end

return Gui