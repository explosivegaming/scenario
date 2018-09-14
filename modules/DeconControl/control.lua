--- Allows control over decon rights, if ExpGamingCore.Ranking is not installed it will allow admins to instant remove trees and thats it.
-- @module DeconControl@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ThisModule 

-- Module Require
local Game = require('FactorioStdLib.Game@^0.8.0')
local Server = require('ExpGamingCore.Server@^4.0.0')
local Ranking -- ExpGamingCore.Ranking@^4.0.0

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Ranking@^4.0.0'] then Ranking = require('ExpGamingCore.Ranking@^4.0.0') end
    end
}

-- Event Handlers Define
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
            if not player then return end
            if not Ranking then 
                if player.admin then self.data.chache[event.player_index] = {'tree-decon',false}
                else self.data.chache[event.player_index] = {'decon',false} end
            else
                local rank = Ranking.get_rank(player)
                if rank:allowed('tree-decon') then self.data.chache[event.player_index] = {'tree-decon',false}
                elseif not rank:allowed('decon') then self.data.chache[event.player_index] = {'no-decon',false} 
                else self.data.chache[event.player_index] = {'decon',false} end
            end
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
                    player_return({'tree-decon.player-print'},defines.textcolor.crit,player)
                    local rank = Ranking.get_group('Admin').lowest
                    Ranking.print(rank,{'tree-decon.rank-print',player.name},defines.textcolor.info)
                    if Admin then Admin.give_warning(player,'<server>','Trying To Decon The Base') end
                end
                self.data.clear = game.tick + 10
            end
        end
    end):open()
end)

-- Module Return
return ThisModule 