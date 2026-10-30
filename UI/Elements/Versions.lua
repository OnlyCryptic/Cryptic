-- [[ Cryptic Hub - Emotes Menu (v1 = emo3 | v2 = emo4) ]]
-- مكانه: Modules/Misc/emotes.lua  (يستبدل الملف القديم)
-- ويحتاج بنفس المجلد: emo3.lua (v1) و emo4.lua (v2)
local BASE = "https://raw.githubusercontent.com/OnlyCryptic/Cryptic/gm/Modules/Misc/"

local function Load(name)
    local ok, src = pcall(game.HttpGet, game, BASE .. name .. ".lua?v=" .. tick())
    if ok and src then
        local f = loadstring(src)
        if f then return f() end
    end
end

return function(Tab, UI)
    local DEFAULT = "v2"
    local emo3 = Load("emo3")
    local emo4 = Load("emo4")
    if type(emo3) ~= "function" or type(emo4) ~= "function" then
        warn("Cryptic Hub: failed to load emo3/emo4")
        return false
    end

    -- ناخذ دالة التوغل حقت كل ملف بدون ما نضيف زر مكرر
    local function capture(mod)
        local cb, label
        local proxy = setmetatable({}, {
            __index = function(_, k)
                if k == "AddToggle" then
                    return function(_, l, f) label, cb = l, f end
                end
                local v = Tab[k]
                if type(v) == "function" then
                    return function(_, ...) return v(Tab, ...) end
                end
                return v
            end
        })
        pcall(mod, proxy, UI)
        return cb, label
    end

    local cb1, label1 = capture(emo3)
    local cb2, label2 = capture(emo4)
    local handlers = { v1 = cb1, v2 = cb2 }
    local label = label2 or label1 or "Emotes Menu"

    local running = nil -- النسخة الشغالة حالياً

    local function apply(state, ver)
        if ver ~= "v1" and ver ~= "v2" then ver = DEFAULT end

        -- طفّ القديمة إذا انطفى التوغل أو تغيرت النسخة
        if running and ((not state) or running ~= ver) then
            if handlers[running] then pcall(handlers[running], false) end
            running = nil
        end
        -- شغّل المطلوبة
        if state and not running then
            if handlers[ver] then pcall(handlers[ver], true) end
            running = ver
        end
    end

    -- القائمة: الأول = الافتراضي (v2)
    Tab:AddVersion(label, function(state, ver)
        apply(state, ver)
    end, { "v2", "v1" })
end