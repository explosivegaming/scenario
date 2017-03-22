
itemRotated = {}
entityRemoved = {}
entityCache = {}
guis = {frames={},buttons={}}

warningAllowed = nil
timeForRegular = 180
CHUNK_SIZE = 32

----------------------------------------------------------------------------------------
---------------------------Remove decorations-------------------------------------------
----------------------------------------------------------------------------------------
local function removeDecorationsArea(surface, area )
	if surface.find_entities_filtered{area = area, type="decorative"} then
		for _, entity in pairs(surface.find_entities_filtered{area = area, type="decorative"}) do
			if (entity.name ~= "red-bottleneck" and entity.name ~= "yellow-bottleneck" and entity.name ~= "green-bottleneck") then
				entity.destroy()
			end
		end
	end
end

local function removeDecorations(surface, x, y, width, height )
	removeDecorationsArea(surface, {{x, y}, {x + width, y + height}})
end

local function clearDecorations()
	local surface = game.surfaces["nauvis"]
	for chunk in surface.get_chunks() do
		removeDecorations(surface, chunk.x * CHUNK_SIZE, chunk.y * CHUNK_SIZE, CHUNK_SIZE - 1, CHUNK_SIZE - 1)
	end
    callAdmin("Decoratives have been removed")
end

script.on_event(defines.events.on_chunk_generated, function(event)
	removeDecorationsArea( event.surface, event.area )
end)

----------------------------------------------------------------------------------------
---------------------------Common use functions---------------------------------------
----------------------------------------------------------------------------------------
function ticktohour (tick)
    local hour = tostring(math.floor(tick * (1 /(60*game.speed)) / 3600))
    return hour
end

function ticktominutes (tick)
  	local minutes = math.floor((tick * (1 /(60*game.speed))) / 60)
    return minutes
end

function callAdmin(msg)
	for _, player in pairs(game.connected_players) do 
		if player.admin then
			player.print(msg)
		end
	end
end

function autoMessage()
	game.print('There are '..#game.connected_players..' players online')
	game.print('This map has been on for '..ticktohour(game.tick)..' Hours and '..(ticktominutes(game.tick)-60*ticktohour(game.tick))..' Minutes')
	game.print('Please join us on:')
	game.print('Discord: https://discord.gg/RPCxzgt')
	game.print('Forum: explosivegaming.nl')
	game.print('Steam: http://steamcommunity.com/groups/tntexplosivegaming')
	game.print('To see these links again goto: Readme > Server Info')
end
----------------------------------------------------------------------------------------
---------------------------Gui Functions------------------------------------------------
----------------------------------------------------------------------------------------
function addFrame(frame)
	guis.frames[frame] = {}
	addButton('close', function(player,element) element.parent.parent.parent.destroy() end)
end

function addTab(frame, tabName, describtion, drawTab)
	guis.frames[frame][tabName] = {tabName, describtion, drawTab}
	addButton(tabName, function(player, element) openTab(player, element.parent.parent.parent.name, element.parent.parent.parent.tab, element.name) end)
end

function addButton(btnName, onClick)
	guis.buttons[btnName] = {btnName, onClick}
end

function drawButton(frame, btnName, caption, describtion)
	frame.add{name=btnName, type = "button", caption=caption, tooltip=describtion}
end

function openTab(player, frameName, tab, tabName)
	local tabBar = player.gui.center[frameName].tabBarScroll.tabBar
	for _,t in pairs(guis.frames[frameName]) do
		if t[1] == tabName then
			tabBar[t[1]].style.font_color = {r = 255, g = 255, b = 255, a = 255}
			clearElement(tab)
			t[3](player, tab)
		else
			tabBar[t[1]].style.font_color = {r = 100, g = 100, b = 100, a = 255}
		end
	end
end

function drawFrame(player, frameName, tabName)
	if player.gui.center[frameName] then player.gui.center[frameName].destroy() end
	local frame = player.gui.center.add{name=frameName,type='frame',caption=frameName,direction='vertical'}
	local tabBarScroll = frame.add{type = "scroll-pane", name= "tabBarScroll", vertical_scroll_policy="never", horizontal_scroll_policy="always"}
	local tabBar = tabBarScroll.add{type='flow',direction='horizontal',name='tabBar'}
	local tab = frame.add{type = "scroll-pane", name= "tab", vertical_scroll_policy="auto", horizontal_scroll_policy="never"}
	for _,t in pairs(guis.frames[frameName]) do
		drawButton(tabBar, t[1], t[1], t[2])
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

function clearElement (elementToClear)
  if elementToClear ~= nil then
    for i, element in pairs(elementToClear.children_names) do
      elementToClear[element].destroy()
    end
  end
end
----------------------------------------------------------------------------------------
---------------------------Player Events------------------------------------------------
----------------------------------------------------------------------------------------
script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
  player.insert{name="burner-mining-drill", count = 1}
  player.insert{name="stone-furnace", count = 1}
  --developer items
  if player.name == "badgamernl" or player.name == "BADgamerNL" then
    player.insert{name="blueprint", count = 1}
    player.insert{name="deconstruction-planner", count = 1}
  end
  player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
end)

