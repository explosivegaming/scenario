--- This file will be loaded when ExpGamingCore.Server is present
-- @function _comment

local Game = require('FactorioStdLib.Game@^0.8.0')
local Server = require('ExpGamingCore.Server@^4.0.0')

Server.add_module_to_interface('ExpGui','ExpGamingCore.Gui')

--- Adds a server thread that allows the camera follows to be toggled off and on
return function(event)
    Server.new_thread{
        name='camera-follow',
        data={cams={},cam_index=1,players={}}
    }:on_event('tick',function(self)
        local update = 4
        if self.data.cam_index >= #self.data.cams then self.data.cam_index = 1 end
        if update > #self.data.cams then update = #self.data.cams end
        for cam_offset = 0,update do
            local _cam = self.data.cams[self.data.cam_index+cam_offset]
            if not _cam then break end
            if not _cam.cam.valid then table.remove(self.data.cams,self.data.cam_index)
            elseif not _cam.entity.valid then table.remove(self.data.cams,self.data.cam_index)
            else _cam.cam.position = _cam.entity.position if not _cam.surface then _cam.cam.surface_index = _cam.entity.surface.index end
            end
        end
        self.data.cam_index = self.data.cam_index+update
    end):on_event('error',function(self,err)
        -- posible error handling if needed
        error(err)
    end):on_event(defines.events.on_player_respawned,function(self,event)
        if self.data.players[event.player_index] then
            local remove = {}
            local player = Game.get_player(event)
            for index,cam in pairs(self.data.players[event.player_index]) do
                if cam.valid then table.insert(self.data.cams,{cam=cam,entity=player.character,surface=player.surface})
                else table.insert(remove,index) end
            end
            for n,index in pairs(remove) do
                table.remove(self.data.players[event.player_index],index-n+1)
            end
        end
    end):open()
end