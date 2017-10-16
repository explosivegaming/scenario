--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b
]]
--Please Only Edit Below This Line-----------------------------------------------------------
local player_table_functions = ExpGui.player_table
--filters that are used. Feel free to add more
player_table_functions.filters = {
	--{name,is_text,function(player,input) return true/false end}
	{name='is_admin',is_text=false,test=function(player) return player.admin end},
	{name='player_name',is_text=true,test=function(player,input) if input and player.name:lower():find(input:lower()) then return true end end},
	{name='online',is_text=false,test=function(player) return player.connected end},
	{name='offline',is_text=false,test=function(player) return not player.connected end},
	{name='online_time',is_text=true,test=function(player,input) if input and tonumber(input) and tonumber(input) < tick_to_min(player.online_time) then return true elseif not input or not tonumber(input) then return true end end},
	{name='rank',is_text=true,test=function(player,input) if input and ranking.string_to_rank(input) and ranking.get_player_rank(player).power <= ranking.string_to_rank(input).power then return true elseif not input or not ranking.string_to_rank(input) then return true end end}
}
--set up all the text inputs
for _,filter in pairs(player_table_functions.filters) do
	if filter.is_text then
		ExpGui.add_input.text(filter.name,{'expgui.player-table-enter',filter.name:gsub('_',' ')},function(player,element) ExpGui.player_table.redraw(player,element) end)
	end
end
--used to draw filters from the list above
function player_table_functions.draw_filters(player,frame,filters)
	debug_write({'GUI','PLAYER-TABLE','DRAW-FILTERS'},player.name)
	local input_bar = frame.add{type='flow',name='input_bar',direction='horizontal'}
	for _,name in pairs(filters) do
		local filter_data = nil
		for _,filter in pairs(player_table_functions.filters) do if filter.name == name then filter_data = filter break end end
		if filter_data and filter_data[2] then
			ExpGui.add_input.draw_text(input_bar,name)
		end
	end
end
--used by script to get the values for the any inputs given by the user
function player_table_functions.get_filters(frame)
	local filters = {}
	for _,filter in pairs(player_table_functions.filters) do
		if frame.input_bar[filter.name] then
			if frame.input_bar[filter.name].text:find('%S') then
				table.insert(filters,{filter.name,frame.input_bar[filter.name].text})
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
	if filter.test and type(filter.test) == 'function' then return filter.test(player,input) end
end
--used by script on filter texts
function player_table_functions.redraw(player,element)
	local frame = global.exp_core.current_filters[player.index][2]
	local filters = global.exp_core.current_filters[player.index][1]
	player_table_functions.draw(player,frame,filters,element.parent.parent)
end
--used to draw the player table with filter that you want
--filter = {{'is_admin',true},{'offline',true},{'player_name'}} ; if the length is 2 then it will not attempt to get a user input
function player_table_functions.draw(player,frame,filters,input_location)
	debug_write({'GUI','PLAYER-TABLE','START'},player.name)
	global.exp_core.current_filters[player.index] = {filters,frame}
	--setup the table
	if frame.player_table then frame.player_table.destroy() end
	player_table = frame.add{name='player_table', type="table", colspan=5}
 	player_table.style.minimal_width = 500
  	player_table.style.maximal_width = 500
	player_table.style.horizontal_spacing = 10
  	player_table.add{name="id", type="label", caption={"expgui.player-table-id"}}
  	player_table.add{name="player_name", type="label", caption={"expgui.player-table-name"}}
	player_table.add{name="status", type="label", caption={"expgui.player-table-status"}}
  	player_table.add{name="online_time", type="label", caption={"expgui.player-table-online-time"}}
  	player_table.add{name="rank", type="label", caption={"expgui.player-table-rank"}}
	for i,p in pairs(game.players) do
		--filter cheaking
		local add=true
		for _,filter in pairs(filters) do
			if #filter == 2 and add then
				debug_write({'GUI','PLAYER-TABLE','CHEAK'},p.name..' '..fliter.name)
				local result = player_table_functions.player_match(p,filter.name,filter.is_text) 
				if not result and filter.is_text == true then result = filter.is_text end
				add = result or false
			end
		end
		for _,filter in pairs(player_table_functions.get_filters(input_location)) do
			if add then
				debug_write({'GUI','PLAYER-TABLE','CHEAK'},p.name..' '..fliter.name)
				add = player_table_functions.player_match(p,filter.name,filter.is_text) or false
			end
		end
		--add the player
		if add then--and player.name ~= p.name then
			debug_write({'GUI','PLAYER-TABLE','ADD'},p.name)
			player_table.add{name=p.name.."_id", type="label", caption=i}
      		player_table.add{name=p.name..'_name', type="label", caption=p.name}
			if p.connected == true 
			then player_table.add{name=p.name.."status", type="label", caption="Online"}
			else player_table.add{name=p.name.."s", type="label", caption="Offline"} end
			player_table.add{name=p.name.."online_time", type="label", caption=tick_to_display_format(p.online_time)}
      		player_table.add{name=p.name.."rank", type="label", caption=ranking.get_player_rank(p).short_hand}
		end
	end
end

Event.register(Event.soft_init,function() global.exp_core.current_filters = {} end)