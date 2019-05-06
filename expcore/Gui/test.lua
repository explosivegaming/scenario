local Gui = require 'expcore.gui'

Gui.new_toolbar_button('click-1')
:set_authenticator(function(player,button_name)
    return global.click_one
end)
:on_click(function(player,element,event)
    player.print('CLICK 1')
end)

Gui.new_toolbar_button('click-2')
:set_caption('Click Two')
:set_authenticator(function(player,button_name)
    return global.click_two
end)
:on_click(function(player,element,event)
    player.print('CLICK 2')
end)

Gui.new_toolbar_button('click-3')
:set_sprites('utility/questionmark')
:set_authenticator(function(player,button_name)
    return global.click_three
end)
:on_click(function(player,element,event)
    player.print('CLICK 3')
end)