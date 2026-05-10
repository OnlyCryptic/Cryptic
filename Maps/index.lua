-- [[ Cryptic Hub - سجل الماب الرئيسي ]]
-- كل ماب جديد يضاف هنا (وليس في main.lua) لإبقاء main نظيف.
--
-- 🔎 NameMatchers : مطابقة باسم اللعبة (الأقوى — يكتشف أي عالم
--                   جديد يحتوي الاسم بأي شكل: "[UPDATE 25] BLOX FRUITS x2")
-- 🗺️ PlaceIds    : إيديات الأماكن المعروفة — بحث سريع بالـ PlaceId
-- 🌌 GameIds     : UniverseId — رقم واحد يغطي كل عوالم اللعبة بما
--                   فيها التحديثات المستقبلية (أقوى من قائمة الأماكن).

return {
    NameMatchers = {
        { pattern = "blox fruits",   file = "Maps/bloxfruits" },
        { pattern = "bloxfruits",    file = "Maps/bloxfruits" },
        { pattern = "sailor piece",  file = "Maps/sailor_piece" },
        { pattern = "sailorpiece",   file = "Maps/sailor_piece" },
        { pattern = "slime rng", file = "Maps/Slime_RNG" },
{ pattern = "slimerng",  file = "Maps/Slime_RNG" },
        { pattern = "murder mystery 2", file = "Maps/djn_mm2" },
        { pattern = "murdermystery2",   file = "Maps/djn_mm2" },
        { pattern = "mm2",              file = "Maps/djn_mm2" },
    },

    PlaceIds = {
        [2753915549]      = "Maps/bloxfruits",  -- First Sea
        [4442272183]      = "Maps/bloxfruits",  -- Second Sea (new)
        [7449423635]      = "Maps/bloxfruits",  -- Third Sea (new)
        [100117331123089] = "Maps/bloxfruits",
        [73902483975735]  = "Maps/bloxfruits",
        [85211729168715]  = "Maps/bloxfruits",
        [79091703265657]  = "Maps/bloxfruits",
        [92416421522960]  = "Maps/Slime_RNG",
        [142823291]       = "Maps/djn_mm2",     -- Murder Mystery 2
    },

    GameIds = {
        [2923187244] = "Maps/bloxfruits",   -- Blox Fruits Universe
        [9186719164] = "Maps/sailor_piece", -- Sailor Piece Universe
    },
}
