local Gui = require 'expcore.gui'

Gui.new_toolbar_button('click-1')
:on_click(function(player,element,event)
    player.print('CLICK 1')
end)

Gui.new_toolbar_button('click-2')
:set_caption('Click Two')
:on_click(function(player,element,event)
    player.print('CLICK 2')
end)

Gui.new_toolbar_button('click-3')
:set_sprites('utility/questionmark')
:on_click(function(player,element,event)
    player.print('CLICK 3')
end)