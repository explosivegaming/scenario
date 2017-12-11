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

return Gui