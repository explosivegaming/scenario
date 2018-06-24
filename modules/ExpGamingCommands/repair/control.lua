--- A full ranking system for factorio.
-- @module ExpGamingCommands.kill
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE


local Game = require('FactorioStdLib.Game')
local Ranking = require('ExpGamingCore.Ranking')

-- Set an item to true to disallow it from being repaired
local disallow = {
    ['loader']=true,
    ['fast-loader']=true,
    ['express-loader']=true,
    ['electric-energy-interface']=true,
    ['infinity-chest']=true
}

-- Given const = 100: admin+ has unlimited, admin has const (100), mod has const / 2 (50), member has const / 5 (20)
local const = 100

--- Used so that the value can be overriden if tempban is present
-- @local
-- @function repairDisallow
-- @param player the player who called the command
-- @param entity the entity which was repaired
local repairDisallow = function(player,entity)
    player_return('You have repaired: '..entity.name..' this item is not allowed.',defines.text_color.crit,player)
    entity.destroy()
end

--- Used to repair and heal items in an area, different ranks get different size areas
-- @command repair
-- @param range the range that items are repaired in
commands.add_command('repair', 'Repairs all destoryed and damaged entites in an area.', {
    ['range']={true,'number-int'}
}, function(event,args)
    local range = args.range
    local player = Game.get_player(event)
    local rank = Ranking.get_rank(player)
    local highest_admin_power = Ranking.get_group('Admin').highest.power-1
    local max_range = rank.power-highest_admin_power > 0 and const/(rank.power-highest_admin_power) or nil
    local center = player and player.position or {x=0,y=0}
    if not range or max_range and range > max_range then player_return({'commands.invalid-range',0,math.floor(max_range)}) return commands.error end
    local area = {{center.x-range,center.y-range},{center.x+range,center.y+range}}
    local max_time_to_live = 2^32 - 1
    local sq_range = range^2
    for key, entity in pairs(player.surface.find_entities_filtered({area=area,type='entity-ghost'})) do
        if entity.force == player.force and (entity.position.x-center.x)^2+(entity.position.y-center.y)^2 < sq_range then
            if disallow[entity.ghost_prototype.name] then repairDisallow(player,entity)
            elseif entity.time_to_live ~= max_time_to_live then entity.revive() end
        end
    end
    for key, entity in pairs(player.surface.find_entities(area)) do
        if entity.force == player.force and (entity.position.x-center.x)^2+(entity.position.y-center.y)^2 < sq_range and entity.health then entity.health = 10000 end
    end
end)

return {
    on_init = function(self) 
        if loaded_modules['ExpGamingAdmin.TempBan'] then verbose('ExpGamingAdmin.TempBan is installed; Loading tempban src') repairDisallow = require(module_path..'/src/tempban') end
    end
}
