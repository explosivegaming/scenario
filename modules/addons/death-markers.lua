local Event = require 'utils.event'
local Game = require 'utils.game'
local Global = require 'utils.global'
local Commands = require 'expcore.commands'
local config = require 'config.death_markers'
local opt_require = ext_require('expcore.common','opt_require')
opt_require 'config.command_auth_runtime_disable' -- if the file is present then we can disable the commands