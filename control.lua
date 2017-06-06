require("silo-script") --do not remove part of factorio default control
require "mod-gui" 
local version = 1 --do not remove part of factorio default control
entityRemoved = {}
entityCache = {}
guis = {frames={},buttons={}}
--this is a list of what will be put into the default list
defaults = {
	--for disallow add to the list the end part of the input action
	--example: defines.input_action.drop_item -> 'drop_item'
	--http://lua-api.factorio.com/latest/defines.html#defines.input_action
	ranks={
	{name='Owner',shortHand='Owner',tag='[Owner]',power=0,colour={r=170,g=0,b=0},disallow={}},
	{name='Community Manager',shortHand='Com Mngr',tag='[Com Mngr]',power=1,colour={r=150,g=68,b=161},disallow={}},
	{name='Developer',shortHand='Dev',tag='[Dev]',power=1,colour={r=179,g=125,b=46},disallow={}},
	{name='Admin',shortHand='Admin',tag='[Admin]',power=2,colour={r=233,g=63,b=233},disallow={'set_allow_commands','edit_permission_group','delete_permission_group','add_permission_group'}},
	{name='Mod',shortHand='Mod',tag='[Mod]',power=3,colour={r=0,g=170,b=0},disallow={'set_allow_commands','server_command','edit_permission_group','delete_permission_group','add_permission_group'}},
	{name='Donator',shortHand='P2W',tag='[P2W]',power=4,colour={r=233,g=63,b=233},disallow={'set_allow_commands','server_command','edit_permission_group','delete_permission_group','add_permission_group'}},
	{name='Veteran',shortHand='Vet',tag='[Veteran]',power=4,colour={r=140,g=120,b=200},disallow={'set_allow_commands','server_command','edit_permission_group','delete_permission_group','add_permission_group'}},
	{name='Member',shortHand='Mem',tag='[Member]',power=5,colour={r=24,g=172,b=188},disallow={'set_allow_commands','server_command','edit_permission_group','delete_permission_group','add_permission_group'}},
	{name='Regular',shortHand='Reg',tag='[Regular]',power=5,colour={r=24,g=172,b=188},disallow={'set_auto_launch_rocket','change_programmable_speaker_alert_parameters','reset_assembling_machine','drop_item','set_allow_commands','server_command','edit_permission_group','delete_permission_group','add_permission_group'}},
	{name='Guest',shortHand='',tag='[Guest]',power=6,colour={r=255,g=159,b=27},disallow={'build_terrain','remove_cables','launch_rocket','cancel_research','set_auto_launch_rocket','change_programmable_speaker_alert_parameters','reset_assembling_machine','drop_item','set_allow_commands','server_command','edit_permission_group','delete_permission_group','add_permission_group'}},
	{name='Jail',shortHand='Jail',tag='[Jail]',power=7,colour={r=50,g=50,b=50},disallow={'open_character_gui','begin_mining','start_walking','player_leave_game','build_terrain','remove_cables','launch_rocket','cancel_research','set_auto_launch_rocket','change_programmable_speaker_alert_parameters','reset_assembling_machine','drop_item','set_allow_commands','server_command','edit_permission_group','delete_permission_group','add_permission_group'}}
	},
	autoRanks={
	Owner={'badgamernl'},
	['Community Manager']={'arty714'},
	Developer={'Cooldude2606'},
	Admin={'eissturm','PropangasEddy','Smou'},
	Mod={'Alanore','Aquaday','cafeslacker','CrashKonijn','Drahc_pro','FlipHalfling90','freek16','Hobbitkicker','hud','Koroto','mark9064','Matthias','MeDDish','Mindxt20','MottledPetrel','Mr_Happy_212','NextIdea','Phoenix27833','samy115','Sand3r205','scarbvis','steentje77','tophatgaming123','VR29'},
	Donator={'M74132','Splicer'},
	Member={},
	Regular={},
	Guest={},
	Jail={}
	},
	selected={},
	oldRanks={},
	queue={}
}

warningAllowed = nil
timeForRegular = 180
timeForVeteran = 600
CHUNK_SIZE = 32
----------------------------------------------------------------------------------------
---------------------------Factorio Code Do Not Remove----------------------------------
----------------------------------------------------------------------------------------
script.on_init(function() 
  global.version = version 
  silo_script.init() 
end) 

script.on_event(defines.events.on_rocket_launched, function(event)
  silo_script.on_rocket_launched(event)
end)

script.on_configuration_changed(function(event)
  if global.version ~= version then
    global.version = version
  end
  silo_script.on_configuration_changed(event)
end)

silo_script.add_remote_interface()
----------------------------------------------------------------------------------------
---------------------------Rank functions-----------------------------------------------
----------------------------------------------------------------------------------------
function getRank(player)
	if player then
		for _,rank in pairs(global.ranks) do
			if player.permission_group == game.permissions.get_group(rank.name) then return rank end
		end
		return stringToRank('Guest')
	end
end

function stringToRank(string)
	if type(string) == 'string' then
		local Foundranks={}
		for _,rank in pairs(global.ranks) do
			if rank.name:lower() == string:lower() then return rank end
			if rank.name:lower():find(string:lower()) then table.insert(Foundranks,rank) end
		end
		if #Foundranks == 1 then return Foundranks[1] end
	end
end

function callRank(msg, rank, inv)
	local rank = stringToRank(rank) or stringToRank('Mod') -- default mod or higher
	local inv = inv or false
	for _, player in pairs(game.players) do 
		rankPower = getRank(player).power
		if inv then 
			if rankPower >= rank.power then 
				player.print(('[Everyone]: '..msg)) 
			end
		else
			if rankPower <= rank.power then
				if rank.shortHand ~= '' then player.print(('['..(rank.shortHand)..']: '..msg)) else player.print(('[Everyone]: '..msg)) end 
			end
		end
	end
