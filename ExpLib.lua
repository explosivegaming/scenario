--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

-- @module ExpLib
-- @usage require('/ExpLib')

local ExpLib = {
    text_hex = {
        ['']='0x0',
        info='0x36F2FF',
        alert='0x000000',
        low='0x2dc42d',
        med='0xffe242',
        high='0xff5400',
        crit='0xFF0000'
    },
    text_rgb = {
        ['']={0,0,0},
        info={54,242,255},
        alert={0,0,0},
        low={45,196,45},
        med={255,226,66},
        high={255,84,0},
        crit={255,0,0}
    }
}

--- Loads a table into the global lua table
-- @usage a = {k1='foo',k2='bar'}
-- _load_to_G(a)
-- @tparam table tbl table to add to the global lua table
function ExpLib._load_to_G(tbl)
    if not is_type(tbl,'table') or game then return end
    for name,value in pairs(tbl) do
        if not _G[name] then _G[name] = value end
    end
end

--- Returns a bolean based on the type of v matching the test type
-- @usage a = 'foo'
-- is_type(a,'string') -- return true
-- @param v the value to be tested
-- @tparam string test_type the type to test for
-- @treturn bolean is v a matching type
function ExpLib.is_type(v,test_type)
    return v and type(v) == test_type or false
end

--- Returns a value to the player or if no player then log the return
-- @usage a = 'to return'
-- player_return(a)
-- @param rtn the value to return
function ExpLib.player_return(rtn)
    if game.player then
        if is_type(rtn,'table') then game.player.print(table.to_string(rtn))
        elseif is_type(rtn,'function') then game.player.print('Cant Display Functions')
        elseif is_type(rtn,'userdata') then game.player.print('Cant Display Userdata')
        else game.player.print(tostring(rtn))
        end
    else
        if is_type(rtn,'table') then log(table.to_string(rtn))
        elseif is_type(rtn,'function') then log('Cant Display Functions')
        elseif is_type(rtn,'userdata') then log('Cant Display Userdata')
        else log(tostring(rtn))
        end
    end
end

--- Logs an embed to the json.data we use a js script to add things we cant here
-- @usage a = 'some data'
-- json_emit('data','info',a)
-- @tparam string type the type of emit your programe will look for
-- @tparam string colour the colour based on the the text_hex use '' for no colour
-- @param data any data which you want to include this will also be conevert to json
function ExpLib.discord_emit(title,colour,description,fields,add_to_server_detail)
    if not is_type(title,'string') or
    not is_type(fields,'table') then return end
    local add_to_server_detail = add_to_server_detail or ''
    local colour = colour or ''
    local description or ''
    local log_data = {
        title=title
        description=description
        color=text_hex[colour],
        fields={
            {
                name='Server Details',
                value='Server Name: {{ serverName }} Online Players: '..#game.connected_players..' Server Time: '..tick_to_display_format(game.tick)..' '..add_to_server_detail
            },
            unpack(fields)
        }
    }
    game.write_file('json.data',table.json(log_data),true,0)
end

--- Convert ticks to hours
-- @usage a = 216001
-- tick_to_hour(a) -- return 1
-- @tparam number tick to convert to hours
-- @treturn number the number of whole hours from this tick
function ExpLib.tick_to_hour(tick)
    if not is_type(tick,'number') then return 0 end
    return math.floor(tick/(216000*game.speed))
end

--- Convert ticks to minutes
-- @usage a = 3601
-- tick_to_hour(a) -- return 1
-- @tparam number tick to convert to minutes
-- @treturn number the number of whole minutes from this tick
function ExpLib.tick_to_min (tick)
    if not is_type(tick,'number') then return 0 end
    return math.floor(tick/(3600*game.speed))
end

--- Returns a tick in a displayable format
-- @usage a = 3600
-- tick_to_display_format(a) -- return '1.00 M'
-- @usage a = 234000
-- tick_to_display_format(a) -- return '1 H 5 M'
-- @tparam number tick to convert
-- @treturn string the formated string
function ExpLib.tick_to_display_format(tick)
    if not is_type(tick,'number') then return '0H 0M' end
    if tick_to_min(tick) < 10 then
		return string.format('%.2f M',tick/(3600*game.speed))
	else
        return string.format('%d H %d M',
            tick_to_hour(tick),
            tick_to_min(tick)-60*tick_to_hour(tick)
        )
	end
end

--- Returns a string as a hex format (also a string)
-- @usage a = 'foo'
-- string.to_hex(a) -- return '666f6f'
-- @tparam string str the string to encode
-- @treturn string the hex format of the string
function string.to_hex(str)
    if not is_type(str,'string') then return '' end
    return str:gsub('.',function (c)
        return string.format('%02X',string.byte(c))
    end)
end

return ExpLib