
--- Please go to ./config if you want to change settings, each file is commented with what it does
-- if it is not in ./config then you should not attempt to change it unless you know what you are doing
-- all files which are loaded (including the config files) are present in ./config/file_loader.lua
-- this file is the landing point for all scenarios please DO NOT edit directly, further comments are to aid development

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

-- Global require function used to extract parts of a module, because simply being in common is not good enough
ext_require = require('expcore.common').ext_require

-- Please go to config/file_loader.lua to edit the files that are loaded
local files = require 'config.file_loader'

-- Loads all files from the config and logs that they are loaded
local total_file_count = string.format('%3d',#files)
local errors = {}
for index,path in pairs(files) do

    -- Loads the next file in the list
    log(string.format('[INFO] Loading files %3d/%s (%s)',index,total_file_count,path))
    local success,file = pcall(require,path)

    -- Error Checking
    if not success then
        -- Failed to load a file
        log('[ERROR] Failed to load file: '..path)
        log('[ERROR] '..file)
        table.insert(errors,'[ERROR] '..path..' :: '..file)
    elseif type(file) == 'string' and file:find('not found') then
        -- Returned a file not found message
        log('[ERROR] File not found: '..path)
        table.insert(errors,'[ERROR] '..path..' :: Not Found')
    end

end

-- Logs all errors again to make it make it easy to find
log('[INFO] All files loaded with '..#errors..' errors:')
for _,error in pairs(errors) do log(error) end