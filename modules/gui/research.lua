--- research gui
-- @gui Research

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Global = require 'utils.global' --- @dep utils.global
local Event = require 'utils.event' --- @dep utils.event
local Roles = require 'expcore.roles' --- @dep expcore.roles
local config = require 'config.research' --- @dep config.research
local format_time = _C.format_time --- @dep expcore.common

local research = {}
Global.register(research, function(tbl)
    research = tbl
end)

research.time = {}
research.res_queue_enable = false

local research_time_format = {
    hours=true,
    minutes=true,
    seconds=true,
    time=true,
    string=true
}

local empty_time = format_time(0, {
	hours=true,
	minutes=true,
	seconds=true,
	time=true,
	string=true,
	null=true
})

local res = {
	['lookup_name'] = {},
	['disp'] = {}
}

local res_total = 0
local mi = 1

for k, v in pairs(config.milestone) do
	research.time[mi] = 0
	res['lookup_name'][k] = mi
	res_total = res_total + v * 60

	res['disp'][mi] = {
		name = '[technology=' .. k .. '] ' .. k:gsub('-', ' '),
		raw_name = k,
		prev = res_total,
		prev_disp = format_time(res_total, research_time_format),
	}

	mi = mi + 1
end

local function add_log()
	local result_data = {}

	for i=1, #research.time, 1 do
		result_data[res['disp'][i]['raw_name']] = research.time[i]
	end

	game.write_file(config.file_name, game.table_to_json(result_data) .. '\n', true, 0)
end

