--[[-- Gui Module - Readme
    - Adds a main gui that contains lots of important information about our server
    @gui Readme
    @alias readme
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Commands = require 'expcore.commands' --- @dep expcore.commands
local Event = require 'utils.event' --- @dep utils.event
local Game = require 'utils.game' --- @dep utils.game
local format_time = _C.format_time --- @dep expcore.common

local tabs = {}
local function Tab(caption,tooltip,element_define)
    tabs[#tabs+1] = {caption, tooltip, element_define}
end

local frame_width = 595 -- controls width of top descritions
local title_width = 270 -- controls the centering of the titles
local scroll_hieght = 275 -- controls the height of the scrolls

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

--- Table which has a title above it above it
-- @element title_table
local title_table =
Gui.element(function(_,parent,bar_size,caption,column_count)
    Gui.title_label(parent, bar_size, caption)

    return parent.add{
        type = 'table',
        column_count = column_count,
        style = 'bordered_table'
    }
end)
:style{
    padding = 0,
    cell_padding = 0,
    vertical_align = 'center',
    horizontally_stretchable = true
}

--- Scroll to be used with Gui.title_label tables
-- @element title_table_scroll
local title_table_scroll =
Gui.element{
    type = 'scroll-pane',
    direction = 'vertical',
    horizontal_scroll_policy = 'never',
    vertical_scroll_policy = 'auto',
    style = 'scroll_pane_under_subheader'
}
:style{
    padding = {1,3},
    maximal_height = scroll_hieght,
    horizontally_stretchable = true,
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
    top_flow.add{ type='sprite', sprite='file/modules/gui/logo.png' }
    local top_vertical_flow = top_flow.add{ type='flow', direction='vertical' }
    top_flow.add{ type='sprite', sprite='file/modules/gui/logo.png' }
    top_vertical_flow.style.horizontal_align = 'center'

    -- Add the title and description to the top flow
    Gui.title_label(top_vertical_flow, 62, 'Welcome to '..server_details.name)
    Gui.centered_label(top_vertical_flow, 380, server_details.description)
    Gui.bar(container)

    -- Get the names of the roles the player has
    local player_roles = Roles.get_player_roles(player)
    local role_names = {}
    for i,role in ipairs(player_roles) do
        role_names[i] = role.name
    end

    -- Add the other information to the gui
    container.add{ type='flow' }.style.height = 4
    local online_time = format_time(game.tick,{days=true,hours=true,minutes=true,long=true})
    Gui.centered_label(sub_content(container), frame_width, {'readme.welcome-general', server_details.reset_time, online_time})
    Gui.centered_label(sub_content(container), frame_width, {'readme.welcome-roles', table.concat(role_names,', ')})
    Gui.centered_label(sub_content(container), frame_width, {'readme.welcome-chat'})

    return container
end))

--- Content area for the rules tab
-- @element rules_content
Tab({'readme.rules-tab'},{'readme.rules-tooltip'},
Gui.element(function(_,parent)
    local container = parent.add{ type='flow', direction='vertical' }

    -- Add the title and description to the content
    Gui.title_label(container, title_width-3, {'readme.rules-tab'})
    Gui.centered_label(container, frame_width, {'readme.rules-general'})
    Gui.bar(container)
    container.add{ type='flow' }

    -- Add a table for the rules
    local rules = Gui.scroll_table(container, scroll_hieght, 1)
    rules.style = 'bordered_table'
    rules.style.cell_padding = 4

    -- Add the rules to the table
    for i = 1,15 do
        Gui.centered_label(rules, 565, {'readme.rules-'..i})
    end

    return container
end))

--- Content area for the commands tab
-- @element commands_content
Tab({'readme.commands-tab'},{'readme.commands-tooltip'},
Gui.element(function(_,parent)
    local container = parent.add{ type='flow', direction='vertical' }
    local player = Gui.get_player_from_element(parent)

    -- Add the title and description to the content
    Gui.title_label(container, title_width-20, {'readme.commands-tab'})
    Gui.centered_label(container, frame_width, {'readme.commands-general'})
    Gui.bar(container)
    container.add{ type='flow' }

    -- Add a table for the commands
    local commands = Gui.scroll_table(container, scroll_hieght, 2)
    commands.style = 'bordered_table'
    commands.style.cell_padding = 0

    -- Add the rules to the table
    for name,command in pairs(Commands.get(player)) do
        Gui.centered_label(commands, 120, name)
        Gui.centered_label(commands, 450, command.help)
    end

    return container
end))

--- Content area for the servers tab
-- @element servers_content
Tab({'readme.servers-tab'},{'readme.servers-tooltip'},
Gui.element(function(_,parent)
    local container = parent.add{ type='flow', direction='vertical' }

    -- Add the title and description to the content
    Gui.title_label(container, title_width-10, {'readme.servers-tab'})
    Gui.centered_label(container, frame_width, {'readme.servers-general'})
    Gui.bar(container)
    container.add{ type='flow' }

    -- Draw the scroll
    local scroll_pane = title_table_scroll(container)
    scroll_pane.style.maximal_height = scroll_hieght + 20 -- the text is a bit shorter

    -- Add the factorio servers
    local factorio_servers = title_table(scroll_pane, 225, {'readme.servers-factorio'}, 2)
    for i = 1,8 do
        Gui.centered_label(factorio_servers, 110, {'readme.servers-'..i})
        Gui.centered_label(factorio_servers, 460, {'readme.servers-d'..i})
    end

    -- Add the external links
    local external_links = title_table(scroll_pane, 235, {'readme.servers-external'}, 2)
    for _,key in ipairs{'discord','website','patreon','status','github'} do
        Gui.centered_label(external_links, 110, key:gsub("^%l", string.upper))
        Gui.centered_label(external_links, 460, {'links.'..key}, {'readme.servers-open-in-browser'})
    end

    return container
end))

--- Content area for the servers tab
-- @element backers_content
Tab({'readme.backers-tab'},{'readme.backers-tooltip'},
Gui.element(function(_,parent)
    local container = parent.add{ type='flow', direction='vertical' }

    -- Add the title and description to the content
    Gui.title_label(container, title_width-10, {'readme.backers-tab'})
    Gui.centered_label(container, frame_width, {'readme.backers-general'})
    Gui.bar(container)
    container.add{ type='flow' }

    -- Find which players will go where
    local done = {}
    local groups = {
        { _roles={'Senior Administrator','Administrator'}, _title={'readme.backers-management'}, _width=230 },
        { _roles={'Board Member','Senior Backer'}, _title={'readme.backers-board'}, _width=145 }, -- change role to board
        { _roles={'Sponsor','Supporter'}, _title={'readme.backers-backers'}, _width=196 }, -- change to backer
        { _roles={'Moderator','Trainee'}, _title={'readme.backers-staff'}, _width=235 },
        { _roles={}, _title={'readme.backers-active'}, _width=235 },
    }

    -- Fill by player roles
    for player_name, player_roles in pairs(Roles.config.players) do
        for _, players in ipairs(groups) do
            for _, role_name in pairs(players._roles) do
                if table.contains(player_roles, role_name) then
                    done[player_name] = true
                    table.insert(players,player_name)
                    break
                end
            end
        end
    end

    -- Fill by active times
    local active_time = 3*3600*60
    for _, player in pairs(game.players) do
        if not done[player.name] then
            if player.online_time > active_time then
                table.insert(groups.Active,player.name)
            end
        end
    end

    -- Add the different tables
    local scroll_pane = title_table_scroll(container)
    for _, players in ipairs(groups) do
        local table = title_table(scroll_pane, players._width, players._title, 4)
        for _,player_name in ipairs(players) do
            Gui.centered_label(table, 140, player_name)
        end

        if #players < 4 then
            for i = 1,4-#players do
                Gui.centered_label(table, 140)
            end
        end
    end

    return container
end))

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
    local left_alignment = Gui.alignment(container, nil, nil, 'bottom')
    left_alignment.style.padding = {32,0,0,0}

    local left_side =
    left_alignment.add{
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