end

function giveRank(player,rank,byPlayer)
	local byPlayer = byPlayer or 'system'
	local rank = stringToRank(rank) or rank or stringToRank('Guest')
	local oldRank = getRank(player)
	local message = 'demoted'
	if rank.power <= oldRank.power then message = 'promoted' end
	if byPlayer.name then 
		callRank(player.name..' was '..message..' to '..rank.name..' by '..byPlayer.name,'Guest')
	else
		callRank(player.name..' was '..message..' to '..rank.name..' by <system>','Guest')
	end
	player.permission_group = game.permissions.get_group(rank.name)
	if player.tag:find('-') then player.print('Your Custom Tag Was Reset Due To A Rank Change') end
	player.tag = getRank(player).tag
	drawToolbar(player)
	drawPlayerList()
	if oldRank.name ~= 'Jail' then global.oldRanks[player.index]=oldRank.name end
end

function revertRank(player,byPlayer)
	local rank = stringToRank(global.oldRanks[player.index])
	giveRank(player,rank,byPlayer)
end

function autoRank(player)
	local currentRank = getRank(player)
	local playerAutoRank = nil
	local oldRank = getRank(player)
	for rank,players in pairs(global.autoRanks) do
		local Break = false
		for _,p in pairs(players) do
			if player.name:lower() == p:lower() then playerAutoRank = stringToRank(rank) Break = true break end
		end
		if Break then break end
	end
	if playerAutoRank == nil then
		if ticktominutes(player.online_time) >= timeForRegular then playerAutoRank = stringToRank('Regular') end
		if ticktominutes(player.online_time) >= timeForVeteran then playerAutoRank = stringToRank('Veteran')
		else playerAutoRank = stringToRank('Guest') end
	end
	if currentRank.name ~='Jail' and currentRank.power > playerAutoRank.power or currentRank.name == 'Guest' then 
		if playerAutoRank.name == 'Guest' then
			player.permission_group=game.permissions.get_group('Guest')
		else
			giveRank(player,playerAutoRank)
		end
	end
	if getRank(player).power <= 3 and not player.admin then callRank(player.name..' needs to be promoted.') end
	if oldRank.name ~= getRank(player).name then global.oldRanks[player.index]=oldRank.name end
end
----------------------------------------------------------------------------------------
---------------------------Common use functions-----------------------------------------
----------------------------------------------------------------------------------------
function ticktohour (tick)
    local hour = tostring(math.floor(tick/(216000*game.speed)))
    return hour
end

function ticktominutes (tick)
  	local minutes = math.floor(tick/(3600*game.speed))
    return minutes
end

function clearSelection(player)
	global.selected[player.index] = {}
end

function sudo(command,args)
	table.insert(global.queue,{fun=command,var=args})
end

function autoMessage()
	local lrank = 'Regular'
	local hrank = 'Mod'
	callRank('There are '..#game.connected_players..' players online',hrank,true)
	callRank('This map has been on for '..ticktohour(game.tick)..' Hours and '..(ticktominutes(game.tick)-60*ticktohour(game.tick))..' Minutes',hrank,true)
	callRank('Please join us on:',lrank,true)
	callRank('Discord: https://discord.gg/RPCxzgt',lrank,true)
	callRank('Forum: explosivegaming.nl',lrank,true)
	callRank('Steam: http://steamcommunity.com/groups/tntexplosivegaming',lrank,true)
	callRank('To see these links again goto: Readme > Server Info',lrank,true)
	for _,player in pairs(game.connected_players) do autoRank(player) end
end

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%player][_%player%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end
----------------------------------------------------------------------------------------
---------------------------Gui Functions------------------------------------------------
----------------------------------------------------------------------------------------
function addFrame(frame,rank,open,caption,tooltip,sprite)
	guis.frames[frame] = {{require=rank,caption=caption,tooltip=tooltip,sprite=sprite}}
	addButton('close', function(player,element) element.parent.parent.parent.destroy() end)
	addButton('btn_'..frame, function(player,element) if player.gui.center[frame] then player.gui.center[frame].destroy() else drawFrame(player,frame,open) end end)
end

function addTab(frame, tabName, describtion, drawTab)
	guis.frames[frame][tabName] = {tabName, describtion, drawTab}
	addButton(tabName, function(player, element) openTab(player, element.parent.parent.parent.name, element.parent.parent.parent.tab, element.name) end)
end

function addButton(btnName, onClick)
	guis.buttons[btnName] = {btnName, onClick}
end

function drawButton(frame, btnName, caption, describtion, sprite)
	if sprite then
		frame.add{name=btnName, type = "sprite-button", sprite=sprite, tooltip=describtion, style = mod_gui.button_style}
	else
		frame.add{name=btnName, type = "button", caption=caption, tooltip=describtion, style = mod_gui.button_style}
	end
end

function openTab(player, frameName, tab, tabName)
	local tabBar = player.gui.center[frameName].tabBarScroll.tabBar
	for _,t in pairs(guis.frames[frameName]) do
		if _ ~= 1 then
			if t[1] == tabName then
				tabBar[t[1]].style.font_color = {r = 255, g = 255, b = 255, player = 255}
				tab.clear()
				t[3](player, tab)
			else
				tabBar[t[1]].style.font_color = {r = 100, g = 100, b = 100, player = 255}
			end
		end
	end
end

function drawFrame(player, frameName, tabName)
	if getRank(player).power <= guis.frames[frameName][1].require then
		player.gui.center.clear()
		local frame = player.gui.center.add{name=frameName,type='frame',caption=frameName,direction='vertical',style=mod_gui.frame_style}
		local tabBarScroll = frame.add{type = "scroll-pane", name= "tabBarScroll", vertical_scroll_policy="never", horizontal_scroll_policy="always"}
		local tabBar = tabBarScroll.add{type='flow',direction='horizontal',name='tabBar'}
		local tab = frame.add{type = "scroll-pane", name= "tab", vertical_scroll_policy="auto", horizontal_scroll_policy="never"}
		for _,t in pairs(guis.frames[frameName]) do
			if _ ~= 1 then drawButton(tabBar, t[1], t[1], t[2]) end
		end
		openTab(player, frameName, tab, tabName)
		drawButton(tabBar, 'close', 'Close', 'Close this window')
		tab.style.minimal_height = 300
		tab.style.maximal_height = 300
		tab.style.minimal_width = 500
		tab.style.maximal_width = 500
		tabBarScroll.style.minimal_height = 60
		tabBarScroll.style.maximal_height = 60
		tabBarScroll.style.minimal_width = 500
		tabBarScroll.style.maximal_width = 500
		player.gui.center.add{type='frame',name='temp'}.destroy()
	end
end

function toggleVisable(frame)
	if frame then
		if frame.style.visible == nil then
			frame.style.visible = false 
		else
			frame.style.visible = not frame.style.visible
		end
	end
end
----------------------------------------------------------------------------------------
---------------------------Player Events------------------------------------------------
----------------------------------------------------------------------------------------
script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
	player.force.friendly_fire = false
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
  player.insert{name="burner-mining-drill", count = 1}
  player.insert{name="stone-furnace", count = 1}
	player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
	silo_script.gui_init(player) -- do not remove part of factorio default
end)

