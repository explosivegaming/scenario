local Gui = require 'utils.gui'

Gui._prototype = {}
Gui.inputs = {}
Gui.structure = {}
Gui.outputs = {}

function Gui._extend_prototype(tbl)
    for k,v in pairs(Gui._prototype) do
        if not tbl[k] then tbl[k] = v end
    end
end

--- Sets the caption for the element config
function Gui._prototype:set_caption(caption)
    self.caption = caption
end

--- Sets the tooltip for the element config
function Gui._prototype:set_tooltip(tooltip)
    self.tooltip = tooltip
end

function Gui.toggle_enable(element)
    if not element or not element.valid then return end
    if not element.enabled then
        -- this way round so if its nil it will become false
        element.enabled = true
    else
        element.enabled = false
    end
end

function Gui.toggle_visible(element)
    if not element or not element.valid then return end
    if not element.visible then
        -- this way round so if its nil it will become false
        element.visible = true
    else
        element.visible = false
    end
end

return Gui