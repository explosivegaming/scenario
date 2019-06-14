--- Core gui file for making element defines and element classes (use require 'expcore.gui')
-- see utils.gui for event handlering
-- see expcore.gui.test for examples for element defines
--[[
>>>> Basic useage with no defines
    This module can be igroned if you are only wanting only event handlers as utils.gui adds the following:

    Gui.uid_name() --- Generates a unqiue name to register events to
    Gui.on_checked_state_changed(callback) --- Register a handler for the on_gui_checked_state_changed event
    Gui.on_click(callback) --- Register a handler for the on_gui_click event
    Gui.on_elem_changed(callback) --- Register a handler for the on_gui_elem_changed
    Gui.on_selection_state_changed(callback) --- Register a handler for the on_gui_selection_state_changed event
    Gui.on_text_changed(callback) --- Register a handler for the on_gui_text_changed event
    Gui.on_value_changed(callback) --- Register a handler for the on_gui_value_changed event

    Note that all event handlers will include event.player as a valid player and that if the player or the
    element is not valid then the callback will not be run.

>>>> Basic prototype functions (see expcore.gui.prototype)
    Using a class defination you can create a new element dinfation in our examples we will be using the checkbox.

    local checkbox_example = Gui.new_checkbox()

    Although all class definations are stored in Gui.classes the main function used to make new element defination are
    made aviable in the top level gui module. All functions which return a new element defination will accept a name argument
    which is a name which is used while debuging and is not required to be used (has not been used in examples)

    Every element define will accept a caption and tooltip (although some may not show) and to do this you would use the two
    set function provided for the element defines:

    checkbox_example:set_caption('Example Checkbox')
    checkbox_example:set_tooltip('Example checkbox')

    Each element define can have event handlers set, for our example checkbox we only have access to on_change which will trigger
    when the state of the checkbox changes; if we want to assign handlers using the utils.gui methods then we can get the uid by calling
    the uid function on the element define; however, each element can only have one handler (of each event) so it is not possible to use
    Gui.on_checked_state_changed and on_change at the same time in our example.

    checkbox_example:on_change(function(player,element,value)
        player.print('Example checkbox is now: '..tostring(value))
    end)

    local checkbox_example_uid = checkbox_example:uid()
    Gui.on_click(checkbox_example_uid,function(event)
        event.player.print('You clicked the example checkbox!')
    end)

    Finally you will want to draw your element defines for which you can call deirectly on the deinfe or use Gui.draw to do; when Gui.draw is
    used it can be given either the element define, the define's uid or the debug name of the define (if set):

    checkbox_example:draw_to(parent_element)
    Gui.draw(checkbox_example_uid,parent_element)

>>>> Using authenticators with draw
    When an element is drawn to its parent it can always be used but if you want to limit who can use it then you can use an authenticator. There
    are two types which can be used: post and pre; using a pre authenticator will mean that the draw function is stoped before the element is added
    to the parent element while using a post authenticator will draw the element to the parent but will disable the element from interaction. Both may
    be used if you have use for such.

    -- unless global.checkbox_example_allow_pre_auth is true then the checkbox will not be drawn
    checkbox_example:set_pre_authenticator(function(player,define_name)
        player.print('Example checkbox pre auth callback ran')
        return global.checkbox_example_allow_pre_auth
    end)

    -- unless global.checkbox_example_allow_post_auth is true then the checkbox will be drawn but deactiveated (provided pre auth returns true)
    checkbox_example:set_post_authenticator(function(player,define_name)
        player.print('Example checkbox pre auth callback ran')
        return global.checkbox_example_allow_post_auth
    end)

>>>> Using store (see expcore.gui.prototype and expcore.gui.instances)
    A powerful assept of this gui system is allowing an automatic store for the state of a gui element, this means that when a gui is closed and re-opened
    the elements which have a store will retain they value even if the element was previously destroied. The store is not limited to only per player and can
    be catergorised by any method you want such as one that is shared between all players or by all players on a force. Using a method that is not limited to
    one player means that when one player changes the state of the element it will be automaticlly updated for all other player (even if the element is already drawn)
    and so this is a powerful and easy way to sync gui elements.

    -- note the example below is the same as checkbox_example:add_store(Gui.categorize_by_player)
    checkbox_example:add_store(function(element)
        local player = Game.get_player_by_index(element.player_index)
        return player.force.name
    end)

    Of course this tool is not limited to only player interactions; the current satate of a define can be gotten using a number of methods and the value can
    even be updated by the script and have all instances of the element define be updated. When you use a category then we must give a category to the get
    and set functions; in our case we used Gui.categorize_by_player which uses the player's name as the category which is why 'Cooldude2606' is given as a argument,
    if we did not set a function for add_store then all instances for all players have the same value and so a category is not required.

    checkbox_example:get_store('Cooldude2606')
    Gui.get_store(name,'Cooldude2606')

    checkbox_example:set_store('Cooldude2606',true)
    Gui.set_store(name,'Cooldude2606',true)

    These methods use the Store module which means that if you have the need to access these sotre location (for example if you want to add a watch function) then
    you can get the store location of any define using checkbox_example.store

    Important note about event handlers: when the store is updated it will also trigger the event handlers (such as on_element_update) for that define but only
    for the valid instances of the define which means if a player does not have the element drawn on a gui then it will not trigger the events; if you want a
    trigger for all updates then you can use on_store_update however you will be required to parse the category which may or may not be a
    player name (depends what store categorize function you use)

>>>> Example formating

    local checkbox_example =
    Gui.new_checkbox()
    :set_caption('Example Checkbox')
    :set_tooltip('Example checkbox')
    :add_store(Gui.categorize_by_player)
    :on_element_update(function(player,element,value)
        player.print('Example checkbox is now: '..tostring(value))
    end)

>>>> Functions
    Gui.new_define(prototype) --- Used internally to create new element defines from a class prototype
    Gui.draw(name,element) --- Draws a copy of the element define to the parent element, see draw_to

    Gui.categorize_by_player(element) --- A categorize function to be used with add_store, each player has their own value
    Gui.categorize_by_force(element) --- A categorize function to be used with add_store, each force has its own value
    Gui.categorize_by_surface(element) --- A categorize function to be used with add_store, each surface has its own value

    Gui.toggle_enabled(element) --- Will toggle the enabled state of an element
    Gui.toggle_visible(element) --- Will toggle the visiblity of an element
    Gui.set_padding(element,up,down,left,right) --- Sets the padding for a gui element
    Gui.set_padding_style(style,up,down,left,right) --- Sets the padding for a gui style
    Gui.create_alignment(element,flow_name) --- Allows the creation of a right align flow to place elements into
    Gui.destory_if_valid(element) --- Destroies an element but tests for it being present and valid first
    Gui.create_scroll_table(element,table_size,maximal_height,name) --- Creates a scroll area with a table inside, table can be any size
    Gui.create_header(element,caption,tooltip,right_align,name) --- Creates a header section with a label and button area
]]
local Gui = require 'utils.gui'
local Game = require 'utils.game'

