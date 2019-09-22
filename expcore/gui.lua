--[[-- Core Module - Gui
    @core Gui
    @alias Gui

@usage-- Making the base button concept
local button =
Gui.new_concept() -- Make a new empty concept
:save_as('button') -- Save it as Gui.concepts.button so it can be used in other files
:new_event('on_click',defines.events.on_gui_click) -- Add an on click event for this concept
:new_property('tooltip') -- Add a property with the default setter method called tooltip
:new_property('caption',function(properties,value) -- Add a property with a custom setter method called caption
    properties.caption = value
    properties.sprite = nil
    properties.type = 'button'
end)
:new_property('sprite',function(properties,value) -- Add a property with a custom setter method called sprite
    properties.image = value
    properties.caption = nil
    properties.type = 'sprite-button'
end)
:define_draw(function(properties,parent,element) -- Add the draw function to create the element from the concept
    -- Properties will include all the information that you need to draw the element
    -- Parent is the parent element for the element, this may have been altered by previous draw functions
    -- Element is the current element being made, this may have a nil value, if it is nil then this is the first draw function
    if properties.type == 'button' then
        element = parent.add{
            type = properties.type,
            name = properties.name,
            caption = properties.caption,
            tooltip = properties.tooltip
        }

    else
        element = parent.add{
            type = properties.type,
            name = properties.name,
            sprite = properties.sprite,
            tooltip = properties.tooltip
        }

    end

    -- If you return element or parent then their values will be updated for the next draw function in the chain
    -- It is best practice to always return the values if you have made any changes to them
    return element, parent
end)

@usage-- Making a new button which has a custom style
local custom_button =
Gui.new_concept('button') -- We can use button here since we used save as on the concept
-- button:clone() -- If we had not used save as then this is how we would use it as a base
:set_caption('Custom Button') -- Set the caption of the concept, this is possible as we added caption as a property
:set_tooltip('Only admins can press this button') -- Set the tooltip of the concept, this is possible as we added tooltip as a property
:on_click(function(event) -- Register a handler to the click event we added with new event
    if not event.player.admin then
        event.player.print('You must be admin to use this button')
    end
end)
:new_event('on_admin_clicked',defines.events.on_gui_click,function(event) -- Add a click event which has a filter function
    return event.player.admin -- Check if the player is admin
end)
:on_admin_clicked(function(event) -- Register a handler to the admin click event we have just created
    -- The admin click event is only an example, because of how sinmple the filter is we could have just used an if else statement
    game.print(event.player.name..' pressed my admin button')
end)

@usage-- Drawing a concept
custom_button:draw(game.player.gui.left)
]]

return require 'expcore.gui.core'