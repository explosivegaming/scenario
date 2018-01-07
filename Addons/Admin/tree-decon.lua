--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

Event.register(-1,function(event)
    Server.new_thread{
        name='tree-decon',
        data={trees={},chache={},clear=0}
    }:on_event('tick',function(self)
        local trees = self.data.trees
        if self.data.clear ~= 0 and self.data.clear < game.tick then self.data.chache = {} self.data.clear = 0 end
        if #trees == 0 then return end
        for i = 0,math.ceil(#trees/10) do
            local tree = table.remove(trees,1)
            if tree and tree.valid then tree.destroy() end
        end
    end):on_event(defines.events.on_marked_for_deconstruction,function(self,event)
        local chache = self.data.chache[event.player_index]
        if not chache then
            local player = Game.get_player(event)
            local rank = Ranking.get_rank(player)
            if rank:allowed('tree-decon') then self.data.chache[event.player_index] = {'tree-decon',false}
            elseif not rank:allowed('decon') then self.data.chache[event.player_index] = {'no-decon',false} 
            else self.data.chache[event.player_index] = {'decon',false} end
            chache = self.data.chache[event.player_index]
        end
        if not event.entity.last_user or event.entity.name == 'entity-ghost' then
            if chache[1] == 'tree-decon' then
                table.insert(self.data.trees,event.entity)
                self.data.clear = game.tick + 10
            end
        else
            if chache[1] == 'no-decon' then
                event.entity.cancel_deconstruction('player')
                if not chache[2] then
                    chache[2] = true
                    local player = Game.get_player(event)
                    player_return({'tree-decon.player-print'},defines.text_color.crit,player)
                    local rank = Ranking.get_group('Admin').lowest
                    Ranking.print(rank,{'tree-decon.rank-print',player.name},defines.text_color.info)
                    Admin.give_warning(player,'<server>','Trying To Decon The Base')
                end
                self.data.clear = game.tick + 10
            end
        end
    end):open()
end)