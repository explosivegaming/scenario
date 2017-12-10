--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
local groups = {}
local ranks = {}

function Ranking._add_group(group) if game then return end table.insert(groups,group) end
function Ranking._add_rank(rank) if game then return end table.insert(ranks,rank) end
function Ranking._set_rank_power() if game then return end for power,rank in pairs(ranks) do rank.power = power end end

--[[
    How to use groups:
name		the name that you can use to refence it.
disallow	if present then all ranks in this group will have this added to their disallow.
allow		if present then all ranks in this group will have this added to their allow.
highest     is asigned by the script to show the highest rank in this group.
lowest      is asigned by the script to show the lowest rank in this group.
How to add ranks:
Name		is what will be used in the scripts and is often the best choice for display in text.
short_hand	is what can be used when short on space but the rank still need to be displayed.
tag			is the tag the player will gain when moved to the rank, it can be nil.
time		is used for auto-rank feature where you are moved to the rank after a certain play time in minutes.
colour		is the RGB value that can be used to emphasise GUI elements based on rank.
power		is asigned by the script based on their index in ranks, you can insert new ranks between current ones.
group		is asigned by the script to show the group this rank is in
disallow	is a list containing input actions that the user can not perform.
allow		is a list of custom commands and effects that that rank can use, all defined in the sctips.

For allow, add the allow as the key and the value as true
Example: test for 'server-interface' => allow['server-interface'] = true

For disallow, add to the list the end part of the input action
Example: defines.input_action.drop_item -> 'drop_item'
http://lua-api.factorio.com/latest/defines.html#defines.input_action
--]]

-- If you wish to add more groups please use addons/playerRanks.lua
-- If you wish to add to these rank groups use addons/playerRanks.lua
-- DO NOT REMOVE ANY OF THESE GROUPS

local root = Ranking._group:create{
    name='Root',
    allow={
        ['server-interface'] = true
    },
    disallow={}
}
local admin = Ranking._group:create{
    name='Admin',
    allow={},
    disallow={}
}
local user = Ranking._group:create{
    name='User',
    allow={},
    disallow={}
}
local jail = Ranking._group:create{
    name='Jail',
    allow={},
    disallow={}
}

-- If you wish to add more ranks please use addons/playerRanks.lua
-- If you wish to add to these rank use addons/playerRanks.lua
root:add_rank{
    name='Root',
    short_hand='Root',
    tag='[Root]',
    colour=defines.color.white,
    is_root=true
}

user:add_rank{
    name='Guest',
    short_hand='',
    tag='',
    colour={r=255,g=159,b=27},
    is_default=true
}

-- used to force rank to be read-only
function Ranking._groups(name) 
    if name then 
        if name then 
            local _return = {}
            for power,group in pairs(groups) do
                _return[group.name] = group
            end
            return _return
        end 
    end 
    return groups 
end

function Ranking._ranks(name) 
    if name then 
        local _return = {}
        for power,rank in pairs(ranks) do
            _return[rank.name] = rank
        end
        return _return
    end 
    return ranks 
end

-- used to save lag by doing some calculation at the start
function Ranking._meta()
    local meta = {}
    for power,rank in pairs(ranks) do
        if rank.is_default then
            meta.default = rank.name
        end
        if rank.is_root then
            meta.root = rank.name
        end
        if rank.time then
            table.insert(meta.time_ranks,rank.name)
            if not meta.time_highest or power > meta.time_highest then meta.time_highest = power end
            if not meta.time_lowest or power < meta.time_lowest then meta.time_lowest = power end
        end
        meta.time_highest = meta.time_highest or 0
        meta.time_lowest = meta.time_lowest or 0
    end
    return meta
end