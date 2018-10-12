local paths = {
    -- ['tile name'] = {health,convert to}
    -- the greater health is the lower the chance it will be down graded, must be grater than 0
    ['refined-concrete']={70,'concrete'},
    ['refined-hazard-concrete-right']={70,'hazard-concrete-right'},
    ['refined-hazard-concrete-left']={70,'hazard-concrete-left'},
    ['concrete']={50,'stone-path'},
    ['hazard-concrete-right']={50,'stone-path'},
    ['hazard-concrete-left']={50,'stone-path'},
    ['stone-path']={40,'world-gen'}, -- world-gen just makes it pick the last tile not placed by a player
    ['sand-1']={5,'sand-2'},
    ['sand-2']={10,'sand-3'},
    ['sand-3']={5,'red-desert-3'},
    ['red-desert-3']={5,'red-desert-2'},
    ['red-desert-2']={10,'dirt-1'},
    ['grass-2']={5,'grass-1'},
    ['grass-1']={5,'grass-3'},
    ['grass-3']={10,'red-desert-0'},
    ['red-desert-0']={5,'red-desert-1'},
    ['red-desert-1']={10,'dirt-1'},
    ['dirt-1']={5,'dirt-2'},
    ['dirt-2']={5,'dirt-3'},
    ['dirt-3']={10,'dirt-4'},
    ['dirt-4']={5,'dirt-5'},
    ['dirt-5']={5,'dirt-6'},
    ['grass-4']={10,'dirt-4'}
}