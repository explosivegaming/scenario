--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local function _global(reset)
    global.addons = not reset and global.addons or {}
    global.addons.player_list = not reset and global.addons.player_list or {update=0,delay=10}
    return global.addons.player_list
end

local function queue_update(tick)
    local data = _global()
    local tick = tick or game.tick
    if tick + data.delay > data.update then
        data.update = tick + data.delay
    end
end

Gui.left.add{
    name='player-list',
    caption='entity/player',
    tooltip='Toggles the player list',
    draw=function(frame)
        frame.caption = ''
        local player_list = frame.add{
            name="scroll",
            type = "scroll-pane",
            direction = "vertical",
            vertical_scroll_policy="always",
            horizontal_scroll_policy="never"
        }

    end,
    open_on_join=true
}