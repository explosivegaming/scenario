--[[-- Core Module - Gui
- Used to define new gui elements and gui event handlers
@module Gui
]]

local Gui = require 'expcore.gui.prototype'

--[[-- Draw a flow that has custom element alignments, default is right align
@element Gui.alignment
@tparam LuaGuiElement parent the parent element that the alignment flow will be added to
@tparam[opt='right'] string horizontal_align the horizontal alignment of the elements in the flow
@tparam[opt='center'] string vertical_align the vertical alignment of the elements in the flow
@tparam[opt='alignment'] string name the name of the alignment flow
@treturn LuaGuiElement the alignment flow that was created

@usage-- Adding a right align flow
local alignment = Gui.alignment(element,'example_right_alignment')

@usage-- Adding a horizontal center and top align flow
local alignment = Gui.alignment(element,'example_center_top_alignment','center','top')

]]
Gui.alignment =
Gui.element(function(_,parent,_,_,name)
    return parent.add{
        name = name or 'alignment',
        type = 'flow',
    }
end)
:style(function(style,_,horizontal_align,vertical_align,_)
    style.padding = {1,2}
    style.vertical_align = vertical_align or 'center'
    style.horizontal_align = horizontal_align or 'right'
    style.vertically_stretchable  = style.vertical_align ~= 'center'
    style.horizontally_stretchable = style.horizontal_align ~= 'center'
end)

--[[-- Draw a scroll pane that has a table inside of it
@element Gui.scroll_table
@tparam LuaGuiElement parent the parent element that the scroll table will be added to
@tparam number height the maximum height for the scroll pane
@tparam number column_count the number of columns that the table will have
@tparam[opt='scroll'] string name the name of the scroll pane that is added, the table is always called 'table'
@treturn LuaGuiElement the table that was created

@usage-- Adding a scroll table with max height of 200 and column count of 3
local scroll_table = Gui.scroll_table(element,'example_scroll_table',200,3)

]]
Gui.scroll_table =
Gui.element(function(_,parent,_,column_count,name)
    -- Draw the scroll
    local scroll_pane =
    parent.add{
        name = name or 'scroll',
        type = 'scroll-pane',
        direction = 'vertical',
        horizontal_scroll_policy = 'never',
        vertical_scroll_policy = 'auto',
        style = 'scroll_pane_under_subheader'
    }

    -- Draw the table
    local scroll_table =
    scroll_pane.add{
        type = 'table',
        name = 'table',
        column_count = column_count
    }

    -- Return the scroll table
    return scroll_table
end)
:style(function(style,element,height,_,_)
    -- Change the style of the scroll
    local scroll_style = element.parent.style
    scroll_style.padding = {1,3}
    scroll_style.maximal_height = height
    scroll_style.horizontally_stretchable = true

    -- Change the style of the table
    style.padding = 0
    style.cell_padding = 0
    style.vertical_align = 'center'
    style.horizontally_stretchable = true
end)

--[[-- Used to add a header to a frame, this has the option for a custom right alignment flow for buttons
@element Gui.header
@tparam LuaGuiElement parent the parent element that the header will be added to
@tparam ?string|Concepts.LocalizedString caption the caption that will be shown on the header
@tparam[opt] ?string|Concepts.LocalizedString tooltip the tooltip that will be shown on the header
@tparam[opt=false] boolean add_alignment when true an alignment flow will be added for buttons
@tparam[opt='header'] string name the name of the header that is being added, the alignment is always called 'alignment'
@treturn LuaGuiElement either the header or the header alignment if add_alignment is true

@usage-- Adding a custom header with a label
local header_alignment = Gui.header(
    element,
    'Example Caption',
    'Example Tooltip',
    true
)

]]
Gui.header =
Gui.element(function(_,parent,caption,tooltip,add_alignment,name)
    -- Draw the header
    local header =
    parent.add{
        name = name or 'header',
        type = 'frame',
        style = 'subheader_frame'
    }

    -- Change the style of the header
    local style = header.style
    style.padding = {2,4}
    style.use_header_filler = false
    style.horizontally_stretchable = true

    -- Draw the caption label
    if caption then
        header.add{
            name = 'header_label',
            type = 'label',
            style = 'heading_1_label',
            caption = caption,
            tooltip = tooltip
        }
    end

    -- Return either the header or the added alignment
    return add_alignment and Gui.alignment(header) or header
end)

--[[-- Used to add a footer to a frame, this has the option for a custom right alignment flow for buttons
@element Gui.header
@tparam LuaGuiElement parent the parent element that the footer will be added to
@tparam ?string|Concepts.LocalizedString caption the caption that will be shown on the footer
@tparam[opt] ?string|Concepts.LocalizedString tooltip the tooltip that will be shown on the footer
@tparam[opt=false] boolean add_alignment when true an alignment flow will be added for buttons
@tparam[opt='footer'] string name the name of the footer that is being added, the alignment is always called 'alignment'
@treturn LuaGuiElement either the footer or the footer alignment if add_alignment is true

@usage-- Adding a custom footer with a label
local header_alignment = Gui.footer(
    element,
    'Example Caption',
    'Example Tooltip',
    true
)

]]
Gui.footer =
Gui.element(function(_,parent,caption,tooltip,add_alignment,name)
    -- Draw the header
    local footer =
    parent.add{
        name = name or 'footer',
        type = 'frame',
        style = 'subfooter_frame'
    }

    -- Change the style of the footer
    local style = footer.style
    style.padding = {2,4}
    style.use_header_filler = false
    style.horizontally_stretchable = true

    -- Draw the caption label
    if caption then
        footer.add{
            name = 'footer_label',
            type = 'label',
            style = 'heading_1_label',
            caption = caption,
            tooltip = tooltip
        }
    end

    -- Return either the footer or the added alignment
    return add_alignment and Gui.alignment(footer) or footer
end)

--[[-- Used for left frame to add a nice boarder to them and contain them
@element Gui.container
@tparam LuaGuiElement parent the parent element that the container will be added to
@tparam string name the name that you want to give the outer frame, often just event_trigger for a left frame
@tparam number width the minimal width that the frame will have

@usage-- Adding a container as a base
local container = Gui.container(parent,'my_container',200)

]]
Gui.container =
Gui.element(function(_,parent,name,_)
    -- Draw the external container
    local frame =
    parent.add{
        name = name,
        type = 'frame'
    }

    -- Return the container
    return frame.add{
        name = 'container',
        type = 'frame',
        direction = 'vertical',
        style = 'window_content_frame_packed'
    }
end)
:style(function(style,element,_,width)
    style.vertically_stretchable = false
    local frame_style = element.parent.style
    frame_style.padding = 2
    frame_style.minimal_width = width
end)