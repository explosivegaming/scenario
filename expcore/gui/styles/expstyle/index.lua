--[[-- Core Module - ExpStyle
    @module ExpStyle
    @alias expstyle
]]

--- @dep expcore.gui

--- @dep gui.concept.frame

--- @dep gui.concept.flow

--- @dep gui.concept.table

--- @dep gui.concept.scroll

local function r(name)
    require('expcore.gui.styles.expstyle.'..name)
end

r 'container'
r 'alignment'
r 'header'
r 'footer'
r 'scroll_table'
r 'time_label'
r 'data_label'
r 'unit_label'
r 'toggle_button'