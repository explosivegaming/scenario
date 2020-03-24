--[[-- Gui Module - Readme
    - Adds a main gui that contains lots of important information about our server
    @gui Readme
    @alias readme
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local Game = require 'utils.game' --- @dep utils.game

local tabs = {}
local function Tab(caption,tooltip,element_define)
    tabs[#tabs+1] = {caption,tooltip,element_define}
end

local function description_label(parent,width,caption)
    local label = parent.add{
        type = 'label',
        caption = caption,
        style = 'description_label'
    }

    local style = label.style
    style.horizontal_align = 'center'
    style.single_line = false
    style.width = width
end

--- Sub content area used within the content areas
-- @element sub_content
local sub_content =
Gui.element(function(_,parent)
    return parent.add{
        type = 'frame',
        direction = 'vertical',
        style = 'image_frame'
    }
end)
:style{
    horizontally_stretchable = true,
    horizontal_align = 'center'
}

--- Content area for the welcome tab
-- @element welcome_content
Tab({'readme.welcome-tab'},{'readme.welcome-tooltip'},
Gui.element(function(_,parent)
    local server_details = global.server_details or { name='ExpGaming S0 - Local', description='Failed to load description: disconnected from sync api.', reset_time='Non Set', branch='Unknown'}
    local container = parent.add{ type='flow', direction='vertical' }
    local player = Gui.get_player_from_element(parent)

    -- Set up the top flow with logos
    local top_flow = container.add{ type='flow' }
    top_flow.add{ type='sprite', sprite='file/modules/gui/logo.png'}
    local top_vertical_flow = top_flow.add{ type='flow', direction='vertical' }
    top_flow.add{ type='sprite', sprite='file/modules/gui/logo.png'}
    top_vertical_flow.style.horizontal_align = 'center'

    -- Add the title to the top flow
    local title_flow = top_vertical_flow.add{ type='flow' }
    title_flow.style.vertical_align = 'center'
    Gui.bar(title_flow,85)
    title_flow.add{
        type = 'label',
        caption = 'Welcome to '..server_details.name,
        style = 'caption_label'
    }
    Gui.bar(title_flow,85)

    -- Add the description to the top flow
    description_label(top_vertical_flow,380,server_details.description)
    Gui.bar(container)

    -- Get the names of the roles the player has
    local player_roles = Roles.get_player_roles(player)
    local role_names = {}
    for i,role in ipairs(player_roles) do
        role_names[i] = role.name
    end

    -- Add the other information to the gui
    description_label(sub_content(container),575,{'readme.welcome-general',server_details.reset_time})
    description_label(sub_content(container),575,{'readme.welcome-roles',table.concat(role_names,', ')})
    description_label(sub_content(container),575,{'readme.welcome-chat'})

    return container
end))

--- Content area for the rules tab
-- @element rules_content
Tab({'readme.rules-tab'},{'readme.rules-tooltip'},
Gui.element(function(_,parent)
    local container = parent.add{ type='flow', direction='vertical' }

    -- Add the title to the content
    local title_flow = container.add{ type='flow' }
    title_flow.style.vertical_align = 'center'
    Gui.bar(title_flow,267)
    title_flow.add{
        type = 'label',
        caption = {'readme.rules-tab'},
        style = 'heading_1_label'
    }
    Gui.bar(title_flow,267)

    -- Add the tab description
    description_label(container,575,{'readme.rules-general'})
    Gui.bar(container)

    -- Add a table for the rules
    local rules = Gui.scroll_table(container,275,1)
    rules.style = 'bordered_table'
    rules.style.top_margin = 2

    -- Add the rules to the table
    for i = 1,15 do
        description_label(rules,545,{'readme.rules-'..i})
    end

    return container
end))

--- Content area for the commands tab
-- @element commands_content
Tab({'readme.commands-tab'},{'readme.commands-tooltip'},
Gui.element{
    type = 'label',
    caption = 'Commands'
})

--- Content area for the servers tab
-- @element servers_content
Tab({'readme.servers-tab'},{'readme.servers-tooltip'},
Gui.element{
    type = 'label',
    caption = 'Servers'
})

--- Content area for the servers tab
-- @element backers_content
Tab({'readme.backers-tab'},{'readme.backers-tooltip'},
Gui.element{
    type = 'label',
    caption = 'Backers'
})

--- Main readme container for the center flow
-- @element readme
local readme_toggle
local readme =
Gui.element(function(event_trigger,parent)
    local container = parent.add{
        name = event_trigger,
        type = 'frame',
        style = 'invisible_frame'
    }

    -- Add the left hand side of the frame back, removed because of frame_tabbed_pane style
    local left_lignment = Gui.alignment(container,nil,nil,'bottom')
    left_lignment.style.padding = {32,0,0,0}

    local left_side =
    left_lignment.add{
        type = 'frame',
        style = 'frame_without_right_side'
    }
    left_side.style.vertically_stretchable = true
    left_side.style.padding = 0
    left_side.style.width = 5

    -- Add the tab pane
    local tab_pane = container.add{
        name = 'pane',
        type = 'tabbed-pane',
        style = 'frame_tabbed_pane'
    }

    -- Add the different content areas
    for _,tab_details in ipairs(tabs) do
        local tab = tab_pane.add{ type = 'tab', style = 'frame_tab', caption = tab_details[1], tooltip = tab_details[2] }
        tab_pane.add_tab(tab, tab_details[3](tab_pane))
    end

    return container
end)
:on_open(function(player)
    local toggle_button = Gui.get_top_element(player, readme_toggle)
    Gui.toolbar_button_style(toggle_button, true)
end)
:on_close(function(player,element)
    local toggle_button = Gui.get_top_element(player, readme_toggle)
    Gui.toolbar_button_style(toggle_button, false)
    Gui.destroy_if_valid(element)
end)

--- Toggle button for the readme gui
-- @element readme_toggle
readme_toggle =
Gui.toolbar_button('virtual-signal/signal-info',{'readme.main-tooltip'},function(player)
    return Roles.player_allowed(player,'gui/readme')
end)
:on_click(function(player,_)
    local center = player.gui.center
    if center[readme.name] then
        player.opened = nil
    else
        player.opened = readme(center)
    end
end)

--- When a player joins the game for the first time show this gui
Event.add(defines.events.on_player_created,function(event)
    local player = Game.get_player_by_index(event.player_index)
    local element = readme(player.gui.center)
    element.pane.selected_tab_index = 1
    player.opened = element
end)

--- When a player joins clear center unless the player has something open
Event.add(defines.events.on_player_joined_game,function(event)
    local player = Game.get_player_by_index(event.player_index)
    if not player.opened then
        player.gui.center.clear()
    end
end)