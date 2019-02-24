--[[ not_luadoc=true
function _log(...) log(...) end -- do not remove this is used for smaller verbose lines
Manager = require("FactorioSoftmodManager")
Manager.setVerbose{
    selfInit=true, -- called while the manager is being set up
    moduleLoad=false, -- when a module is required by the manager
    moduleInit=false, -- when and within the initation of a module
    modulePost=false, -- when and within the post of a module
    moduleEnv=false, -- during module runtime, this is a global option set within each module for fine control
    eventRegistered=false, -- when a module registers its event handlers
    errorCaught=true, -- when an error is caught during runtime
    output=Manager._verbose -- can be: can be: print || log || other function
}
Manager() -- can be Manager.loadModules() if called else where
]]


require 'utils.data_stages'
Container = require 'container'
Container.debug=false
Container.logLevel=Container.defines.logAll
Container.safeError=true
Container.handlers = {
    require=function(path,env,...)
        env = env or {}
        local success, rtn, sandbox_env = Container.sandbox(_R.require,env,path,...)
        return rtn
    end,
    Event='utils.event',
    Global='utils.global',
    --error=error,
    logging=function(...) log(...) end,
    tableToString=serpent.line
}
Container.loadHandlers()
Container.files = {
    'AdvancedStartingItems',
    'ChatPopup',
    'DamagePopup',
    'DeathMarkers',
    'DeconControl',
    'ExpGamingAdmin',
    'ExpGamingBot',
    'ExpGamingCommands',
    'ExpGamingCore',
    'ExpGamingInfo',
    'ExpGamingLib',
    'ExpGamingPlayer',
    'FactorioStdLib',
    'GameSettingsGui',
    'GuiAnnouncements',
    'PlayerAutoColor',
    'SpawnArea',
    'WarpPoints',
    'WornPaths',
    'ExpGamingAdmin.Gui',
    'ExpGamingAdmin.Ban',
    'ExpGamingAdmin.Reports',
    'ExpGamingAdmin.ClearInventory',
    'ExpGamingAdmin.TempBan',
    'ExpGamingAdmin.Teleport',
    'ExpGamingAdmin.Commands',
    'ExpGamingAdmin.Jail',
    'ExpGamingAdmin.Warnings',
    'ExpGamingAdmin.Kick',
    'ExpGamingBot.autoMessage',
    'ExpGamingBot.discordAlerts',
    'ExpGamingBot.autoChat',
    'ExpGamingCommands.cheatMode',
    'ExpGamingCommands.repair',
    'ExpGamingCommands.tags',
    'ExpGamingCommands.home',
    'ExpGamingCore.Command',
    'ExpGamingCommands.teleport',
    'ExpGamingCommands.bonus',
    'ExpGamingCommands.kill',
    'ExpGamingCore.Server',
    'ExpGamingCore.Gui',
    'ExpGamingInfo.Science',
    'ExpGamingPlayer.playerList',
    'ExpGamingCore.Sync',
    'ExpGamingCore.Role',
    'ExpGamingInfo.Readme',
    'ExpGamingInfo.Rockets',
    'ExpGamingCore.Group',
    'ExpGamingInfo.Tasklist',
    'ExpGamingPlayer.playerInfo',
    'ExpGamingPlayer.afkKick',
    'FactorioStdLib.Table',
    'ExpGamingPlayer.polls',
    'FactorioStdLib.Color',
    'FactorioStdLib.Game',
    'FactorioStdLib.String',
    'ExpGamingPlayer.inventorySearch',
    'ExpGamingCore.Gui.center',
    'ExpGamingCore.Gui.popup',
    'ExpGamingCore.Gui.toolbar',
    'ExpGamingCore.Gui.left',
    'ExpGamingCore.Gui.inputs'
}
Container.loadFiles()
Container.initFiles()
Container.postFiles()