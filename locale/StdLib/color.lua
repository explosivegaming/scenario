--- A defines module for retrieving colors by name.
-- Extends the Factorio defines table.
-- @usage require('stdlib/defines/color')
-- @module defines.color
-- @see Concepts.Color

-- defines table is automatically required in all mod loading stages.
-- luacheck: ignore 122/defines
-- Ignore assigning to read only defines table. defines table is not ready only, however
-- marking it this way allows warnings to be generated when trying to assign values

defines = defines or {} --luacheck: ignore defines (This is used for testing locally)

--- A table of colors allowing retrieval by color name.
-- @usage color = defines.color.red
-- @tfield Concepts.Color white
-- @tfield Concepts.Color black
-- @tfield Concepts.Color darkgrey
-- @tfield Concepts.Color grey
-- @tfield Concepts.Color lightgrey
-- @tfield Concepts.Color red
-- @tfield Concepts.Color darkred
-- @tfield Concepts.Color lightred
-- @tfield Concepts.Color green
-- @tfield Concepts.Color darkgreen
-- @tfield Concepts.Color lightgreen
-- @tfield Concepts.Color blue
-- @tfield Concepts.Color darkblue
-- @tfield Concepts.Color lightblue
-- @tfield Concepts.Color orange
-- @tfield Concepts.Color yellow
-- @tfield Concepts.Color pink
-- @tfield Concepts.Color purple
-- @tfield Concepts.Color brown
defines.color = {}

local colors = {
    white = {r = 1.00, g = 1.00, b = 1.00},
    black = {r = 0.00, g = 0.00, b = 0.00},
    darkgrey = {r = 0.25, g = 0.25, b = 0.25},
    grey = {r = 0.50, g = 0.50, b = 0.50},
    lightgrey = {r = 0.75, g = 0.75, b = 0.75},
    red = {r = 1.00, g = 0.00, b = 0.00},
    darkred = {r = 0.50, g = 0.00, b = 0.00},
    lightred = {r = 1.00, g = 0.50, b = 0.50},
    green = {r = 0.00, g = 1.00, b = 0.00},
    darkgreen = {r = 0.00, g = 0.50, b = 0.00},
    lightgreen = {r = 0.50, g = 1.00, b = 0.50},
    blue = {r = 0.00, g = 0.00, b = 1.00},
    darkblue = {r = 0.00, g = 0.00, b = 0.50},
    lightblue = {r = 0.50, g = 0.50, b = 1.00},
    orange = {r = 1.00, g = 0.55, b = 0.10},
    yellow = {r = 1.00, g = 1.00, b = 0.00},
    pink = {r = 1.00, g = 0.00, b = 1.00},
    purple = {r = 0.60, g = 0.10, b = 0.60},
    brown = {r = 0.60, g = 0.40, b = 0.10}
}

--- Returns white for dark colors or black for lighter colors.
-- @tfield Concepts.Color green defines.color.black
-- @tfield Concepts.Color grey defines.color.black
-- @tfield Concepts.Color lightblue defines.color.black
-- @tfield Concepts.Color lightgreen defines.color.black
-- @tfield Concepts.Color lightgrey defines.color.black
-- @tfield Concepts.Color lightred defines.color.black
-- @tfield Concepts.Color orange defines.color.black
-- @tfield Concepts.Color white defines.color.black
-- @tfield Concepts.Color yellow defines.color.black
-- @tfield Concepts.Color black defines.color.white
-- @tfield Concepts.Color blue defines.color.white
-- @tfield Concepts.Color brown defines.color.white
-- @tfield Concepts.Color darkblue defines.color.white
-- @tfield Concepts.Color darkgreen defines.color.white
-- @tfield Concepts.Color darkgrey defines.color.white
-- @tfield Concepts.Color darkred defines.color.white
-- @tfield Concepts.Color pink defines.color.white
-- @tfield Concepts.Color purple defines.color.white
-- @tfield Concepts.Color red defines.color.white
defines.anticolor = {}

local anticolors = {
    green = colors.black,
    grey = colors.black,
    lightblue = colors.black,
    lightgreen = colors.black,
    lightgrey = colors.black,
    lightred = colors.black,
    orange = colors.black,
    white = colors.black,
    yellow = colors.black,
    black = colors.white,
    blue = colors.white,
    brown = colors.white,
    darkblue = colors.white,
    darkgreen = colors.white,
    darkgrey = colors.white,
    darkred = colors.white,
    pink = colors.white,
    purple = colors.white,
    red = colors.white
}

--- Returns a lighter color of a named color.
-- @tfield Concepts.Color white defines.color.lightgrey
-- @tfield Concepts.Color grey defines.color.darkgrey
-- @tfield Concepts.Color lightgrey defines.color.grey
-- @tfield Concepts.Color red defines.color.lightred
-- @tfield Concepts.Color green defines.color.lightgreen
-- @tfield Concepts.Color blue defines.color.lightblue
-- @tfield Concepts.Color yellow defines.color.orange
-- @tfield Concepts.Color pink defines.color.purple
defines.lightcolor = {}
local lightcolors = {
    white = colors.lightgrey, 
    grey = colors.darkgrey, 
    lightgrey = colors.grey,
    red = colors.lightred, 
    green = colors.lightgreen, 
    blue = colors.lightblue,
    yellow = colors.orange, 
    pink = colors.purple
}

