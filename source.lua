
entityRemoved = {}
entityCache = {}
guis = {frames={},buttons={}}
--functions can not be included in the default list or be added by code
defaults = {
	itemRotated = {},
	ranks={
	{name='Owner',shortHand='Owner',tag='[Owner]',power=0,colour={r=170,g=0,b=0}},
	{name='Community Manager',shortHand='CM',tag='[Com Mngr]',power=1,colour={r=150,g=68,b=161}},
	{name='Developer',shortHand='Dev',tag='[Dev]',power=1,colour={r=179,g=125,b=46}},
	{name='Admin',shortHand='Admin',tag='[Admin]',power=2,colour={r=170,g=41,b=170}},
	{name='Mod',shortHand='Mod',tag='[Mod]',power=3,colour={r=233,g=63,b=233}},
	{name='Donator',shortHand='P2W',tag='[P2W]',power=4,colour={r=233,g=63,b=233}},
	{name='Member',shortHand='Mem',tag='[Member]',power=5,colour={r=24,g=172,b=188}},
	{name='Regular',shortHand='Reg',tag='[Regukar]',power=5,colour={r=24,g=172,b=188}},
	{name='Guest',shortHand='',tag='[Guest]',power=6,colour={r=255,g=159,b=27}},
	{name='Jail',shortHand='Jail',tag='[Jail]',power=7,colour={r=170,g=0,b=0}}
	},
	autoRanks={
	Owner={'badgamernl'},
	['Community Manager']={'arty714'},
	Developer={'Cooldude2606'},
	Admin={'eissturm','PropangasEddy'},
	Mod={'Alanore','Aquaday','cafeslacker','CrashKonijn','Drahc_pro','Flip','freek18','Hobbitkicker','hud','Matthias','MeDDish','Mindxt20','MottledPetrel','Mr_Happy_212','Phoenix27833','Sand3r205','ScarbVis','Smou','steentje77','TopHatGaming123'},
	Donator={},
	Member={},
	Regular={},
	Guest={},
	Jail={}
	},
	selected={}
}

warningAllowed = nil
timeForRegular = 180
CHUNK_SIZE = 32

function loadVar(t)
	if t == nil then
		local g = nil
		if game.players[1].gui.left.hidden then 
			g = game.players[1].gui.left.hidden.caption 
		else 
			g = game.players[1].gui.left.add{type='frame',name='hidden',caption=table.tostring(defaults)}.caption
			game.players[1].gui.left.hidden.style.visible = false
		end
		gTable = loadstring('return '..g)()
	else gTable = t end
	itemRotated = gTable.itemRotated
	ranks= gTable.ranks
	autoRanks= gTable.autoRanks
	selected= gTable.selected
end

function saveVar()
	gTable.itemRotated = itemRotated
	gTable.ranks = ranks
	gTable.autoRanks = autoRanks
	selected= gTable.selected
	game.players[1].gui.left.hidden.caption = table.tostring(gTable)
end
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
    callRank("Decoratives have been removed")
end

script.on_event(defines.events.on_chunk_generated, function(event)
	removeDecorationsArea( event.surface, event.area )
end)
----------------------------------------------------------------------------------------
---------------------------Rank functions-----------------------------------------------
----------------------------------------------------------------------------------------
function getRank(player)
	if player then
		for _,rank in pairs(ranks) do
			if player.tag == rank.tag then return rank end
		end
		return stringToRank('Guest')
	end
end

function stringToRank(string)
	if type(string) == 'string' then
		for _,rank in pairs(ranks) do 
			if rank.name == string then return rank end
		end
	end
end

function callRank(msg, rank, inv)
	local rank = stringToRank(rank) or stringToRank('Mod') -- default mod or higher
	local inv = inv or false
	for _, player in pairs(game.players) do 
		rankPower = getRank(player).power
		if inv then if rankPower >= rank.power then player.print(msg) end else
			if rankPower <= rank.power then 
				if rank.shortHand then 
					player.print(('['..(rank.shortHand)..']: '..msg))
				else
					player.print(('[Everyone]: '..msg))
				end
		end
	end
end

