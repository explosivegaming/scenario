local Gui = require "expcore.gui" --- @dep expcore.gui
local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data

-- Used to store the state of the toolbar when a player leaves
local ToolbarState = PlayerData.Settings:combine('ToolbarState')
ToolbarState:set_metadata{
    stringify = function(_)
        return "Value calculated on disconnect"
    end
}

-- Styles used for sprite buttons
local button_size = 20
local Styles = {
    header = Gui.sprite_style(22),
    item = Gui.sprite_style(button_size)
}

--- Set the style of the fake toolbar element
local function copy_style(src, dst)
    dst.style = src.style.name
    dst.style.height = button_size
    dst.style.width = button_size
    dst.style.padding = -2
end

local toolbar_container, move_up, move_down

--- Reorder the buttons in the left flow to match that of the current state, reads the datastore
local function reorder_toolbar_menu(player)
    local frame = Gui.get_left_element(player, toolbar_container)
    local list = frame.container.scroll.list
    local order = ToolbarState:get(player)

    for index, state in ipairs(order) do
        local element_define = Gui.defines[state.element_uid]

        -- Switch item order
        local top_element = list[element_define.name]
        list.swap_children(index, top_element.get_index_in_parent())

        -- Check if the player is allowed to see the button
        local allowed = element_define.authenticator
        if type(allowed) == 'function' then allowed = allowed(player) end

        -- Update the checkbox state and item visibility
        local checkbox = list[element_define.name].checkbox
        local toolbar_button = Gui.get_top_element(player, element_define)
        toolbar_button.visible = allowed and state.favourite or false
        checkbox.state = state.favourite
    end
end

--- Reorder the buttons relative to each other, this will update the datastore
local function move_toolbar_button(player, item, offset)
    local old_index = item.get_index_in_parent()
    local new_index = old_index + offset

    -- Swap the position in the list
    local list = item.parent
    local other_item = list.children[new_index]
    list.swap_children(old_index, new_index)

    -- Swap the position in the top flow, offset by 1 because of settings button
    local top_flow = Gui.get_top_flow(player)
    top_flow.swap_children(old_index+1, new_index+1)

    -- Check if the element has a left element to move
    local element_define = Gui.defines[item.tags.top_element_uid]
    local other_define = Gui.defines[other_item.tags.top_element_uid]
    if element_define.left_flow_element and other_define.left_flow_element then
        local left_element = Gui.get_left_element(player, element_define.left_flow_element)
        local left_index = left_element.get_index_in_parent()
        left_element.parent.swap_children(left_index, left_index-1)
    end

    -- If we are moving in/out of first/last place we need to update the move buttons
    local last_index = #list.children
    if old_index == 1 then -- Moving out of index 1
        other_item.move[move_up.name].enabled = false
        item.move[move_up.name].enabled = true
    elseif new_index == 1 then -- Moving into index 1
        other_item.move[move_up.name].enabled = true
        item.move[move_up.name].enabled = false
    elseif old_index == last_index then -- Moving out of the last index
        other_item.move[move_down.name].enabled = false
        item.move[move_down.name].enabled = true
    elseif new_index == last_index then -- Moving into the last index
        other_item.move[move_down.name].enabled = true
        item.move[move_down.name].enabled = false
    end
end

--- Resets the toolbar to its default state when pressed
-- @element reset_toolbar
local reset_toolbar =
Gui.element {
    type = "sprite-button",
    sprite = "utility/reset",
    style = "shortcut_bar_button_red",
    tooltip = {"toolbar.reset"},
    name = Gui.unique_static_name
}
:style(Gui.sprite_style(Styles.header.width, -1))
:on_click(function(player)
    ToolbarState:set(player, nil)
end)

--- Replaces the default method for opening and closing the toolbar
-- @element toggle_toolbar
local toggle_toolbar =
Gui.element {
    type = "sprite-button",
    sprite = "utility/bookmark",
    tooltip = {"toolbar.toggle"},
    style = "tool_button",
    auto_toggle = true,
    name = Gui.unique_static_name
}
:style(Styles.header)
:on_click(function(player, element)
    Gui.toggle_top_flow(player, element.toggled)
end)

--- Move an element up the list
-- @element move_up
move_up =
Gui.element {
    type = "sprite-button",
    sprite = "utility/speed_up",
    tooltip = {"toolbar.move-up"},
    name = Gui.unique_static_name
}
:style(Styles.item)
:on_click(function(player, element)
    local item = element.parent.parent
    move_toolbar_button(player, item, -1)
end)

--- Move an element down the list
-- @element move_down
move_down =
Gui.element {
    type = "sprite-button",
    sprite = "utility/speed_down",
    tooltip = {"toolbar.move-down"},
    name = Gui.unique_static_name
}
:style(Styles.item)
:on_click(function(player, element)
    local item = element.parent.parent
    move_toolbar_button(player, item, 1)
end)

