--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

--[[
    How to use groups:
name		the name that you can use to refence it.
disallow	if present then all ranks in this group will have this added to their disallow.
allow		if present then all ranks in this group will have this added to their allow.
highest     is asigned by the script to show the highest rank in this group.
lowest      is asigned by the script to show the lowest rank in this group.
How to add ranks:
Name		is what will be used in the scripts and is often the best choice for display in text.
short_hand	is what can be used when short on space but the rank still need to be displayed.
tag			is the tag the player will gain when moved to the rank, it can be nil.
time		is used for auto-rank feature where you are moved to the rank after a certain play time in minutes.
colour		is the RGB value that can be used to emphasise GUI elements based on rank.
power		is asigned by the script based on their index in ranks, you can insert new ranks between current ones.
group		is asigned by the script to show the group this rank is in
disallow	is a list containing input actions that the user can not perform.
allow		is a list of custom commands and effects that that rank can use, all defined in the sctips.

For allow, add the allow as the key and the value as true
Example: test for 'server-interface' => allow['server-interface'] = true

For disallow, add to the list the end part of the input action
Example: defines.input_action.drop_item -> 'drop_item'
http://lua-api.factorio.com/latest/defines.html#defines.input_action
--]]

-- see ExpCore/ranks.lua for examples - you add your own and edit pre-made ones here.

function Ranking._base_preset()
    return {}
end