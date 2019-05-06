--- Adds a button handler
local mod_gui = require 'mod-gui'
local Gui = require './core'

local Button = {
    config={},
    clean_names={},
    _prototype=Gui._extend_prototype{}
}

local function get_config(name)
    local config = Button.config[name]
    if not config and Button.clean_names[name] then
        return Button.config[Button.clean_names[name]]
    elseif not config then
        return error('Invalid name for checkbox, name not found.',3)
    end
    return config
end

function Button.new_button(name)
    local uid = Gui.uid_name()
    Button.config[uid] = setmetatable({
        name=uid,
        clean_name=name,
        style=mod_gui.button_style,
        type='button'
    },{__index=Button._prototype})
    if name then
        Button.clean_names[uid]=name
        Button.clean_names[name]=uid
    end
    return Button.config[uid]
end

function Button.draw_button(name,element)
    local button = get_config(name)
    return button:draw_to(element)
end

function Button._prototype:draw_to(element)
    if element.children[self.name] then return end
    local draw = table.deep_copy(self)
    draw.authenticator = nil
    draw.clean_name = nil
    draw.raw_mouse_button_filter = nil
    draw.key_button_filter = nil
    draw._on_click = nil
    draw._on_left_click = nil
    draw._on_right_click = nil
    draw.has_handler = nil
    local self_element = element.add(draw)
    if self.authenticator then
        self_element.enabled = not not self.authenticator(element.player,self.clean_name or self.name)
    end
    return self_element
end

function Button._prototype:set_sprites(sprite,hovered_sprite,clicked_sprite)
    self.type = 'sprite-button'
    self.sprite = sprite
    self.hovered_sprite = hovered_sprite
    self.clicked_sprite = clicked_sprite
    return self
end

function Button._prototype:set_click_filter(filter,...)
    if type(filter) == 'string' then
        filter = {[filter]=true}
        for _,v in pairs({...}) do
            filter[v] = true
        end
    end
    for k,v in pairs(filter) do
        if type(v) == 'string' then
            filter[k] = defines.mouse_button_type[v]
        end
    end
    self.mouse_button_filter = filter
    self.raw_mouse_button_filter = filter
    return self
end

function Button._prototype:set_key_filter(filter,...)
    if type(filter) == 'string' then
        filter = {[filter]=true}
        for _,v in pairs({...}) do
            filter[v] = true
        end
    end
    self.key_button_filter = filter
    return self
end

function Button._prototype:set_authenticator(callback)
    if type(callback) ~= 'function' then
        return error('Authenicater callback must be a function')
    end
    self.authenticator = callback
    return self
end

function Button._prototype:on_click(callback)
    if type(callback) ~= 'function' then
        return error('Event callback must be a function')
    end
    self._on_click = callback
    self:_add_handler()
    return self
end

function Button._prototype:on_left_click(callback)
    if type(callback) ~= 'function' then
        return error('Event callback must be a function')
    end
    self._on_left_click = callback
    self:_add_handler()
    return self
end

function Button._prototype:on_right_click(callback)
    if type(callback) ~= 'function' then
        return error('Event callback must be a function')
    end
    self._on_right_click = callback
    self:_add_handler()
    return self
end

function Button._prototype:_add_handler()
    if self.has_handler then return end
    self.has_handler = true
    Gui.on_click(self.name,function(event)
        local mosue_button = event.button
        local keys = {alt=event.alt,control=event.control,shift=event.shift}
        event.keys = keys

        if self.authenticator then
            if not self.authenticator(event.player,self.clean_name or self.name) then return end
        end

        if mosue_button == defines.mouse_button_type.left and self._on_left_click then
            self.on_left_click(event.player,event.element,event)
        elseif mosue_button == defines.mouse_button_type.right and self._on_right_click then
            self.on_right_click(event.player,event.element,event)
        end

        if self.raw_mouse_button_filter and not self.raw_mouse_button_filter[mosue_button] then return end
        if self.key_button_filter then
            for key,state in pairs(self.key_button_filter) do
                if state and not keys[key] then return end
            end
        end

        self._on_click(event.player,event.element,event)
    end)
end

return Button