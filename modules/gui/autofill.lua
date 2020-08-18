--[[-- Gui Module - Autofill
    - Adds a button to enable Autofill
    @gui Autofill
    @alias autofill
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Global = require 'utils.global' --- @dep utils.global
local config = require 'config.gui.autofill' --- @dep config.gui.autofill
local Event = require 'utils.event' --- @dep utils.event

--- Table that stores if autofill is enabled or not
local autofill_player_settings = {}
Global.register(autofill_player_settings, function(tbl)
    autofill_player_settings = tbl
end)

local autofill_container

--- Draw a section header and main scroll
-- @element autofill_section_container
local section =
Gui.element(function(_, parent, section_name, table_size)
	-- Draw the header for the section
    Gui.header(
        parent,
        {'autofill.'..section_name..'-caption'},
        {'autofill.'..section_name..'-tooltip'},
		true,
		section_name..'-header'
    )
    -- Table used to display the settings
    local scroll_table = Gui.scroll_table(parent, 215, table_size, section_name..'-scroll-table')
    return scroll_table
end)

local toggle_item_button =
Gui.element(function(event_trigger, parent, item_name)
    return parent.add{
        name = event_trigger,
        type = 'sprite-button',
        sprite = 'item/'..item_name,
        tooltip = {'autofill.toggle-tooltip'},
        style = 'shortcut_bar_button_red'
    }
end)
:style(Gui.sprite_style(32, nil, { right_margin = -3 }))
:on_click(function(player, element)
    for _, setting in pairs(autofill_player_settings[player.name]) do
        if 'item/'..setting.item == element.sprite then
            if setting.enabled then
                setting.enabled = false
                element.style = 'shortcut_bar_button_red'
            else
                setting.enabled = true
                element.style = 'shortcut_bar_button_green'
            end
        end
    end
end)

local amount_textfield =
Gui.element(function(event_trigger, parent, amount)
    return parent.add{
        name = event_trigger,
        type = 'textfield',
        text = amount,
        tooltip = {'autofill.amount-tooltip'},
        clear_and_focus_on_right_click = true
    }
end)
:style{
    maximal_width = 90,
    height = 28
}

local add_autofill_setting =
Gui.element(function(_, parent, item_name, amount)
    local toggle_flow = parent.add{ type = 'flow', name = 'toggle-setting-'..item_name }
    local amount_flow = parent.add{ type = 'flow', name = 'amount-setting-'..item_name }
    toggle_flow.style.padding = 0
    amount_flow.style.padding = 0
    toggle_item_button(toggle_flow, item_name)
    amount_textfield(amount_flow, amount)
end)

--- Main gui container for the left flow
-- @element autofill_container
autofill_container =
Gui.element(function(event_trigger, parent)
    -- Draw the internal container
    local container = Gui.container(parent, event_trigger, 100)
    -- Draw the header
    local ammo_table = section(container, 'ammo', 2)
    local fuel_table = section(container, 'fuel', 2)

    for _, setting in pairs(config.default_settings) do
        if setting.type == 'ammo' then
            add_autofill_setting(ammo_table, setting.item, setting.amount)
        elseif  setting.type == 'fuel' then
            add_autofill_setting(fuel_table, setting.item, setting.amount)
        end
    end

    -- Return the external container
    return container.parent
end)
:add_to_left_flow()

--- Button on the top flow used to toggle autofill container
-- @element autofill_toggle
Gui.left_toolbar_button(config.icon, {'autofill.main-tooltip'}, autofill_container)

--- When a player is created make sure they have the default autofill settings
Event.add(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    if not autofill_player_settings[player.name] then
        autofill_player_settings[player.name] = config.default_settings
    end
end)