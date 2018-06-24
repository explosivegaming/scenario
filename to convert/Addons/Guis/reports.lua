--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local confirm_report = Gui.inputs.add{
    type='button',
    name='admin-report-confirm',
    caption='utility/spawn_flag',
    tooltip={'reports.name'}
}:on_event('click',function(event)
    local parent = event.element.parent
    local player = Game.get_player(parent.player.caption)
    local reason = parent.reason.text
    Admin.report(player,event.player_index,reason)
    Gui.center.clear(event.player_index)
end)

Admin.report_btn = Gui.inputs.add{
    type='button',
    name='admin-report',
    caption='utility/spawn_flag',
    tooltip={'reports.name'}
}:on_event('click',function(event)
    local parent = event.element.parent
    local player = Game.get_player(parent.children[1].name)
    if not player then return end
    local _player = Game.get_player(event)
    Gui.center.clear(_player)
    local frame = Gui.center.get_flow(_player).add{
        type='frame',
        name='report-gui'
    }
    _player.opened=frame
    frame.caption={'reports.name'}
    frame.add{
        type='textfield',
        name='reason'
    }.style.width = 300
    local btn = confirm_report:draw(frame)
    btn.style.height = 30
    btn.style.width = 30
    frame.add{
        type='label',
        name='player',
        caption=player.name
    }.style.visible = false
end)