function giveRank(player,rank,byPlayer)
	local byPlayer = byPlayer or 'system'
	oldRank = getRank(player)
	local message = 'demoted'
	if rank.power <= oldRank.power then message = 'promoted' end
	callRank(player.name..' was '..message..' to '..rank.name..' by '..byPlayer.name,oldRank.name)
	player.tag = rank.tag
	drawToolbar(player)
	drawPlayerList()
end

function autoRank(player)
	local currentRank = getRank(player)
	local playerAutoRank = nil
	for rank,players in pairs(autoRanks) do
		local Break = false
		for _,p in pairs(players) do
			if player.name == p then playerAutoRank = stringToRank(rank) Break = true break end
		end
		if Break then break end
	end
	if playerAutoRank then
		if currentRank.power > playerAutoRank.power then
			player.tag=playerAutoRank.tag
		end
	elseif ticktominutes(player.online_time) >= timeForRegular then
		player.tag=stringToRank('Regular').tag
	end
	if getRank(player).power <= 3 and not player.admin then
		callRank(player.name..' needs to be promoted.')
	end
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
	selected[player.index] = {}
end

function autoMessage()
	rank = stringToRank('Regular')
	hrank = stringToRank('Mod')
	callRank('There are '..#game.connected_players..' players online',hrank,true)
	callRank('This map has been on for '..ticktohour(game.tick)..' Hours and '..(ticktominutes(game.tick)-60*ticktohour(game.tick))..' Minutes',hrank,true)
	callRank('Please join us on:',rank,true)
	callRank('Discord: https://discord.gg/RPCxzgt',rank,true)
	callRank('Forum: explosivegaming.nl',rank,true)
	callRank('Steam: http://steamcommunity.com/groups/tntexplosivegaming',rank,true)
	callRank('To see these links again goto: Readme > Server Info',rank,true)
end
----------------------------------------------------------------------------------------
---------------------------Table Functions----------------------------------------------
----------------------------------------------------------------------------------------
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
function addFrame(frame,rank,open,caption,tooltip)
	guis.frames[frame] = {{require=rank,caption=caption,tooltip=tooltip}}
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

function drawButton(frame, btnName, caption, describtion)
	frame.add{name=btnName, type = "button", caption=caption, tooltip=describtion}
end

function openTab(player, frameName, tab, tabName)
	local tabBar = player.gui.center[frameName].tabBarScroll.tabBar
	for _,t in pairs(guis.frames[frameName]) do
		if _ ~= 1 then
			if t[1] == tabName then
				tabBar[t[1]].style.font_color = {r = 255, g = 255, b = 255, player = 255}
				clearElement(tab)
				t[3](player, tab)
			else
				tabBar[t[1]].style.font_color = {r = 100, g = 100, b = 100, player = 255}
			end
		end
	end
end

function drawFrame(player, frameName, tabName)
	if getRank(player).power <= guis.frames[frameName][1].require then
		if player.gui.center[frameName] then player.gui.center[frameName].destroy() end
		local frame = player.gui.center.add{name=frameName,type='frame',caption=frameName,direction='vertical'}
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
  player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
end)

script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.players[event.player_index]
	drawPlayerList()
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
end)