script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.players[event.player_index]
	drawPlayerList()
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]
  player.print({"", "Welcome"})
  if player.gui.left.PlayerList ~= nil then
    player.gui.left.PlayerList.destroy()
  end
  if player.gui.center.README ~= nil then
    player.gui.center.README.destroy()
  end
  if player.gui.top.PlayerList ~= nil then
    player.gui.top.PlayerList.destroy()
  end
	drawPlayerList()
  drawToolbar()
  local playerStringTable = encode(game.players, "players", {"name", "admin", "online_time", "connected", "index"})
  game.write_file("players.json", playerStringTable, false)
  if not player.admin and ticktominutes(player.online_time) < 1 then
    drawFrame(player,'Readme','Rules')
  end
end)

script.on_event(defines.events.on_player_left_game, function(event)
  local player = game.players[event.player_index]
  drawPlayerList()
end)
----------------------------------------------------------------------------------------
---------------------------Gui Events---------------------------------------------------
----------------------------------------------------------------------------------------
script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]
	for _,btn in pairs(guis.buttons) do
		if btn[1] == event.element.name then
			if btn[2] then btn[2](player,event.element) else game.print('Invaid Button'..btn[1]) end
			break
		end
	end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
	local player = game.players[event.player_index]
	if event.element.parent.parent.filterTable then
		local frame = event.element
		local filters = {}
		local commands = false
		if frame.parent.parent.parent.name == 'Admin' then commands = true filters[#filters+1] = 'online' end
		if frame.parent.parent.filterTable.status_input and not commands then 
			local status_input = frame.parent.parent.filterTable.status_input.text
			if status_input == 'yes' or status_input == 'online' or status_input == 'true' or status_input == 'y' then filters[#filters+1] = 'online'
			elseif status_input ~= '' then filters[#filters+1] = 'offline' end
		end if frame.parent.parent.filterTable.hours_input then
			local hours_input =  frame.parent.parent.filterTable.hours_input.text
			if tonumber(hours_input) and tonumber(hours_input) > 0 then filters[#filters+1] = tonumber(hours_input) end
		end if frame.parent.parent.filterTable.name_input then
			local name_input =  frame.parent.parent.filterTable.name_input.text
			if name_input then filters[#filters+1] = name_input end
		end
		if frame.parent.parent.playerTable then frame.parent.parent.playerTable.destroy() end
		drawPlayerTable(player, frame.parent.parent, commands, filters)
	end
end)
----------------------------------------------------------------------------------------
---------------------------Grefer Events------------------------------------------------
----------------------------------------------------------------------------------------
script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	local eplayer = game.players[event.player_index]
	if not eplayer.admin and ticktominutes(eplayer.online_time) < timeForRegular then
    if event.entity.type ~= "tree" and event.entity.type ~= "simple-entity" then
      event.entity.cancel_deconstruction("player")
      eplayer.print("You are not allowed to do this yet, player for a bit longer. Try again in about: " .. math.floor((timeForRegular - ticktominutes(eplayer.online_time))) .. " minutes")
      callAdmin(eplayer.name .. " tryed to deconstruced something")
    end
  elseif event.entity.type == "tree" or event.entity.type == "simple-entity" then
    event.entity.destroy()
	end
end)

script.on_event(defines.events.on_built_entity, function(event)
	local eplayer = game.players[event.player_index]
	local timeForRegular = 120
	if not eplayer.admin and ticktominutes(eplayer.online_time) < timeForRegular then
		if event.created_entity.type == "tile-ghost" then
			event.created_entity.destroy()
			eplayer.print("You are not allowed to do this yet, player for a bit longer. Try: " .. math.floor((timeForRegular - ticktominutes(eplayer.online_time))) .. " minutes")
			callAdmin(eplayer.name .. " tryed to place concrete/stone with robots")
		end
	end
end)
----------------------------------------------------------------------------------------
---------------------------Other Events-------------------------------------------------
----------------------------------------------------------------------------------------
script.on_event(defines.events.on_rocket_launched, function(event)
  local force = event.rocket.force
  if event.rocket.get_item_count("satellite") == 0 then
    if (#game.players <= 1) then
      game.show_message_dialog{text = {"gui-rocket-silo.rocket-launched-without-satellite"}}
    else
      for index, player in pairs(force.players) do
        player.print({"gui-rocket-silo.rocket-launched-without-satellite"})
      end
    end
    return
  end
  if not global.satellite_sent then
    global.satellite_sent = {}
  end
  if global.satellite_sent[force.name] then
    global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1   
  else
    game.set_game_state{game_finished=true, player_won=true, can_continue=true}
    global.satellite_sent[force.name] = 1
  end
  for index, player in pairs(force.players) do
    if player.gui.left.rocket_score then
      player.gui.left.rocket_score.rocket_count.caption = tostring(global.satellite_sent[force.name])
    else
      local frame = player.gui.left.add{name = "rocket_score", type = "frame", direction = "horizontal", caption={"score"}}
      frame.add{name="rocket_count_label", type = "label", caption={"", {"rockets-sent"}, ":"}}
      frame.add{name="rocket_count", type = "label", caption=tostring(global.satellite_sent[force.name])}
    end
  end 
end)

script.on_event(defines.events.on_tick, function(event) if (game.tick*(1/(60*game.speed))/60) % 30 == 0 then autoMessage() end end)
----------------------------------------------------------------------------------------
---------------------------IDK What There Do Functions----------------------------------
----------------------------------------------------------------------------------------
function encode ( table, name, items )
  local encodeString
  local encodeSubString
  local encodeSubSubString
  for i, keyTable in pairs(table) do
    encodeSubSubString = nil
    for i, keyItem in pairs(items) do
      if type(keyTable[keyItem]) == "string" then
        if encodeSubSubString ~= nil then
          encodeSubSubString = encodeSubSubString .. ",\"" .. keyItem .. "\": \"" .. keyTable[keyItem] .. "\""
        else
          encodeSubSubString = "\"" .. keyItem .. "\": \"" .. keyTable[keyItem] .. "\""
        end
      elseif type(keyTable[keyItem]) == "number" then
        if encodeSubSubString ~= nil then
          encodeSubSubString = encodeSubSubString .. ",\"" .. keyItem .. "\": " .. tostring(keyTable[keyItem])
        else
          encodeSubSubString = "\"" .. keyItem .. "\": " .. tostring(keyTable[keyItem])
        end
      elseif type(keyTable[keyItem]) == "boolean" then
        if encodeSubSubString ~= nil then
          encodeSubSubString = encodeSubSubString .. ",\"" .. keyItem .. "\": " .. tostring(keyTable[keyItem])
        else
          encodeSubSubString = "\"" .. keyItem .. "\": " .. tostring(keyTable[keyItem])
        end
      end
    end
    if encodeSubSubString ~= nil and encodeSubString ~= nil then
      encodeSubString = encodeSubString .. ", {" .. encodeSubSubString .. "}"
    else
      encodeSubString = "{" .. encodeSubSubString .. "}"
    end
  end
  encodeString = "{" .. "\"" .. name .. "\": [" .. encodeSubString .. "]}"
  return encodeString
end
----------------------------------------------------------------------------------------
---------------------------Tool Bar-----------------------------------------------------
----------------------------------------------------------------------------------------
addButton("btn_toolbar_playerList", function(player) toggleVisable(player.gui.left.PlayerList) end)
addButton("btn_toolbar_rocket_score",function(player) toggleVisable(player.gui.left.rocket_score) end)
addButton("btn_readme",function(player) if player.gui.center.Readme then player.gui.center.Readme.destroy() else drawFrame(player,'Readme','Rules') end end)
addButton("btn_admin",function(player) if player.gui.center.Admin then player.gui.center.Admin.destroy() else drawFrame(player,'Admin','Modifiers') end end)
function drawToolbar()
  for i, a in pairs(game.connected_players) do
    local frame = a.gui.top
    clearElement(frame)
		drawButton(frame,"btn_toolbar_playerList", "Playerlist", "Adds a player list to your game.")
		drawButton(frame,"btn_toolbar_rocket_score", "Rocket score", "Show the satellite launched counter if a satellite has launched.")
    drawButton(frame,"btn_readme", "Readme", "Rules, Server info, How to chat, Playerlist, Adminlist.")
    if a.tag == '[Owner]' or a.tag == '[Developer]' or a.tag == '[Com Mngr]' then
			drawButton(frame,"btn_admin", "Admin", "All admin fuctions are here")
    end
  end
end
----------------------------------------------------------------------------------------
---------------------------Player List--------------------------------------------------
----------------------------------------------------------------------------------------
function drawPlayerList()
  for i, a in pairs(game.connected_players) do
    if  a.gui.left.PlayerList == nil then
      a.gui.left.add{type = "frame", name= "PlayerList", direction = "vertical"}
                .add{type = "scroll-pane", name= "PlayerListScroll", direction = "vertical", vertical_scroll_policy="always", horizontal_scroll_policy="never"}
    end
    clearElement(a.gui.left.PlayerList.PlayerListScroll)
    a.gui.left.PlayerList.PlayerListScroll.style.maximal_height = 200
    for i, player in pairs(game.connected_players) do
			if player.character then
				if player.tag == '[Jail]' or player.character.active == false then
					a.gui.left.PlayerList.PlayerListScroll.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - Jail"}}
					a.gui.left.PlayerList.PlayerListScroll[player.name].style.font_color = {r=50,g=50,b=50}
					player.character.active = false
					player.tag = '[Jail]'
				end
			end
      if player.admin == true then
        if player.name == "badgamernl" or player.name == "BADgamerNL" then
					a.gui.left.PlayerList.PlayerListScroll.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - OWNER"}}
					a.gui.left.PlayerList.PlayerListScroll[player.name].style.font_color = {r=170,g=0,b=0}
					player.tag = "[Owner]"
        elseif player.name == "eissturm" or player.name == "PropangasEddy" then
					a.gui.left.PlayerList.PlayerListScroll.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - ADMIN"}}
					a.gui.left.PlayerList.PlayerListScroll[player.name].style.font_color = {r=170,g=41,b=170}
					player.tag = "[Admin]"
        elseif player.name == "Cooldude2606" then
					a.gui.left.PlayerList.PlayerListScroll.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - DEV"}}
					a.gui.left.PlayerList.PlayerListScroll[player.name].style.font_color = {r=179,g=125,b=46}
					player.tag = "[Developer]"
        elseif player.name == "arty714" then
					a.gui.left.PlayerList.PlayerListScroll.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - CM"}}
					a.gui.left.PlayerList.PlayerListScroll[player.name].style.font_color = {r=150,g=68,b=161}
					player.tag = "[Com Mngr]"
        else
					a.gui.left.PlayerList.PlayerListScroll.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - MOD"}}
					a.gui.left.PlayerList.PlayerListScroll[player.name].style.font_color = {r=233,g=63,b=233}
					player.tag = "[Moderator]"
        end
			end
		end
		for i, player in pairs(game.connected_players) do
			if player.tag ~= '[Jail]' then
				if player.admin == false then
					if ticktominutes(player.online_time) >= timeForRegular then
						a.gui.left.PlayerList.PlayerListScroll.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name}}
						a.gui.left.PlayerList.PlayerListScroll[player.name].style.font_color = {r=24,g=172,b=188}
						player.tag = "[Regular]"
					elseif player.name == "explosivegaming" then
						for i=10,1,-1 do 
							a.gui.left.PlayerList.PlayerListScroll.add{type = "label",  name=player.name .. i, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , i}}
							a.gui.left.PlayerList.PlayerListScroll[player.name .. i].style.font_color = {r=24,g=172,b=188}
							player.tag = "[TEST]"
						end
					else
						a.gui.left.PlayerList.PlayerListScroll.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name}}
						a.gui.left.PlayerList.PlayerListScroll[player.name].style.font_color = {r=255,g=159,b=27}
						player.tag = "[Guest]"
					end
				end
      end
    end
  end
