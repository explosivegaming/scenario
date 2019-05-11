--- Adds a button handler
local mod_gui = require 'mod-gui'
local Gui = require './core'

local Button = {
    config={},
    clean_names={},
    _prototype=Gui._extend_prototype{
        on_click = Gui._new_event_adder('on_click'),
        on_left_click = Gui._new_event_adder('on_left_click'),
        on_right_click = Gui._new_event_adder('on_right_click'),
    }
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
    local self = setmetatable({
        name=uid,
        clean_name=name,
        events={},
        draw_data={
            name=uid,
            style=mod_gui.button_style,
            type='button'
        }
    },{
        __index=Button._prototype,
        __call=function(element) return Button.config[uid]:draw_to(element) end
    })
    Button.config[uid] = self

    if name then
        Button.clean_names[uid]=name
        Button.clean_names[name]=uid
    end

    Gui.on_click(self.name,function(event)
        local mouse_button = event.button
        local keys = {alt=event.alt,control=event.control,shift=event.shift}
        event.keys = keys

        if self.post_authenticator then
            if not self.post_authenticator(event.player,self.clean_name or self.name) then return end
        end

        if mouse_button == defines.mouse_button_type.left and self.events.on_left_click then
            self.events.on_left_click(event.player,event.element,event)
        elseif mouse_button == defines.mouse_button_type.right and self.events.on_right_click then
            self.events.on_right_click(event.player,event.element,event)
        end

        if self.mouse_button_filter and not self.mouse_button_filter[mouse_button] then return end
        if self.key_button_filter then
            for key,state in pairs(self.key_button_filter) do
                if state and not keys[key] then return end
            end
        end

        if self.events.on_click then
            self.events.on_click(event.player,event.element,event)
        end
    end)

    return self
end

function Button.draw_button(name,element)
    local config = get_config(name)
    return config:draw_to(element)
end

function Button._prototype:set_sprites(sprite,hovered_sprite,clicked_sprite)
    self.draw_data.type = 'sprite-button'
    self.draw_data.sprite = sprite
    self.draw_data.hovered_sprite = hovered_sprite
    self.draw_data.clicked_sprite = clicked_sprite
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

return Button