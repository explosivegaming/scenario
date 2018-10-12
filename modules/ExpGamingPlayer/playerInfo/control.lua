--- Used to give so common info on a player as a lua table or a frame.
-- @module ExpGamingPlayer.playerInfo@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Game = require('FactorioStdLib.Game@^0.8.0')
local Gui = require('ExpGamingCore.Gui@^4.0.0')
local Role -- ExpGamingCore.Role@^4.0.0
local Group -- ExpGamingCore.Group@^4.0.0

local function get_player_info(player,frame,add_cam)
    local player = Game.get_player(player)
    if not player then return {} end
    local _player = {}
    _player.index = player.index
    _player.name = player.name
    _player.online = player.connected
    _player.tag = player.tag
    _player.color = player.color
    _player.admin = player.admin
    _player.online_time = player.online_time
    _player.group = player.permission_group.name
    if Role then
        _player.highest_role = Role.get_highest(player).name
        local roles = {}; for _,role in pairs(Role.get(player)) do table.insert(roles,role.name) end
        _player.roles = roles
    end
    if frame then
        local frame = frame.add{type='frame',direction='vertical',style='image_frame'}
        frame.style.width = 200
        if Role then frame.style.height = 275
        else frame.style.height = 260 end
        frame.add{type='label',caption={'ExpGamingPlayer-playerInfo.name',_player.index,_player.name},style='caption_label'}
        local _online = {'ExpGamingPlayer-playerInfo.no'}; if _player.online then _online = {'ExpGamingPlayer-playerInfo.yes'} end
        frame.add{type='label',caption={'ExpGamingPlayer-playerInfo.online',_online,tick_to_display_format(_player.online_time)}}
        local _admin = {'ExpGamingPlayer-playerInfo.no'}; if _player.admin then _admin = {'ExpGamingPlayer-playerInfo.yes'} end
        frame.add{type='label',caption={'ExpGamingPlayer-playerInfo.admin',_admin}}
        if Role then
            frame.add{type='label',caption={'ExpGamingPlayer-playerInfo.group',_player.group}}
            frame.add{type='label',caption={'ExpGamingPlayer-playerInfo.role',_player.highest_role}}
            frame.add{type='label',caption={'ExpGamingPlayer-playerInfo.roles',table.concat(_player.roles,', ')}}.style.single_line = false
        end
        if add_cam then
            Gui.cam_link{entity=player.character,frame=frame,width=200,height=150,zoom=0.5,respawn_open=true}
        end
    end
    return _player
end

return setmetatable({
    get_player_info=get_player_info,
    on_init=function(self)
        if loaded_modules['ExpGamingCore.Role@^4.0.0'] then Role = require('ExpGamingCore.Role@^4.0.0') end
        if loaded_modules['ExpGamingCore.Group@^4.0.0'] then Group = require('ExpGamingCore.Group@^4.0.0') end
    end
},{
    __call=function(self,...) self.get_player_info(...) end
})