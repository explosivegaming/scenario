--- Allows control over decon rights, if ExpGamingCore.Role is not installed it will allow admins to instant remove trees and thats it.
-- @module DeconControl@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alias ThisModule

-- Module Require
local Game = require('FactorioStdLib.Game')
local Server = require('ExpGamingCore.Server')
local Role -- ExpGamingCore.Role@^4.0.0
local Admin -- ExpGamingAdmin@^4.0.0

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Role'] then Role = require('ExpGamingCore.Role') end
        if loaded_modules['ExpGamingAdmin'] then Admin = require('ExpGamingAdmin') end
    end
}

-- Event Handlers Define
Event.register(-1,function(event)
    Server.new_thread{
        name='tree-decon',
        data={trees={},cache={},clear=0}
    }:on_event('tick',function(self)
        local trees = self.data.trees
        if self.data.clear ~= 0 and self.data.clear < game.tick then self.data.cache = {} self.data.clear = 0 end
        if #trees == 0 then return end
        for i = 0,math.ceil(#trees/10) do
            local tree = table.remove(trees,1)
            if tree and tree.valid then tree.destroy() end
        end
    end):on_event(defines.events.on_marked_for_deconstruction,function(self,event)
        local cache = self.data.cache[event.player_index]
        if not cache then
            local player = Game.get_player(event)
            if not player then return end
            if not Role then 
                if player.admin then self.data.cache[event.player_index] = {'tree-decon',false}
                else self.data.cache[event.player_index] = {'decon',false} end
            else
                if Role.allowed(player,'tree-decon') then self.data.cache[event.player_index] = {'tree-decon',false}
                elseif not Role.allowed(player,'decon') then self.data.cache[event.player_index] = {'no-decon',false} 
                else self.data.cache[event.player_index] = {'decon',false} end
            end
            cache = self.data.cache[event.player_index]
        end
        if not event.entity.last_user or event.entity.name == 'entity-ghost' then
            if cache[1] == 'tree-decon' then
                table.insert(self.data.trees,event.entity)
                self.data.clear = game.tick + 10
            end
        else
            if cache[1] == 'no-decon' then
                event.entity.cancel_deconstruction('player')
                if not cache[2] then
                    cache[2] = true
                    local player = Game.get_player(event)
                    player_return({'DeconControl.player-print'},defines.textcolor.crit,player)
                    Role.print(Role.meta.groups.Admin.lowest,{'DeconControl.rank-print',player.name},defines.textcolor.info)
                    if Admin then Admin.give_warning(player,'<server>','Trying To Decon The Base') end
                end
                self.data.clear = game.tick + 10
            end
        end
    end):open()
end)

-- Module Return
return ThisModule