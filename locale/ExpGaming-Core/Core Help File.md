# Functions added in core
See code for more details.
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
* ExpGui.toggle_visible(frame)
    * Toggles the visibility of a frame
* ExpGui.player_table.draw_filters(player,frame,filters)
    * filters = {filter-name,...}
* ExpGui.player_table.draw(player,frame,filters,input_location)
    * filters = {{'filter name',value},{'filter name'},{...},...}
    * input_location = GUI element -> draw_filters frame
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
    * Get the players rank
* string_to_rank(string)
    * Convert a rank name to the rank object
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
    * Otherwise looks at play time
* Event.rank_change
    * event is raised upon rank change -> event = {player,by_player,new_rank,old_rank}
## Lib
* Factorio StdLib game, event and core
* tick_to_display_format(tick)
    * output -> 0H 0M or 0.00M when less than 10
* tick_to_hour (tick)
    * Convert ticks to hours based on game speed
* tick_to_min (tick)
    * Convert ticks to minutes based on game speed
* table.to_string(tbl)
    * We stole this but we don't know from where, just google it
    * output -> table as a string
## Get Commands
* get_temp_var_data(name)
    * name = value retured by sudo
    * returens a list if the data returend by thefunction if any
* get_sudo_info(string) 
    * return either a list or string based on the string boliean 
## Other
* define_command(name,help,inputs,restriction,event)
    * Add game commands in a way it does not cause crashes
    * name  = 'test' -> /test
    * help = 'help message'
    * inputs = {'input name',...,true/nil} last value being true means no cap on the length
    * restriction = 'rank name'
    * event = on command -> function(player,event,args)
* sudo(command,args,custom_return_name)
    * Ask server to run a script function at a diffrent time
    * command = function or function name
    * args (as function needs) = {...}
    * custom_return_name (opt) = name of the value temp varible returned
    * returns the name of its temp varible
* refresh_temp_var(name,value,offset)
    * name = value retured by sudo
    * value (opt) = new value if making a new temp varible
    * offset (opt) = if the base time is too short, for very big commands
* command: /server-interface
    * Run loadstring on lua code given like /c but does not break achievements
    * restriction = 'Admin'