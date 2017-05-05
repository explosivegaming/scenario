require("silo-script")
require "mod-gui"
local version = 1
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
	{name='Member',shortHand='Mem',tag='[Member]',power=5,colour={r=24,g=172,b=188},disallow={'set_allow_commands','server_command','edit_permission_group','delete_permission_group','add_permission_group'}},
	{name='Regular',shortHand='Reg',tag='[Regular]',power=5,colour={r=24,g=172,b=188},disallow={'set_auto_launch_rocket','change_programmable_speaker_alert_parameters','reset_assembling_machine','drop_item','set_allow_commands','server_command','edit_permission_group','delete_permission_group','add_permission_group'}},
	{name='Guest',shortHand='',tag='[Guest]',power=6,colour={r=255,g=159,b=27},disallow={'build_terrain','remove_cables','launch_rocket','cancel_research','set_auto_launch_rocket','change_programmable_speaker_alert_parameters','reset_assembling_machine','drop_item','set_allow_commands','server_command','edit_permission_group','delete_permission_group','add_permission_group'}},
	{name='Jail',shortHand='Jail',tag='[Jail]',power=7,colour={r=50,g=50,b=50},disallow={'open_character_gui','begin_mining','start_walking','player_leave_game','build_terrain','remove_cables','launch_rocket','cancel_research','set_auto_launch_rocket','change_programmable_speaker_alert_parameters','reset_assembling_machine','drop_item','set_allow_commands','server_command','edit_permission_group','delete_permission_group','add_permission_group'}}
	},
	autoRanks={
	Owner={'badgamernl'},
	['Community Manager']={'arty714'},
	Developer={'Cooldude2606'},
	Admin={'eissturm','PropangasEddy'},
	Mod={'Alanore','Aquaday','cafeslacker','CrashKonijn','Drahc_pro','FlipHalfing90','freek18','Hobbitkicker','hud','Koroto','Matthias','MeDDish','Mindxt20','MottledPetrel','Mr_Happy_212','Phoenix27833','samy115','Sand3r205','scarbvis','Smou','steentje77','tophatgaming123'},
	Donator={},
	Member={},
	Regular={},
	Guest={},
	Jail={}
	},
	selected={},
	oldRanks={}
}

warningAllowed = nil
timeForRegular = 180
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
	drawToolbar(player)
	drawPlayerList()
	global.oldRanks[player.index]=oldRank.name
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
		if ticktominutes(player.online_time) >= timeForRegular then playerAutoRank = stringToRank('Regular')
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
		if player.gui.center[frameName] then player.gui.center[frameName].destroy() end
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
end)

script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.players[event.player_index]
	drawPlayerList()
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
end)

script.on_event(defines.events.on_player_joined_game, function(event)
	--runs when the first player joins to make the permission groups
	if #game.players == 1 and global.ranks == nil then
		for name,value in pairs(defaults) do global[name] = value end
		for _,rank in pairs(global.ranks) do
			game.permissions.create_group(rank.name)
			for _,toRemove in pairs(rank.disallow) do
				game.permissions.get_group(rank.name).set_allows_action(defines.input_action[toRemove],false)
			end
		end
	end
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
	silo_script.on_gui_click(event)
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
		drawPlayerTable(player, frame.parent.parent, commands, select, filters)
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

script.on_event(defines.events.on_built_entity, function(event)
	local eplayer = game.players[event.player_index]
	local timeForRegular = 120
	if getRank(eplayer).power > 5 then
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
script.on_event(defines.events.on_tick, function(event) if (game.tick/(3600*game.speed)) % 15 == 0 then autoMessage() end end)
----------------------------------------------------------------------------------------
---------------------------Tool Bar-----------------------------------------------------
----------------------------------------------------------------------------------------
addButton("btn_toolbar_playerList", function(player) toggleVisable(mod_gui.get_frame_flow(player).PlayerList) end)
function drawToolbar(player)
  local frame = mod_gui.get_button_flow(player)
  frame.clear()
	drawButton(frame,"btn_toolbar_playerList", "Playerlist", "Adds/removes the player list to/from your game.",'entity/player')
	for _,f in pairs(guis.frames) do
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
				if playerRank.shortHand ~= '' then Plist.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , ' - '..playerRank.shortHand..'		'}}
				else Plist.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name..'		'}} end				
				Plist[player.name].style.font_color = playerRank.colour
				player.tag = playerRank.tag
			end
    end
		for i, player in pairs(game.connected_players) do
			playerRank = getRank(player)
			if playerRank.power > 3 and playerRank.name ~= 'Jail' then
				if playerRank.shortHand ~= '' then Plist.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , ' - '..playerRank.shortHand..'		'}}
				else Plist.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name..'		'}} end
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
addButton('jail',function(player,frame) 
	local p=game.players[frame.parent.name] 
	if p.permission_group.name ~= 'Jail' then giveRank(p,'Jail',player) 
	else revertRank(p,player) end 
end)
addButton('kill',
	function(player,frame)
	local p = game.players[frame.parent.name]
	if p.character then p.character.die() end
end)
addButton('revert',
	function(player,frame)
	local p = game.players[frame.parent.name]
	revertRank(p,player)
end)
function drawPlayerTable(player, frame, commands, select,filters)
	--setup the table
	if frame.playerTable then frame.playerTable.destroy() end
	pTable = frame.add{name='playerTable', type="table", colspan=5}
  pTable.style.minimal_width = 500
  pTable.style.maximal_width = 500
	pTable.style.horizontal_spacing = 10
  pTable.add{name="id", type="label", caption="Id"}
  pTable.add{name="Pname", type="label", caption="Name"}
  if commands==false and select ==false then pTable.add{name="status", type="label", caption="Status"} end
  pTable.add{name="online_time", type="label", caption="Online Time"}
  pTable.add{name="rank", type="label", caption="Rank"}
	if commands then pTable.add{name="commands", type="label", caption="Commands"} end
	if select then pTable.add{name="select_label", type="label", caption="Selection"} end
	--filter checking
  for i, p in pairs(game.players) do
    local addPlayer = true
    for _,filter in pairs(filters) do
      if filter == 'admin' then if p.admin == false then addPlayer = false break end
			elseif filter == 'online' then if p.connected == false then addPlayer = false break end
			elseif filter == 'offline' then if p.connected == true then addPlayer = false break end
			elseif filter == 'lower' then if getRank(p).power <= getRank(player).power then addPlayer = false break end
			elseif filter == 'selected' then local Break = nil for _,name in pairs(global.selected[player.index]) do if name == p.name then Break = true break end end if not Break then addPlayer = false break end
			elseif type(filter)=='number' then if filter > ticktominutes(p.online_time) then addPlayer = false break end
			elseif type(filter)=='string' then if p.name:lower():find(filter:lower()) == nil then addPlayer = false break end
			end
		end
		--addes the player to the list
    if addPlayer == true and player.name ~= p.name then
      if pTable[p.name] == nil then
        pTable.add{name=i .. "id", type="label", caption=i}
        pTable.add{name=p.name..'_name', type="label", caption=p.name}
				--status
				if not commands and not select then 
					if p.connected == true 
					then pTable.add{name=p.name .. "Status", type="label", caption="ONLINE"}
					else pTable.add{name=p.name .. "Status", type="label", caption="OFFLINE"} 
					end
				end
				--time and rank
        pTable.add{name=p.name .. "Online_Time", type="label", caption=(ticktohour(p.online_time)..'H '..(ticktominutes(p.online_time)-60*ticktohour(p.online_time))..'M')}
        pTable.add{name=p.name .. "Rank", type="label", caption=getRank(p).shortHand}
				--commands
				if commands then
					pTable.add{name=p.name, type="flow"}
					drawButton(pTable[p.name],'goto','Tp','Goto to the players location')
					drawButton(pTable[p.name],'bring','Br','Bring player player to your location')
					if getRank(p).power > getRank(player).power then
						drawButton(pTable[p.name],'jail','Ja','Jail/Unjail player')
						drawButton(pTable[p.name],'revert','Re','Set A players rank to their forma one')
						drawButton(pTable[p.name],'kill','Ki','Kill this player')
					end
				--player slecction
				elseif select then
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
		local chat = "Chatting for new players can be difficult because it’s different than other games! It’s very simple, the button you need to press is the “GRAVE/TILDE” key it’s located under the “ESC key”. If you would like to change the key go to your controls tab in options. The key you need to change is “Toggle Lua console” it’s located in the second column 2nd from bottom."
		frame.add{name=i, type="label", caption={"", chat}, single_line=false}.style.maximal_width=480
	end)
