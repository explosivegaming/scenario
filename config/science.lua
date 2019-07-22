-- config file for the science info gui
return { -- list of all science packs to be shown in the gui
    show_eta=true, -- when true the eta for research completion will be shown
    color_clamp=5, -- the amount required for the text to show as green or red
    color_flux=0.1, -- the ammount of flucuation allowed in production before icon change
    'automation-science-pack',
    'logistic-science-pack',
    'military-science-pack',
    'chemical-science-pack',
    'production-science-pack',
    'utility-science-pack',
    'space-science-pack',
}