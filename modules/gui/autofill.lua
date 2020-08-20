--[[-- Gui Module - Autofill
    - Adds a button to enable Autofill
    @gui Autofill
    @alias autofill
]]

local Game = require 'utils.game' --- @dep utils.game
local Gui = require 'expcore.gui' --- @dep expcore.gui
local Global = require 'utils.global' --- @dep utils.global
local config = require 'config.gui.autofill' --- @dep config.gui.autofill
local Event = require 'utils.event' --- @dep utils.event
local table = require 'overrides.table' --- @dep overrides.table

local print_text = Game.print_floating_text -- (surface, position, text, color)

--- Table that stores if autofill is enabled or not
local autofill_player_settings = {}
Global.register(autofill_player_settings, function(tbl)
    autofill_player_settings = tbl
end)

local autofill_container

local function rich_img(type, value)
    return '[img='..type..'/'..value..']'
end

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
Gui.element(function(event_trigger, parent, setting)
    return parent.add{
        name = event_trigger,
        type = 'sprite-button',
        sprite = 'item/'..setting.item,
        tooltip = {'autofill.toggle-tooltip', rich_img('item', setting.item), setting.type},
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
Gui.element(function(event_trigger, parent, setting)
    return parent.add{
        name = event_trigger,
        type = 'textfield',
        text = setting.amount,
        tooltip = {'autofill.amount-tooltip', setting.type},
        clear_and_focus_on_right_click = true
    }
end)
:style{
    maximal_width = 90,
    height = 32,
    padding = -2
}
:on_confirmed(function(player, element, _)
    local parent_name = element.parent.name
    for _, setting in pairs(autofill_player_settings[player.name]) do
        if 'amount-setting-'..setting.item == parent_name then
            setting.amount = tonumber(element.text)
            player.print({'autofill.confirmed', setting.amount, '[img=item/'..setting.item..']'})
        end
    end
end)

local add_autofill_setting =
Gui.element(function(_, parent, setting)
    local toggle_flow = parent.add{ type = 'flow', name = 'toggle-setting-'..setting.item }
    local amount_flow = parent.add{ type = 'flow', name = 'amount-setting-'..setting.item }
    toggle_flow.style.padding = 0
    amount_flow.style.padding = 0
    toggle_item_button(toggle_flow, setting)
    amount_textfield(amount_flow, setting)
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
            add_autofill_setting(ammo_table, setting)
        elseif  setting.type == 'fuel' then
            add_autofill_setting(fuel_table, setting)
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
        autofill_player_settings[player.name] = table.deep_copy(config.default_settings)
    end
end)

local function entity_build(event)
    -- Check if player exists
    local player = game.players[event.player_index]
    if not player then
        return
    end
    -- Check if the entity is in the config and enabled
    local entity = event.created_entity
    local entity_configs = config.entities[entity.name]
    if not entity_configs then
        return
    end
    -- Get the inventory of the player
    local player_inventory = player.get_main_inventory()

    local text_position = { x = entity.position.x, y = entity.position.y }
    -- Loop over all possible item settings to insert into the entity
    for _, setting in pairs(autofill_player_settings[player.name]) do
        if not setting.enabled then
            goto end_setting
        end
        -- Loop over possible inventories for this setting to put into the vehicle
        for _, inventory in pairs(setting.inventories) do
            -- Check in the configs if the inventory type exists and is enabled for this vehicle
            if not entity_configs[inventory] or not entity_configs[inventory].enabled then
                goto end_inventory
            end

            -- Get the inventory of the entity
            local entity_inventory = entity.get_inventory(inventory)
            if not entity_inventory then
                goto end_inventory
            end

            local item = setting.item
            local preferd_amount = setting.amount
            local item_amount = player_inventory.get_item_count(item)
            if item_amount ~= 0 then
                local inserted
                text_position.y = text_position.y - 0.2
                if item_amount >= preferd_amount then
                    if not entity_inventory.can_insert({name=item, count=preferd_amount}) then
                        goto end_inventory
                    end
                    inserted = entity_inventory.insert({name=item, count=preferd_amount})
                    player_inventory.remove({name=item, count=inserted})
                    print_text(entity.surface, text_position, {'autofill.filled', rich_img('entity', entity.name), inserted, rich_img('item', item) }, { r = 0, g = 255, b = 0, a = 1})
                else
                    inserted = entity_inventory.insert({name=item, count=item_amount})
                    player_inventory.remove({name=item, count=inserted})
                    print_text(entity.surface, text_position, {'autofill.filled', rich_img('entity', entity.name), inserted, rich_img('item', item) }, { r = 255, g = 165, b = 0, a = 1})
                end
            end
            ::end_inventory::
        end
        ::end_setting::
    end
end

Event.add(defines.events.on_built_entity, entity_build)