-- added by cooldude2606
--- Returns a lighter color of a named color.
-- @tfield Concepts.Color info
-- @tfield Concepts.Color bg
-- @tfield Concepts.Color low
-- @tfield Concepts.Color med
-- @tfield Concepts.Color high
-- @tfield Concepts.Color crit
defines.text_color = {}
local text_color = {
    info = {r = 0.21, g = 0.95, b = 1.00},
    bg = {r = 0.00, g = 0.00, b = 0.00},
    low = {r = 0.18, g = 0.77, b = 0.18},
    med = {r = 1.00, g = 0.89, b = 0.26},
    high = {r = 1.00, g = 0.33, b = 0.00},
    crit = {r = 1.00, g = 0.00, b = 0.00}
}

local _mt = {
    color = {
        __index = function(_, c)
            return colors[c]
            and { r = colors[c]['r'], g=colors[c]['g'], b=colors[c]['b'], a = colors[c]['a'] }
            or { r = 1, g = 1, b = 1, a = 1 }
        end,
        __pairs = function()
            local k = nil
            local c = colors
            return function()
                local v
                k, v = next(c, k)
                return k, (v and {r = v['r'], g = v['g'], b = v['b'], a = v['a']}) or nil
            end
        end
    },
    anticolor = {
        __index = function(_, c)
            return anticolors[c]
            and { r = anticolors[c]['r'], g=anticolors[c]['g'], b=anticolors[c]['b'], a = anticolors[c]['a'] }
            or { r = 1, g = 1, b = 1, a = 1 }
        end,
        __pairs = function()
            local k = nil
            local c = anticolors
            return function()
                local v
                k, v = next(c, k)
                return k, (v and {r = v['r'], g = v['g'], b = v['b'], a = v['a']}) or nil
            end
        end
    },
    lightcolor = {
        __index = function(_, c)
            return lightcolors[c]
            and { r = lightcolors[c]['r'], g=lightcolors[c]['g'], b=lightcolors[c]['b'], a = lightcolors[c]['a'] }
            or { r = 1, g = 1, b = 1, a = 1 }
        end,
        __pairs = function()
            local k = nil
            local c = lightcolors
            return function()
                local v
                k, v = next(c, k)
                return k, (v and {r = v['r'], g = v['g'], b = v['b'], a = v['a']}) or nil
            end
        end
    },
    text_color = { -- added by cooldude2606
        __index = function(_, c)
            return text_color[c]
            and { r = text_color[c]['r'], g=text_color[c]['g'], b=text_color[c]['b'], a = text_color[c]['a'] }
            or { r = 1, g = 1, b = 1, a = 1 }
        end,
        __pairs = function()
            local k = nil
            local c = text_color
            return function()
                local v
                k, v = next(c, k)
                return k, (v and {r = v['r'], g = v['g'], b = v['b'], a = v['a']}) or nil
            end
        end
    }
}
setmetatable(defines.color, _mt.color)
setmetatable(defines.anticolor, _mt.anticolor)
setmetatable(defines.text_color, _mt.text_color)
setmetatable(defines.lightcolor, _mt.lightcolor)

--- For playing with colors.
-- @module Color
-- @usage local Color = require('stdlib/color/color')

--require 'stdlib/defines/color'
local fail_if_missing = require 'game'['fail_if_missing']

Color = {} --luacheck: allow defined top

--- Set a value for the alpha channel in the given color table.
-- `color.a` represents the alpha channel in the given color table.
-- <ul>
-- <li>If ***alpha*** is given, set `color.a` to it.
-- <li>If ***alpha*** is not given, and if the given color table does not have a value for `color.a`, set `color.a` to 1.
-- <li>If ***alpha*** is not given, and if the given color table already has a value for `color.a`, then leave `color.a` alone.
-- </ul>
-- @tparam[opt=white] defines.color|Concepts.Color color the color to configure
-- @tparam[opt=1] float alpha the alpha value (*[0 - 1]*) to set for the given color
-- @treturn Concepts.Color a color table that has the specified value for the alpha channel
function Color.set(color, alpha)
    color = color or defines.color.white
    Color.to_table(color)
    color.a = alpha or color.a or 1
    return color
end

--- Converts a color in the array format to a color in the table format.
-- @tparam array c_arr the color to convert &mdash; { [1] = @{float}, [2] = @{float}, [3] = @{float}, [4] = @{float} }
-- @treturn Concepts.Color a converted color &mdash; { r = c\_arr[1], g = c\_arr[2], b = c\_arr[3], a = c\_arr[4] }
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
-- @treturn Concepts.Color a color table with RGB converted from Hex and with alpha
function Color.from_hex(hex, alpha)
    fail_if_missing(hex, "missing color hex value")
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
