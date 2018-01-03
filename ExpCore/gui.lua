--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]

local Gui = {}
local Gui_data = {}

-- only really used when parts of expcore are missing, or script debuging (ie to store the location of frames)
function Gui._global(reset)
    global.exp_core = not reset and global.exp_core or {}
    global.exp_core.gui = not reset and global.exp_core.gui or {}
    return global.exp_core.gui
end

-- this is to enforce the read only propetry of the gui
function Gui._add_data(key,value_key,value) 
    if game then return end 
    if not Gui_data[key] then Gui_data[key] = {} end
    Gui_data[key][value_key] = value
end

function Gui._get_data(key) return Gui_data[key] end

function Gui:_load_parts(parts)
    for _,part in pairs(parts) do
        self[part] = require('/GuiParts/'..part)
    end
end

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

local function _thread()
    local thread = Server.get_thread('camera-follow')
    if not thread then
        thread = Server.new_thread{
            name='camera-follow',
            data={cams={},cam_index=1,players={}}
        }:on_event('tick',function(self) 
            local _cam = self.data.cams[self.data.cam_index]
            if not _cam then self.data.cam_index = 1 _cam = self.data.cams[self.data.cam_index] end
            if not _cam then return end
            if not _cam.cam.valid then table.remove(self.data.cams,self.data.cam_index)
            elseif not _cam.entity.valid then table.remove(self.data.cams,self.data.cam_index)
            else _cam.cam.position = _cam.entity.position if not _cam.surface then _cam.cam.surface_index = _cam.entity.surface.index end self.data.cam_index = self.data.cam_index+1
            end
        end):on_event('error',function(self,err)
            -- posible error handling if needed
            error(err)
        end):on_event(defines.events.on_player_respawned,function(self,event)
            if self.data.players[event.player_index] then
                local remove = {}
                for index,cam in pairs(self.data.players[event.player_index]) do
                    Gui.cam_link{cam=cam,entity=Game.get_player(event).character}
                    if not cam.valid then table.insert(remove,index) end
                end
                for _,index in pairs(remove) do
                    table.remove(self.data.players[event.player_index],index)
                end
            end
        end)
        thread:open()
    end
    return thread
end
--- Adds a camera that updates every tick (or less depeading on how many are opening) it will move to follow an entity
-- @usage Gui.cam_link{entity=game.player.character,frame=frame,width=50,hight=50,zoom=1}
-- @usage Gui.cam_link{entity=game.player.character,cam=frame.camera,surface=game.surfaces['testing']}
-- @param entity this is the entity that the camera will follow
-- @param[opt] cam a camera that you already have in the gui
-- @param[opt] frame the frame to add the camera to, no effect if cam param is given
-- @param[chain=frame] zoom the zoom to give the new camera
-- @param[chain=frame] width the width to give the new camera
-- @param[chain=frame] height the height to give the new camera
-- @param[opt] surface this will over ride the surface that the camera follows on, allowing for a 'ghost surface' while keeping same position
-- @param[opt] respawn_open if set to true then the camera will auto re link to the player after a respawn
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
    if not Server or not Server._thread then
        if not Gui._global().cams then
            Gui._global().cams = {}
            Gui._global().cam_index = 1
        end
        if data.cam then
            local surface = data.surface and data.surface.index or nil
            table.insert(Gui._global().cams,{cam=data.cam,entity=data.entity,surface=surface})
        end
        if not Gui._global().players then
            Gui._global().players = {}
        end
        if data.respawn_open then
            if data.entity.player then
                if not Gui._global().players[data.entity.player.index] then Gui._global().players[data.entity.player.index] = {} end
                table.insert(Gui._global().players[data.entity.player.index],data.cam)
            end
        end
    else
        local thread = _thread()
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

Event.register(defines.events.on_tick, function(event)
	if (event.tick/(3600*game.speed)) % 15 == 0 then
		Gui.left.update()
    end
    if Gui._global().cams and is_type(Gui._global().cams,'table') and #Gui._global().cams > 0 then
        local _cam = Gui._global().cams[Gui._global().cam_index]
        if not _cam then Gui._global().cam_index = 1 _cam = Gui._global().cams[Gui._global().cam_index] end
        if not _cam then return end
        if not _cam.cam.valid then table.remove(Gui._global().cams,Gui._global().cam_index)
        elseif not _cam.entity.valid then table.remove(Gui._global().cams,Gui._global().cam_index)
        else _cam.cam.position = _cam.entity.position if not _cam.surface then _cam.cam.surface_index = _cam.entity.surface.index end Gui._global().cam_index = Gui._global().cam_index+1
        end
    end
end)

Event.register(defines.events.on_player_respawned,function(event)
    if Gui._global().players and is_type(Gui._global().players,'table') and #Gui._global().players > 0 and Gui._global().players[event.player_index] then
        local remove = {}
        for index,cam in pairs(Gui._global().players[event.player_index]) do
            Gui.cam_link{cam=cam,entity=Game.get_player(event).character}
            if not cam.valid then table.insert(remove,index) end
        end
        for _,index in pairs(remove) do
            table.remove(Gui._global().players[event.player_index],index)
        end
    end
end)

return Gui