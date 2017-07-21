--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Repair Command',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Allows fast repairing of the factory after a biter attck or grifer',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
define_command('repair','Used to repair large parts of the factory. Admin can use all as range.',{'range'},'Mod',function(player,event,args)
    if player == '<server>' then
        for key, entity in pairs(game.surfaces[1].find_entities_filtered({type = "entity-ghost"})) do entity.revive() end
		for key, entity in pairs(game.surfaces[1].find_entities()) do if entity.health then entity.health = 10000 end end
		print('Command Complete') return
    else
        if args[1] == 'all' then 
            if get_rank(player).power > string_to_rank('Admin').power then player.print('401 - Unauthorized: Access is denied due to invalid credentials') return end
            for key, entity in pairs(game.surfaces[1].find_entities_filtered({type = "entity-ghost"})) do entity.revive() end
            for key, entity in pairs(game.surfaces[1].find_entities()) do if entity.health then entity.health = 10000 end end return
        elseif tonumber(args[1]) and tonumber(args[1]) < 50 and tonumber(args[1]) > 0 then
            local range = tonumber(args[1])
            local pos = player.position
            for key, entity in pairs(game.surfaces[1].find_entities_filtered({area={{pos.x-range,pos.y-range},{pos.x+range,pos.y+range}},type = "entity-ghost"})) do entity.revive() end
			for key, entity in pairs(game.surfaces[1].find_entities({{pos.x-range,pos.y-range},{pos.x+range,pos.y+range}})) do if entity.health then entity.health = 10000 end end return
        else player.print('Invaild Range, must be number below 50')
        end
    end
end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits