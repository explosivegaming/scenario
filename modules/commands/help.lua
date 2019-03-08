local Commands = require 'expcore.commands'
local Global = require 'utils.global'
require 'expcore.common_parse'

local results_per_page = 5

local search_cache = {}
Global.register(search_cache,function(tbl)
    search_cache = tbl
end)

Commands.new_command('chelp','Searches for a keyword in all commands you are allowed to use.')
:add_param('keyword',false) -- the keyword that will be looked for
:add_param('page',true,'integer') -- the keyword that will be looked for
:add_defaults{page=1}
:register(function(player,keyword,page,raw)
    -- gets a value for pages, might have result in cache
    local pages
    if search_cache[player.index] and search_cache[player.index].keyword == keyword:lower() then
        pages = search_cache[player.index].pages
    else
        pages = {{}}
        local current_page = 1
        local page_count = 0
        -- loops other all commands returned by search, includes game commands
        for _,command_data in pairs(Commands.search(keyword,player)) do
            -- if the number of results if greater than the number already added then it moves onto a new page
            if page_count > results_per_page then
                page_count = 0
                current_page = current_page + 1
                table.insert(pages,{})
            end
            -- adds the new command to the page
            page_count = page_count + 1
            table.insert(pages[current_page],{
                'exp-commands.chelp-format',
                command_data.name,
                command_data.description,
                command_data.help,
                command_data.aliases:concat(', ')
            })
        end
        -- adds the result to the cache
        search_cache[player.index] = {
            keyword=keyword:lower(),
            pages=pages
        }
    end
    -- print the requested page
    Commands.print{'exp-commands.chelp-title',keyword,page,#pages}
    if pages[page] then
        for _,command in pairs(pages[page]) do
            Commands.print(command)
        end
    else
        Commands.print{'exp-commands.chelp-out-of-range',page}
    end
    -- blocks command complete message
    return Commands.success
end)