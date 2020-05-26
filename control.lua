
--- Please go to ./config if you want to change settings, each file is commented with what it does
-- if it is not in ./config then you should not attempt to change it unless you know what you are doing
-- all files which are loaded (including the config files) are present in ./config/file_loader.lua
-- this file is the landing point for all scenarios please DO NOT edit directly, further comments are to aid development

log('[START] -----| Explosive Gaming Scenario Loader |-----')
log('[INFO] Setting up lua environment')

-- Require the global overrides
require 'overrides.stages' -- Data stages used in factorio, often used to test for runtime
require 'overrides.print' -- Overrides the _G.print function
require 'overrides.math' -- Omitting the math library is a very bad idea
require 'overrides.table' -- Adds alot more functions to the table module
global.version = require 'overrides.version' -- The current version for exp gaming scenario
inspect = require 'overrides.inspect' -- Used to covert any value into human readable string
Debug = require 'overrides.debug' -- Global Debug module
_C = require 'expcore.common' -- _C is used to store lots of common functions expected to be used

-- Please go to config/file_loader.lua to edit the files that are loaded
log('[INFO] Getting file loader config')
local files = require 'config._file_loader' --- @dep config._file_loader

-- Loads all files from the config and logs that they are loaded
local total_file_count = string.format('%3d', #files)
local errors = {}
for index, path in pairs(files) do

    -- Loads the next file in the list
    log(string.format('[INFO] Loading file %3d/%s (%s)', index, total_file_count, path))
    local success, file = pcall(require, path)

    -- Error Checking
    if not success then
        -- Failed to load a file
        log('[ERROR] Failed to load file: '..path)
        table.insert(errors, '[ERROR] '..path..' :: '..file)
    elseif type(file) == 'string' and file:find('not found') then
        -- Returned a file not found message
        log('[ERROR] File not found: '..path)
        table.insert(errors, '[ERROR] '..path..' :: Not Found')
    end

end

-- Override the default require; require can no longer load new scripts
log('[INFO] Require Overright! No more requires can be made!')
require 'overrides.require'

-- Logs all errors again to make it make it easy to find
log('[INFO] All files loaded with '..#errors..' errors:')
for _, error in pairs(errors) do log(error) end
log('[END] -----| Explosive Gaming Scenario Loader |-----')