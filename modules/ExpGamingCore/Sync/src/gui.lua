--- Allows syncing with an outside server and info panle.
-- @submodule ExpGamingCore.Sync
-- @alias Sync
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

--- This file will be loaded when ExpGamingCore.Gui is present
-- @function _comment

local Game = require('FactorioStdLib.Game@^0.8.0')
local Gui = require('ExpGamingCore.Gui@^4.0.0')
local Sync = Sync -- this is to force sync to remain in the ENV

local Sync_gui_functions = {}

--- Adds a emeltent to the sever info gui
-- @usage Sync.add_to_gui('string') -- return true
-- @param element see examples before for what can be used, it can also be a return from Gui.inputs.add
-- @treturn bolean based on weather it was successful or not
function Sync.add_to_gui(element,...)
    if game then return false end
    if is_type(element,'function') then
        table.insert(Sync_gui_functions,{'function',element,...})
    elseif is_type(element,'table') then
        if element.draw then table.insert(Sync_gui_functions,{'gui',element})
        else table.insert(Sync_gui_functions,{'table',element}) end
    else table.insert(Sync_gui_functions,{'string',element}) end
    return true
end

Sync.add_to_gui('Welcome to the Explosive Gaming comunity! This is one of many servers which we host.')
Sync.add_to_gui(function(player,frame) return 'This server\'s next reset: '..Sync.info.reset_time end)

--- Formats a lable to be a certain format
-- @local label_format
local function label_format(label,width)
    label.style.width = width
    label.style.align = 'center'
    label.style.single_line = false
end

--- Creates a center gui that will appear on join
-- @gui server-info
Sync.info_gui = Gui.center{
    name='server-info',
    caption='Server Info',
    tooltip='Basic info about the current server',
    draw=function(self,frame)
        frame.caption = ''
        local info = Sync.info
        local frame = frame.add{type='flow',direction='vertical'}
        local _flow = frame.add{type='flow'}
        Gui.bar(_flow,200)
        label_format(_flow.add{
            type='label',
            caption='Welcome To '..info.server_name,
            style='caption_label'
        },180)
        Gui.bar(_flow,200)
        label_format(frame.add{
            type='label',
            caption=info.server_description,style='description_label'
        },600)
        Gui.bar(frame,600)
        local _frame = frame
        local frame = frame.add{
            type='frame',
            direction='vertical',
            style='image_frame'
        }
        frame.style.width = 600
        local text_flow = frame.add{type='flow',direction='vertical'}
        local button_flow = frame.add{type='table',column_count=3}
        for _,element in pairs(table.deepcopy(Sync_gui_functions)) do
            local _type = table.remove(element,1)
            if _type == 'function' then
                local success, err = pcall(table.remove(element,1),frame.player_index,frame,unpack(element))
                if not success then error(err) else
                    if is_type(err,'table') then
                        if element.draw then element:draw(button_flow).style.width = 195
                        else label_format(text_flow.add{type='label',caption=err},585) end
                    else label_format(text_flow.add{type='label',caption=tostring(err)},585) end
                end
            elseif _type == 'gui' then element[1]:draw(button_flow).style.width = 195
            elseif _type == 'string' then label_format(text_flow.add{type='label',caption=tostring(element[1])},585)
            elseif _type == 'table' then label_format(text_flow.add{type='label',caption=element[1]},585) end
        end
        _frame.add{
            type='label',
            caption='Press Ecs or E to close; this is only visible once!',
            style='fake_disabled_label'
        }.style.font='default-small'
end}

script.on_event(defines.events.on_gui_click,function(event)
    local element = event.element
    if element and element.valid and element.caption and element.caption == 'Press Ecs or E to close; this is only visible once!' then
        Gui.center.clear(event)
    end
end)

script.on_event(defines.events.on_player_joined_game,function(event) Sync.info_gui(event) end)