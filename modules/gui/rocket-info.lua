local Gui = require 'expcore.gui'
local Roles = require 'expcore.roles'
local Event = require 'utils.event'
local config = require 'config.rockets'
local Global = require 'utils.global'
local format_time = ext_require('expcore.common','format_time')
local Colors = require 'resources.color_presets'

local rocket_times = {}
local rocket_stats = {}
local rocket_silos = {}

Global.register({
    rocket_times = rocket_times,
    rocket_stats = rocket_stats,
    rocket_silos = rocket_silos
},function(tbl)
    rocket_times = tbl.rocket_times
    rocket_stats = tbl.rocket_stats
    rocket_silos = tbl.rocket_silos
end)

local function get_silo_name(entity)
    local position = entity.position
    return 'X '..math.floor(position.x)..' Y '..math.floor(position.y)
end

local zoom_to_map_name = Gui.uid_name()
Gui.on_click(zoom_to_map_name,function(event)
    local force = event.player.force
    local rocket_silo_name = event.element.caption
    local rocket_silo = rocket_silos[force.name][rocket_silo_name]
    local position = rocket_silo.entity.position
    event.player.zoom_to_world(position,2)
end)

local launch_rocket =
Gui.new_button()
:set_sprites('utility/center')
:set_tooltip('Click to launch rocket')
:set_embeded_flow(function(element,rocket_silo_name)
    return 'launch_'..rocket_silo_name
end)
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.width = 16
    style.height = 16
end)
:on_click(function(player,element)
    local force = player.force
    local rocket_silo_name = element.parent.name:sub(8)
    local rocket_silo = rocket_silos[force.name][rocket_silo_name]
    rocket_silo.entity.launch_rocket()
end)

local toggle_rocket =
Gui.new_button()
:set_sprites('utility/play')
:set_tooltip('Click to launch rocket')
:set_embeded_flow(function(element,rocket_silo_name)
    return 'toggle_'..rocket_silo_name
end)
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.width = 16
    style.height = 16
end)
:on_click(function(player,element)
    local force = player.force
    local rocket_silo_name = element.parent.name:sub(7)
    local rocket_silo = rocket_silos[force.name][rocket_silo_name]
    local status = true
    if status then
        player.print('WIP; We currently have no way to test or set the auto launch of a rocket so this button does not work!')
    else
        element.sprite = 'utility/stop'
    end
end)

local header_expand =
Gui.new_button()
:set_sprites('utility/expand_dark','utility/expand')
:set_tooltip('Click to expand')
:set_style('tool_button',function(style)
    Gui.set_padding_style(style,-2,-2,-2,-2)
    style.height = 20
    style.width = 20
end)
:on_click(function(player,element)
    local flow_name = element.parent.name
    local flow = element.parent.parent.parent[flow_name]
    if Gui.toggle_visible(flow) then
        element.sprite = 'utility/collapse_dark'
        element.hovered_sprite = 'utility/collapse'
    else
        element.sprite = 'utility/expand_dark'
        element.hovered_sprite = 'utility/expand'
    end
end)

local function create_header_flow_combo(player,element,name,table_size,caption,tooltip)
    -- header for the combo
    local header =
    element.add{
        type='frame',
        name=name..'-header',
        style='subheader_frame',
    }
    Gui.set_padding(header,1,1,3,3)
    header.style.horizontally_stretchable = true

    -- caption for header bar
    header.add{
        type='label',
        style='heading_1_label',
        caption=caption,
        tooltip=tooltip
    }

    -- right aligned button to toggle the drop down area
    local expand_flow = Gui.create_right_align(header,name)
    header_expand(expand_flow)

    -- flow for the combo
    local flow =
    element.add{
        name=name,
        type='scroll-pane',
        direction='vertical',
        horizontal_scroll_policy='never',
        vertical_scroll_policy='auto-and-reserve-space'
    }
    Gui.set_padding(flow,1,1,2,2)
    flow.style.horizontally_stretchable = true
    flow.style.maximal_height = 215

    flow.visible = false

    -- table to allow for nice looking labels
    local flow_table =
    flow.add{
        name='table',
        type='table',
        column_count=table_size
    }
    Gui.set_padding(flow_table)
    flow_table.style.horizontally_stretchable = true
    flow_table.style.vertical_align = 'center'
    flow_table.style.cell_padding = 0
end

local function player_allowed(player,action)
    if not config.progress['allow_'..action] then
        return false
    end

    if config.progress[action..'_admins_only'] and not player.admin then
        return false
    end

    if config.progress[action..'_role_permision'] and not Roles.player_allowed(player,config.progress[action..'_role_permision']) then
        return false
    end

    return true
end

