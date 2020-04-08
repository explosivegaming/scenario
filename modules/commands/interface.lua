--[[-- Commands Module - Interface
    - Adds a command that acts as a direct link to the the active softmod, for debug use
    @commands Interface
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local Global = require 'utils.global' --- @dep utils.global
local Common = require 'expcore.common' --- @dep expcore.common

-- modules that are loaded into the interface env to be accessed
local interface_modules = {
    ['Game']='utils.game',
    ['_C']=Common,
    ['Commands']=Commands,
    ['output']=Common.player_return,
    ['Group']='expcore.permission_groups',
    ['Roles']='expcore.roles',
    ['Store']='expcore.store',
    ['Gui']='expcore.gui',
    ['Async']='expcore.async'
}

-- loads all the modules given in the above table
for key,value in pairs(interface_modules) do
    if type(value) == 'string' then
        interface_modules[key] = Common.opt_require(value)
    end
end

local interface_env = {} -- used as a persistent sandbox for interface commands
local interface_callbacks = {} -- saves callbacks which can load new values per use
Global.register({
    interface_env = interface_env,
    interface_callbacks = interface_callbacks
},function(tbl)
    interface_env = tbl.interface_env
    interface_callbacks = tbl.interface_callbacks
end)

--- Adds a callback function when the interface command is used
-- nb: returned value is saved in the env that the interface uses
-- @tparam string name the name that the value is loaded under, cant use upvalues
-- @tparam function callback the function that will run whent he command is used
-- callback param - player: LuaPlayer - the player who used the command
local function add_interface_callback(name,callback)
    if type(callback) == 'function' then
        interface_callbacks[name] = callback
    end
end

-- this is a meta function for __index when self[key] is nil
local function get_index(self,key)
    if interface_env[key] then
        return interface_env[key]
    elseif interface_modules[key] then
        return interface_modules[key]
    end
end

--- Sends an innovation to be ran and returns the result.
-- @command interface
-- @tparam string innovation the command that will be run
Commands.new_command('interface','Sends an innovation to be ran and returns the result.')
:add_param('innovation',false)
:enable_auto_concat()
:set_flag('admin_only')
:register(function(player,innovation,raw)
    if not innovation:find('%s') and not innovation:find('return') then
        -- if there are no spaces and return is not present then return is appended to the start
        innovation='return '..innovation
    end
    -- temp_env will index to interface_env and interface_modules if value not found
    local temp_env = setmetatable({},{__index=get_index})
    if player then -- player can be nil when it is the server
        for name,callback in pairs(interface_callbacks) do
            -- loops over callbacks and loads the values returned
            local success, rtn = pcall(callback,player)
            temp_env[name]=rtn
        end
    end
    -- sets the global metatable to prevent new values being made
    -- global will index to temp_env and new indexs saved to interface_sandbox
    local old_mt = getmetatable(_G)
    setmetatable(_G,{__index=temp_env,__newindex=interface_env})
    -- runs the innovation and returns values to the player
    innovation = loadstring(innovation)
    local success, rtn = pcall(innovation)
    setmetatable(_G,old_mt)
    if not success then
        if type(rtn) == 'string' then
            -- there may be stack trace that must be removed to avoid desyncs
            rtn = rtn:gsub('%.%.%..-/temp/currently%-playing','')
        end
        return Commands.error(rtn)
    else
        return Commands.success(rtn)
    end
end)

-- adds some basic callbacks for the interface
add_interface_callback('player',function(player) return player end)
add_interface_callback('surface',function(player) return player.surface end)
add_interface_callback('force',function(player) return player.force end)
add_interface_callback('position',function(player) return player.position end)
add_interface_callback('entity',function(player) return player.selected end)
add_interface_callback('tile',function(player) return player.surface.get_tile(player.position) end)

return {
    add_interface_callback=add_interface_callback,
    interface_env=interface_env,
    interface_callbacks=interface_callbacks,
    clean_stack_trace=function(str) return str:gsub('%.%.%..-/temp/currently%-playing','') end
}