script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.players[event.player_index]
	drawPlayerList()
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
end)

script.on_event(defines.events.on_player_joined_game, function(event)
	--runs when the first player joins to make the permission groups
	if global.ranks == nil then scriptInit() end
	if commands.commands.server_interface == nil then commandInit() end
	--Standard start up
  local player = game.players[event.player_index]
	autoRank(player)
  player.print({"", "Welcome"})
	drawPlayerList()
  drawToolbar(player)
  if not player.admin and ticktominutes(player.online_time) < 1 then drawFrame(player,'Readme','Rules') end
end)

script.on_event(defines.events.on_player_left_game, function(event)
  local player = game.players[event.player_index]
  drawPlayerList()
end)
----------------------------------------------------------------------------------------
---------------------------Gui Events---------------------------------------------------
----------------------------------------------------------------------------------------
script.on_event(defines.events.on_gui_click, function(event)
	silo_script.on_gui_click(event) -- do not remove part of factorio default
  local player = game.players[event.player_index]
	if event.element.type == 'button' or event.element.type == 'sprite-button' then
		for _,btn in pairs(guis.buttons) do
			if btn[1] == event.element.name then
				if btn[2] then btn[2](player,event.element) else callRank('Invaid Button'..btn[1],'Mod') end
				break
			end
		end
	elseif event.element.type == 'checkbox' then
		if event.element.name == 'select' then
			global.selected[event.player_index] = global.selected[event.player_index] or {}
			selected = global.selected[event.player_index]
			if event.element.state then
				table.insert(selected,event.element.parent.name)
			else
				for _,name in pairs(selected) do
					if name == event.element.parent.name then table.remove(selected,_) break end
				end
			end
		end
	end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
	local player = game.players[event.player_index]
	if event.element.parent.name == 'filterTable' then
		local frame = event.element
		filters = getPlayerTableFilters(frame)
		local select = false
		if frame.parent.parent.parent.name == 'Admin' and frame.parent.sel_input then select = true filters.powerOver = true end
		drawPlayerTable(player, frame.parent.parent, select, filters)
	end
end)
----------------------------------------------------------------------------------------
---------------------------Grefer Events------------------------------------------------
----------------------------------------------------------------------------------------
script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	local eplayer = game.players[event.player_index]
	if getRank(eplayer).power > 5 then
    if event.entity.type ~= "tree" and event.entity.type ~= "simple-entity" then
      event.entity.cancel_deconstruction("player")
      eplayer.print("You are not allowed to do this yet, play for player bit longer. Try again in about: " .. math.floor((timeForRegular - ticktominutes(eplayer.online_time))) .. " minutes")
      callRank(eplayer.name .. " tryed to deconstruced something")
    end
  elseif event.entity.type == "tree" or event.entity.type == "simple-entity" and getRank(eplayer).power < 5 then
    event.entity.destroy()
	end
end)
----------------------------------------------------------------------------------------
---------------------------Other Events-------------------------------------------------
----------------------------------------------------------------------------------------
script.on_event(defines.events.on_tick, function(event) 
	if game.tick % 60 == 0 then 
		command=table.remove(global.queue)
		if command and command.fun and type(command.fun) == 'function' then
			local args = command.var or {}
			command.fun(args[1],args[2],args[3],args[4],args[5],args[6]) 
		end
	end
	if (game.tick/(3600*game.speed)) % 15 == 0 then autoMessage() end 
end)
----------------------------------------------------------------------------------------
---------------------------Tool Bar-----------------------------------------------------
----------------------------------------------------------------------------------------
addButton("btn_toolbar_playerList", function(player) toggleVisable(mod_gui.get_frame_flow(player).PlayerList) end)
function drawToolbar(player)
  local frame = mod_gui.get_button_flow(player)
	if not frame.btn_toolbar_playerList then drawButton(frame,"btn_toolbar_playerList", "Playerlist", "Adds/removes the player list to/from your game.",'entity/player') end
	for _,f in pairs(guis.frames) do
		if frame["btn_".._] then frame["btn_".._].destroy() end
		if getRank(player).power <= f[1].require then drawButton(frame,"btn_".._, f[1].caption, f[1].tooltip, f[1].sprite) end
  end
