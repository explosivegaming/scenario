--- Config file for the science info gui
-- @config Science

return { -- list of all science packs to be shown in the gui
    show_eta=true, --- @setting show_eta when true the eta for research completion will be shown
    color_clamp=5, --- @setting color_clamp the amount required for the text to show as green or red
    color_flux=0.1, --- @setting color_flux the ammount of flucuation allowed in production before icon change
    'automation-science-pack',
    'logistic-science-pack',
    'military-science-pack',
    'chemical-science-pack',
    'production-science-pack',
    'utility-science-pack',
    'space-science-pack',
}