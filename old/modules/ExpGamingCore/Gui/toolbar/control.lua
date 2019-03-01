--- Adds a toolbar to the top left of the screen
-- @module ExpGamingCore.Gui.Toolbar
-- @alias toolbar
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

--- This is a submodule of ExpGamingCore.Gui but for ldoc reasons it is under its own module
-- @function _comment

local Game = require('FactorioStdLib.Game')
local mod_gui = require('mod-gui')
local Gui = require('ExpGamingCore.Gui')
local order_config = require(module_path..'/order_config')
local Role -- this is optional and is handled by it being present, it is loaded on init

local toolbar = {}

toolbar.hide = Gui.inputs{
    name='gui-toolbar-hide',
    type='button',
    caption='<'
}:on_event('click',function(event)
    if event.element.caption == '<' then
        event.element.caption = '>'
        for _,child in pairs(event.element.parent.children) do
            if child.name ~= event.element.name then child.style.visible = false end
        end
    else
        event.element.caption = '<'
        for _,child in pairs(event.element.parent.children) do
            if child.name ~= event.element.name then child.style.visible = true end
        end
    end
end)

--- Add a button to the toolbar, ranks need to be allowed to use these buttons if ranks is preset
-- @usage toolbar.add('foo','Foo','Test',function() game.print('test') end)
-- @tparam string name the name of the button
-- @tparam string caption can be a sprite path or text to show
-- @tparam string tooltip the help to show for the button
-- @tparam function callback the function which is called on_click
-- @treturn table the button object that was made, calling the returned value will draw the toolbar button added
function toolbar.add(name,caption,tooltip,callback)
    verbose('Created Toolbar Button: '..name)
    local button = Gui.inputs.add{type='button',name=name,caption=caption,tooltip=tooltip}
    button:on_event(Gui.inputs.events.click,callback)
    Gui.data('toolbar',name,button)
    return button
end

--- Draws the toolbar for a certain player
-- @usage toolbar.draw(1)
-- @param player the player to draw the tool bar of
function toolbar.draw(player)
    player = Game.get_player(player)
    if not player then return end
	local toolbar_frame = mod_gui.get_button_flow(player)
    toolbar_frame.clear()
    if not Gui.data.toolbar then return end
    toolbar.hide(toolbar_frame).style.maximal_width = 15
    local done = {}
    for _,name in pairs(order_config) do
        local button = Gui.data.toolbar[name]
        if button then
            done[name] = true
            if is_type(Role,'table') then
                if Role.allowed(player,name) then
                    button(toolbar_frame)
                end
            else button(toolbar_frame) end
        end
    end
    for name,button in pairs(Gui.data.toolbar) do
        if not done[name] then
            if is_type(Role,'table') then
                if Role.allowed(player,name) then
                    button(toolbar_frame)
                end
            else button(toolbar_frame) end
        end
	end
end

function toolbar.on_init()
    if loaded_modules['ExpGamingCore.Role'] then Role = require('ExpGamingCore.Role') end
end

Event.add({defines.events.on_role_change,defines.events.on_player_joined_game},toolbar.draw)
-- calling with only a player will draw the toolbar for that player, more params will attempt to add a button
return setmetatable(toolbar,{__call=function(self,player,extra,...) if extra then return self.add(player,extra,...) else self.draw(player) end end})