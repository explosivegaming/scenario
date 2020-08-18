--- This file contains all the different settings for the autofill system and gui
-- @config Autofill

return {
  -- General config
  icon = 'item/piercing-rounds-magazine', --- @setting icon that will be used for the toolbar
  default_settings = {
    {
      type = 'ammo',
      item = 'uranium-rounds-magazine',
      amount = 100,
      enabled = false
    },
    {
      type = 'ammo',
      item = 'piercing-rounds-magazine',
      amount = 100,
      enabled = false
    },
    {
      type = 'ammo',
      item = 'firearm-magazine',
      amount = 100,
      enabled = false
    },
    {
      type = 'fuel',
      item = 'nuclear-fuel',
      amount = 100,
      enabled = false
    },
    {
      type = 'fuel',
      item = 'solid-fuel',
      amount = 100,
      enabled = false
    },
    {
      type = 'fuel',
      item = 'coal',
      amount = 100,
      enabled = false
    }
  }
}