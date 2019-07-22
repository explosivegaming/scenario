--- Gui class define for buttons and sprite buttons
--[[
>>>> Functions
    Button.new_button(name) --- Creates a new button element define

    Button._prototype:on_click(player,element) --- Registers a handler for when the button is clicked
    Button._prototype:on_left_click(player,element) --- Registers a handler for when the button is clicked with the left mouse button
    Button._prototype:on_right_click(player,element) --- Registers a handler for when the button is clicked with the right mouse button

    Button._prototype:set_sprites(sprite,hovered_sprite,clicked_sprite) --- Adds sprites to a button making it a sprite button
    Button._prototype:set_click_filter(filter,...) --- Adds a click / mouse button filter to the button
    Button._prototype:set_key_filter(filter,...) --- Adds a control key filter to the button

    Other functions present from expcore.gui.core
]]
local mod_gui = require 'mod-gui' --- @dep mod-gui
local Gui = require 'expcore.gui.core' --- @dep expcore.gui.core
local Prototype = require 'expcore.gui.prototype' --- @dep expcore.gui.prototype

local Button = {
    _prototype=Prototype.extend{
        on_raw_click = Prototype.event,
        on_click = Prototype.event,
        on_left_click = Prototype.event,
        on_right_click = Prototype.event,
    }
}

--- Creates a new button element define
-- @tparam[opt] string name the optional debug name that can be added
-- @treturn table the new button element define
function Button.new_button(name)

    local self = Gui.new_define(Button._prototype,name)
    self.draw_data.type = 'button'
    self.draw_data.style = mod_gui.button_style

    Gui.on_click(self.name,function(event)
        local mouse_button = event.button
        local keys = {alt=event.alt,control=event.control,shift=event.shift}
        local player,element = event.player,event.element
        event.keys = keys

        self:raise_event('on_raw_click',event)

        if self.post_authenticator then
            if not self.post_authenticator(event.player,self.name) then return end
        end

        if mouse_button == defines.mouse_button_type.left then
            self:raise_event('on_left_click',player,element)
        elseif mouse_button == defines.mouse_button_type.right and self.events.on_right_click then
            self:raise_event('on_right_click',player,element)
        end

        if self.mouse_button_filter and not self.mouse_button_filter[mouse_button] then return end
        if self.key_button_filter then
            for key,state in pairs(self.key_button_filter) do
                if state and not keys[key] then return end
            end
        end

        self:raise_event('on_click',player,element)
    end)

    return self
end

--- Adds sprites to a button making it a sprite button
-- @tparam SpritePath sprite the sprite path for the default sprite for the button
-- @tparam[opt] SpritePath hovered_sprite the sprite path for the sprite when the player hovers over the button
-- @tparam[opt] SpritePath clicked_sprite the sprite path for the sprite when the player clicks the button
-- @treturn self returns the button define to allow chaining
function Button._prototype:set_sprites(sprite,hovered_sprite,clicked_sprite)
    self.draw_data.type = 'sprite-button'
    self.draw_data.sprite = sprite
    self.draw_data.hovered_sprite = hovered_sprite
    self.draw_data.clicked_sprite = clicked_sprite
    return self
end

--- Adds a click / mouse button filter to the button
-- @tparam table filter ?string|table either a of mouse buttons or the first mouse button to filter, with a table true means allowed
-- @tparam[opt] table ... when filter is not a you can add the mouse buttons one after each other
-- @treturn self returns the button define to allow chaining
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

--- Adds a control key filter to the button
-- @tparam table filter ?string|table either a of control keys or the first control keys to filter, with a table true means allowed
-- @tparam[opt] table ... when filter is not a you can add the control keys one after each other
-- @treturn self returns the button define to allow chaining
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