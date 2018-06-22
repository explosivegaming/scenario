--- A defines module for retrieving colors by name.
-- Extends the Factorio defines table.
-- @module StdLib.Color
-- @alias defines.color

-- defines table is automatically required in all mod loading stages.
-- luacheck: ignore 122/defines
-- Ignore assigning to read only defines table. defines table is not ready only, however
-- marking it this way allows warnings to be generated when trying to assign values

defines = defines or {} --luacheck: ignore defines (This is used for testing locally)

--- A table of colors allowing retrieval by color name.
-- @table defines.color
-- @field white {r=1.00,g=1.00,b=1.00}
-- @field black {r=0.00,g=0.00,b=0.00}
-- @field darkgrey {r=0.25,g=0.25,b=0.25}
-- @field grey {r=0.50,g=0.50,b=0.50}
-- @field lightgrey {r=0.75,g=0.75,b=0.75}
-- @field red {r=1.00,g=0.00,b=0.00}
-- @field darkred {r=0.50,g=0.00,b=0.00}
-- @field lightred {r=1.00,g=0.50,b=0.50}
-- @field green {r=0.00,g=1.00,b=0.00}
-- @field darkgreen {r=0.00,g=0.50,b=0.00}
-- @field lightgreen {r=0.50,g=1.00,b=0.50}
-- @field blue {r=0.00,g=0.00,b=1.00}
-- @field darkblue {r=0.00,g=0.00,b=0.50}
-- @field lightblue {r=0.50,g=0.50,b=1.00}
-- @field orange {r=1.00,g=0.55,b=0.10}
-- @field yellow {r=1.00,g=1.00,b=0.00}
-- @field pink {r=1.00,g=0.00,b=1.00}
-- @field purple {r=0.60,g=0.10,b=0.60}
-- @field brown {r=0.60,g=0.40,b=0.10}
defines.color = {
    white={r=1.00,g=1.00,b=1.00},
    black={r=0.00,g=0.00,b=0.00},
    darkgrey={r=0.25,g=0.25,b=0.25},
    grey={r=0.50,g=0.50,b=0.50},
    lightgrey={r=0.75,g=0.75,b=0.75},
    red={r=1.00,g=0.00,b=0.00},
    darkred={r=0.50,g=0.00,b=0.00},
    lightred={r=1.00,g=0.50,b=0.50},
    green={r=0.00,g=1.00,b=0.00},
    darkgreen={r=0.00,g=0.50,b=0.00},
    lightgreen={r=0.50,g=1.00,b=0.50},
    blue={r=0.00,g=0.00,b=1.00},
    darkblue={r=0.00,g=0.00,b=0.50},
    lightblue={r=0.50,g=0.50,b=1.00},
    orange={r=1.00,g=0.55,b=0.10},
    yellow={r=1.00,g=1.00,b=0.00},
    pink={r=1.00,g=0.00,b=1.00},
    purple={r=0.60,g=0.10,b=0.60},
    brown={r=0.60,g=0.40,b=0.10}
}
local colors = defines.color

--- Returns white for dark colors or black for lighter colors.
-- @table defines.anticolor
defines.anticolor = {
    green = colors.black, -- defines.color.black
    grey = colors.black, -- defines.color.black
    lightblue = colors.black, -- defines.color.black
    lightgreen = colors.black, -- defines.color.black
    lightgrey = colors.black, -- defines.color.black
    lightred = colors.black, -- defines.color.black
    orange = colors.black, -- defines.color.black
    white = colors.black, -- defines.color.black
    yellow = colors.black, -- defines.color.black
    black = colors.white, -- defines.color.white
    blue = colors.white, -- defines.color.white
    brown = colors.white, -- defines.color.white
    darkblue = colors.white, -- defines.color.white
    darkgreen = colors.white, -- defines.color.white
    darkgrey = colors.white, -- defines.color.white
    darkred = colors.white, -- defines.color.white
    pink = colors.white, -- defines.color.white
    purple = colors.white, -- defines.color.white
    red = colors.white -- defines.color.white
}

--- Returns a lighter color of a named color
-- @table defines.lightcolor
defines.lightcolor = {
    white = colors.lightgrey, -- defines.color.lightgrey
    grey = colors.darkgrey, -- defines.color.darkgrey
    lightgrey = colors.grey, -- defines.color.grey
    red = colors.lightred, -- defines.color.lightred
    green = colors.lightgreen, -- defines.color.lightgreen
    blue = colors.lightblue, -- defines.color.lightblue
    yellow = colors.orange, -- defines.color.orange
    pink = colors.purple -- defines.color.purple
}

-- added by cooldude260