--- A flow which represents one item in the toolbar list
-- @element toolbar_list_item
local toolbar_list_item =
Gui.element(function(definition, parent, element_define)
    local flow = parent.add {
        type = "frame",
        style = "shortcut_selection_row",
        name = element_define.name,
        tags = {
            top_element_uid = element_define.uid
        }
    }
    flow.style.horizontally_stretchable = true
    flow.style.vertical_align = "center"

    -- Add the button and the icon edit button
    local element = element_define(flow)
    local player = Gui.get_player_from_element(parent)
    local top_element = Gui.get_top_element(player, element_define)
    copy_style(top_element, element)

    -- Add the checkbox that can toggle the visibility
    local checkbox = flow.add{
        type = "checkbox",
        name = "checkbox",
        caption = element_define.tooltip or element_define.caption or "None",
        state = top_element.visible or false,
        tags = {
            top_element_name = element_define.name
        }
    }
    definition:triggers_events(checkbox)
    checkbox.style.width = 180

    -- Add the buttons used to move the flow up and down
    local move_flow = flow.add{ type = "flow", name = "move" }
    move_flow.style.horizontal_spacing = 0
    move_up(move_flow)
    move_down(move_flow)

    return definition:no_events(flow)
end)
:on_checked_changed(function(player, element)
    local top_flow = Gui.get_top_flow(player)
    local top_element = top_flow[element.tags.top_element_name]
    local had_visible = Gui.top_flow_has_visible_elements(player)
    top_element.visible = element.state

    -- Check if we are on the edge case between 0 and 1 visible elements
    if element.state and not had_visible then
        Gui.toggle_top_flow(player, true)
        local container = element.parent.parent.parent.parent
        local button = container.header.alignment[toggle_toolbar.name]
        button.toggled = true
        button.enabled = true
    elseif not element.state and not Gui.top_flow_has_visible_elements(player) then
        Gui.toggle_top_flow(player, false)
        local container = element.parent.parent.parent.parent
        local button = container.header.alignment[toggle_toolbar.name]
        button.toggled = false
        button.enabled = false
    end
end)

--- Scrollable list of all toolbar buttons
-- @element toolbar_list
local toolbar_list =
Gui.element(function(_, parent)
    local scroll_pane = parent.add {
        name = "scroll",
        type = "scroll-pane",
        direction = "vertical",
        horizontal_scroll_policy = "never",
        vertical_scroll_policy = "auto",
        style = "scroll_pane_under_subheader"
    }
    scroll_pane.style.horizontally_stretchable = true
    scroll_pane.style.padding = 0
    scroll_pane.style.maximal_height = 224

    local flow = scroll_pane.add {
        name = "list",
        type = "flow",
        direction = "vertical"
    }
    flow.style.vertical_spacing = 0
    flow.style.horizontally_stretchable = true

    return flow
end)

