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
    global.addons.player_list = not reset and global.addons.player_list or {update=0,delay=10,intervial=54000}
    return global.addons.player_list
end

local function update()
    Gui.left.update('player-list')
end

local function queue_update(tick)
    local data = _global()
    local tick = is_type(tick,'table') and tick.tick or is_type(tick,'number') and tick or game.tick
    if tick + data.delay > data.update then
        data.update = tick + data.delay
    end
end

Gui.left.add{
    name='player-list',
    caption='entity/player',
    tooltip={'player-list.tooltip'},
    draw=function(frame)
        frame.caption = ''
        local player_list = frame.add{
            name="scroll",
            type = "scroll-pane",
            direction = "vertical",
            vertical_scroll_policy="always",
            horizontal_scroll_policy="never"
        }
        for _,rank in pairs(Ranking._ranks()) do
            for _,player in pairs(rank:get_players(true)) do
                if rank.short_hand == '' then
                    player_list.add{
                        type='label',
                        style='caption_style',
                        caption={'player-list.format-nil',tick_to_display_format(player.online_time),player.name}
                    }.style.font_color = rank.colour
                else
                    player_list.add{
                        type='label',
                        style='caption_style',
                        caption={'player-list.format',tick_to_display_format(player.online_time),player.name,rank.short_hand}
                    }.style.font_color = rank.colour
                end
            end
        end
    end,
    open_on_join=true
}

Event.register(defines.events.on_tick,function(event)
    local data = _global()
    if event.tick > data.update then
        update()
        data.update = event.tick + data.intervial
    end
end)

Event.register(defines.events.on_player_joined_game,queue_update)
Event.register(defines.events.on_player_left_game,queue_update)
Event.register(defines.events.rank_change,queue_update)