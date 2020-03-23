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

--- Content area for the welcome tab
-- @element welcome_content
Tab('Welcome',nil,
Gui.element{
    type = 'label',
    caption = 'Welcome'
})

--- Content area for the rules tab
-- @element rules_content
Tab('Rules',nil,
Gui.element{
    type = 'label',
    caption = 'Rules'
})

--- Content area for the commands tab
-- @element commands_content
Tab('Commands',nil,
Gui.element{
    type = 'label',
    caption = 'Commands'
})

--- Content area for the servers tab
-- @element servers_content
Tab('Servers',nil,
Gui.element{
    type = 'label',
    caption = 'Servers'
})

--- Content area for the servers tab
-- @element servers_content
Tab('Backers',nil,
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

    tab_pane.style.width = 500
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
Gui.toolbar_button('virtual-signal/signal-info','Information',function(player)
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