end

addButton('goto',
	function(player,frame)
		local p = game.players[frame.parent.name]
		player.teleport(game.surfaces[p.surface.name].find_non_colliding_position("player", p.position, 32, 1))
end)
addButton('bring',
	function(player,frame)
	local p = game.players[frame.parent.name]
	p.teleport(game.surfaces[player.surface.name].find_non_colliding_position("player", player.position, 32, 1))
end)
addButton('jail',
	function(player,frame)
	local p = game.players[frame.parent.name]
	if p.character then
		if p.character.active then
			p.character.active = false
			p.tag = '[Jail]'
			drawPlayerList()
		else
			p.character.active = true
			p.tag = '[Guest]'
			drawPlayerList()
		end
	end
end)
addButton('kill',
	function(player,frame)
	local p = game.players[frame.parent.name]
	if p.character then p.character.die() end
end)
function drawPlayerTable(player, frame, commands, filters)
	frame.add{name='playerTable', type="table", colspan=5}
  frame.playerTable.style.minimal_width = 500
  frame.playerTable.style.maximal_width = 500
	frame.playerTable.style.horizontal_spacing = 10
  frame.playerTable.add{name="id", type="label", caption="Id		"}
  frame.playerTable.add{name="name", type="label", caption="Name		"}
  if not commands then frame.playerTable.add{name="status", type="label", caption="Status		"} end
  frame.playerTable.add{name="online_time", type="label", caption="Online Time	"}
  frame.playerTable.add{name="rank", type="label", caption="Rank	"}
	if commands then frame.playerTable.add{name="commands", type="label", caption="Commands"} end
  for i, p in pairs(game.players) do
    local addPlayer = true
    for _,filter in pairs(filters) do
      if filter == 'admin' then if p.admin == false then addPlayer = false break end
			elseif filter == 'online' then if p.connected == false then addPlayer = false break end
			elseif filter == 'offline' then if p.connected == true then addPlayer = false break end
			elseif type(filter)=='number' then if filter > ticktominutes(p.online_time) then addPlayer = false break end
			elseif type(filter)=='string' then if p.name:lower():find(filter:lower()) == nil then addPlayer = false break end
	  end
	end
    if addPlayer == true and player.name ~= p.name then
      if frame.playerTable[p.name] == nil then
        frame.playerTable.add{name=i .. "id", type="label", caption=i}
        frame.playerTable.add{name=p.name..'_name', type="label", caption=p.name}
				if not commands then 
					if p.connected == true then
						frame.playerTable.add{name=p.name .. "Status", type="label", caption="ONLINE"}
					else
						frame.playerTable.add{name=p.name .. "Status", type="label", caption="OFFLINE"}
					end
				end
        frame.playerTable.add{name=p.name .. "Online_Time", type="label", caption=(ticktohour(p.online_time)..'H '..(ticktominutes(p.online_time)-60*ticktohour(p.online_time))..'M')}
        frame.playerTable.add{name=p.name .. "Rank", type="label", caption=p.tag}
				if commands then
					frame.playerTable.add{name=p.name, type="flow"}
					drawButton(frame.playerTable[p.name],'goto','Tp','Goto to the players location')
					drawButton(frame.playerTable[p.name],'bring','Br','Bring a player to your location')
					if p.tag == '[Owner]' or p.tag == '[Developer]' or p.tag == '[Com Mngr]' then else
						drawButton(frame.playerTable[p.name],'jail','Ja','Jail/Unjail a player')
						drawButton(frame.playerTable[p.name],'kill','Ki','Kill this player')
					end
				end
      end
    end
  end