local function research_res_n(res_)
	local res_n = 1

	for k, _ in pairs(res_) do
		if research.time[k] == 0 then
			res_n = k - 1
			break
		end
	end

	if research.time[#res_] > 0 then
		if res_n == 1 then
			res_n = #res_
		end
	end

	if res_n < 3 then
		res_n = 3

	elseif res_n > (#research.time - 5) then
		res_n = #research.time - 5
	end

	return res_n
end

local function research_notification(event)
    local is_inf_res = false

    if config.inf_res[event.research.name] then
		if event.research.name == 'mining-productivity-4' and event.research.level == 5 then
			-- Add run result to log
			add_log()
		end

		if event.research.level >= config.inf_res[event.research.name] then
			is_inf_res = true
		end
    end

    if is_inf_res then
        if event.research.name == 'mining-productivity-4' then
			if config.bonus_inventory.enabled then
				if (event.research.level - 1) <= math.ceil(config.bonus_inventory.limit / config.bonus_inventory.rate) then
					event.research.force[config.bonus_inventory.name] = math.max((event.research.level - 1) * config.bonus_inventory.rate, config.bonus_inventory.limit)
				end
			end

            if config.pollution_ageing_by_research then
                game.map_settings.pollution.ageing = math.min(10, event.research.level / 5)
            end
        end

        if not (event.by_script) then
            game.print{'expcom-res.inf', format_time(game.tick, research_time_format), event.research.name, event.research.level - 1}
        end

    else
        if not (event.by_script) then
            game.print{'expcom-res.msg', format_time(game.tick, research_time_format), event.research.name}
        end

		if event.research.name == 'mining-productivity-1' or event.research.name == 'mining-productivity-2' or event.research.name == 'mining-productivity-3' then
			if config.bonus_inventory.enabled then
				event.research.force[config.bonus_inventory.name] = event.research.level * config.bonus_inventory.rate
			end
		end
    end
end

--- Display label for the clock display
-- @element research_gui_clock_display
local research_gui_clock =
Gui.element{
    type = 'label',
    name = Gui.unique_static_name,
    caption = empty_time,
    style = 'heading_1_label'
}

--- A vertical flow containing the clock
-- @element research_clock_set
local research_clock_set =
Gui.element(function(_, parent, name)
    local research_set = parent.add{type='flow', direction='vertical', name=name}
    local disp = Gui.scroll_table(research_set, 360, 1, 'disp')

    research_gui_clock(disp)

    return research_set
end)

--- A vertical flow containing the data
-- @element research_data_set
local research_data_set =
Gui.element(function(_, parent, name)
    local research_set = parent.add{type='flow', direction='vertical', name=name}
    local disp = Gui.scroll_table(research_set, 360, 4, 'disp')

	for i=1, 8, 1 do
        disp.add{
			type = 'label',
            name = 'research_display_n_' .. i,
            caption = '',
            style = 'heading_1_label'
        }

		disp.add{
			type = 'label',
            name = 'research_display_d_' .. i,
            caption = empty_time,
            style = 'heading_1_label'
        }

		disp.add{
			type = 'label',
            name = 'research_display_p_' .. i,
			caption = '',
            style = 'heading_1_label'
        }

		disp.add{
			type = 'label',
            name = 'research_display_t_' .. i,
            caption = empty_time,
            style = 'heading_1_label'
        }
	end

	local res_n = research_res_n(res['disp'])

	for j=1, 8, 1 do
		local res_j = res_n + j - 3

		if res['disp'][res_j] then
			local res_r = res['disp'][res_j]
			disp['research_display_n_' .. j].caption = res_r.name

			if research.time[res_j] == 0 then
				disp['research_display_d_' .. j].caption = empty_time
				disp['research_display_p_' .. j].caption = res_r.prev_disp
				disp['research_display_t_' .. j].caption = empty_time

			else
				if research.time[res_j] < res['disp'][res_j].prev then
					disp['research_display_d_' .. j].caption = '-' .. format_time(res['disp'][res_j].prev - research.time[res_j], research_time_format)

				else
					disp['research_display_d_' .. j].caption = format_time(research.time[res_j] - res['disp'][res_j].prev, research_time_format)
				end

				disp['research_display_p_' .. j].caption = res_r.prev_disp
				disp['research_display_t_' .. j].caption = format_time(research.time[res_j], research_time_format)
			end

		else
			disp['research_display_n_' .. j].caption = ''
			disp['research_display_d_' .. j].caption = ''
			disp['research_display_p_' .. j].caption = ''
			disp['research_display_t_' .. j].caption = ''
		end
	end

    return research_set
end)

local research_container =
Gui.element(function(definition, parent)
	local container = Gui.container(parent, definition.name, 320)

	research_clock_set(container, 'research_st_1')
    research_data_set(container, 'research_st_2')

    return container.parent
end)
:static_name(Gui.unique_static_name)
:add_to_left_flow()

Gui.left_toolbar_button('item/space-science-pack', {'expcom-res.main-tooltip'}, research_container, function(player)
	return Roles.player_allowed(player, 'gui/research')
end)

Event.add(defines.events.on_research_finished, function(event)
	research_notification(event)

	if res['lookup_name'][event.research.name] == nil then
		return
	end

	local n_i = res['lookup_name'][event.research.name]
	research.time[n_i] = game.tick

	local res_n = research_res_n(res['disp'])
	local res_disp = {}

	for j=1, 8, 1 do
		local res_j = res_n + j - 3
		res_disp[j] = {}

		if res['disp'][res_j] then
			local res_r = res['disp'][res_j]
			res_disp[j]['n'] = res_r.name

			if research.time[res_j] == 0 then
				res_disp[j]['d'] = empty_time
				res_disp[j]['p']= res_r.prev_disp
				res_disp[j]['t'] = empty_time

			else
				if research.time[res_j] < res['disp'][res_j].prev then
					res_disp[j]['d'] = '-' .. format_time(res['disp'][res_j].prev - research.time[res_j], research_time_format)

				else
					res_disp[j]['d'] = format_time(research.time[res_j] - res['disp'][res_j].prev, research_time_format)
				end

				res_disp[j]['p'] = res_r.prev_disp
				res_disp[j]['t'] = format_time(research.time[res_j], research_time_format)
			end

		else
			res_disp[j]['n'] = ''
			res_disp[j]['d'] = ''
			res_disp[j]['p'] = ''
			res_disp[j]['t'] = ''
		end
	end

	for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, research_container)
		local disp = frame.container['research_st_2'].disp.table

		for j=1, 8, 1 do
			disp['research_display_n_' .. j].caption = res_disp[j]['n']
			disp['research_display_d_' .. j].caption = res_disp[j]['d']
			disp['research_display_p_' .. j].caption = res_disp[j]['p']
			disp['research_display_t_' .. j].caption = res_disp[j]['t']
		end
    end
end)

Event.on_nth_tick(60, function()
	local current_time = format_time(game.tick, research_time_format)

	for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, research_container)
		local disp = frame.container['research_st_1'].disp.table
		disp[research_gui_clock.name].caption = current_time
    end
end)
