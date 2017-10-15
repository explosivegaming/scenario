# Functions added in core
See code for more details. (may not be upto date as im lazy)
## GUI
### Defining
* ExpGui.add_frame.center(name,default_display,default_tooltip,tabs,event)
    * tabs (opt) = {{name},{...},...}
    * event (opt) = on draw -> function(player,frame)
* ExpGui.add_frame.tab(name,default_display,default_tooltip,frame,event) 
    * frame = 'frame name'
    * event = on draw -> function(player,frame)
* ExpGui.add_frame.left(name,default_display,default_tooltip,vis,event)
    * vis = player on join -> true/false
    * event = on draw -> function(player,frame)
* ExpGui.add_frame.popup(style,default_display,default_tooltip,on_click,event)
    * on_click = on draw for toolbar -> function(player,element)
    * event = on draw for popup -> function(player,frame,args)
* ExpGui.toolbar.add_button(name,default_display,default_tooltip,event)
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
* ranking.get_player_rank(player)
    * Get the players rank
* ranking.string_to_rank(string)
    * Convert a rank name to the rank object
* ranking.rank_print(msg, rank, inv)
    * rank = 'rank name'
    * inv = lower ranks rather than higher -> true/false/nil
* ranking.give_rank(player,rank,by_player)
    * rank = 'rank name'
    * by_player = player or nil
* ranking.revert_rank(player,by_player)
    * by_player = player or nil
* ranking.find_new_rank(player)
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
* table.tostring(tbl)
    * We stole this but we don't know from where, just google it
    * output -> table as a string
## Get Commands
* server.get_uuid_data(uuid)
    * uuid = value retured by callback
    * returnd the data stored here
* server.get_callback_queue_info(string) 
    * return either a list or string based on the string boliean
* ranking.get_ranks(part)
    * returns a list of all the ranks
    * part (opt) = part of the rank you want to return ie name
* ranking.get_player_rank_presets(rank)
    * returns the current rank presets
    * rank (opt) = rank name if only one rank is needed
* ranking.get_ranked_players(rank)
    * returns the ranks and online time of every player
    * rank (opt) = limits it to only this rank
* get_commands(rank)
    * returns all commands that are useable
    * rank (opt) = rank name to limt it to what that rank can use
## Server
* server.queue_callback(command,args,uuid)
    * Ask server to run a script function at a diffrent time
    * command = function to be ran
    * args (as function needs) = {...}
    * uuid (opt) = the uuid that it will return (use with get_uuid_data)
    * returns the uuid
* server.add_callback(callback,uuid)
    * Sets a function in memory
    * used with /socket to run
    * callbacl = function to save to memory
    * uuid = sting for a custom uuid
* server.refresh_uuid(uuid,value,offset)
    * uuid = location of the data to be refreshed
    * value (opt) = new value if making a new temp varible
    * offset (opt) = if the base time is too short, for very big commands
* server.get_uuid(string)
    * returns the same value that queue_callback would when given a custom return name
    * will return the same as callback but cant be used to get the value of a previous callback
* server.emit(code, callback)
    * you dont see this i was just asked to add it
## Other
* server.clear_callbacks()
    * resets the callback system
* define_command(name,help,inputs,event)
    * Add game commands in a way it does not cause crashes
    * name  = 'test' -> /test
    * help = 'help message'
    * inputs = {'input name',...,true/nil} last value being true means no cap on the length
    * event = on command -> function(player,event,args)
* command: /server-interface
    * Run loadstring on lua code given like /c but does not break achievements
* command: /debug
    * same as server-interface but runs in debug mode
* command: /socket
    * its just magic ok, its for server sync