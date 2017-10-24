--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
define_command('temp-ban',{'temp-ban.help'},{'player','reason',true},function(player,event,args)
    if player == '<server>' then
        local jail_player = game.players[args[1]]
        if not jail_player then print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
        ranking.give_rank(jail_player,'Jail')
        table.insert(global.temp_bans,{jail_player.name,player,table.concat(args,' ',2),jail_player})
        ExpGui.draw_frame.popup('temp_ban',{player,table.concat(args,' ',2)})
        ranking.rank_print(jail_player.name..' has been temp banned by '..player..' reason: '..table.concat(args,' ',2),'Guest')
        game.write_file('multi.log','\n{"type":"TEMP_BAN","tick":'..game.tick..',"username":"'..jail_player.name..'","by":"<server>","reason":"'..table.concat(args,' ',2)..'"}\n', true, 0)
        jail_player.gui.center.clear()
        for _,gui in pairs(mod_gui.get_frame_flow(jail_player).children) do gui.style.visible = false end
        mod_gui.get_frame_flow(jail_player).popups.style.visible = true
    else
        local jail_player = game.players[args[1]]
        if not jail_player then player.print{'commands.invalid-player',args[1]} return end
        if ranking.get_player_rank(player).power < ranking.get_player_rank(jail_player).power then
            server.queue_callback(ranking.give_rank,{jail_player,'Jail',player})
            global.temp_bans[jail_player.name] = {player.name,table.concat(args,' ',2)}
            ExpGui.draw_frame.popup('temp_ban',{player.name,table.concat(args,' ',2),jail_player})
            ranking.rank_print({'temp-ban.text',jail_player.name,player.name,table.concat(args,' ',2)},'Guest')
            local online_mods=0; for _,player in pairs(game.connected_players) do if ranking.get_player_rank(player).power <= ranking.string_to_rank_group('Moderation').lowest_rank.power then online_mods=online_mods+1 end end
            json_log({type='TEMP_BAN',colour='#ff5400',tick=game.tick,online=#game.connected_players,onlineMods=online_mods,username=jail_player.name,by=player.name,reason=table.concat(args,' ',2)})
            jail_player.gui.center.clear()
            for _,gui in pairs(mod_gui.get_frame_flow(jail_player).children) do gui.style.visible = false end
            mod_gui.get_frame_flow(jail_player).popups.style.visible = true
        else player.print{'commands.unauthorized'} return end
    end
end)

ExpGui.add_frame.popup('temp_ban',{'temp-ban.name'},{'temp-ban.tooltip'},nil,function(player,frame,args)
    if player == args[3] then
        frame.add{name='title',type='label',caption={'temp-ban.title'},style="caption_label_style"}
        frame.add{name='info',type='label',caption={'temp-ban.info'}}
        frame.add{name='by_player',type='label',caption={'temp-ban.by-player',args[1]}}
        frame.add{name='reason',type='label',caption={'temp-ban.reason',args[2]}}
    else frame.parent.destroy()
    end
end)

Event.register(defines.events.on_player_joined_game,function(event)
    local player = game.players[event.player_index]
    if global.temp_bans[player.name] then
        player.gui.center.clear()
        for _,gui in pairs(mod_gui.get_frame_flow(player).children) do gui.style.visible = false end
        mod_gui.get_frame_flow(player).popups.style.visible = true 
        ExpGui.draw_frame.popup('temp_ban',{global.temp_bans[player.name][1],global.temp_bans[player.name][2],player})
    end
end)

function get_temp_bans() return global.temp_bans end
Event.register(Event.soft_init,function() global.temp_bans = {} end)


