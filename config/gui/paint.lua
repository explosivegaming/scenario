--- This file contains all the different settings for the paint system and Gui
-- @config Paint

return {
    -- General config
    default_tile = 'refined-concrete', --- @setting default_tile The default tile that u use to built with
    default_tile_find = 'refined%-concrete', --- @setting default_tile_find Maybe enable hazard versions aswell? replace - with %-(.*)

    -- Gui
    default_icon = 'utility/brush_icon', --- @setting default_icon of the top gui
    colors_table_size = 6, --- @setting colors_table_size best 6 without hazard and 7 with hazard enabled
}