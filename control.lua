--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

-- replaces the base error function
_error = error
error = function(err)
    if _G.discord_emit and game then
        local color = _G.Color and Color.to_hex(defines.text_color.bg) or '0x0'
        discord_emit{title='SCRIPT ERROR',color=color,description=err}
    elseif _G.Game and game then
        if Game.print_all(err) == 0 then
            _error(err)
        end
    else
        _error(err)
    end
end

require("mod-gui")
-- loads the stdlib and allows Core Game and Event
Color, Game, Event = require('/StdLib/load'){'Color','Game','Event'}

-- loads the ExpLib, functions are plased into the lua global
local ExpLib = require 'ExpLib'
ExpLib._unpack_to_G(ExpLib)
_G.discord_emit = nil -- un-comment this line if you are not using the json.data

-- loads the ExpCore files these are need in order to run the other addons
Ranking, Server, Gui = require('/ExpCore/load'){'Ranking','Server','Gui'}
-- this loads the ranks that Ranking uses
require('/ExpCore/ranks')
-- this loads any edits that are not need in core pcall as file may not be preset
pcall(require,'/Addons/playerRanks')
-- this makes sure that all the little details are cleaned up
Ranking._auto_edit_ranks()

-- button testing - there are global for a reason
text = Gui.inputs.add{
    name='text-button',
    type='button',
    caption='Test'
}:on_event(Gui.inputs.events.click,function(event) game.print('test') end)

sprite = Gui.inputs.add{
    name='sprite-button',
    type='button',
    caption='item/lab'
}:on_event(Gui.inputs.events.click,function(event) game.print('test') end)

Gui.toolbar.add('button1','btn1','test btn1',function(event) game.print('test') end)
Gui.toolbar.add('button2','btn2','test btn2',function(event) game.print('test') end)
Gui.toolbar.add('button3','item/lab','test btn3',function(event) game.print('test') end)

input_test = Gui.inputs.add_button('test-inputs','Try RMB','alt,ctrl,shift and mouse buttons',{
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.left and keys.alt end,
        function(player,element) player_return('Left: Alt',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.left and keys.ctrl end,
        function(player,element) player_return('Left: Ctrl',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.left and keys.shift end,
        function(player,element) player_return('Left: Shift',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.right and keys.alt end,
        function(player,element) player_return('Right: Alt',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.right and keys.ctrl end,
        function(player,element) player_return('Right: Ctrl',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.right and keys.shift end,
        function(player,element) player_return('Right: Shift',nil,player) end
    }
}):on_event('error',function(err) game.print('this is error handliling') end)

elem_test = Gui.inputs.add_elem_button('test-elem','item','Testing Elems',function(player,element,elem)
    player_return(elem.type..' '..elem.value,nil,player)
end)

check_test = Gui.inputs.add_checkbox('test-check',false,'Cheat Mode',function(parent) 
    return game.players[parent.player_index].cheat_mode 
end,function(player,element) 
    player.cheat_mode = true 
end,function(player,element)
    player.cheat_mode = false
end)

radio_test = Gui.inputs.add_checkbox('test-radio',true,'Kill Self',function(parent) 
    return game.players[parent.player_index].in_combat
end,function(player,element) 
    if player.character then player.character.die() end
end)