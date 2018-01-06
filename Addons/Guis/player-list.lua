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

local get_player_info = get_player_info or function(player,frame)
    frame.add{
        type='label',
        caption={'player-list.no-info-file'}
    }
end

local function update()
    Gui.left.update('player-list')
end

local function queue_update(tick)
    local data = _global()
    local tick = is_type(tick,'table') and tick.tick or is_type(tick,'number') and tick or game.tick
    if tick + data.delay > data.update - data.intervial then
        data.update = tick + data.delay
    end
end

local back_btn = Gui.inputs.add{
    type='button',
    caption='utility/enter',
    name='player-list-back'
}:on_event('click',function(event)
    event.element.parent.parent.scroll.style.visible = true
    event.element.parent.destroy()
end)

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
                local flow = player_list.add{type='flow'}
                if rank.short_hand == '' then
                    flow.add{
                        type='label',
                        name=player.name,
                        style='caption_label',
                        caption={'player-list.format-nil',tick_to_display_format(player.online_time),player.name}
                    }.style.font_color = rank.colour
                else
                    flow.add{
                        type='label',
                        name=player.name,
                        style='caption_label',
                        caption={'player-list.format',tick_to_display_format(player.online_time),player.name,rank.short_hand}
                    }.style.font_color = rank.colour
                end
                if Admin.report_btn and not rank:allowed('no-report') and not player.index == frame.player_index then
                    local btn = Admin.report_btn:draw(flow)
                    btn.style.height = 20
                    btn.style.width = 20
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

Event.register(defines.events.on_gui_click,function(event)
    if event.element and event.element.valid 
    and event.element.parent and event.element.parent.parent and event.element.parent.parent.parent 
    and event.element.parent.parent.parent.name == 'player-list' then else return end
    if event.button == defines.mouse_button_type.right then else return end
    local player_list = event.element.parent.parent.parent
    player_list.scroll.style.visible = false
    local flow = player_list.add{type='flow',direction='vertical'}
    back_btn:draw(flow)
    get_player_info(event.element.name,flow,true)
    if event.player_index == Game.get_player(event.element.name).index then return end
    if Admin and Admin.allowed(event.player_index) then Admin.btn_flow(flow).caption = event.element.name end
end)

Event.register(defines.events.on_player_joined_game,queue_update)
Event.register(defines.events.on_player_left_game,queue_update)
Event.register(defines.events.rank_change,queue_update)