Gui.classes = {} -- Stores the class definations used to create element defines
Gui.defines = {} -- Stores the indivdual element definations
Gui.names = {} -- Stores debug names to link to gui uids

--- Used to create new element defines from a class prototype, please use the own given by the class
-- @tparam table prototype the class prototype that will be used for the element define
-- @treturn table the new element define with all functions accessed via __index metamethod
function Gui.new_define(prototype,debug_name)
    local name = Gui.uid_name()
    local define = setmetatable({
        debug_name = debug_name,
        name = name,
        events = {},
        draw_data = {
            name = name
        }
    },{
        __index = prototype,
        __call = function(self,...)
            return self:draw_to(...)
        end
    })
    Gui.defines[define.name] = define
    return define
end

--- Gets an element define give the uid, debug name or a copy of the element define
-- @tparam name ?string|table the uid, debug name or define for the element define to get
-- @tparam[opt] boolean internal when true the error trace is one level higher (used internally)
-- @treturn table the element define that was found or an error
function Gui.get_define(name,internal)
    if type(name) == 'table' then
        if name.name and Gui.defines[name.name] then
            return Gui.defines[name.name]
        end
    end

    local define = Gui.defines[name]

    if not define and Gui.names[name] then
        return Gui.defines[Gui.names[name]]

    elseif not define then
        return error('Invalid name for element define, name not found.',internal and 3 or 2) or nil

    end

    return define
end

--- A categorize function to be used with add_store, each player has their own value
-- @tparam LuaGuiElement element the element that will be converted to a string
-- @treturn string the player's name who owns this element
function Gui.categorize_by_player(element)
    local player = Game.get_player_by_index(element.player_index)
    return player.name
end

--- A categorize function to be used with add_store, each force has its own value
-- @tparam LuaGuiElement element the element that will be converted to a string
-- @treturn string the player's force name who owns this element
function Gui.categorize_by_force(element)
    local player = Game.get_player_by_index(element.player_index)
    return player.force.name
end

--- A categorize function to be used with add_store, each surface has its own value
-- @tparam LuaGuiElement element the element that will be converted to a string
-- @treturn string the player's surface name who owns this element
function Gui.categorize_by_surface(element)
    local player = Game.get_player_by_index(element.player_index)
    return player.surface.name
end

--- Draws a copy of the element define to the parent element, see draw_to
-- @tparam name ?string|table the uid, debug name or define for the element define to draw
-- @tparam element LuaGuiEelement the parent element that it the define will be drawn to
-- @treturn LuaGuiElement the new element that was created
function Gui.draw(name,element,...)
    local define = Gui.get_define(name,true)
    return define:draw_to(element,...)
end

