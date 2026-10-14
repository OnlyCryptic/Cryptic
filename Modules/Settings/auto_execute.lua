-- [[ Cryptic Hub - Auto Execute ]]
return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end
    local labels = {
        en  = "Auto Execute",
        ar  = "تشغيل تلقائي",
        ru  = "Автозапуск",
        pt  = "Execução automática",
        es  = "Ejecución automática",
        fr  = "Exécution automatique",
        id  = "Eksekusi otomatis",
        tr  = "Otomatik çalıştır",
        hi  = "ऑटो एक्ज़िक्यूट",
        de  = "Automatisch ausführen",
        uk  = "Автозапуск",
        it  = "Esecuzione automatica",
        vi  = "Tự động chạy",
        th  = "รันอัตโนมัติ",
        zh  = "自动执行",
        ko  = "자동 실행",
        fil = "Auto Execute",
        ja  = "自動実行",
        pl  = "Autostart",
        tw  = "自動執行",
        nl  = "Automatisch uitvoeren",
    }
    if i18n and i18n.Register then
        for code, text in pairs(labels) do
            i18n.Register(code, { ["misc.auto_exec.label"] = text })
        end
    end
    local function TT(key, fallback)
        local v = T(key)
        if v == nil or v == key then return fallback end
        return v
    end

    local HttpService = game:GetService("HttpService")
    local FILE = "CrypticAutoExec.json"

    local function LoadState()
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(FILE))
        end)
        return ok and type(data) == "table" and data.enabled == true
    end

    local function SaveState(on)
        pcall(function()
            writefile(FILE, HttpService:JSONEncode({ enabled = on }))
        end)
    end

    local function Apply(on)
        on = on == true
        SaveState(on)
        -- لو انفتح: نجهّز التشغيل التلقائي للنقلة الجاية (main.lua يحمي من التكرار)
        if on and getgenv().CrypticArmAutoExec then
            pcall(getgenv().CrypticArmAutoExec)
        end
        -- لو انطفى: الملف صار enabled=false، والكود اللي بالطابور يتحقق منه ويتجاهل نفسه
    end

    local saved = LoadState()

    local toggle = Tab:AddToggle(TT("misc.auto_exec.label", "Auto Execute"), function(active)
        Apply(active)
    end)

    -- نرجّع الحالة المحفوظة (يبقى مفعّل لين تطفيه)
    if saved and toggle then
        pcall(function() toggle:SetState(true) end)
    end
end