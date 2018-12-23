local warp_min_distance = warp_min_distance^2
local warps = warps
local self = self

commands.add_command('make-warp', 'Make a warp point at your location', {
    ['name']={true,'string-inf'}
}, function(event,args)
    if not game.player then return end
    local position = game.player.position
    local name = args.name
    if anme:len() > 40 then player_return({'ExpGamingCore_Command.error-string-len',40},defines.textcolor.med) return commands.error end
    if game.player.gui.top[name] then player_return({'WarpPoints.name-used'},defines.textcolor.med) return commands.error end
    if warps.warps[name] then player_return({'WarpPoints.name-used'},defines.textcolor.med) return commands.error end
    for name,warp in pairs(warps.warps) do
        local dx = position.x-warp.position.x
        local dy = position.y-warp.position.y
        if dx^2 + dy^2 < warp_min_distance then player_return({'WarpPoints.too-close'},defines.textcolor.med) return commands.error end
    end
    -- to do add a test for all warps
    self.make_warp_point(position,game.player.surface,game.player.force,name)
end)