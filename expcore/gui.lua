-- This file is used to require all the different elements of the gui module
local Gui = require('./gui/core')

local Buttons = require('./gui/buttons')
Gui.new_button = Buttons.new_button
Gui.inputs.buttons = Buttons

local Toolbar = require('./gui/toolbar')
Gui.new_toolbar_button = Toolbar.new_button
Gui.add_button_to_toolbar = Toolbar.add_button
Gui.structure.toolbar = Toolbar

local Checkboxs = require('./gui/checkboxs')
Gui.new_checkbox = Checkboxs.new_checkbox
Gui.new_radiobutton = Checkboxs.new_radiobutton
Gui.new_radiobutton_option_set = Checkboxs.new_option_set
Gui.inputs.checkboxs = Checkboxs

return Gui