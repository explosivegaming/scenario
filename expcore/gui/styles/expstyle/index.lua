--[[-- Core Module - ExpStyle
    @core ExpStyle
]]

local function r(name)
    require('expcore.gui.styles.expstyle.'..name)
end

r 'container'
r 'alignment'
r 'header'
r 'scroll_table'
r 'time_label'