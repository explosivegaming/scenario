local Sync = require('ExpGamingCore.Sync')
local Gui = require('ExpGamingCore.Gui')

Sync.add_to_gui(Gui.inputs.add_button('readme-sync-guildlines','View Guildlines','View the guildlines in the readme',function(player,element)
    Gui.center.open_tab(player,'readme','guildlines')
end))

Sync.add_to_gui(Gui.inputs.add_button('readme-sync-links','View Other Links','View the links in the readme',function(player,element)
    Gui.center.open_tab(player,'readme','links')
end))

Sync.add_to_gui(Gui.inputs.add_button('readme-sync-rules','View All Rules','View the all rules in the readme',function(player,element)
    Gui.center.open_tab(player,'readme','rules')
end))