--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]

local Gui = {}
local Gui_data = {}

-- this is to enforce the read only propetry of the gui
function Gui._add_data(key,value_key,value) 
    if game then return end 
    if not Gui_data[key] then Gui_data[key] = {} end
    Gui_data[key][value_key] = value
end

function Gui._get_data(key) return Gui_data[key] end

function Gui:_load_parts(parts)
    for _,part in pairs(parts) do
        self[part] = require('/GuiParts/'..part)
    end
end

function Gui.bar(frame,width)
    local line = frame.add{
        type='progressbar',
        size=1,
        value=1
    }
    line.style.height = 3
    line.style.width = width or 10
    line.style.color = defines.color.white
    return line
end

Event.register(defines.events.on_tick, function(event)
	if (event.tick/(3600*game.speed)) % 15 == 0 then
		Gui.left.update()
	end
end)

return Gui