end
----------------------------------------------------------------------------------------
---------------------------Read Me Gui--------------------------------------------------
----------------------------------------------------------------------------------------
addFrame('Readme')
		
addTab('Readme','Rules','The rules of the server',
	function(player,frame)
		local rules = {
			"Hacking/cheating, exploiting and abusing bugs is not allowed.",
			"Do not disrespect any player in the server (This includes staff).",
			"Do not spam, this includes stuff such as chat spam, item spam, chest spam etc.",
			"Do not laydown concrete with bots when you dont have permission to.",
			"Do not walk in a random direction for no reason(to save map size).",
			"Do not make train roundabouts.",
			"Do not complain about lag, low fps and low ups or other things like that.",
			"Do not ask for rank.",
			"Left Hand Drive (LHD) only.",
			"Use common sense."}
		for i, rule in pairs(rules) do
			frame.add{name=i, type="label", caption={"", i ,". ", rule}}
		end
	end)
addTab('Readme','Server Info','Info about the server',
	function(player,frame)
		local serverInfo = {
			"Discord voice and chat server:",
			"https://discord.gg/RPCxzgt",
			"Our forum:",
			"explosivegaming.nl",
			"Steam:",
			"http://steamcommunity.com/groups/tntexplosivegaming"
    }
		for i, line in pairs(serverInfo) do
			frame.add{name=i, type="label", caption={"", line}}
		end
	end)