script.on_event(defines.events.on_player_joined_game, function(event)
	loadVar()
  local player = game.players[event.player_index]
	autoRank(player)
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
  drawToolbar(player)
  local playerStringTable = encode(game.players, "players", {"name", "admin", "online_time", "connected", "index"})
  game.write_file("players.json", playerStringTable, false, 0)
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
	if event.element.type == 'button' then
		for _,btn in pairs(guis.buttons) do
			if btn[1] == event.element.name then
				if btn[2] then btn[2](player,event.element) else game.print('Invaid Button'..btn[1]) end
				break
			end
		end
	elseif event.element.type == 'checkbox' then
		if event.element.name == 'select' then
			if not selected[event.player_index] then selected[event.player_index] = {} end
			if event.element.state then
				table.insert(selected[event.player_index],event.element.parent.name)
			else
				for _,name in pairs(selected[event.player_index]) do
					if name == event.element.parent.name then table.remove(selected[event.player_index],_) break end
				end
			end
		end
	end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
	local player = game.players[event.player_index]
	if event.element.parent.name == 'filterTable' then
		local frame = event.element
		local filters = {}
		local commands = false
		local select = false
		if frame.parent.parent.parent.name == 'Admin' and not frame.parent.sel_input then commands = true filters[#filters+1] = 'online' end
		if frame.parent.parent.parent.name == 'Admin' and frame.parent.sel_input then select = true filters[#filters+1] = 'lower' end
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
		end if frame.parent.parent.filterTable.sel_input then
			local sel_input =  frame.parent.parent.filterTable.sel_input.text
			if sel_input == 'yes' or sel_input == 'online' or sel_input == 'true' or sel_input == 'y' then filters[#filters+1] = 'selected' end
		end
		if frame.parent.parent.playerTable then frame.parent.parent.playerTable.destroy() end
		drawPlayerTable(player, frame.parent.parent, commands, select, filters)
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
      eplayer.print("You are not allowed to do this yet, play for player bit longer. Try again in about: " .. math.floor((timeForRegular - ticktominutes(eplayer.online_time))) .. " minutes")
      callRank(eplayer.name .. " tryed to deconstruced something")
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
			eplayer.print("You are not allowed to do this yet, play for player bit longer. Try: " .. math.floor((timeForRegular - ticktominutes(eplayer.online_time))) .. " minutes")
			callRank(eplayer.name .. " tryed to place concrete/stone with robots")
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

script.on_event(defines.events.on_tick, function(event) if (game.tick/(3600*game.speed)) % 15 == 0 then autoMessage() end end)
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
function drawToolbar(player)
  local frame = player.gui.top
  clearElement(frame)
	drawButton(frame,"btn_toolbar_playerList", "Playerlist", "Adds player player list to your game.")
	drawButton(frame,"btn_toolbar_rocket_score", "Rocket score", "Show the satellite launched counter if player satellite has launched.")
	for _,f in pairs(guis.frames) do
		if getRank(player).power <= f[1].require then drawButton(frame,"btn_".._, f[1].caption, f[1].tooltip) end
  end
end
----------------------------------------------------------------------------------------
---------------------------Player List--------------------------------------------------
----------------------------------------------------------------------------------------
function drawPlayerList()
  for i, player in pairs(game.connected_players) do
    if  player.gui.left.PlayerList == nil then
      player.gui.left.add{type = "frame", name= "PlayerList", direction = "vertical"}
                .add{type = "scroll-pane", name= "PlayerListScroll", direction = "vertical", vertical_scroll_policy="always", horizontal_scroll_policy="never"}
    end
		Plist= player.gui.left.PlayerList.PlayerListScroll
    clearElement(Plist)
    Plist.style.maximal_height = 200
    for i, player in pairs(game.connected_players) do
			if player.character then
				if player.tag == '[Jail]' or player.character.active == false then
					player.character.active = false
					player.tag = '[Jail]'
				end
			end
			playerRank = getRank(player)
			if playerRank.power <= 3 then
				if playerRank.shortHand ~= '' then Plist.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , ' - '..playerRank.shortHand}}
				else Plist.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name}} end				
				Plist[player.name].style.font_color = playerRank.colour
				player.tag = playerRank.tag
			end
    end
		for i, player in pairs(game.connected_players) do
			playerRank = getRank(player)
			if playerRank.power > 3 then
				if playerRank.shortHand ~= '' then Plist.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , ' - '..playerRank.shortHand}}
				else Plist.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name}} end
				Plist[player.name].style.font_color = playerRank.colour
				player.tag = playerRank.tag
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
function drawPlayerTable(player, frame, commands, select,filters)
	if frame.playerTable then frame.playerTable.destroy() end
	frame.add{name='playerTable', type="table", colspan=5}
  frame.playerTable.style.minimal_width = 500
  frame.playerTable.style.maximal_width = 500
	frame.playerTable.style.horizontal_spacing = 10
  frame.playerTable.add{name="id", type="label", caption="Id		"}
  frame.playerTable.add{name="name", type="label", caption="Name		"}
  if commands==false and select ==false then frame.playerTable.add{name="status", type="label", caption="Status		"} end
  frame.playerTable.add{name="online_time", type="label", caption="Online Time	"}
  frame.playerTable.add{name="rank", type="label", caption="Rank	"}
	if commands then frame.playerTable.add{name="commands", type="label", caption="Commands"} end
	if select then frame.playerTable.add{name="select_label", type="label", caption="Selection"} end
  for i, p in pairs(game.players) do
    local addPlayer = true
    for _,filter in pairs(filters) do
      if filter == 'admin' then if p.admin == false then addPlayer = false break end
			elseif filter == 'online' then if p.connected == false then addPlayer = false break end
			elseif filter == 'offline' then if p.connected == true then addPlayer = false break end
			elseif filter == 'lower' then if getRank(p).power <= getRank(player).power then addPlayer = false break end
			elseif filter == 'selected' then local Break = nil for _,name in pairs(selected[player.index]) do if name == p.name then Break = true break end end if not Break then addPlayer = false break end
			elseif type(filter)=='number' then if filter > ticktominutes(p.online_time) then addPlayer = false break end
			elseif type(filter)=='string' then if p.name:lower():find(filter:lower()) == nil then addPlayer = false break end
		end
	end
    if addPlayer == true and player.name ~= p.name then
      if frame.playerTable[p.name] == nil then
        frame.playerTable.add{name=i .. "id", type="label", caption=i}
        frame.playerTable.add{name=p.name..'_name', type="label", caption=p.name}
				if not commands and not select then 
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
					drawButton(frame.playerTable[p.name],'bring','Br','Bring player player to your location')
					if getRank(p).power >= getRank(player).power then
						drawButton(frame.playerTable[p.name],'jail','Ja','Jail/Unjail player player')
						drawButton(frame.playerTable[p.name],'kill','Ki','Kill this player')
					end
				elseif select then
					frame.playerTable.add{name=p.name, type="flow"}
					local state = false
					for _,name in pairs(selected[player.index]) do if name == p.name then state = true break end end
					frame.playerTable[p.name].add{name='select', type="checkbox",state=state}
				end
      end
    end
  end
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
			"Do not remove/move major parts of the factory without permission.",
			"Do not walk in player random direction for no reason(to save map size).",
			"Do not remove stuff just because you don't like it, tell people first.",
			"Do not make train roundabouts.",
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
		drawPlayerTable(player, frame, false, false,{'admin'})
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
		drawPlayerTable(player, frame, false, false, {})
	end)
