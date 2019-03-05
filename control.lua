-- If you're looking to configure anything, you want config.lua. Nearly everything in this file is dictated by the config.

-- Info on the data lifecycle and how we use it: https://github.com/Refactorio/RedMew/wiki/The-data-lifecycle
require 'resources.data_stages'
_LIFECYCLE = _STAGE.control -- Control stage

-- Overrides the _G.print function
require 'utils.print_override'

-- Omitting the math library is a very bad idea
require 'utils.math'

-- Global Debug and make sure our version file is registered
Debug = require 'utils.debug'
require 'resources.version'

local files = {
    'modules.test',
    'modules.commands.me',
    'modules.commands.kill',
    'modules.commands.admin-chat',
    'modules.commands.tag',
    'modules.commands.teleport',
}

-- Loads all files in array above and logs progress
local total_files = string.format('%3d',#files)
local errors = {}
for index,path in pairs(files) do
    log(string.format('[INFO] Loading files %3d/%s',index,total_files))
    local success,file = pcall(require,path)
    -- error checking
    if not success then
        log('[ERROR] Failed to load file: '..path)
        log('[ERROR] '..file)
        table.insert(errors,'[ERROR] '..path..' :: '..file)
    elseif type(file) == 'string' and file:find('not found') then
        log('[ERROR] File not found: '..path)
        table.insert(errors,'[ERROR] '..path..' :: Not Found')
    end
end
log('[INFO] All files loaded with '..#errors..' errors:')
for _,error in pairs(errors) do log(error) end -- logs all errors again to make it make it easy to find