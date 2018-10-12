local warps = warps
local self = self

commands.add_command('make-warp', 'Make a warp point at your location', {
    ['name']={true,'string-inf'}
}, function(event,args)
    if not game.player then return end
    local position = game.player.position
    local name = args.name
    if game.player.gui.top[name] then player_return({'warp-system.name-used'},defines.textcolor.med) return commands.error end
    if warps.warps[name] then player_return({'warp-system.name-used'},defines.textcolor.med) return commands.error end
    if position.x^2 + position.y^2 < 100 then player_return({'warp-system.too-close'},defines.textcolor.med) return commands.error end
    -- to do add a test for all warps
    self.make_warp_point(position,game.player.surface,game.player.force,name)
end)