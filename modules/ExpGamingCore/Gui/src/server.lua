--- Adds a objective version to custom guis.
-- @submodule ExpGamingCore.Gui
-- @alias Gui
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

--- This file will be loaded when ExpGamingCore.Commands is present
-- @function _comment

--- Adds a server thread that allows the camera follows to be toggled off and on
-- @function __comment
script.on_event(-1,function(event)
    Server.new_thread{
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
    end):open()
end)