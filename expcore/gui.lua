-- This file is used to require all the different elements of the gui module
local Gui = require('./gui/core')

local Button = require('./gui/buttons')
Gui.new_button = Button.new_button
Gui.classes.button = Button

local Toolbar = require('./gui/toolbar')
Gui.new_toolbar_button = Toolbar.new_button
Gui.add_button_to_toolbar = Toolbar.add_button
Gui.update_toolbar = Toolbar.update
Gui.classes.toolbar = Toolbar

local Checkbox = require('./gui/checkboxs')
Gui.new_checkbox = Checkbox.new_checkbox
Gui.new_radiobutton = Checkbox.new_radiobutton
Gui.new_radiobutton_option_set = Checkbox.new_option_set
Gui.classes.checkbox = Checkbox

local Dropdown = require('./gui/dropdown')
Gui.new_dropdown = Dropdown.new_dropdown
Gui.new_list_box = Dropdown.new_list_box
Gui.classes.dropdown = Dropdown

return Gui