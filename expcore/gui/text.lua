--- Gui class define for text fields and text boxs
--[[
>>>> Functions
    Text.new_text_field(name) --- Creates a new text field element define
    Text._prototype_field:on_element_update(callback) --- Registers a handler for when an element instance updates
    Text._prototype_field:on_store_update(callback) --- Registers a handler for when the stored value updates

    Text.new_text_box(name) --- Creates a new text box element define
    Text._prototype_field:on_element_update(callback) --- Registers a handler for when an element instance updates
    Text._prototype_field:on_store_update(callback) --- Registers a handler for when the stored value updates
    Text._prototype_box:set_selectable(state) --- Sets the text box to be selectable
    Text._prototype_box:set_word_wrap(state) --- Sets the text box to have word wrap
    Text._prototype_box:set_read_only(state) --- Sets the text box to be read only

    Other functions present from expcore.gui.core
]]
local Gui = require 'expcore.gui.core'
local Game = require 'utils.game'

--- Event call for on_text_changed and store update
-- @tparam table define the define that this is acting on
-- @tparam LuaGuiElement element the element that triggered the event
-- @tparam string value the new text for the text field
local function event_call(define,element,value)
    local player = Game.get_player_by_index(element.player_index)

    if define.events.on_element_update then
        define.events.on_element_update(player,element,value)
    end

end

--- Store call for store update
-- @tparam table define the define that this is acting on
-- @tparam LuaGuiElement element the element that triggered the event
-- @tparam string value the new text for the text field
local function store_call(define,element,value)
    element.text = value
    event_call(define,element,value)
end

local Text = {
    _prototype_field=Gui._prototype_factory{
        on_element_update = Gui._event_factory('on_element_update'),
        on_store_update = Gui._event_factory('on_store_update'),
        add_store = Gui._store_factory(store_call),
        add_sync_store = Gui._sync_store_factory(store_call)
    },
    _prototype_box=Gui._prototype_factory{
        on_element_update = Gui._event_factory('on_element_update'),
        on_store_update = Gui._event_factory('on_store_update'),
        add_store = Gui._store_factory(store_call),
        add_sync_store = Gui._sync_store_factory(store_call)
    }
}

--- Creates a new text field element define
-- @tparam[opt] string name the optional debug name that can be added
-- @treturn table the new text field element define
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

--- Creates a new text box element define
-- @tparam[opt] string name the optional debug name that can be added
-- @treturn table the new text box element define
function Text.new_text_box(name)
    local self = Text.new_text_field(name)
    self.draw_data.type = 'text-box'

    local mt = getmetatable(self)
    mt.__index = Text._prototype_box

    return self
end

--- Sets the text box to be selectable
-- @tparam[opt=true] boolean state when false will set the state to false
-- @treturn self table the define to allow for chaining
function Text._prototype_box:set_selectable(state)
    if state == false then
        self.selectable = false
    else
        self.selectable = true
    end
    return self
end

--- Sets the text box to have word wrap
-- @tparam[opt=true] boolean state when false will set the state to false
-- @treturn self table the define to allow for chaining
function Text._prototype_box:set_word_wrap(state)
    if state == false then
        self.word_wrap = false
    else
        self.word_wrap = true
    end
    return self
end

--- Sets the text box to be read only
-- @tparam[opt=true] boolean state when false will set the state to false
-- @treturn self table the define to allow for chaining
function Text._prototype_box:set_read_only(state)
    if state == false then
        self.read_only = false
    else
        self.read_only = true
    end
    return self
end

return Text