addTab('Readme','Admins','List of all the people who can ban you :P',
	function(player,frame)
		local admins = {
			"This list contains all the people that are admin in this world. Do you want to become",
			"an admin dont ask for it! an admin will see what you've made and the time you put",
			"in the server."}
		for i, line in pairs(admins) do
			frame.add{name=i, type="label", caption={"", line}, single_line=false}
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
addFrame('Admin',3,'Player List','Admin',"All admin fuctions are here")

addButton('btn_toolbar_automessage',function() autoMessage() end)
addButton('tp_all',function(player,frame) for i,p in pairs(game.connected_players) do local pos = game.surfaces[player.surface.name].find_non_colliding_position("player", player.position, 32, 1) if p ~= player then p.teleport(pos) end end end)
addButton('revive_dead_entitys_range',function(player,frame) if tonumber(frame.parent.range.text) then local range = tonumber(frame.parent.range.text) for key, entity in pairs(game.surfaces[1].find_entities_filtered({area={{player.position.x-range,player.position.y-range},{player.position.x+range,player.position.y+range}},type = "entity-ghost"})) do entity.revive() end end end)
addButton('add_dev_items',function(player,frame) player.insert{name="deconstruction-planner", count = 1} player.insert{name="blueprint-book", count = 1} player.insert{name="blueprint", count = 20} end)
addButton('sendMessage',function(player,frame) local rank = stringToRank(frame.parent.message.rank.items[frame.parent.message.rank.selected_index]) if rank then callRank(frame.parent.message.message.text,rank.name) end end)
addButton('setRanks', 
	function(player,frame) 
		rank = stringToRank(frame.parent.rank_input.items[frame.parent.rank_input.selected_index]) 
		if rank then 
			for _,playerName in pairs(global.selected[player.index]) do 
				p=game.players[playerName] 
				if getRank(player).power < getRank(p).power and rank.power > getRank(player).power then 
					giveRank(p,rank,player)
					clearSelection(player) 
					drawPlayerTable(player, frame.parent.parent, false, true, {})
				else 
					player.print('You can not edit '..p.name.."'s rank there rank is too high (or the rank you have slected is above you)") 
				end 
			end 
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
		frame.message.add{type='drop-down',name='rank'}
		for _,rank in pairs(global.ranks) do if rank.power >= getRank(player).power then frame.message.rank.add_item(rank.name) end end
		frame.message.rank.selected_index = 1
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
		frame.rank.add{name='rank_input',type='drop-down'}
		for _,rank in pairs(global.ranks) do if rank.power > getRank(player).power then frame.rank.rank_input.add_item(rank.name) end end
		frame.rank.rank_input.selected_index = 1
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
addFrame('Admin+',2,'Modifiers','Admin+',"Because we are better")

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