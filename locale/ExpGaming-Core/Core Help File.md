# Functions added in core
See code for more detail.
## GUI
### Defining
* ExpGui.add_frame.center(name,default_display,default_tooltip,restriction,tabs,event)
    * restriction = 'rank name'
    * tabs (opt) = {{name,restriction},{...},...}
    * event (opt) = on draw -> function(player,frame)
* ExpGui.add_frame.tab(name,default_display,default_tooltip,restriction,frame,event) 
    * restriction = 'rank name'
    * frame = 'frame name'
    * event = on draw -> function(player,frame)
* ExpGui.add_frame.left(name,default_display,default_tooltip,restriction,vis,event)
    * restriction = 'rank name'
    * vis = player on join -> true/false
    * event = on draw -> function(player,frame)
* ExpGui.add_frame.popup(style,default_display,default_tooltip,restriction,on_click,event)
    * restriction = 'rank name'
    * on_click = on draw for toolbar -> function(player,element)
    * event = on draw for popup -> function(player,frame,args)
* ExpGui.toolbar.add_button(name,default_display,default_tooltip,restriction,event)
    * restriction = 'rank name'
    * event = on click -> function(player,element)
* ExpGui.add_input.button(name,default_display,default_tooltip,event)
    * event = on click -> function(player,element)
* ExpGui.add_input.text(name,default_display,event)
    * event = on text change -> function(player,element)
### Drawing
* ExpGui.player_table.draw_filters(player,frame,filters)
    * filters = {filter-name,...}
* ExpGui.player_table.draw(player,frame,filters,input_location)
    * filters = {{'filter name',value},{'filter name'},{...},...}
    * input_location = gui element -> draw_filters frame
* ExpGui.draw_frame.left(player,element,update)
    * element = 'frame name'
    * update = true
* ExpGui.draw_frame.popup(style,args)
    * style = 'style name'
    * args = {...}
* ExpGui.add_input.draw_button(frame,name,display,tooltip)
    * display (opt)
    * tooltip (opt)
* ExpGui.add_input.draw_text(frame,name,display)
    * display (opt)
## Ranks
* get_rank(player)
    * Gets the players rank
* string_to_rank(string)
    * Converts a rank name to the rank object
* rank_print(msg, rank, inv)
    * rank = 'rank name'
    * inv = lower ranks rather than higher -> true/false/nil
* give_rank(player,rank,by_player)
    * rank = 'rank name'
    * by_player = player or nil
* revert_rank(player,by_player)
    * by_player = player or nil
* find_new_rank(player)
    * Looks in presets if play time under 5 minutes
    * Other wise looks at play time
* Event.rank_change
    * event is rasised upon rank change -> event = {player,by_player,new_rank,old_rank}
## Lib
* Factorio StdLib game, event and core
* tick_to_display_format(tick)
    * output -> 0H 0M or 0.00M when less than 10
* tick_to_hour (tick)
    * converts ticks to hours based on game speed
* tick_to_min (tick)
    * converts ticks to minutes based on game speed
* table.to_string(tbl)
    * We stole this but we dont know where from, just google it
    * output -> table as a string
## Other
* define_command(name,help,inputs,restriction,event)
    * This adds game commands in a way not to cause crashes
    * name  = 'test' -> /test
    * help = 'help message'
    * inputs = {'input name',...,true/nil} last value being true means no cap on the leanth
    * restriction = 'rank name'
    * event = on command -> function(player,event,args)
* sudo(command,args)
    * Asks server to run a script function for a user ie give_rank
    * command = function(...)
    * args = {...}
* command: /server-interface
    * runs loadstring on lua code given like /c but does not break achevements
    * restriction = 'Admin'