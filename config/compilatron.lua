-- config file for the compliatrons including where they spawn and what messages they show
return {
    message_cycle=60*15, -- 15 seconds default, how often (in ticks) the messages will cycle
    locations={ -- defines the spawn locations for all compilatrons
        ['Spawn']={x=0,y=0}
    },
    messages={ -- the messages that each one will say, must be same name as its location
        ['Spawn']={
            {'info.website'},
            {'info.read-readme'},
            {'info.discord'},
            {'info.softmod'},
            {'info.wiki'},
            {'info.redmew'},
            {'info.feedback'},
            {'info.custom-commands'},
            {'info.status'},
            {'info.lhd'},
            {'info.github'},
        }
    }
}