addTab('Readme','How to chat','Just in case you dont know how to chat',
	function(player,frame)
		local chat = {
				"Chatting for new players can be difficult because it’s different than other games!",
				"It’s very simple, the button you need to press is the “GRAVE/TILDE key”",
				"it’s located under the “ESC key”. If you would like to change the key go to your",
				"controls tab in options. The key you need to change is “Toggle Lua console”",
				"it’s located in the second column 2nd from bottom."}
		for i, line in pairs(chat) do
			frame.add{name=i, type="label", caption={"", line}}
		end
	end)
addTab('Readme','Admins','List of all the people who can ban you :P',
	function(player,frame)
		local admins = {
			"This list contains all the people that are admin in this world. Do you want to become",
			"an admin dont ask for it! an admin will see what you've made and the time you put",
			"in the server."}
		for i, line in pairs(admins) do
			frame.add{name=i, type="label", caption={"", line}}
		end
		drawPlayerTable(player, frame, false, {'admin'})
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
---------------------------Modifier Gui-------------------------------------------------
----------------------------------------------------------------------------------------
addFrame('Admin')

addButton('btn_toolbar_automessage',function() autoMessage() end)
addButton('revive_dead_entitys',function(player,frame) for key, entity in pairs(game.surfaces[1].find_entities_filtered({type = "entity-ghost"})) do entity.revive() end end)
addButton('revive_dead_entitys_range',function(player,frame) if tonumber(frame.parent.range.text) then local range = tonumber(frame.parent.range.text) for key, entity in pairs(game.surfaces[1].find_entities_filtered({area={{player.position.x-range,player.position.y-range},{player.position.x+range,player.position.y+range}},type = "entity-ghost"})) do entity.revive() end end end)
addButton('remove_biters',function(player,frame) for key, entity in pairs(game.surfaces[1].find_entities_filtered({force='enemy'})) do entity.destroy() end end)
addButton('tp_all',function(player,frame) for i,p in pairs(game.connected_players) do local pos = game.surfaces[player.surface.name].find_non_colliding_position("player", player.position, 32, 1) if p ~= player then p.teleport(pos) end end end)
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
					player.print(modifier .. " needs to be a higher number or it contains an letter")
				end
			end
		end
	end)
	
