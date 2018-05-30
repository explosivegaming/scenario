--- Root Script File
-- @script control.lua
function _log(...) log(...) end
--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
Manager = require("FactorioSoftmodManager")
Manager.setVerbose{
    selfInit=true, -- called while the manager is being set up
    moduleLoad=true, -- when a module is required by the manager
    moduleInit=true, -- when and within the initation of a module
    moduleEnv=true, -- during module runtime, this is a global option set within each module for fine control
    eventRegistered=false, -- when a module registers its event handlers
    errorCaught=true, -- when an error is caught during runtime
    output=Manager._verbose -- can be: can be: print || log || other function
}
Manager() -- can be Manager.loadModules() if called else where