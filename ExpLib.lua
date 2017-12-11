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

local ExpLib = {}
--- Loads a table into the global lua table
-- @usage a = {k1='foo',k2='bar'}
-- _load_to_G(a)
-- @tparam table tbl table to add to the global lua table
function ExpLib._unpack_to_G(tbl)
    if not type(tbl) == 'table' or game then return end
    for name,value in pairs(tbl) do
        if not _G[name] then _G[name] = value end
    end
end

--- Returns a bolean based on the type of v matching the test type
-- @usage a = 'foo'
-- is_type(a,'string') -- return true
-- @param v the value to be tested
-- @tparam[opt=nil] string test_type the type to test for if nil then it tests for nil
-- @treturn bolean is v a matching type
function ExpLib.is_type(v,test_type)
    return test_type and v and type(v) == test_type or not test_type and not v or false 
end

--- Returns a value to the player or if no player then log the return
-- @usage a = 'to return'
-- player_return(a)
-- @param rtn the value to return
-- @param player the player to print to
function ExpLib.player_return(rtn,player)
    if player then
        local player = Game.get_player(player)
        if is_type(rtn,'table') then 
            -- test if its a localised string
            if is_type(rtn.__self,'userdata') then player.print('Cant Display Userdata')
            elseif is_type(rtn[1],'string') and string.find(rtn[1],'.+[.].+') and not string.find(rtn[1],'%s') then pcall(player.print,rtn)
            else player.print(table.to_string(rtn))
            end
        elseif is_type(rtn,'function') then player.print('Cant Display Functions')
        else player.print(tostring(rtn))
        end
    elseif game.player then
        if is_type(rtn,'table') then 
            -- test if its a localised string
            if is_type(rtn.__self,'userdata') then player.print('Cant Display Userdata')
            elseif is_type(rtn[1],'string') and string.find(rtn[1],'.+[.].+') and not string.find(rtn[1],'%s') then pcall(game.player.print,rtn)
            else game.player.print(table.to_string(rtn))
            end
        elseif is_type(rtn,'function') then game.player.print('Cant Display Functions')
        else game.player.print(tostring(rtn))
        end
    else
        if is_type(rtn,'table') then log(table.to_string(rtn))
        elseif is_type(rtn,'function') then log('Cant Display Functions')
        else log(tostring(rtn))
        end
    end
end

--- Logs an embed to the json.data we use a js script to add things we cant here
-- @usage json_emit{title='BAN',color_name='info',description='A player was banned' ... }
-- @tparam table arg a table which contains everything that the embeded will use
-- @param[opt=''] title the tile of the embed
-- @param[opt='0x0'] color the color given in hex you can use Color.to_hex{r=0,g=0,b=0}
-- @param[opt=''] description the description of the embed
-- @param[opt=''] server_detail sting to add onto the pre-set server detail
-- @param[opt] fieldone the filed to add to the embed (key is name) (value is text) (start value with <<inline>> to make inline)
-- @param[optchain] fieldtwo 
function ExpLib.discord_emit(args)
    if not is_type(args,'table') then return end
    local title = is_type(args.title,'string') and args.title or ''
    local color = is_type(args.color,'string') and args.color:find("0x") and args.color or '0x0'
    local description = is_type(args.description,'string') and args.description or ''
    local server_detail = is_type(args.server_detail,'string') and args.server_detail or ''
    local done, fields = {title=true,color=true,description=true,server_detail=true}, {{
        name='Server Details',
        value='Server Name: {{ serverName }} Online Players: '..#game.connected_players..' Server Time: '..tick_to_display_format(game.tick)..' '..server_detail
    }}
    for key, value in pairs(args) do
        if not done[key] then
            done[key] = true
            local f = {name=key,value='',inline=false}
            local value, inline = value:gsub("<<inline>>",'',1)
            f.value = value
            if inline > 0 then f.inline = true end
            table.insert(fields,f)
        end
    end
    local log_data = {
        title=title,
        description=description,
        color=color,
        fields=fields
    }
    game.write_file('json.data','\n'..table.json(log_data),true,0)
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

return ExpLib