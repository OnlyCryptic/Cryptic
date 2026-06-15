-- [[ Cryptic Hub - سجل الماب الرئيسي ]]
-- كل ماب جديد يضاف هنا (وليس في main.lua) لإبقاء main نظيف.

return {
    NameMatchers = {
        { pattern = "blox fruits",      file = "Maps/bloxfruits" },
        { pattern = "bloxfruits",       file = "Maps/bloxfruits" },

        { pattern = "sailor piece",     file = "Maps/sailor_piece" },
        { pattern = "sailorpiece",      file = "Maps/sailor_piece" },

        { pattern = "blade ball",       file = "Maps/BB" },

        { pattern = "slime rng",        file = "Maps/Slime_RNG" },
        { pattern = "slimerng",         file = "Maps/Slime_RNG" },

        { pattern = "wizard alchemy",   file = "Maps/wizard_alchemy" },

        { pattern = "grow a garden 2",  file = "Maps/gag2" },
        { pattern = "growagarden2",     file = "Maps/gag2" },

        { pattern = "murder mystery 2", file = "Maps/djn_mm2" },
        { pattern = "murdermystery2",   file = "Maps/djn_mm2" },
        { pattern = "mm2",              file = "Maps/djn_mm2" },
    },

    PlaceIds = {
        [2753915549]       = "Maps/bloxfruits",
        [4442272183]       = "Maps/bloxfruits",
        [7449423635]       = "Maps/bloxfruits",
        [100117331123089]  = "Maps/bloxfruits",
        [73902483975735]   = "Maps/bloxfruits",
        [85211729168715]   = "Maps/bloxfruits",
        [79091703265657]   = "Maps/bloxfruits",

        [118821269826806]  = "Maps/wizard_alchemy",

        [92416421522960]   = "Maps/Slime_RNG",

        [13772394625]      = "Maps/BB",

        [142823291]        = "Maps/djn_mm2",

        [97598239454123]   = "Maps/gag2",
    },

    GameIds = {
        [2923187244]  = "Maps/bloxfruits",
        [4777817887]  = "Maps/BB",
        [9792947201]  = "Maps/Slime_RNG",
        [10006104044] = "Maps/wizard_alchemy",
        [9186719164]  = "Maps/sailor_piece",

        [10200395747] = "Maps/gag2",
    },
}