----------------------------------------------------------------------------------------
---------------------------Admin Gui----------------------------------------------------
----------------------------------------------------------------------------------------
addFrame('Admin',2,'Player List','Admin',"All admin fuctions are here")

addButton('btn_toolbar_automessage',function() autoMessage() end)
addButton('tp_all',function(player,frame) for i,p in pairs(game.connected_players) do local pos = game.surfaces[player.surface.name].find_non_colliding_position("player", player.position, 32, 1) if p ~= player then p.teleport(pos) end end end)
addButton('revive_dead_entitys_range',function(player,frame) if tonumber(frame.parent.range.text) then local range = tonumber(frame.parent.range.text) for key, entity in pairs(game.surfaces[1].find_entities_filtered({area={{player.position.x-range,player.position.y-range},{player.position.x+range,player.position.y+range}},type = "entity-ghost"})) do entity.revive() end end end)
addButton('add_dev_items',function(player,frame) player.insert{name="deconstruction-planner", count = 1} player.insert{name="blueprint-book", count = 1} player.insert{name="blueprint", count = 20} end)
addButton('sendMessage',function(player,frame) local rank = stringToRank(frame.parent.message.rank.text) if rank then callRank(frame.parent.message.message.text,rank.name) else for _,rank in pairs(ranks) do player.print(rank.name) end  end)
addButton('setRanks',player.print(frame.parent.rank_input.text..' is not a Rank, Ranks are:') 
	function(player,frame) 
		rank = stringToRank(frame.parent.rank_input.text) 
		if rank then 
			for _,playerName in pairs(selected[player.index]) do 
				p=game.players[playerName] 
				if getRank(player).power < getRank(p).power and rank.power > getRank(player).power then 
					giveRank(p,rank,player) 
				else 
					player.print('You can not edit '..p.name.."'s rank there rank is too high (or the rank you have slected is above you)") 
				end 
			end 
		else 
			player.print(frame.parent.rank_input.text..' is not a Rank, Ranks are:') for _,rank in pairs(ranks) do if rank.power > getRank(player).power then player.print(rank.name) end end 
		end
	end)
