--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]

local left = {}
left._left = {}

--- Used to add a left gui frame
-- @usage Gui.left.add{name='foo',caption='Foo',tooltip='just testing',open_on_join=true,can_open=function,draw=function}
-- @param obj this is what will be made, needs a name and a draw function(root_frame), open_on_join can be used to set the deaful state true/false, can_open is a test to block it from opening but is not needed
-- @return the object that is made to... well idk but for the future
function left.add(obj)
    if not is_type(obj,'table') then return end    
    if not is_type(obj.name,'string') then return end
    setmetatable(obj,{__index=left._left})
    Gui._add_data('left',obj.name,obj)
    Gui.toolbar.add(obj.name,obj.caption,obj.tooltip,obj.toggle)
    return obj
end

--- This is used to update all the guis of conected players, good idea to use our thread system as it as nested for loops
-- @usage Gui.left.update()
-- @tparam string frame this is the name of a frame if you only want to update one
function left.update(frame)
    if not Server or not Server._thread then
        for _,player in pairs(game.connected_players) do
            local frames = Gui._get_data('left') or {}
            if frame then frames = {[frame]=frames[frame]} or {} end
            for name,left in pairs(frames) do
                if _left then
                    local fake_event = {player_index=player.index,element={name=name}}
                    left.open(fake_event)
                end
            end
        end
    else
        local frames = Gui._get_data('left') or {}
        if frame then frames = {[frame]=frames[frame]} or {} end
        Server.new_thread{
            data={players=game.connected_players,frames=frames}
        }:on_event('tick',function(thread)
            if #thread.data.players == 0 then thread:close() return end
            local player = table.remove(thread.data.players,1)
            Server.new_thread{
                data={player=player,frames=thread.data.frames}
            }:on_event('resolve',function(thread)
                for name,left in pairs(thread.data.frames) do
                    if left then
                        local fake_event = {player_index=thread.data.player.index,element={name=name}}
                        left.open(fake_event)
                    end
                end
            end):queue()
        end):open()
    end
end

--- Used to open the left gui of every player
-- @usage Gui.left.open('foo')
-- @tparam string left_name this is the gui that you want to open
function left.open(left_name)
    local _left = Gui._get_data('left')[left_name]
    if not _left then return end
    if not Server or not Server._thread then
        for _,player in pairs(game.connected_players) do
            local left_flow = mod_gui.get_frame_flow(player)
            if left_flow[_left.name] then left_flow[_left.name].style.visible = true end
        end
    else
        Server.new_thread{
            data={players=game.connected_players}
        }:on_event('tick',function(thread)
            if #thread.data.players == 0 then thread:close() return end
            local player = table.remove(thread.data.players,1)
            local left_flow = mod_gui.get_frame_flow(player)
            if left_flow[_left.name] then left_flow[_left.name].style.visible = true end
        end):open()
    end
end

--- Used to close the left gui of every player
-- @usage Gui.left.close('foo')
-- @tparam string left_name this is the gui that you want to close
function left.close(left_name)
    local _left = Gui._get_data('left')[left_name]
    if not _left then return end
    if not Server or not Server._thread then
        for _,player in pairs(game.connected_players) do
            local left_flow = mod_gui.get_frame_flow(player)
            if left_flow[_left.name] then left_flow[_left.name].style.visible = false end
        end
    else
        Server.new_thread{
            data={players=game.connected_players}
        }:on_event('tick',function(thread)
            if #thread.data.players == 0 then thread:close() return end
            local player = table.remove(thread.data.players,1)
            local left_flow = mod_gui.get_frame_flow(player)
            if left_flow[_left.name] then left_flow[_left.name].style.visible = false end
        end):open()
    end
end

-- this is used to draw the gui for the first time (these guis are never destoryed), used by the script
function left._left.open(event)
    local player = Game.get_player(event)
    local _left = Gui._get_data('left')[event.element.name]
    local left_flow = mod_gui.get_frame_flow(player)
    local frame = nil
    if left_flow[_left.name] then 
        frame = left_flow[_left.name] 
        frame.clear()
    else 
        frame = left_flow.add{type='frame',name=_left.name,style=mod_gui.frame_style,caption=_left.caption,direction='vertical'}
        frame.style.visible = false
        if is_type(_left.open_on_join,'boolean') then frame.style.visible = _left.open_on_join end
    end
    if is_type(_left.draw,'function') then _left.draw(frame) else frame.style.visible = false error('No Callback On '.._left.name) end
end

-- this is called when the toolbar button is pressed
function left._left.toggle(event)
    local player = Game.get_player(event)
    local _left = Gui._get_data('left')[event.element.name]
    local left_flow = mod_gui.get_frame_flow(player)
    if not left_flow[_left.name] then _left.open(event) end
    local left = left_flow[_left.name]
    local open = false
    if is_type(_left.can_open,'function') then
        local success, err = pcall(_left.can_open,player)
        if not success then error(err)
        elseif err == true then open = true end
    else
        if is_type(Ranking,'table') and Ranking._presets and Ranking._presets().meta.rank_count > 0 then
            if Ranking.get_rank(player):allowed(_left.name) then open = true end
        end
    end
    if open and left.style.visible ~= true then
        left.style.visible = true
    else
        left.style.visible = false
    end
    if not open then player_return('You can not open this panel right now',defines.text_color.crit,player) player.play_sound{path='utility/cannot_build'} end
end

-- draws the left guis when a player first joins, fake_event is just because i am lazy
Event.register(defines.events.on_player_joined_game,function(event)
    local player = Game.get_player(event)
    local frames = Gui._get_data('left') or {}
    for name,left in pairs(frames) do
        local fake_event = {player_index=player.index,element={name=name}}
        left.open(fake_event)
    end
end)

return left