end
----------------------------------------------------------------------------------------
---------------------------Player List--------------------------------------------------
----------------------------------------------------------------------------------------
function drawPlayerList()
  for i, player in pairs(game.connected_players) do
		local flow = mod_gui.get_frame_flow(player)
    if  flow.PlayerList == nil then
      flow.add{type = "frame", name= "PlayerList", direction = "vertical",style=mod_gui.frame_style}
                .add{type = "scroll-pane", name= "PlayerListScroll", direction = "vertical", vertical_scroll_policy="always", horizontal_scroll_policy="never"}
    end
		local Plist= flow.PlayerList.PlayerListScroll
    Plist.clear()
    Plist.style.maximal_height = 200
    for i, player in pairs(game.connected_players) do
			playerRank = getRank(player)
			if playerRank.power <= 3 or playerRank.name == 'Jail' then
				if playerRank.shortHand ~= '' then Plist.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , ' - '..playerRank.shortHand}}
				else Plist.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name}} end				
				Plist[player.name].style.font_color = playerRank.colour
				if player.tag:find('-') then else player.tag = playerRank.tag end
			end
    end
		for i, player in pairs(game.connected_players) do
			playerRank = getRank(player)
			if playerRank.power > 3 and playerRank.name ~= 'Jail' then
				if playerRank.shortHand ~= '' then Plist.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , ' - '..playerRank.shortHand}}
				else Plist.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name}} end
				Plist[player.name].style.font_color = playerRank.colour
				if player.tag:find('-') then else player.tag = playerRank.tag end
			end
		end
  end
end

function getPlayerTableFilters(frame)
	local filters = {online=nil,time=0,name=nil,selected=nil,powerOver=nil,admin=nil}
	local filterTable = frame.parent.parent.filterTable
	if filterTable.status_input then 
			local status_input = filterTable.status_input.text
			if status_input == 'yes' or status_input == 'online' or status_input == 'true' or status_input == 'y' then filters.online = true
			elseif status_input ~= '' then filters.online = false end
		end if filterTable.hours_input then
			local hours_input = filterTable.hours_input.text
			if tonumber(hours_input) and tonumber(hours_input) > 0 then filters.time = tonumber(hours_input) end
		end if filterTable.name_input then
			local name_input = filterTable.name_input.text
			if name_input then filters.name = name_input end
		end
	return filters
end

function drawPlayerTable(player, frame, select,filters)
	--setup the table
	if frame.playerTable then frame.playerTable.destroy() end
	pTable = frame.add{name='playerTable', type="table", colspan=5}
  pTable.style.minimal_width = 500
  pTable.style.maximal_width = 500
	pTable.style.horizontal_spacing = 10
  pTable.add{name="id", type="label", caption="Id"}
  pTable.add{name="Pname", type="label", caption="Name"}
  pTable.add{name="online_time", type="label", caption="Online Time"}
  pTable.add{name="rank", type="label", caption="Rank"}
	if select then pTable.add{name="select_label", type="label", caption="Selection"} end
	--filter checking
  for i, p in pairs(game.players) do 
    local addPlayer = nil
    if addPlayer ~= false and filters.admin then 						if p.admin ~= filters.admin then addPlayer = false end end
		if addPlayer ~= false and filters.online == true then 	if p.connected == false then addPlayer = false end end
		if addPlayer ~= false and filters.online == false then 	if p.connected == true then addPlayer = false end end
		if addPlayer ~= false and filters.powerOver then 				if getRank(p).power <= getRank(player).power then addPlayer = false end end
		if addPlayer ~= false and filters.time then 						if filters.time > ticktominutes(p.online_time) then addPlayer = false end end
		if addPlayer ~= false and filters.name then 						if p.name:lower():find(filters.name:lower()) == nil then addPlayer = false end end
		--addes the player to the list
		if addPlayer == nil then addPlayer = true end
    if addPlayer == true and player.name ~= p.name then
      if pTable[p.name] == nil then
        pTable.add{name=i .. "id", type="label", caption=i}
        pTable.add{name=p.name..'_name', type="label", caption=p.name}
				--status
				if not select then 
					if p.connected == true 
					then pTable.add{name=p.name .. "Status", type="label", caption="ONLINE"}
					else pTable.add{name=p.name .. "Status", type="label", caption="OFFLINE"} end end
				--time and rank
        pTable.add{name=p.name .. "Online_Time", type="label", caption=(ticktohour(p.online_time)..'H '..(ticktominutes(p.online_time)-60*ticktohour(p.online_time))..'M')}
        pTable.add{name=p.name .. "Rank", type="label", caption=getRank(p).shortHand}
				--player slecction
				if select then
					pTable.add{name=p.name, type="flow"}
					local state = false
					for _,name in pairs(global.selected[player.index]) do if name == p.name then state = true break end end
					pTable[p.name].add{name='select', type="checkbox",state=state}
				end
      end
    end
  end
end
----------------------------------------------------------------------------------------
---------------------------Init---------------------------------------------------------
----------------------------------------------------------------------------------------
function scriptInit()
	--global
	for name,value in pairs(defaults) do global[name] = value end
	--ranks
	for _,rank in pairs(global.ranks) do
		game.permissions.create_group(rank.name)
		for _,toRemove in pairs(rank.disallow) do
			game.permissions.get_group(rank.name).set_allows_action(defines.input_action[toRemove],false)
		end
	end
	--end
	game.print('Script Init Complete')
end

