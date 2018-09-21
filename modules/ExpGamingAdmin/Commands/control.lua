--- A full ranking system for factorio.
-- @module ExpGamingAdmin.Commands@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Admin = require('ExpGamingAdmin.AdminLib@^4.0.0')

--- Used to clear all parts of a player, removing warnings, reports, jail and temp ban
-- @command clear-all
-- @param player the player to clear
commands.add_command('clear-all', 'Clears a player of any temp-ban, reports or warnings', {
    ['player']={true,'player'}
}, function(event,args)
    Admin.clear_player(args.player,event.player_index)
end)

return {
    on_init = function(self) 
        if loaded_modules['ExpGamingAdmin.TempBan'] then verbose('ExpGamingAdmin.TempBan is installed; Loading tempban src') require(module_path..'/src/tempban',{Admin=Admin}) end
        if loaded_modules['ExpGamingAdmin.Jail'] then verbose('ExpGamingAdmin.Jail is installed; Loading tempban src') require(module_path..'/src/jail',{Admin=Admin}) end
        if loaded_modules['ExpGamingAdmin.Warnings'] then verbose('ExpGamingAdmin.Warnings is installed; Loading tempban src') require(module_path..'/src/warnings',{Admin=Admin}) end
        if loaded_modules['ExpGamingAdmin.Reports'] then verbose('ExpGamingAdmin.Reports is installed; Loading tempban src') require(module_path..'/src/reports',{Admin=Admin}) end
        if loaded_modules['ExpGamingAdmin.ClearInventory'] then verbose('ExpGamingAdmin.ClearInventory is installed; Loading tempban src') require(module_path..'/src/clear',{Admin=Admin}) end
    end
}