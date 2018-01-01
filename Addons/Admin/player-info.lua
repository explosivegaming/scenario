--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

function get_player_info(player,frame)
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
    _player.rank = Ranking.get_rank(player).name
    _player.group = Ranking.get_group(player).name
    if frame then
        local frame = frame.add{type='frame',direction='vertical',style='image_frame'}
        frame.add{type='label',caption={'player-info.name',_player.index,_player.name},style='caption_label'}
        local _online = {'player-info.yes'}; if _player.online then _admin = {'player-info.no'} end
        frame.add{type='label',caption={'player-info.online',_online,tick_to_display_format(_player.online_time)}}
        local _admin = {'player-info.yes'}; if _player.admin then _admin = {'player-info.no'} end
        frame.add{type='label',caption={'player-info.admin',_admin}}
        frame.add{type='label',caption={'player-info.group',_player.group}}
        frame.add{type='label',caption={'player-info.rank',_player.rank}}
    end
    return _player
end