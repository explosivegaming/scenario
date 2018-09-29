--- Adds a toolbar to the top left of the screen
-- @module ExpGamingCore.Gui.Toolbar
-- @alias toolbar
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

--- This is a submodule of ExpGamingCore.Gui but for ldoc reasons it is under its own module
-- @function _comment

local Game = require('FactorioStdLib.Game')
local Role -- this is optional and is hanndled by it being present, it is loaded on init
local mod_gui = require("mod-gui")
local Gui = Gui -- this is to force gui to remain in the ENV

local toolbar = {}

--- Add a button to the toolbar, ranks need to be allowed to use these buttons if ranks is preset
-- @usage toolbar.add('foo','Foo','Test',function() game.print('test') end)
-- @tparam string name the name of the button
-- @tparam string caption can be a sprite path or text to show
-- @tparam string tooltip the help to show for the button
-- @tparam function callback the function which is called on_click
-- @treturn table the button object that was made
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
    local player = Game.get_player(player)
    if not player then return end
	local toolbar_frame = mod_gui.get_button_flow(player)
    toolbar_frame.clear()
    if not Gui.data.toolbar then return end
    for name,button in pairs(Gui.data.toolbar) do
        if is_type(Role,'table') then
            if Role.allowed(player,name) then
                button:draw(toolbar_frame)
            end
        else button:draw(toolbar_frame) end
	end
end

function toolbar:on_init()
    if loaded_modules['ExpGamingCore.Role'] then Role = require('ExpGamingCore.Role') end
end

toolbar.on_role_change = toolbar.draw
toolbar.on_player_joined_game = toolbar.draw
return toolbar