addButton('clearSelection',function(player,frame) clearSelection(player) drawPlayerTable(player, frame.parent.parent, false, true, {}) end)

addTab('Admin', 'Commands', 'Random useful commands', 
	function(player, frame)
		drawButton(frame,'btn_toolbar_automessage','Auto Message','Send the auto message to all online players')
		drawButton(frame,'add_dev_items','Get Blueprints','Get all the blueprints')
		drawButton(frame,'revive_dead_entitys_range','Revive Entitys','Brings all dead machines back to life in player range')
		frame.add{type='textfield',name='range',text='Range'}
		frame.add{type='flow',name='message'}
		frame.message.add{type='textfield',name='message',text='Enter message'}
		frame.message.add{type='textfield',name='rank',text='Endter rank'}
		drawButton(frame,'sendMessage','Send Message','Send a message to all ranks higher than the slected')
		drawButton(frame,'tp_all','TP All Here','Brings all players to you')
	end)
addTab('Admin','Edit Ranks', 'Edit the ranks of players below you',
	function(player,frame)
		clearSelection(player)
		frame.add{name='filterTable',type='table',colspan=2}
		frame.filterTable.add{name='name_label',type='label',caption='Name'}
		frame.filterTable.add{name='sel_label',type='label',caption='Selected?'}
		frame.filterTable.add{name='name_input',type='textfield'}
		frame.filterTable.add{name='sel_input',type='textfield'}
		frame.add{type='flow',name='rank',direction='horizontal'}
		frame.rank.add{name='rank_label',type='label',caption='Rank'}
		frame.rank.add{name='rank_input',type='textfield'}
		drawButton(frame.rank,'setRanks','Set Ranks','Sets the rank of all selected players')
		drawButton(frame.rank,'clearSelection','Clear Selection','Clears all currently selected players')
		drawPlayerTable(player, frame, false, true, {'lower'})
	end)
addTab('Admin', 'Player List', 'Send player message to all players', 
	function(player, frame)
		frame.add{name='filterTable',type='table',colspan=2}
		frame.filterTable.add{name='name_label',type='label',caption='Name'}
		frame.filterTable.add{name='hours_label',type='label',caption='Online Time (minutes)'}
		frame.filterTable.add{name='name_input',type='textfield'}
		frame.filterTable.add{name='hours_input',type='textfield'}
		drawPlayerTable(player, frame, true,false, {'online'})
	end)
----------------------------------------------------------------------------------------
---------------------------Admin+ Gui---------------------------------------------------
----------------------------------------------------------------------------------------
addFrame('Admin+',1,'Modifiers','Admin+',"Because we are better")

addButton('remove_biters',function(player,frame) for key, entity in pairs(game.surfaces[1].find_entities_filtered({force='enemy'})) do entity.destroy() end end)
addButton('toggle_cheat',function(player,frame) player.cheat_mode = not player.cheat_mode end)
addButton('revive_dead_entitys',function(player,frame) for key, entity in pairs(game.surfaces[1].find_entities_filtered({type = "entity-ghost"})) do entity.revive() end end)
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
		drawButton(frame,'btn_toolbar_automessage','Auto Message','Send the auto message to all online players')
		drawButton(frame,'add_dev_items','Get Blueprints','Get all the blueprints')
		drawButton(frame,'revive_dead_entitys','Revive All Entitys','Brings all dead machines back to life')
		drawButton(frame,'revive_dead_entitys_range','Revive Entitys','Brings all dead machines back to life in player range')
		frame.add{type='textfield',name='range',text='Range'}
		drawButton(frame,'remove_biters','Kill Biters','Removes all biters in map')
		drawButton(frame,'tp_all','TP All Here','Brings all players to you')
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