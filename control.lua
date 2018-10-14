-- not_luadoc=true
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