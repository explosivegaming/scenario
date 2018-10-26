local Sync = Sync
local get_allowed_afk_time = self
local Server = require('ExpGamingCore.Server@^4.0.0')
Event[defines.events.on_tick] = nil

local function on_tick(self)
    -- the _env should be auto loaded but does not, so to prevent desyncs it cant be an anon function
    if (game.tick%3600) ~= 0 then return end
    for _,player in pairs(game.connected_players) do
        local afk = #game.connected_players < 3 and 10 or get_allowed_afk_time(player)
        if afk then
            if player.afk_time > afk*3600 then game.kick_player(player,'AFK For Too Long ('..math.floor(afk)..' Minutes)') end
        end
    end
end

local function on_error(self,err)
    -- the _env should be auto loaded but does not, so to prevent desyncs it cant be an anon function
    if Sync then
        Sync.emit_embeded{
            title='Auto Kick Error',
            color=Color.to_hex(defines.textcolor.bg),
            description='Auto Kick Error - Closed Thread',
            Error=err
        }
    end
    self:close()
end

script.on_init(function(event)
    Server.new_thread{
        name='afk-kick',
    }:on_event('tick',on_tick):on_event('error',function(self,err)
        ):open()
end)
