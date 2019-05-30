-- config file for the compliatrons including where they spawn and what messages they show
return {
    message_cycle=60*15, -- 15 seconds default, how often (in ticks) the messages will cycle
    locations={ -- defines the spawn locations for all compilatrons
        ['Spawn']={x=0,y=0}
    },
    messages={ -- the messages that each one will say, must be same name as its location
        ['Spawn']={
            {'info.website-message'},
            {'info.read-readme'},
            {'info.discord-message'},
            {'info.softmod'},
            {'info.wiki-message'},
            {'info.redmew'},
            {'info.feedback-message'},
            {'info.custom-commands'},
            {'info.status-message'},
            {'info.lhd'},
            {'info.github-message'},
        }
    }
}