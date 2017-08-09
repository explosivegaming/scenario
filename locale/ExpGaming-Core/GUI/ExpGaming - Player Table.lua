--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='ExpGaming - Player Table',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Allows addition of a player table with filters',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
local player_table_functions = ExpGui.player_table
local yes = {'yes','y','true','ye'}
local no = {'no','false','nay'}
--filters that are used. Feel free to add more
player_table_functions.filters = {
	--{name,is_text,function(player,input) return true end}
	{'is_admin',false,function(player) return player.admin end},
	{'player_name',true,function(player,input) if input and player.name:lower():find(input:lower()) then return true end end},
	{'online',false,function(player) return player.connected end},
	{'offline',false,function(player) return not player.connected end},
	{'online_time',true,function(player,input) if input and tonumber(input) and tonumber(input) < tick_to_min(player.online_time) then return true elseif not input or not tonumber(input) then return true end end},
	{'rank',true,function(player,input) if input and string_to_rank(input) and get_rank(player).power <= string_to_rank(input).power then return true elseif not input or not string_to_rank(input) then return true end end}
}
--set up all the text inputs
for _,filter in pairs(player_table_functions.filters) do
	if filter[2] then
		ExpGui.add_input.text(filter[1],'Enter '..filter[1]:gsub('_',' '),function(player,element) ExpGui.player_table.redraw(player,element) end)
	end
end
--used to draw filters from the list above
function player_table_functions.draw_filters(player,frame,filters)
	local input_bar = frame.add{type='flow',name='input_bar',direction='horizontal'}
	for _,name in pairs(filters) do
		local filter_data = nil
		for _,filter in pairs(player_table_functions.filters) do if filter[1] == name then filter_data = filter break end end
		if filter_data and filter_data[2] then
			ExpGui.add_input.draw_text(input_bar,name)
		end
	end
end
--used by script to get the values for the any inputs given by the user
function player_table_functions.get_filters(frame)
	local filters = {}
	for _,filter in pairs(player_table_functions.filters) do
		if frame.input_bar[filter[1]] then
			if frame.input_bar[filter[1]].text:find('%S') then
				table.insert(filters,{filter[1],frame.input_bar[filter[1]].text})
			end
		end
	end
	return filters
end
--used to test if a player matches filter criteria
function player_table_functions.player_match(player,filter,input)
	for _,f in pairs(player_table_functions.filters) do
		if filter == f or filter == f[1] then if filter == f[1] then filter = f break end end
	end
	if filter[3] and type(filter[3]) == 'function' then return filter[3](player,input) end
end
--used by script on filter texts
function player_table_functions.redraw(player,element)
	local frame = global.current_filters[player.index][2]
	local filters = global.current_filters[player.index][1]
	player_table_functions.draw(player,frame,filters,element.parent.parent)
end
--used to draw the player table with filter that you want
--filter = {{'is_admin',true},{'offline',true},{'player_name'}} ; if the length is 2 then it will not attempt to get a user input
function player_table_functions.draw(player,frame,filters,input_location)
	global.current_filters[player.index] = {filters,frame}
	--setup the table
	if frame.player_table then frame.player_table.destroy() end
	player_table = frame.add{name='player_table', type="table", colspan=5}
  player_table.style.minimal_width = 500
  player_table.style.maximal_width = 500
	player_table.style.horizontal_spacing = 10
  player_table.add{name="id", type="label", caption="Id"}
  player_table.add{name="player_name", type="label", caption="Name"}
	player_table.add{name="status", type="label", caption="Status"}
  player_table.add{name="online_time", type="label", caption="Online Time"}
  player_table.add{name="rank", type="label", caption="Rank"}
	for i,p in pairs(game.players) do
		--filter cheaking
		local add=true
		for _,filter in pairs(filters) do
			if #filter == 2 and add then
				local result = player_table_functions.player_match(p,filter[1],filter[2]) 
				if not result and filter[2] == true then result = filter[2] end
				add = result or false
			end
		end
		for _,filter in pairs(player_table_functions.get_filters(input_location)) do
			if add then
				add = player_table_functions.player_match(p,filter[1],filter[2]) or false
			end
		end
		--add the player
		if add then--and player.name ~= p.name then
			player_table.add{name=p.name.."_id", type="label", caption=i}
      player_table.add{name=p.name..'_name', type="label", caption=p.name}
			if p.connected == true 
			then player_table.add{name=p.name.."status", type="label", caption="Online"}
			else player_table.add{name=p.name.."s", type="label", caption="Offline"} end
			player_table.add{name=p.name.."online_time", type="label", caption=tick_to_display_format(p.online_time)}
      player_table.add{name=p.name.."rank", type="label", caption=get_rank(p).short_hand}
		end
	end
end

Event.register(-1,function() global.current_filters = {} end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits