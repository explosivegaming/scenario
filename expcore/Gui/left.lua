local Gui = require './core'
local Toolbar = require './toolbar'
local Buttons = require './buttons'
local mod_gui = require 'mod-gui'
local Game = require 'utils.game'
local Events = require 'utils.events'

local LeftFrames = {
    buttons={},
    draw_functions={},
    open_by_default={}
}

function LeftFrames.get_flow(player)
    return mod_gui.get_frame_flow(player)
end

function LeftFrames.get_open(player)
    local open = {}
    local flow = LeftFrames.get_flow(player)

    for _,child in pairs(flow.children) do
        if LeftFrames.buttons[child.name] then
            if child.valid and child.visible then
                table.insert(open,child)
            end
        end
    end

    if #open == 0 then
        flow[LeftFrames.toogle_button.name].visible = false
    end

    return open
end

function LeftFrames.get_frame(player,name)
    local flow = LeftFrames.get_flow(player)
    if flow[name] and flow[name].valid then
        return flow[name]
    end
end

function LeftFrames.toogle_frame(player,name,state)
    local frame = LeftFrames.get_frame(player,name)
    if state ~= nil then
        frame.visible = state
    else
        Gui.toggle_visible(frame)
    end
end

function LeftFrames.new_frame(name)
    local frame_name = Gui.uid_name()
    LeftFrames.add_frame(frame_name,name)
    return frame_name
end

function LeftFrames.add_frame(define_name,permision_name)
    LeftFrames.buttons[define_name] =
    Toolbar.new_button(permision_name)
    :on_click(function(player,_element)
        LeftFrames.toogle_frame(player,define_name)
    end)
end

function LeftFrames.set_open_by_default(define_name,state)
    if not LeftFrames.buttons[define_name] then
        return error('Left frame is not registered',2)
    end

    LeftFrames.draw_functions[define_name] = state
end

function LeftFrames.on_update(define_name,callback)
    if not LeftFrames.buttons[define_name] then
        return error('Left frame is not registered',2)
    end

    LeftFrames.open_by_default[define_name] = callback
end

function LeftFrames.update(define_name,player)
    player = Game.get_player_from_any(player)
    local frame = LeftFrames.get_frame(player,define_name)
    frame.clear()
    if LeftFrames.draw_functions[define_name] then
        LeftFrames.draw_functions[define_name](frame,player)
    end
end

function LeftFrames.update_all_frames(player)
    player = Game.get_player_from_any(player)
    for define_name,draw_function in pairs(LeftFrames.draw_functions) do
        local frame = LeftFrames.get_frame(player,define_name)
        frame.clear()
        draw_function(frame,player)
    end
end

function LeftFrames.update_all_players(define_name,update_offline)
    local players = update_offline and game.players or game.connected_players
    for _,player in pairs(players) do
        LeftFrames.update(define_name,player)
    end
end

function LeftFrames.update_all(update_offline)
    local players = update_offline and game.players or game.connected_players
    for _,player in pairs(players) do
        LeftFrames.update_all_frames(player)
    end
end

LeftFrames.toogle_button =
Buttons.new_button()
:set_caption('<')
:on_click(function(player,_element)
    local flow = LeftFrames.get_flow(player)

    for _,child in pairs(flow.children) do
        if LeftFrames.buttons[child.name] then
            if child.valid and child.visible then
                child.visible = false
            end
        end
    end
end)

Events.add(defines.events.on_player_created,function(event)
    local player = Game.get_plyaer_by_index(event.player_index)
    local flow = LeftFrames.get_flow(player)

    LeftFrames.toogle_button(flow)

    for define_name,_ in pairs(LeftFrames.buttons) do
        local frame = flow.add{
            type='frame',
            name=define_name
        }

        if LeftFrames.draw_functions[define_name] then
            LeftFrames.draw_functions[define_name](frame,player)
        end
    end
end)