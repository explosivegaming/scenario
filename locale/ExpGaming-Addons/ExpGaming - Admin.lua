--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Admin Gui',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='AA gui to help the server admins',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
local force_modifiers = {
	"manual_mining_speed_modifier",
	"manual_crafting_speed_modifier",
	"character_running_speed_modifier",
	"worker_robots_speed_modifier",
	"worker_robots_storage_bonus",
	"character_build_distance_bonus",
	"character_item_drop_distance_bonus",
	"character_reach_distance_bonus",
	"character_resource_reach_distance_bonus",
	"character_item_pickup_distance_bonus",
	"character_loot_pickup_distance_bonus"
}

ExpGui.add_frame.center('admin','Admin','A few admin only things','Admin',{{'commands','Admin'}})

ExpGui.add_input.button('set_mods','Save Changes','Edit the force modifiers',function(player,element)
	for i, modifier in pairs(force_modifiers) do
		local number = tonumber(( element.parent.parent.modifiers[modifier .. "_input"].text):match("[%d]+[.%d+]"))
		if number ~= nil then
			if number >= 0 and number < 50 and number ~= player.force[modifier] then
				player.force[modifier] = number
				player.print(modifier .. " changed to number: " .. tostring(number))
			elseif number == player.force[modifier] then
				player.print(modifier .. " Did not change")
			else
				player.print(modifier .. " needs to be player higher number or it contains an letter")
			end
		end
	end
end)

ExpGui.add_frame.tab('modifiers','Modifiers','Some Force Modifiers','Admin','admin',function(player,frame)
    frame.add{type = "flow", name= "flow",direction = "horizontal"}
    frame.add{name="modifiers", type="table", colspan=3}
    frame.modifiers.add{name="Mname", type="label", caption="name"}
    frame.modifiers.add{name="input", type="label", caption="input"}
    frame.modifiers.add{name="current", type="label", caption="current"}
    for i, modifier in pairs(force_modifiers) do
      frame.modifiers.add{name=modifier, type="label", caption=modifier}
      frame.modifiers.add{name=modifier .. "_input", type="textfield", caption="inputTextField"}
      frame.modifiers.add{name=modifier .. "_current", type="label", caption=tostring(player.force[modifier])}
    end
    ExpGui.add_input.draw_button(frame.flow,'set_mods')
end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits