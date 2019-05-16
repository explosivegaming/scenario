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
Gui.draw_option_set = Checkbox.draw_option_set
Gui.classes.checkbox = Checkbox

local Dropdown = require('./gui/dropdown')
Gui.new_dropdown = Dropdown.new_dropdown
Gui.new_list_box = Dropdown.new_list_box
Gui.classes.dropdown = Dropdown

local Slider = require('./gui/slider')
Gui.new_slider = Slider.new_slider
Gui.classes.slider = Slider

local Text = require('./gui/text')
Gui.new_text_filed = Text.new_text_field
Gui.new_text_box = Text.new_text_box
Gui.classes.text = Text

local ElemButton = require('./gui/elem-button')
Gui.new_elem_button = ElemButton.new_elem_button
Gui.classes.elem_button = ElemButton

return Gui