local function generate_container(player,element)
    Gui.set_padding(element,1,2,2,2)
    element.style.minimal_width = 200

    -- main container which contains the other elements
    local container =
    element.add{
        name='container',
        type='frame',
        direction='vertical',
        style='window_content_frame_packed'
    }
    Gui.set_padding(container)

    if config.stats.show_stats then
        create_header_flow_combo(player,container,'stats',2,'Statistics','Stats about rockets')
    end

    if config.milestones.show_milestones then
        create_header_flow_combo(player,container,'milestones',2,'Milestones','Rocket milestones')
    end

    if config.progress.show_progress then
        local col_count = 2
        if player_allowed(player,'remote_launch') then col_count = col_count+1 end
        if player_allowed(player,'toggle_active') then col_count = col_count+1 end

        create_header_flow_combo(player,container,'progress',col_count,'Build Progress','Build progress of rockets')
        container.progress.add{
            type='label',
            name='no_silos',
            caption='Your force has no silos'
        }
    end

end

local function create_label_pair_time(element,name,raw_value,caption,tooltip,no_hours)
    local value = no_hours and format_time(raw_value,{minutes=true,seconds=true}) or format_time(raw_value)
    local value_tooltip = format_time(raw_value,{hours=not no_hours,minutes=true,seconds=true,long=true})
    if not element[name] then
        -- main label to show the name of the value
        element.add{
            type='label',
            name=name..'-label',
            caption=caption,
            tooltip=tooltip
        }
        -- flow which allows right align for the value
        local right_flow = Gui.create_right_align(element,name)
        right_flow.add{
            type='label',
            name='label',
            caption=value,
            tooltip=value_tooltip
        }
    else
        element[name].label.caption = value
        element[name].label.tooltip = value_tooltip
    end
end

local function generate_stats(player,frame)
    if not config.stats.show_stats then return end
    local element = frame.container.stats.table
    local force_rockets = player.force.rockets_launched

    if config.stats.show_first_rocket then
        create_label_pair_time(element,'first_launch',rocket_stats.first_launch or 0,'First Launch','The time of launch of the first rocket')
    end

    if config.stats.show_last_rocket then
        create_label_pair_time(element,'last_launch',rocket_stats.last_launch or 0,'Last Launch','The time that the last rocket was launched')
    end

    if config.stats.show_fastest_rocket then
        create_label_pair_time(element,'fastest_launch',rocket_stats.fastest_launch or 0,'Fastest Launch','The time taken for the fastest launch',true)
    end

    if config.stats.show_total_rockets then
        local total_rockets = 0

        for _,force in pairs(game.forces) do
            total_rockets = total_rockets + force.rockets_launched
        end
        total_rockets = total_rockets > 0 and total_rockets or 1
        local percentage = math.round(force_rockets/total_rockets,3)*100

        if not element.total_rockets then
            -- main label to show the name of the value
            element.add{
                type='label',
                name='total_rockets-label',
                caption='Total Lauched',
                tooltip='The total number of rockets launched'
            }
            -- flow which allows right align for the value
            local right_flow = Gui.create_right_align(element,'total_rockets')
            right_flow.add{
                type='label',
                name='label',
                caption=force_rockets,
                tooltip=percentage
            }
        else
            element.total_rockets.label.caption = force_rockets
            element.total_rockets.label.tooltip = percentage
        end
    end

    if config.stats.show_game_avg then
        local tick = game.tick > 0 and game.tick or 1
        local avg = math.floor(force_rockets/tick)
        create_label_pair_time(element,'avg_launch',avg,'Avg Launch','The average time to launch a rocket',true)
    end

    for _,over in pairs(config.stats.rolling_avg) do
        local total = 0
        local rocket_count = 0
        for i = force_rockets,force_rockets-over,-1 do
            if rocket_times[i] then
                rocket_count = rocket_count + 1
                total = total + rocket_times[i]
            end
        end
        total = total > 0 and total or 1
        local avg = math.floor(rocket_count/total)
        create_label_pair_time(element,'avg_launch_'..over,avg,'Avg Launch '..over,'The rolling average time to launch a rocket for the past '..over..' rockets',true)
    end

end

local function generate_milestones(player,frame)
    if not config.milestones.show_milestones then return end
    local element = frame.container.milestones.table
    local force_rockets = player.force.rockets_launched

    for _,milestone in ipairs(config.milestones) do
        if milestone <= force_rockets and not element['milstone-'..milestone] then
            create_label_pair_time(element,'milstone-'..milestone,rocket_times[player.force.name][milestone],'Milestone '..milestone,'Time taken to launch '..milestone..' rockets')
        end
    end
end