--- Main toolbar container for the left flow
-- @element toolbar_container
toolbar_container =
Gui.element(function(definition, parent)
    -- Draw the internal container
    local container = Gui.container(parent, definition.name, 268)
    container.style.maximal_width = 268
    container.style.minimal_width = 268

    -- Draw the header
    local player = Gui.get_player_from_element(parent)
    local header = Gui.header(container, {"toolbar.main-caption"}, {"toolbar.main-tooltip"}, true)

    -- Draw the toolbar control buttons
    local toggle_element = toggle_toolbar(header)
    toggle_element.toggled = Gui.get_top_flow(player).visible
    reset_toolbar(header)

    -- Draw toolbar list element
    local list_element = toolbar_list(container)
    local flow_order = Gui.get_top_flow_order(player)

    for _, element_define in ipairs(flow_order) do
        -- Ensure the element exists
        local element = list_element[element_define.name]
        if not element then
            element = toolbar_list_item(list_element, element_define)
        end

        -- Set the visible state
        local allowed = element_define.authenticator
        if type(allowed) == 'function' then allowed = allowed(player) end
        element.visible = allowed or false
    end

    -- Set the state of the move buttons for the first and last element
    local children = list_element.children
    children[1].move[move_up.name].enabled = false
    children[#children].move[move_down.name].enabled = false

    -- Return the external container
    return container.parent
end)
:static_name(Gui.unique_static_name)
:add_to_left_flow(true)

--- Set the default value for the datastore
local toolbar_default_state = {}
ToolbarState:set_default(toolbar_default_state)

--- For all top element, register an on click which will copy their style
for index, element_define in ipairs(Gui.top_elements) do
    -- This is a bit hacky, the gui system cant have multiple handlers registered
    local prev_handler = element_define[Gui.events.on_toolbar_button_toggled]

    -- Add the handler for when the button is toggled
    element_define:on_event(Gui.events.on_toolbar_button_toggled, function(player, element, event)
        if prev_handler then prev_handler(player, element, event) end -- Kind of hacky but works
        local frame = Gui.get_left_element(player, toolbar_container)
        if not frame then return end -- Gui might not be loaded yet
        local button = frame.container.scroll.list[element_define.name][element_define.name]
        local toolbar_button = Gui.get_top_element(player, element_define)
        copy_style(toolbar_button, button)
    end)

    -- Add the element to the default state
    table.insert(toolbar_default_state, {
        element_uid = element_define.uid,
        favourite = true,
    })
end

--- Make the toolbar the first left element
Gui.inject_top_flow_order(function(player)
    local order = ToolbarState:get(player)

    local elements = {}
    for index, state in ipairs(order) do
        elements[index] = Gui.defines[state.element_uid]
    end

    return elements
end)

--- Make the toolbar the first left element
Gui.inject_left_flow_order(function(player)
    local order = Gui.get_top_flow_order(player)
    local elements, element_map = { toolbar_container }, { [toolbar_container] = true }

    -- Add the flows that have a top element
    for _, element_define in ipairs(order) do
        if element_define.left_flow_element then
            table.insert(elements, element_define.left_flow_element)
            element_map[element_define.left_flow_element] = true
        end
    end

    -- Add the flows that dont have a top element
    for _, element_define in ipairs(Gui.left_elements) do
        if not element_map[element_define] then
            table.insert(elements, element_define)
        end
    end

    return elements
end)

--- Overwrite the default toggle behaviour and instead toggle this menu
Gui.core_defines.hide_top_flow:on_click(function(player, _, _)
    Gui.toggle_left_element(player, toolbar_container)
end)

--- Overwrite the default toggle behaviour and instead toggle this menu
Gui.core_defines.show_top_flow:on_click(function(player, _, _)
    Gui.toggle_left_element(player, toolbar_container)
end)

--- Get the datastore id for this element define, to best of ability it should be unique between versions
local function to_datastore_id(element_define)
    return element_define.uid -- TODO
end

--- Get the element from a datastore id, to best of ability it should be unique between versions
local function from_datastore_id(datastore_id)
    return Gui.defines[datastore_id]
end

--- When the value updates also update the guis
ToolbarState:on_update(function(player_name, _)
    local player = game.get_player(player_name)
    Gui.reorder_top_flow(player)
    Gui.reorder_left_flow(player)
    reorder_toolbar_menu(player)
end)

--- Uncompress the data to be more useable
ToolbarState:on_load(function(player_name, value)
    -- If there is no value, do nothing
    if value == nil then return end

    -- Create a hash map of the favourites
    local favourites = {}
    for _, id in ipairs(value[2]) do
        favourites[id] = true
    end

    -- Read the order from the value
    local elements = {}
    local element_hash = {}
    for index, id in ipairs(value[1]) do
        local element = from_datastore_id(id)
        element_hash[element] = true
        elements[index] = {
            element_uid = element.uid,
            favourite = favourites[id] or false,
        }
    end

    -- Add any in the default state that are missing
    for _, state in ipairs(toolbar_default_state) do
        if not element_hash[state.element_uid] then
            table.insert(elements, table.deep_copy(state))
        end
    end

    -- Create a hash map of the open left flows
    local left_flows = {}
    for _, id in ipairs(value[3]) do
        local element = from_datastore_id(id)
        left_flows[element] = true
    end

    -- Set the visible state of all left flows
    local player = game.get_player(player_name)
    for _, left_element in ipairs(Gui.left_elements) do
        Gui.toggle_left_element(player, left_element, left_flows[left_element] or false)
    end

    -- Set the toolbar visible state
    local top_flow = Gui.get_top_flow(player)
    top_flow.parent.visible = value[4]

    return elements
end)

--- Save the current state of the players toolbar menu
ToolbarState:on_save(function(player_name, _)
    local order, favourites, left_flows = {}, {}, {}

    local player = game.get_player(player_name)
    local top_flow_open = Gui.get_top_flow(player).parent.visible
    local frame = Gui.get_left_element(player, toolbar_container)
    local list = frame.container.scroll.list

    for _, element_define in ipairs(Gui.top_elements) do
        -- Add the element to the order array
        local id = to_datastore_id(element_define)
        local index = list[element_define.name].get_index_in_parent()
        order[index] = id

        -- If its a favourite then insert it
        if list[element_define.name].checkbox.state then
            table.insert(favourites, id)
        end

        -- If it has a left flow and its open then insert it
        if element_define.left_flow_element then
            local left_element = Gui.get_left_element(player, element_define.left_flow_element)
            if left_element.visible then
                table.insert(left_flows, id)
            end
        end
    end

    return { order, favourites, left_flows, top_flow_open }
end)