function commandInit()
	commands.add_command('server-interface','<command>  #1#',function(event)
		if event.player_index then
			local byPlayer = game.players[event.player_index]
			if getRank(byPlayer).power > 1 then byPlayer.print('401 - Unauthorized: Access is denied due to invalid credentials') return end
			if event.parameter then else byPlayer.print('Invaid Input, /server-interface <command>') return end
			local returned,value = pcall(loadstring(event.parameter)) 
			if type(value) == 'table' then game.write_file('log.txt', '\n Ran by: '..byPlayer.name..'\n $£$ '..table.tostring(value), true, 0) byPlayer.print(table.tostring(value))
			else game.write_file('log.txt', '\n Ran by: '..byPlayer.name..'\n $£$ '..tostring(value), true, 0) byPlayer.print(value) end
		else 
			if event.parameter then else print('Invaid Input, /server-interface <command>') return end
			local returned,value = pcall(loadstring(event.parameter)) 
			if type(value) == 'table' then game.write_file('log.txt', '\n $£$ '..table.tostring(value), true, 0) print(table.tostring(value))
			else game.write_file('log.txt', '\n $£$ '..tostring(value), true, 0) print(value) end
		end
	end)
	commands.add_command('auto-message','Sends the auto message to all players #6#',function(event) autoMessage() end)
	--base layout for all commands
	commands.add_command('online-time','<player_name> Get a players online time #6#',function(event)
		if event.player_index then --is it a player or the server
			local byPlayer = game.players[event.player_index] -- it's a player so gets them
			if event.parameter then else byPlayer.print('Invaild Input, /online-time <player>') return end -- are there any arguments
			if getRank(byPlayer).power > 4 then byPlayer.print('401 - Unauthorized: Access is denied due to invalid credentials') return end -- is the user have vaild rank to use command
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end -- gets all the arguments passed
			if #args == 1 then else byPlayer.print('Invaild Input, /online-time <player> ') return end -- is enouth arguments passed to aloow the command to work
			local player = game.players[args[1]] if player then else byPlayer.print('Invaild Player Name,'..args[1]..', try using tab key to auto-coomplet the name') return end -- arguments vaildtion
			byPlayer.print(ticktohour(player.online_time)..'H '..(ticktominutes(player.online_time)-60*ticktohour(player.online_time))..'M') -- finally the command is done
		else -- when the server runs commands no output is given to any user, also server has no rank validation
			if event.parameter then else print('Invaild Input, /online-time <player>') return end -- are there any arguments
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end -- gets all the arguments passed
			if #args == 1 then else print('Invaild Input, /online-time <player>') return end -- is enouth arguments passed to aloow the command to work
			local player = game.players[args[1]] if player then else print('Invaild Player Name,'..args[1]..', try using tab key to auto-coomplet the name') return end -- arguments vaildtion
			print(ticktohour(player.online_time)..'H '..(ticktominutes(player.online_time)-60*ticktohour(player.online_time))..'M') -- finally the command is done
			print('Command Complete')
		end
	end)
	--revive-entities
	commands.add_command('revive-entities','<range/all> Reives all entitys in this range. Admins can use all as range #4#',function(event)
		if event.player_index then
			local byPlayer = game.players[event.player_index]
			if event.parameter then else byPlayer.print('Invaild Input, /revive-entities <range/all>') return end
			local pos = byPlayer.position
			if getRank(byPlayer).power > 4 then byPlayer.print('401 - Unauthorized: Access is denied due to invalid credentials') return end
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
			if #args == 1 then else byPlayer.print('Invaild Input, /revive-entities <range/all>') return end
			local range = tonumber(args[1]) if range or args[1] == 'all' then else byPlayer.print('Invaild Range, must be number below 50') return end
			if args[1] == 'all' then 
				if getRank(byPlayer).power > 2 then byPlayer.print('401 - Unauthorized: Access is denied due to invalid credentials') return end
				for key, entity in pairs(game.surfaces[1].find_entities_filtered({type = "entity-ghost"})) do entity.revive() end return
			elseif range < 50 and range > 0 then else byPlayer.print('Invaild Range, must be number below 50') return end
				for key, entity in pairs(game.surfaces[1].find_entities_filtered({area={{pos.x-range,pos.y-range},{pos.x+range,pos.y+range}},type = "entity-ghost"})) do entity.revive()
			end
		else
			for key, entity in pairs(game.surfaces[1].find_entities_filtered({type = "entity-ghost"})) do entity.revive() end print('Command Complete')
		end
	end)
	-- tp 
	commands.add_command('tp','<player> <to_player> teleports one player to another #4#',function(event)
		if event.player_index then
			local byPlayer = game.players[event.player_index]
			if event.parameter then else byPlayer.print('Invaild Input, /tp <player> <to_player>') return end
			if getRank(byPlayer).power > 4 then byPlayer.print('401 - Unauthorized: Access is denied due to invalid credentials') return end
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
			if #args == 2 then else byPlayer.print('Invaild Input, /tp <player> <to_player>') return end
			local p1 = game.players[args[1]] if p1 then else byPlayer.print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
			local p2 = game.players[args[2]] if p2 then else byPlayer.print('Invaild Player Name,'..args[2]..', try using tab key to auto-complete the name') return end
			if p1 == p2 then  byPlayer.print('Invaild Players, must be two diffrent players') return end
			if p1.connected and p2.connected then else byPlayer.print('Invaild Player, player is not online') return end
			if getRank(byPlayer).power > getRank(p1).power then byPlayer.print('401 - Unauthorized: Access is denied due to invalid credentials') return end
			p1.teleport(game.surfaces[p2.surface.name].find_non_colliding_position("player", p2.position, 32, 1))
		else
			if event.parameter then else print('Invaild Input, /tp <player> <to_player>') return end
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
			if #args == 2 then else print('Invaild Input, /tp <player> <to_player>') return end
			local p1 = game.players[args[1]] if p1 then else print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
			local p2 = game.players[args[2]] if p2 then else print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
			if p1 == p2 then print('Invaild Players, must be two diffrent players') return end
			if p1.connected and p2.connected then else print('Invaild Players, one/both of players is not online') return end
			p1.teleport(game.surfaces[p2.surface.name].find_non_colliding_position("player", p2.position, 32, 1))
			print('Command Complete')
		end
	end)
	-- kill 
	commands.add_command('kill','<player> if no player stated then you kill your self #6#',function(event)
		if event.player_index then
			local byPlayer = game.players[event.player_index]
			if event.parameter then
				local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
				if #args == 1 then else byPlayer.print('Invaild Input, /kill <player> ') return end
				local player = game.players[args[1]] if player then else byPlayer.print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
				if getRank(byPlayer).power > getRank(player).power or getRank(byPlayer).power > 4 then byPlayer.print('401 - Unauthorized: Access is denied due to invalid credentials') return end
				if player.connected then else byPlayer.print('Invaild Player, player is not online') return end
				if player.character then player.character.die() else byPlayer.print('Invaild Player, their are already dead') return end
			else
				if byPlayer.character then byPlayer.character.die() else byPlayer.print('Invaild Player, you are already dead') return end
			end
		else
			if event.parameter then else print('Invaild Input, /kill <player> ') return end
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
			if #args == 1 then else print('Invaild Input, /kill <player> ') return end
			local player = game.players[args[1]] if player then else print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
			if player.connected then else print('Invaild Player, player is not online') return end
			if player.character then player.character.die() else print('Invaild Player, their are already dead') return end
			print('Command Complete')
		end
	end)
	-- jail/unjail
	commands.add_command('jail','<player> jail the player disallowing them to move #3#',function(event)
		if event.player_index then
			local byPlayer = game.players[event.player_index]
			if event.parameter then else byPlayer.print('Invaild Input, /jail <player>') return end
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
			if #args == 1 then else byPlayer.print('Invaild Input, /jail <player> ') return end
			local player = game.players[args[1]] if player then else byPlayer.print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
			if getRank(byPlayer).power > getRank(player).power or getRank(byPlayer).power > 4 then byPlayer.print('401 - Unauthorized: Access is denied due to invalid credentials') return end
			if player.connected then else byPlayer.print('Invaild Player, player is not online') return end
			if player == byPlayer then byPlayer.print('Invaild Player, you can\'t jail yourself') return end
			if player.permission_group.name ~= 'Jail' then giveRank(player,'Jail',byPlayer) end
		else
			if event.parameter then else print('Invaild Input, /jail <player>') return end
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
			if #args == 1 then else print('Invaild Input, /jail <player>') return end
			local player = game.players[args[1]] if player then else print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
			if player.permission_group.name ~= 'Jail' then sudo(giveRank,{player,'Jail',byPlayer}) end
			print('Command Complete')
		end
	end)
	commands.add_command('unjail','<player> jail the player disallowing them to move #3#',function(event)
		if event.player_index then
			local byPlayer = game.players[event.player_index]
			if event.parameter then else byPlayer.print('Invaild Input, /unjail <player>') return end
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
			if #args == 1 then else byPlayer.print('Invaild Input, /unjail <player> ') return end
			local player = game.players[args[1]] if player then else byPlayer.print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
			if getRank(byPlayer).power > getRank(player).power or getRank(byPlayer).power > 4 then byPlayer.print('401 - Unauthorized: Access is denied due to invalid credentials') return end
			if player.permission_group.name == 'Jail' then revertRank(player,byPlayer) end
		else
			if event.parameter then else print('Invaild Input, /unjail <player>') return end
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
			if #args == 1 then else print('Invaild Input, /unjail <player>') return end 
			local player = game.players[args[1]] if player then else print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
			if player.permission_group.name == 'Jail' then sudo(revertRank,{player,byPlayer}) end
			print('Command Complete')
		end
	end)
	-- tag
	commands.add_command('tag','<tag> Gives you your own tag #6#',function(event)
		if event.player_index then
			local byPlayer = game.players[event.player_index]
			local tag = nil
			if event.parameter then tag = event.parameter end
			if tag and tag:len() > 20 then byPlayer.print('Invaild Tag, must be less then 20 characters') return end
			if tag then byPlayer.tag = getRank(byPlayer).tag..' - '..tag..' ' else byPlayer.tag = getRank(byPlayer).tag end
		else
			if event.parameter then else print('Invaild Input, /tag <player> <tag/nil>') return end
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
			if #args > 0 then else print('Invaild Input, /tag <player> <tag/nil>') return end 
			local player = game.players[args[1]] if player then else print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
			if args[2] then player.tag = getRank(player).tag..' - '..table.concat(args,' ',2)..' ' else player.tag = getRank(player).tag end
			print('Command Complete')
		end
	end)
	-- tp-all
	commands.add_command('tp-all','<player> Sends everyone to this one person #2#',function(event)
		if event.player_index then
			local byPlayer = game.players[event.player_index]
			if getRank(byPlayer).power > 2 then byPlayer.print('401 - Unauthorized: Access is denied due to invalid credentials') return end
			if event.parameter then else byPlayer.print('Invaild Input, /tp-all <player>') return end
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
			if #args == 1 then else byPlayer.print('Invaild Input, /tp-all <player>') return end 
			local player = game.players[args[1]] if player then else byPlayer.print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
			for i,p in pairs(game.connected_players) do 
				local pos = game.surfaces[player.surface.name].find_non_colliding_position("player", player.position, 32, 1) 
				if p ~= player then p.teleport(pos) end 
			end
		else
			if event.parameter then else print('Invaild Input, /tp-all <player>') return end
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
			if #args == 1 then else print('Invaild Input, /tp-all <player>') return end 
			local player = game.players[args[1]] if player then else print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
			for i,p in pairs(game.connected_players) do 
				local pos = game.surfaces[player.surface.name].find_non_colliding_position("player", player.position, 32, 1) 
				if p ~= player then p.teleport(pos) end 
			end
			print('Command Complete')
		end
	end)
	-- call-rank
	commands.add_command('call-rank','<rank> <message> sends a message to this rank and above #5#',function(event)
		if event.player_index then
			local byPlayer = game.players[event.player_index]
			if getRank(byPlayer).power > 5 then byPlayer.print('401 - Unauthorized: Access is denied due to invalid credentials') return end
			if event.parameter then else byPlayer.print('Invaild Input, /call-rank <rank> <message>') return end
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
			if #args > 1 then else byPlayer.print('Invaild Input, /call-rank <rank> <message>') return end 
			local rank = stringToRank(args[1]) if rank then else byPlayer.print('Invaild Rank, ther is no rank by that name') return end
			if rank.name ~= 'Mod' and getRank(byPlayer).power > rank.power then byPlayer.print('Invaild Rank, rank must not be a higher rank then your (mod is the only exception)') return end
			callRank(table.concat(args,' ',2),rank.name)
		else
			if event.parameter then else print('Invaild Input, /call-rank <rank> <message>') return end
			local args = {} for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
			if #args > 1 then else print('Invaild Input, /call-rank <rank> <message>') return end 
			local rank = stringToRank(args[1]) if rank then callRank(table.concat(args,' ',2),rank.name)
			else print('Invaild Rank, try asking for help from an admin') return end
			print('Command Complete')
		end
	end)