local function generate_progress(player,frame)
    if not config.progress.show_progress then return end
    local element = frame.container.progress.table
    local force = player.force.name

    if not rocket_silos[force] or table.size(rocket_silos[force]) == 0 then
        element.parent.no_silos.visible = true

    else
        element.parent.no_silos.visible = false
        for rocket_silo_name,rocket_silo in pairs(rocket_silos[force]) do
            if not rocket_silo.entity or not rocket_silo.entity.valid then
                rocket_silos[force][rocket_silo_name] = nil
                if element['label_'..rocket_silo_name] then element['label_'..rocket_silo_name].destroy() end
                if element['launch_'..rocket_silo_name] then element['launch_'..rocket_silo_name].destroy() end
                if element['toggle_'..rocket_silo_name] then element['toggle_'..rocket_silo_name].destroy() end
                if element[rocket_silo_name] then element[rocket_silo_name].destroy() end

            elseif not element[rocket_silo_name] then
                local progress = rocket_silo.entity.rocket_parts
                local status = rocket_silo.entity.status == 21
                local active = false -- need way to check this

                if player_allowed(player,'toggle_active') then
                    local toggle_rocket_element = toggle_rocket(element,rocket_silo_name)
                    toggle_rocket_element.enabled = false -- remove when done
                    if active then
                        toggle_rocket_element.sprite = 'utility/stop'
                    else
                        toggle_rocket_element.sprite = 'utility/play'
                    end
                end

                if player_allowed(player,'remote_launch') then
                    local launch_rocket_element = launch_rocket(element,rocket_silo_name)
                    launch_rocket_element.enabled = status
                end

                -- main label to show the name of the value
                local flow = element.add{type='flow',name='label_'..rocket_silo_name}
                Gui.set_padding(flow,0,0,2,0)
                flow.add{
                    type='label',
                    name=zoom_to_map_name,
                    caption=rocket_silo_name,
                    tooltip='Click to view on map'
                }

                -- flow which allows right align for the value
                local right_flow = Gui.create_right_align(element,rocket_silo_name)
                right_flow.add{
                    type='label',
                    name='label',
                    caption=progress..'%',
                    tooltip=rocket_silo.launched or 0
                }

            else
                local progress = rocket_silo.entity.rocket_parts
                local status = rocket_silo.entity.status == 21
                local active = false -- need way to check this

                local label = element[rocket_silo_name].label
                label.caption = progress..'%'
                label.tooltip = rocket_silo.launched or 0

                if status then
                    label.caption = '100%'
                    label.style.font_color = Colors.cyan
                else
                    label.style.font_color = Colors.white
                end

                if player_allowed(player,'toggle_active') then
                    local toggle_rocket_element = element['toggle_'..rocket_silo_name]
                    if active then
                        toggle_rocket_element[toggle_rocket.name].sprite = 'utility/stop'
                    else
                        toggle_rocket_element[toggle_rocket.name].sprite = 'utility/play'
                    end
                end

                if player_allowed(player,'remote_launch') then
                    local launch_rocket_element = element['launch_'..rocket_silo_name]
                    launch_rocket_element[launch_rocket.name].enabled = status
                end



            end
        end

    end
end

local rocket_info =
Gui.new_left_frame('gui/rocket-info')
:set_sprites('entity/rocket-silo')
:set_post_authenticator(function(player,define_name)
    return true
    --return player.force.rockets_launched > 0 and Gui.classes.toolbar.allowed(player,define_name)
end)
:set_open_by_default(function(player,define_name)
    return true
    --return player.force.rockets_launched > 0
end)
:set_direction('vertical')
:on_draw(function(player,element)
    generate_container(player,element)
    generate_stats(player,element)
    generate_milestones(player,element)
    generate_progress(player,element)
end)
:on_update(function(player,element)
    generate_stats(player,element)
    generate_milestones(player,element)
    generate_progress(player,element)
end)

Event.add(defines.events.on_rocket_launched,function(event)
    local force = event.rocket_silo.force
    local force_name = force.name
    local rockets_launched = force.rockets_launched

    if not rocket_stats[force_name] then
        rocket_stats[force_name] = {}
    end

    if rockets_launched == 1 then
        rocket_stats.first_launch = event.tick
        rocket_stats.fastest_launch = event.tick
    elseif event.tick-rocket_stats.last_launch < rocket_stats.fastest_launch then
        rocket_stats.fastest_launch = event.tick-rocket_stats.last_launch
    end

    rocket_stats.last_launch = event.tick

    if not rocket_times[force_name] then
        rocket_times[force_name] = {}
    end

    rocket_times[force_name][rockets_launched] = event.tick

    local silo_name = get_silo_name(event.rocket_silo)

    if not rocket_silos[force_name] then
        rocket_silos[force_name] = {}
    end

    if not rocket_silos[force_name][silo_name] then
        rocket_silos[force_name][silo_name] = {entity=event.rocket_silo,launched=0}
    end

    rocket_silos[force_name][silo_name].launched = rocket_silos[force_name][silo_name].launched+1

    for _,player in pairs(force.players) do
        rocket_info:update(player)
        Gui.update_toolbar(player)
    end
end)

local function on_built(event)
    local entity = event.created_entity
    if entity.valid and entity.name == 'rocket-silo' then
        local force = entity.force
        local force_name = force.name
        local silo_name = get_silo_name(entity)

        if not rocket_silos[force_name] then
            rocket_silos[force_name] = {}
        end

        rocket_silos[force_name][silo_name] = {entity=entity,launched=0}

        for _,player in pairs(force.players) do
            rocket_info:update(player)
        end
    end
end

Event.add(defines.events.on_built_entity,on_built)
Event.add(defines.events.on_robot_built_entity,on_built)
Event.on_nth_tick(150,function()
    for _,force in pairs(game.forces) do
        local silos = rocket_silos[force.name]
        if silos then
            for _,player in pairs(force.connected_players) do
                local frame = rocket_info:get_frame(player)
                generate_progress(player,frame)
            end
        end
    end
end)

return rocket_info