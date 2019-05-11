local Gui = require 'utils.gui'
local Game = require 'utils.game'

Gui._prototype = {}
Gui.inputs = {}
Gui.structure = {}
Gui.outputs = {}

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

--- Gets the uid for the config
function Gui._prototype:uid()
    return self.name
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
    local _element = element.add(self.draw_data)
    if self.post_authenticator then
        _element.enabled = not not self.post_authenticator(player,self.clean_name or self.name)
    end
    if self._post_draw then self._post_draw(_element) end
    return _element
end

function Gui.toggle_enable(element)
    if not element or not element.valid then return end
    if not element.enabled then
        -- this way round so if its nil it will become false
        element.enabled = true
    else
        element.enabled = false
    end
end

function Gui.toggle_visible(element)
    if not element or not element.valid then return end
    if not element.visible then
        -- this way round so if its nil it will become false
        element.visible = true
    else
        element.visible = false
    end
end

return Gui