end
----------------------------------------------------------------------------------------
---------------------------Read Me Gui--------------------------------------------------
----------------------------------------------------------------------------------------
addFrame('Readme',6, 'Rules','Readme', 'Rules, Server info, How to chat, Playerlist, Adminlist.')
		
addTab('Readme','Rules','The rules of the server',
	function(player,frame)
		local rules = {
			"Hacking/cheating, exploiting and abusing bugs is not allowed.",
			"Do not disrespect any player in the server (This includes staff).",
			"Do not spam, this includes stuff such as chat spam, item spam, chest spam etc.",
			"Do not laydown concrete with bots without permission.",
			"Do not use active provider chests without permission.",
			"Do not use speakers on global without permission.",
			"Do not remove/move major parts of the factory without permission.",
			"Do not walk in player random direction for no reason(to save map size).",
			"Do not remove stuff just because you don't like it, tell people first.",
			"Do not make train roundabouts. Or any loops of any kind",
			"Trains are Left Hand Drive (LHD) only.",
			"Do not complain about lag, low fps and low ups or other things like that.",
			"Do not ask for rank.",
			"Use common sense and what an admin says goes."}
		for i, rule in pairs(rules) do
			frame.add{name=i, type="label", caption={"", i ,". ", rule}}
		end
	end)
