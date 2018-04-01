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
function ExpLib.player_return(rtn,colour,player)
    local colour = colour or defines.color.white
    local player = player or game.player
    if player then
        local player = Game.get_player(player)
        if not player then return end
        player.play_sound{path='utility/scenario_message'}
        if is_type(rtn,'table') then 
            -- test if its a localised string
            if is_type(rtn.__self,'userdata') then player.print('Cant Display Userdata',colour)
            elseif is_type(rtn[1],'string') and string.find(rtn[1],'.+[.].+') and not string.find(rtn[1],'%s') then pcall(player.print,rtn,colour)
            else player.print(table.to_string(rtn),colour)
            end
        elseif is_type(rtn,'function') then player.print('Cant Display Functions',colour)
        else player.print(tostring(rtn),colour)
        end
    else
        local _return = 'Invalid'
        if is_type(rtn,'table') then _return = table.to_string(rtn)
        elseif is_type(rtn,'function') then _return = 'Cant Display Functions'
        elseif is_type(rtn,'userdata') then _return = 'Cant Display Userdata'
        else _return = tostring(rtn)
        end log(_return) rcon.print(_return)
    end
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

function ExpLib.Gui_tree(root)
    local tree = {}
    for _,child in pairs(root.children) do
        if #child.children > 0 then
            if child.name then
                tree[child.name] = ExpLib.Gui_tree(child)
            else
                table.insert(tree,ExpLib.Gui_tree(child))
            end
        else
            if child.name then
                tree[child.name] = child.type
            else
                table.insert(tree,child.type)
            end
        end
    end
    return tree
end

return ExpLib