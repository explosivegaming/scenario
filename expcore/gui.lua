-- This file is used to require all the different elements of the gui module
local opt_require = ext_require('expcore.common','opt_require')

local Gui = require('./gui/core')

local Buttons = require('./gui/buttons')
Gui.new_button = Buttons.new_button
Gui.inputs.buttons = Buttons

local Toolbar = require('./gui/toolbar')
Gui.new_toolbar_button = Toolbar.new_button
Gui.add_button_to_toolbar = Toolbar.add_button
Gui.structure.toolbar = Toolbar

--[[local Checkboxs = opt_require('./gui/checkboxs')
Gui.new_checkbox = Checkboxs.new_checkbox
Gui.new_radiobutton = Checkboxs.new_radiobutton
Gui.inputs.checkboxs = Checkboxs

local TextEntry = opt_require('./gui/text')
Gui.new_text_entry = TextEntry.new_text_entry
Gui.inputs.text_entrys = TextEntry
]]
return Gui