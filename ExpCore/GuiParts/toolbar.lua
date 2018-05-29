--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]

local toolbar = {}

--- Add a button to the toolbar, ranks need to be allowed to use these buttons if ranks is preset
-- @usage toolbar.add('foo','Foo','Test',function() game.print('test') end)
-- @tparam string name the name of the button
-- @tparam string caption can be a sprite path or text to show
-- @tparma string tooltip the help to show for the button
-- @tparam function callback the function which is called on_click
-- @treturn table the button object that was made
function toolbar.add(name,caption,tooltip,callback)
    verbose('Created Toolbar Button: '..name)
    local button = Gui.inputs.add{type='button',name=name,caption=caption,tooltip=tooltip}
    button:on_event(Gui.inputs.events.click,callback)
    Gui._add_data('toolbar',name,button)
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
    if not Gui._get_data('toolbar') then return end
    for name,button in pairs(Gui._get_data('toolbar')) do
        if is_type(Ranking,'table') and Ranking._presets and Ranking._presets().meta.rank_count > 0 then
            local rank = Ranking.get_rank(player)
            if rank:allowed(name) then
                button:draw(toolbar_frame)
            end
        else button:draw(toolbar_frame) end
	end
end

if defines.events.rank_change then
    Event.register(defines.events.rank_change,toolbar.draw)
end
Event.register(defines.events.on_player_joined_game,toolbar.draw)

return toolbar