--- Returns a lighter color of a named color.
-- @table defines.textcolor
-- @field info {r=0.21,g=0.95,b=1.00}
-- @field bg {r=0.00,g=0.00,b=0.00}
-- @field low {r=0.18,g=0.77,b=0.18}
-- @field med {r=1.00,g=0.89,b=0.26}
-- @field high {r=1.00,g=0.33,b=0.00}
-- @field crit {r=1.00,g=0.00,b=0.00}
defines.textcolor = {
    info={r=0.21,g=0.95,b=1.00},
    bg={r=0.00,g=0.00,b=0.00},
    low={r=0.18,g=0.77,b=0.18},
    med={r=1.00,g=0.89,b=0.26},
    high={r=1.00,g=0.33,b=0.00},
    crit={r=1.00,g=0.00,b=0.00}
}

-- metatable remade by cooldude
local _mt = {
    __index=function(tbl,key)
        return rawget(tbl,tostring(key):lower()) or rawget(defines.color,'white')
    end,
    __pairs=function(tbl)
        return function()
            local v
            k, v = next(tbl, k)
            return k, (v and {r = v['r'], g = v['g'], b = v['b'], a = v['a']}) or nil
        end, tbl, nil
    end,
    __eq=function(tbl1,tbl2)
        return tbl1.r == tbl2.r and tbl1.g == tbl2.g and tbl1.b == tbl2.b and tbl1.a == tbl2.a
    end
}

setmetatable(defines.color, _mt)
setmetatable(defines.anticolor, _mt)
setmetatable(defines.textcolor, _mt)
setmetatable(defines.lightcolor, _mt)

local Color = {} --luacheck: allow defined top

--- Set a value for the alpha channel in the given color table.
-- `color.a` represents the alpha channel in the given color table.
-- <ul>
-- <li>If ***alpha*** is given, set `color.a` to it.
-- <li>If ***alpha*** is not given, and if the given color table does not have a value for `color.a`, set `color.a` to 1.
-- <li>If ***alpha*** is not given, and if the given color table already has a value for `color.a`, then leave `color.a` alone.
-- </ul>
-- @tparam[opt=white] defines.color|Concepts.Color color the color to configure
-- @tparam[opt=1] float alpha the alpha value (*[0 - 1]*) to set for the given color
-- @treturn a color table that has the specified value for the alpha channel
function Color.set(color, alpha)
    color = color or defines.color.white
    Color.to_table(color)
    color.a = alpha or color.a or 1
    return color
end

--- Converts a color in the array format to a color in the table format.
-- @tparam table c_arr the color to convert 
-- @treturn a converted color &mdash; { r = c\_arr[1], g = c\_arr[2], b = c\_arr[3], a = c\_arr[4] }
function Color.to_table(c_arr)
    if #c_arr > 0 then
        return {r = c_arr[1], g = c_arr[2], b = c_arr[3], a = c_arr[4]}
    end
    return c_arr
end

--- Converts a color in the rgb format to a color table
-- @tparam[opt=0] int r 0-255 red
-- @tparam[opt=0] int g 0-255 green
-- @tparam[opt=0] int b 0-255 blue
-- @tparam[opt=255] int a 0-255 alpha
-- @treturn Concepts.Color
function Color.from_rgb(r, g, b, a)
    r = r or 0
    g = g or 0
    b = b or 0
    a = a or 255
    return {r = r/255, g = g/255, b = b/255, a = a/255}
end

--- Get a color table with a hexadecimal string.
-- Optionally provide the value for the alpha channel.
-- @tparam string hex hexadecimal color string (#ffffff, not #fff)
-- @tparam[opt=1] float alpha the alpha value to set; such that ***[ 0 &#8924; value &#8924; 1 ]***
-- @treturn a color table with RGB converted from Hex and with alpha
function Color.from_hex(hex, alpha)
    if not _G.Game then error('StdLib/Game not loaded') end
    _G.Game.fail_if_missing(hex, "missing color hex value")
    if hex:find("#") then hex = hex:sub(2) end
    if not(#hex == 6) then error("invalid color hex value: "..hex)  end
    local number = tonumber(hex, 16)
    return {
        r = bit32.extract(number, 16, 8) / 255,
        g = bit32.extract(number, 8, 8) / 255,
        b = bit32.extract(number, 0, 8) / 255,
        a = alpha or 1
    }
end

--added by cooldude2606

--- Converts a color in the color table format to rgb
-- @tparam table color the color to convert
-- @treturn table the color as rgb
function Color.to_rgb(color)
    local r = color.r or 0
    local g = color.g or 0
    local b = color.b or 0
    local a = color.a or 0.5
    return {r = r*255, g = g*255, b = b*255, a = a*255}
end

--added by cooldude2606

--- Converts a color in the color table format to hex
-- @tparam table color the color to convert
-- @treturn string the color as hex
function Color.to_hex(color)
    local hexadecimal  = '0x'
    for key, value in pairs{math.floor(color.r*255),math.floor(color.g*255),math.floor(color.b*255)} do
		local hex = ''
		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex			
		end
		if string.len(hex) == 0 then hex = '00'
		elseif string.len(hex) == 1 then hex = '0' .. hex
		end
		hexadecimal = hexadecimal .. hex
    end
    return hexadecimal 
end

return Color
