--- Adds a location for popups which can be dismissed by a player and created from other scripts
-- @module ExpGamingCore.Gui.Popup
-- @alias popup
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

--- This is a submodule of ExpGamingCore.Gui but for ldoc reasons it is under its own module
-- @function _comment

local Game = require('FactorioStdLib.Game')
local mod_gui = require('mod-gui')
local Gui = require('ExpGamingCore.Gui')
local Server -- loaded on_init

local popup = {}
popup._prototype = {}

--- Used to add a popup gui style
-- @usage Gui.left.add{name='foo',caption='Foo',draw=function}
-- @usage return_value(data,player) -- opens popup for one player use popup.open to open for more than one player
-- @param obj this is what will be made, needs a name and a draw function(root_frame,data)
-- @return the object that is made, calling the returned value will open the popup for that player
function popup.add(obj)
    if not is_type(obj,'table') then return end    
    if not is_type(obj.name,'string') then return end
    verbose('Created Popup Gui: '..obj.name)
    setmetatable(obj,{__index=popup._prototype,__call=function(self,data,player) local players = player and {player} or nil return popup.open(self.name,data,players) end})
    local name = obj.name; obj.name = nil
    Gui.data('popup',name,obj)
    obj.name = name
    return obj
end

-- this is used by the script to find the popup flow
function popup.flow(player)
    local player = Game.get_player(player)
    if not player then error('Invalid Player',2) end
    local flow = mod_gui.get_frame_flow(player).popups 
    if not flow then flow = mod_gui.get_frame_flow(player).add{name='popups',type='flow',direction='vertical'} flow.style.visible=false end
    return flow
end

--- Use to open a popup for these players
-- @usage Gui.popup.open('ban',nil,{player=1,reason='foo'})
-- @tparam string style this is the name you gave to the popup when added
-- @param data this is the data that is sent to the draw function
-- @tparam[opt=game.connected_players] table players the players to open the popup for
function popup.open(style,data,players)
    local _popup = Gui.data.popup[style]
    local players = players or game.connected_players
    local data = data or {}
    if not _popup then return end
    if not Server or not Server._thread then
        for _,player in pairs(players) do
            if _popup.left then _popup.left:close(player) end
            local flow = popup.flow(player)
            flow.style.visible=true
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
            _popup.close(_frame)
            if is_type(_popup.draw,'function') then
                local success, err = pcall(_popup.draw,frame,data)
                if not success then error(err) end
            else error('No Draw On Popup '.._popup.name) end
        end
    else
        Server.new_thread{
            data={players=players,popup=_popup,data=data}
        }:on_event('tick',function(self)
            if #self.data.players == 0 then self:close() return end
            local player = table.remove(self.data.players,1)
            if self.data.popup.left then self.data.popup.left:close(player) end
            local flow = popup.flow(player)
            flow.style.visible=true
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
            self.data.popup.close(_frame)
            if is_type(self.data.popup.draw,'function') then
                local success, err = pcall(self.data.popup.draw,frame,self.data.data)
                if not success then error(err) end
            else error('No Draw On Popup '..self.data.popup.name) end
        end):open()
    end
end

function popup:on_init()
    if loaded_modules['ExpGamingCore.Server'] then Server = require('ExpGamingCore.Server') end
    if loaded_modules['ExpGamingCore.Gui.left'] then
        function popup._prototype:add_left(obj)
            obj.name = obj.name or self.name
            self.left = Gui.left(obj)
        end
    end
end

function popup:on_post()
    popup._prototype.close = Gui.inputs.add{
        type='button',
        name='popup-close',
        caption='utility/set_bar_slot',
        tooltip='Close This Popup'
    }:on_event('click',function(event)
        local frame = event.element.parent
        local parent = frame.parent
        if frame and frame.valid then frame.destroy() if #parent.children == 0 then parent.style.visible = false end end
    end)
end

script.on_event(defines.events.on_player_joined_game,popup.flow)

-- calling will attempt to add a new popup style
return setmetatable(popup,{__call=function(self,...) return self.add(...) end})