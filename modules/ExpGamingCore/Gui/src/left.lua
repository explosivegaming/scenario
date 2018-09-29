--- Adds a organiser for left gui ellements which will automaticaly update there information and have open requirements
-- @module ExpGamingCore.Gui.Left
-- @alias left
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

--- This is a submodule of ExpGamingCore.Gui but for ldoc reasons it is under its own module
-- @function _comment

local Game = require('FactorioStdLib.Game')
local Server = require('ExpGamingCore.Server')
local Color = require('FactorioStdLib.Color')
local Role -- this is optional and is hanndled by it being present, it is loaded on init
local mod_gui = require("mod-gui")
local Gui = Gui -- this is to force gui to remain in the ENV

local left = {}
left._left = {}

-- used for debugging
function left.override_open(state)
    global.over_ride_left_can_open = state
end
--- Used to add a left gui frame
-- @usage Gui.left.add{name='foo',caption='Foo',tooltip='just testing',open_on_join=true,can_open=function,draw=function}
-- @param obj this is what will be made, needs a name and a draw function(root_frame), open_on_join can be used to set the deaful state true/false, can_open is a test to block it from opening but is not needed
-- @return the object that is made to... well idk but for the future
function left.add(obj)
    if not is_type(obj,'table') then return end    
    if not is_type(obj.name,'string') then return end
    verbose('Created Left Gui: '..obj.name)
    setmetatable(obj,{__index=left._left})
    Gui.data('left',obj.name,obj)
    Gui.toolbar.add(obj.name,obj.caption,obj.tooltip,obj.toggle)
    return obj
end

--- This is used to update all the guis of conected players, good idea to use our thread system as it as nested for loops
-- @usage Gui.left.update()
-- @tparam[opt] string frame this is the name of a frame if you only want to update one
-- @param[opt] players the player to update for, if not given all players are updated, can be one player
function left.update(frame,players)
    if not Server or not Server._thread then
        local players = is_type(players,'table') and #players > 0 and {unpack(players)} or is_type(players,'table') and {players} or Game.get_player(players) and {Game.get_player(players)} or game.connected_players
        for _,player in pairs(players) do
            local frames = Gui.data.left or {}
            if frame then frames = {[frame]=frames[frame]} or {} end
            for name,left in pairs(frames) do
                if _left then
                    local fake_event = {player_index=player.index,element={name=name}}
                    left.open(fake_event)
                end
            end
        end
    else
        local frames = Gui.data.left or {}
        if frame then frames = {[frame]=frames[frame]} or {} end
        local players = is_type(players,'table') and #players > 0 and {unpack(players)} or is_type(players,'table') and {players} or Game.get_player(players) and {Game.get_player(players)} or game.connected_players
        Server.new_thread{
            data={players=players,frames=frames}
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
    local _left = Gui.data.left[left_name]
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
    local _left = Gui.data.left[left_name]
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
    local _left = Gui.data.left[event.element.name]
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
    local _left = Gui.data.left[event.element.name]
    local left_flow = mod_gui.get_frame_flow(player)
    if not left_flow[_left.name] then _left.open(event) end
    local left = left_flow[_left.name]
    local open = false
    if is_type(_left.can_open,'function') then
        local success, err = pcall(_left.can_open,player)
        if not success then error(err)
        elseif err == true then open = true 
        elseif global.over_ride_left_can_open then 
            if is_type(Role,'table')  then
                if Role.allowed(player,_left.name) then open = true
                else open = {gui.unauthorized} end
            else open = true end 
        else open = err end
    else
        if is_type(Role,'table')  then
            if Role.allowed(player,_left.name) then open = true 
            else open = {gui.unauthorized} end
        else open = true end
    end
    if open == true and left.style.visible ~= true then
        left.style.visible = true
    else
        left.style.visible = false
    end
    if open == false then player_return({'gui.cant-open-no-reason'},defines.textcolor.crit,player) player.play_sound{path='utility/cannot_build'} 
    elseif open ~= true then player_return({'gui.cant-open',open},defines.textcolor.crit,player) player.play_sound{path='utility/cannot_build'} end
end

left.on_player_joined_game = function(event)
    -- draws the left guis when a player first joins, fake_event is just because i am lazy
    local player = Game.get_player(event)
    local frames = Gui.data.left or {}
    for name,left in pairs(frames) do
        local fake_event = {player_index=player.index,element={name=name}}
        left.open(fake_event)
    end
end

function left:on_init()
    if loaded_modules['ExpGamingCore.Role'] then Role = require('ExpGamingCore.Role') end
end

return left