local Event = require 'utils.event' ---@dep utils.event
local Datastore = require 'expcore.datastore' --- @dep expcore.datastore

local graftorioGlobal = Datastore.connect('graftorio')

-- this is prep for graftorio, as otherwise it bugs out
prometheus = require('modules.graftorio.prometheus.prometheus')
require('modules.graftorio.graftorio_utils')
-- local handler = require('event_handler')
gauges = {}
histograms = {}

local statics = require 'modules.graftorio.statics'
local force_stats = require 'modules.graftorio.force_stats'
local trains = require 'modules.graftorio.trains'
local power = require 'modules.graftorio.power'
local plugins = require 'modules.graftorio.plugins'
local remote = require 'modules.graftorio.remote'
local translation = require 'modules.graftorio.translation'

local export = require 'modules.graftorio.export'

Event.on_load(statics.on_load)
Event.on_init(statics.on_init)
for event, handler in pairs(statics.events) do
  Event.add(event, handler)
end

Event.on_load(force_stats.on_load)
Event.on_init(force_stats.on_init)
for event, handler in pairs(force_stats.events) do
  Event.add(event, handler)
end

Event.on_load(trains.on_load)
Event.on_init(trains.on_init)
for event, handler in pairs(trains.events) do
  Event.add(event, handler)
end

Event.on_load(power.on_load)
Event.on_init(power.on_init)
for event, handler in pairs(power.events) do
  Event.add(event, handler)
end

Event.on_load(plugins.on_load)
Event.on_init(plugins.on_init)
for event, handler in pairs(plugins.events) do
  Event.add(event, handler)
end

Event.on_load(remote.on_load)
Event.on_init(remote.on_init)

Event.on_load(translation.on_load)
Event.on_init(translation.on_init)
for event, handler in pairs(translation.events) do
  Event.add(event, handler)
end

-- Keep as last to export it all
Event.on_load(export.on_load)
Event.on_init(export.on_init)
for tick, handler in pairs(export["on_nth_tick"]) do
  Event.on_nth_tick(tick, handler)
end
for event, handler in pairs(export.events) do
  Event.add(event, handler)
end
-- Event.on_nth_tick(600, export["on_nth_tick"])