addTab('Readme','Server Info','Info about the server',
	function(player,frame)
		frame.add{name=1, type="label", caption={"", "Discord voice and chat server:"}}
		frame.add{name=2, type='textfield', text='https://discord.gg/RPCxzgt'}.style.minimal_width=400
		frame.add{name=3, type="label", caption={"", "Our forum:"}}
		frame.add{name=4, type='textfield', text='https://explosivegaming.nl'}.style.minimal_width=400
		frame.add{name=5, type="label", caption={"", "Steam:"}}
		frame.add{name=6, type='textfield', text='http://steamcommunity.com/groups/tntexplosivegaming'}.style.minimal_width=400
	end)
addTab('Readme','How to chat','Just in case you dont know how to chat',
	function(player,frame)
		local chat = "Chatting for new players can be difficult because it’s different than other games! It’s very simple, the button you need to press is the “GRAVE/TILDE” key it’s located under the “ESC key”. If you would like to change the key go to your controls tab in options. The key you need to change is “Toggle Lua console” it’s located in the second column 2nd from bottom."
		frame.add{name=i, type="label", caption={"", chat}, single_line=false}.style.maximal_width=480
	end)
addTab('Readme', 'Commands', 'Random useful commands', 
	function(player, frame)
		frame.add{name='commandTable',type='table',colspan=2}
		for command,help in pairs(commands.commands) do
			local power = tonumber(help:sub(-2,-2))
			if power then else callRank(command..'has a help error') power = 0 end
			if getRank(player).power > power then else
				frame.commandTable.add{name='command_'..command,type='label',caption='/'..command}
				frame.commandTable.add{name='help_'..command,type='label',caption=help:sub(1,-4),single_line=false}.style.maximal_width=480
			end
		end
	end)
addTab('Readme','Players','List of all the people who have been on the server',
	function(player,frame)
		local players = {
			"These are the players who have supported us in the making of this factory. Without",
			"you the player we wouldn't have been as far as we are now."}
		for i, line in pairs(players) do
			frame.add{name=i, type="label", caption={"", line}}
		end
		frame.add{name='filterTable',type='table',colspan=3}
		frame.filterTable.add{name='name_label',type='label',caption='Name'}
		frame.filterTable.add{name='status_label',type='label',caption='Online?'}
		frame.filterTable.add{name='hours_label',type='label',caption='Online Time (minutes)'}
		frame.filterTable.add{name='name_input',type='textfield'}
		frame.filterTable.add{name='status_input',type='textfield'}
		frame.filterTable.add{name='hours_input',type='textfield'}
		drawPlayerTable(player, frame, false, {})
	end)
----------------------------------------------------------------------------------------
---------------------------Admin Gui----------------------------------------------------
----------------------------------------------------------------------------------------
addFrame('Admin',3,'Edit Ranks','Admin',"All admin fuctions are here")

