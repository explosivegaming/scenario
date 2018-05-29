--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]

local popup = {}
popup._popup = {}

function popup._load()
    popup._popup.close = Gui.inputs.add{
        type='button',
        name='popup-close',
        caption='utility/set_bar_slot',
        tooltip='Close This Popup'
    }:on_event('click',function(event)
        local frame = event.element.parent
        if frame and frame.valid then frame.destroy() end
    end)
end

--- Used to add a popup gui style
-- @usage Gui.left.add{name='foo',caption='Foo',draw=function}
-- @param obj this is what will be made, needs a name and a draw function(root_frame,data)
-- @return the object that is made to... well idk but for the future
function popup.add(obj)
    if not is_type(obj,'table') then return end    
    if not is_type(obj.name,'string') then return end
    verbose('Created Popup Gui: '..obj.name)
    setmetatable(obj,{__index=popup._popup})
    local name = obj.name; obj.name = nil
    Gui._add_data('popup',name,obj)
    obj.name = name
    return obj
end

-- this is used by the script to find the popup flow
function popup.flow(player)
    local player = Game.get_player(player)
    local flow = mod_gui.get_frame_flow(player).popups or mod_gui.get_frame_flow(player).add{name='popups',type='flow',direction='vertical'}
    return flow
end

--- Use to open a popup for these players
-- @usage Gui.popup.open('ban',nil,{player=1,reason='foo'})
-- @tparam string style this is the name you gave to the popup when added
-- @param data this is the data that is sent to the draw function
-- @tparam[opt=game.connected_players] table players the players to open the popup for
function popup.open(style,data,players)
    local _popup = Gui._get_data('popup')[style]
    local players = players or game.connected_players
    local data = data or {}
    if not _popup then return end
    if _popup.left then Gui.left.close(_popup.left.name) end
    if not Server or not Server._thread then
        for _,player in pairs(players) do
            local flow = popup.flow(player)
            local _frame = flow.add{
                type='frame',
                direction='horizontal',
                style=mod_gui.frame_style
            }
            local frame = _frame.add{
                type='frame',
                name='inner_frame',
                direction='vertical',
                style='image_frame'
            }
            _popup.close:draw(_frame)
            if is_type(_popup.draw,'function') then
                local success, err = pcall(_popup.draw,frame,data)
                if not success then error(err) end
            else error('No Draw On Popup '.._popup.name) end
        end
    else
        Server.new_thread{
            data={players=players,popup=_popup,data=data}
        }:on_event('tick',function(thread)
            if #thread.data.players == 0 then thread:close() return end
            local player = table.remove(thread.data.players,1)
            local flow = popup.flow(player)
            local _frame = flow.add{
                type='frame',
                direction='horizontal',
                style=mod_gui.frame_style
            }
            local frame = _frame.add{
                type='frame',
                name='inner_frame',
                direction='vertical',
                style='image_frame'
            }
            thread.data.popup.close:draw(_frame)
            if is_type(thread.data.popup.draw,'function') then
                local success, err = pcall(thread.data.popup.draw,frame,thread.data.data)
                if not success then error(err) end
            else error('No Draw On Popup '..thread.data.popup.name) end
        end):open()
    end
end

function popup._popup:add_left(obj)
    obj.name = obj.name or self.name
    self.left = Gui.left.add(obj)
end

Event.register(defines.events.on_player_joined_game,popup.flow)

return popup