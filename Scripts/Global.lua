--global variables

Global = {
    realW = 0,
    realH = 0,
    delta = 0,
    debounce = 0,
    mouseX = 0,
    mouseY = 0,
    input = "",
    wheel = 0,
    screen = "",
    ratio = "",
    state = "",
    substate = {
        [PLAYER_1] = "",
        [PLAYER_2] = "",
    },
    allgroups = {
        -- ["Name"] = "string"
        -- ["Songs"] = { Songs }
        -- ["Count"] = 0
    },
    songgroup = "",
    songlist = {},
    song = "",
    selection = 1,
    level = 1,
    confirm = {
        [PLAYER_1] = 0,
        [PLAYER_2] = 0,
    },
    players = 1,
    master = 1,
    mastersteps = nil,
    steps = {},
    pnsteps = {
        [PLAYER_1] = 1,
        [PLAYER_2] = 1,
    },
    pnselection = {
        [PLAYER_1] = 1,
        [PLAYER_2] = 1,
    },
    pncursteps = {
        [PLAYER_1] = nil,
        [PLAYER_2] = nil,
    },
    pnskin = {
        [PLAYER_1] = -1,
        [PLAYER_2] = -1,
    },
    blocksteps = false,
    blockjoin = true,
    prevstate = "",
    toggle = false,
    bgcolor = {0.66,0.68,0.7,1},
    lockinput = false,
};