addButton('setRanks', 
	function(player,frame) 
		rank = stringToRank(frame.parent.rank_input.items[frame.parent.rank_input.selected_index]) 
		if rank then 
			for _,playerName in pairs(global.selected[player.index]) do 
				p=game.players[playerName] 
				if getRank(player).power < getRank(p).power and rank.power > getRank(player).power then 
					giveRank(p,rank,player)
					clearSelection(player) 
					drawPlayerTable(player, frame.parent.parent, true, {})
				else 
					player.print('You can not edit '..p.name.."'s rank there rank is too high (or the rank you have slected is above you)") 
				end 
			end 
		end
	end)
addButton('clearSelection',function(player,frame) clearSelection(player) drawPlayerTable(player, frame.parent.parent, true, {}) end)

addTab('Admin', 'Commands', 'Random useful commands', 
	function(player, frame)
		frame.add{name='commandTable',type='table',colspan=2}
		for command,help in pairs(commands.commands) do
			local power = tonumber(help:sub(-2,-2))
			if power then else callRank(command..'has a help error') power = 0 end
			if getRank(player).power > power then else
				frame.commandTable.add{name='command_'..command,type='label',caption='/'..command}
				frame.commandTable.add{name='help_'..command,type='label',caption=help:sub(1,-4),single_line=false}.style.maximal_width=480
			end
		end
	end)
addTab('Admin','Edit Ranks', 'Edit the ranks of players below you',
	function(player,frame)
		clearSelection(player)
		frame.add{name='filterTable',type='table',colspan=1}
		frame.filterTable.add{name='name_label',type='label',caption='Name'}
		frame.filterTable.add{name='name_input',type='textfield'}
		frame.add{type='flow',name='rank',direction='horizontal'}
		frame.rank.add{name='rank_label',type='label',caption='Rank'}
		frame.rank.add{name='rank_input',type='drop-down'}
		for _,rank in pairs(global.ranks) do if rank.power > getRank(player).power then frame.rank.rank_input.add_item(rank.name) end end
		frame.rank.rank_input.selected_index = 1
		drawButton(frame.rank,'setRanks','Set Ranks','Sets the rank of all selected players')
		drawButton(frame.rank,'clearSelection','Clear Selection','Clears all currently selected players')
		drawPlayerTable(player, frame, true, {powerOver=true})
	end)
----------------------------------------------------------------------------------------
---------------------------Admin+ Gui---------------------------------------------------
----------------------------------------------------------------------------------------
addFrame('Admin+',2,'Modifiers','Admin+',"Because we are better")

addButton('remove_biters',function(player,frame) for key, entity in pairs(game.surfaces[1].find_entities_filtered({force='enemy'})) do entity.destroy() end end)
addButton('toggle_cheat',function(player,frame) player.cheat_mode = not player.cheat_mode end)
addButton("btn_Modifier_apply",
	function(player,frame)
		local forceModifiers = {
			"manual_mining_speed_modifier",
			"manual_crafting_speed_modifier",
			"character_running_speed_modifier",
			"worker_robots_speed_modifier",
			"worker_robots_storage_bonus",
			"character_build_distance_bonus",
			"character_item_drop_distance_bonus",
			"character_reach_distance_bonus",
			"character_resource_reach_distance_bonus",
			"character_item_pickup_distance_bonus",
			"character_loot_pickup_distance_bonus"
		}
		for i, modifier in pairs(forceModifiers) do 
			local number = tonumber(( frame.parent.parent.modifierTable[modifier .. "_input"].text):match("[%d]+[.%d+]"))
			if number ~= nil then
				if number >= 0 and number < 50 and number ~= player.force[modifier] then
					player.force[modifier] = number
					player.print(modifier .. " changed to number: " .. tostring(number))
				elseif number == player.force[modifier] then
					player.print(modifier .. " Did not change")
				else
					player.print(modifier .. " needs to be player higher number or it contains an letter")
				end
			end
		end
	end)
	
addTab('Admin+', 'Commands', 'Random useful commands',
	function(player, frame)
		drawButton(frame,'remove_biters','Kill Biters','Removes all biters in map')
		drawButton(frame,'toggle_cheat','Toggle Cheat Mode','Toggle your cheat mode')
	end)

addTab('Admin+', 'Modifiers', 'Edit in game modifiers',
	function(player,frame)
		local forceModifiers = {
    "manual_mining_speed_modifier",
    "manual_crafting_speed_modifier",
    "character_running_speed_modifier",
    "worker_robots_speed_modifier",
    "worker_robots_storage_bonus",
    "character_build_distance_bonus",
    "character_item_drop_distance_bonus",
    "character_reach_distance_bonus",
    "character_resource_reach_distance_bonus",
    "character_item_pickup_distance_bonus",
    "character_loot_pickup_distance_bonus"
		}
    frame.add{type = "flow", name= "flowNavigation",direction = "horizontal"}
    frame.add{name="modifierTable", type="table", colspan=3}
    frame.modifierTable.add{name="Mname", type="label", caption="name"}
    frame.modifierTable.add{name="input", type="label", caption="input"}
    frame.modifierTable.add{name="current", type="label", caption="current"}
    for i, modifier in pairs(forceModifiers) do
      frame.modifierTable.add{name=modifier, type="label", caption=modifier}
      frame.modifierTable.add{name=modifier .. "_input", type="textfield", caption="inputTextField"}
      frame.modifierTable.add{name=modifier .. "_current", type="label", caption=tostring(player.force[modifier])}
    end
    drawButton(frame.flowNavigation,"btn_Modifier_apply","Apply","Apply the new values to the game")
end)
