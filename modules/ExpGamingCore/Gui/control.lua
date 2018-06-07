--- Adds a objective version to custom guis.
-- @module ExpGamingCore.Gui
-- @alias Gui
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Gui = {}
local Gui_data = {}

--- Stores all the on_player_joined_game event handlers for the guis
-- @table events
Gui.events = {join={},rank={}}

--- Used to set and get data about different guis
-- @usage Gui.data[location] -- returns the gui data for that gui location ex center
-- @usage Gui.data(location,gui_name,gui_data) -- adds gui data for a gui at a location
-- @tparam string location the location to get/set the data, center left etc...
-- @tparam[opt] string key the name of the gui to set the value of
-- @param[opt] value the data that will be set can be any value but table advised
-- @treturn[1] table all the gui data that is locationed in that location
Gui.data = setmetatable({},{
    __call=function(tbl,location,key,value)
        if not location then return tbl end
        if not key then return rawget(tbl,location) or rawset(tbl,location,{}) and rawget(tbl,location) end
        if game then error('New guis cannot be added during runtime',2) end
        if not rawget(tbl,location) then rawset(tbl,location,{}) end
        rawset(rawget(tbl,location),key,value)
    end
})

-- loaded the different gui parts, each is its own module for ldoc reasons
local join, rank
Gui.center, join, rank = require(module_path..'/src/center')
table.insert(Gui.events.join,event) table.insert(Gui.events.rank,rank)
Gui.inputs, event  = require(module_path..'/src/inputs')
table.insert(Gui.events.join,event) table.insert(Gui.events.rank,rank)
Gui.left, event  = require(module_path..'/src/left')
table.insert(Gui.events.join,event) table.insert(Gui.events.rank,rank)
Gui.popup, event  = require(module_path..'/src/popup')
table.insert(Gui.events.join,event) table.insert(Gui.events.rank,rank)
Gui.toolbar, event  = require(module_path..'/src/toolbar')
table.insert(Gui.events.join,event) table.insert(Gui.events.rank,rank)
join, rank = nil, nil

--- Add a white bar to any gui frame
-- @usage Gui.bar(frame,100)
-- @param frame the frame to draw the line to
-- @param[opt=10] width the width of the bar
-- @return the line that was made type is progressbar
function Gui.bar(frame,width)
    local line = frame.add{
        type='progressbar',
        size=1,
        value=1
    }
    line.style.height = 3
    line.style.width = width or 10
    line.style.color = defines.color.white
    return line
end

--- Used to set the index of a drop down to a certian item
-- @usage Gui.set_dropdown_index(dropdown,player.name) -- will select the index with the players name as the value
-- @param dropdown the dropdown that is to be effected
-- @param _item this is the item to look for
-- @return returns the dropdown if it was successful
function Gui.set_dropdown_index(dropdown,_item)
    if dropdown and dropdown.valid and dropdown.items and _item then else return end
    local _index = 1
    for index, item in pairs(dropdown.items) do
        if item == _item then _index = index break end
    end
    dropdown.selected_index = _index
    return dropdown
end

function Gui:on_init()
    if loaded_modules.Server then verbose('ExpGamingCore.Server is installed; Loading server src') require(module_path..'/src/server') end
    if loaded_modules.Ranking then
        verbose('ExpGamingCore.Ranking is installed; Loading ranking src')
        script.on_event('on_player_joined_game',function(event)
            for _,callback in pairs(Gui.events.rank) do callback(event) end
        end)
    end  
end

function Gui:on_post()
    Gui.test = require(module_path..'/src/test')
end

--- Prams for Gui.cam_link
-- @table ParametersForCamLink
-- @field entity this is the entity that the camera will follow
-- @field cam a camera that you already have in the gui
-- @field frame the frame to add the camera to, no effect if cam param is given
-- @field zoom the zoom to give the new camera
-- @field width the width to give the new camera
-- @field height the height to give the new camera
-- @field surface this will over ride the surface that the camera follows on, allowing for a 'ghost surface' while keeping same position
-- @field respawn_open if set to true then the camera will auto re link to the player after a respawn

--- Adds a camera that updates every tick (or less depeading on how many are opening) it will move to follow an entity
-- @usage Gui.cam_link{entity=game.player.character,frame=frame,width=50,hight=50,zoom=1}
-- @usage Gui.cam_link{entity=game.player.character,cam=frame.camera,surface=game.surfaces['testing']}
-- @tparam table data contains all other params given below
-- @return the camera that the function used be it made or given as a param 
function Gui.cam_link(data)
    if not data.entity or not data.entity.valid then return end
    if is_type(data.cam,'table') and data.cam.__self and data.cam.valid then
        data.cam = data.cam
    elseif data.frame then
        data.cam={}
        data.cam.type='camera'
        data.cam.name='camera'
        data.cam.position= data.entity.position
        data.cam.surface_index= data.surface and data.surface.index or data.entity.surface.index
        data.cam.zomm = data.zoom
        data.cam = data.frame.add(data.cam)
        data.cam.style.width = data.width or 100
        data.cam.style.height = data.height or 100
    else return end
    if not Server or not Server._thread or not Server.get_thread('camera-follow') then
        if not global().cams then
            global().cams = {}
            global().cam_index = 1
        end
        if data.cam then
            local surface = data.surface and data.surface.index or nil
            table.insert(global().cams,{cam=data.cam,entity=data.entity,surface=surface})
        end
        if not global().players then
            global().players = {}
        end
        if data.respawn_open then
            if data.entity.player then
                if not global().players[data.entity.player.index] then global().players[data.entity.player.index] = {} end
                table.insert(global().players[data.entity.player.index],data.cam)
            end
        end
    else
        local thread = Server.get_thread('camera-follow')
        local surface = data.surface and data.surface.index or nil
        table.insert(thread.data.cams,{cam=data.cam,entity=data.entity,surface=surface})
        if data.respawn_open then
            if data.entity.player then
                if not thread.data.players[data.entity.player.index] then thread.data.players[data.entity.player.index] = {} end
                table.insert(thread.data.players[data.entity.player.index],data.cam)
            end
        end
    end
    return data.cam
end

script.on_event('on_player_joined_game',function(event)
    for _,callback in pairs(Gui.events.join) do callback(event) end
end)

script.on_event('on_tick', function(event)
	if Gui.left and ((event.tick+10)/(3600*game.speed)) % 15 == 0 then
		Gui.left.update()
    end
    if global().cams and is_type(global().cams,'table') and #global().cams > 0 then
        local _cam = global().cams[global().cam_index]
        if not _cam then global().cam_index = 1 _cam = global().cams[global().cam_index] end
        if not _cam then return end
        if not _cam.cam.valid then table.remove(global().cams,global().cam_index)
        elseif not _cam.entity.valid then table.remove(global().cams,global().cam_index)
        else _cam.cam.position = _cam.entity.position if not _cam.surface then _cam.cam.surface_index = _cam.entity.surface.index end global().cam_index = global().cam_index+1
        end
    end
end)

script.on_event('on_player_respawned',function(event)
    if global().players and is_type(global().players,'table') and #global().players > 0 and global().players[event.player_index] then
        local remove = {}
        for index,cam in pairs(global().players[event.player_index]) do
            Gui.cam_link{cam=cam,entity=Game.get_player(event).character}
            if not cam.valid then table.insert(remove,index) end
        end
        for _,index in pairs(remove) do
            table.remove(global().players[event.player_index],index)
        end
    end
end)

return Gui