addTab('Admin', 'Commands', 'Random useful commands', 
	function(player, frame)
		drawButton(frame,'btn_toolbar_automessage','Auto Message','Send the auto message to all online players')
		drawButton(frame,'revive_dead_entitys','Revive All Entitys','Brings all dead machines back to life')
		drawButton(frame,'revive_dead_entitys_range','Revive Entitys','Brings all dead machines back to life in a range')
		frame.add{type='textfield',name='range',text='Range'}
		drawButton(frame,'remove_biters','Kill Biters','Removes all biters in map')
		drawButton(frame,'tp_all','TP All Here','Brings all players to you')
		drawButton(frame,'toggle_cheat','Toggle Cheat Mode','Toggle your cheat mode')
	end)
addTab('Admin', 'Modifiers', 'Edit in game modifiers',
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
    frame.modifierTable.add{name="name", type="label", caption="name"}
    frame.modifierTable.add{name="input", type="label", caption="input"}
    frame.modifierTable.add{name="current", type="label", caption="current"}
    for i, modifier in pairs(forceModifiers) do
      frame.modifierTable.add{name=modifier, type="label", caption=modifier}
      frame.modifierTable.add{name=modifier .. "_input", type="textfield", caption="inputTextField"}
      frame.modifierTable.add{name=modifier .. "_current", type="label", caption=tostring(player.force[modifier])}
    end
    drawButton(frame.flowNavigation,"btn_Modifier_apply","Apply","Apply the new values to the game")
end)
addTab('Admin', 'Player List', 'Send a message to all players', 
	function(player, frame)
		frame.add{name='filterTable',type='table',colspan=2}
		frame.filterTable.add{name='name_label',type='label',caption='Name'}
		frame.filterTable.add{name='hours_label',type='label',caption='Online Time (minutes)'}
		frame.filterTable.add{name='name_input',type='textfield'}
		frame.filterTable.add{name='hours_input',type='textfield'}
		drawPlayerTable(player, frame, true, {'online'})
	end)