--- Will toggle the enabled state of an element
-- @tparam LuaGuiElement element the gui element to toggle
-- @treturn boolean the new state that the element has
function Gui.toggle_enabled(element)
    if not element or not element.valid then return end
    if not element.enabled then
        element.enabled = true
    else
        element.enabled = false
    end
    return element.enabled
end

--- Will toggle the visiblity of an element
-- @tparam LuaGuiElement element the gui element to toggle
-- @treturn boolean the new state that the element has
function Gui.toggle_visible(element)
    if not element or not element.valid then return end
    if not element.visible then
        element.visible = true
    else
        element.visible = false
    end
    return element.visible
end

--- Sets the padding for a gui element
-- @tparam LuaGuiElement element the element to set the padding for
-- @tparam[opt=0] number up the amount of padding on the top
-- @tparam[opt=0] number down the amount of padding on the bottom
-- @tparam[opt=0] number left the amount of padding on the left
-- @tparam[opt=0] number right the amount of padding on the right
function Gui.set_padding(element,up,down,left,right)
    local style = element.style
    style.top_padding = up or 0
    style.bottom_padding = down or 0
    style.left_padding = left or 0
    style.right_padding = right or 0
end

--- Sets the padding for a gui style
-- @tparam element LuaStyle the element to set the padding for
-- @tparam[opt=0] number up the amount of padding on the top
-- @tparam[opt=0] number down the amount of padding on the bottom
-- @tparam[opt=0] number left the amount of padding on the left
-- @tparam[opt=0] number right the amount of padding on the right
function Gui.set_padding_style(style,up,down,left,right)
    style.top_padding = up or 0
    style.bottom_padding = down or 0
    style.left_padding = left or 0
    style.right_padding = right or 0
end

--- Allows the creation of an alignment flow to place elements into
-- @tparam LuaGuiElement element the element to add this alignment into
-- @tparam[opt] string name the name to use for the alignment
-- @tparam[opt='right'] string horizontal_align the horizontal alignment of the elements in this flow
-- @tparam[opt='center'] string vertical_align the vertical alignment of the elements in this flow
-- @treturn LuaGuiElement the new flow that was created
function Gui.create_alignment(element,name,horizontal_align,vertical_align)
    local flow = element.add{name=name,type='flow'}
    local style = flow.style
    Gui.set_padding(flow,1,1,2,2)
    style.horizontal_align = horizontal_align or 'right'
    style.vertical_align = vertical_align or 'center'
    style.horizontally_stretchable =style.horizontal_align ~= 'center'
    style.vertically_stretchable  = style.vertical_align ~= 'center'
    return flow
end

--- Destroies an element but tests for it being present and valid first
-- @tparam LuaGuiElement element the element to be destroied
-- @treturn boolean true if it was destoried
function Gui.destory_if_valid(element)
    if element and element.valid then
        element.destroy()
        return true
    end
end

--- Creates a scroll area with a table inside, table can be any size
-- @tparam LuaGuiElement element the element to add this scroll into
-- @tparam number table_size the number of columns in the table
-- @tparam number maximal_height the max hieght of the scroll
-- @tparam[opt='scroll'] string name the name of the scoll element
-- @treturn LuaGuiElement the table that was made
function Gui.create_scroll_table(element,table_size,maximal_height,name)
    local list_scroll =
    element.add{
        name=name or 'scroll',
        type='scroll-pane',
        direction='vertical',
        horizontal_scroll_policy='never',
        vertical_scroll_policy='auto-and-reserve-space'
    }
    Gui.set_padding(list_scroll,1,1,2,2)
    list_scroll.style.horizontally_stretchable = true
    list_scroll.style.maximal_height = maximal_height

    local list_table =
    list_scroll.add{
        name='table',
        type='table',
        column_count=table_size
    }
    Gui.set_padding(list_table)
    list_table.style.horizontally_stretchable = true
    list_table.style.vertical_align = 'center'
    list_table.style.cell_padding = 0

    return list_table
end

--- Creates a header section with a label and button area
-- @tparam LuaGuiElement element the element to add this header into
-- @tparam localeString caption the caption that is used as the title
-- @tparam[opt] localeString tooltip the tooltip that is shown on the caption
-- @tparam[opt] boolean right_align when true will include the right align area
-- @tparam[opt='header'] string name the name of the header area
-- @treturn LuaGuiElement the header that was made, or the align area if that was created
function Gui.create_header(element,caption,tooltip,right_align,name)
    local header =
    element.add{
        name=name or 'header',
        type='frame',
        style='subheader_frame'
    }
    Gui.set_padding(header,2,2,4,4)
    header.style.horizontally_stretchable = true
    header.style.use_header_filler = false

    header.add{
        type='label',
        style='heading_1_label',
        caption=caption,
        tooltip=tooltip
    }

    return right_align and Gui.create_alignment(header,'header-align') or header
end

return Gui