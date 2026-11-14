-- ============================================================
--  Cryptic Hub - main.lua  (نسخة التحميل السريع)
--  الفكرة:
--   - تحميل (HttpGet) كل الملفات بالتوازي من أول لحظة، مو واحد ورا واحد
--   - تشغيل الموديولات بالترتيب مع تنفس بين الملفات الثقيلة (بدون لاق)
--  الترتيب:
--   1) الخدمات   2) حماية التشغيل المزدوج   3) الإعدادات
--   4) التشغيل التلقائي   5) محرك التحميل المسبق   6) i18n + الماب
--   7) هيكل التابات   8) أدوات البناء   9) بناء التابات
--  10) إعادة الدخول بعد تغيير اللغة   11) تشغيل الواجهة
-- ============================================================

-- ============================================================
-- 1) الخدمات والمتغيرات
-- ============================================================
local HttpService     = game:GetService("HttpService")
local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local StarterGui      = game:GetService("StarterGui")
local lp              = Players.LocalPlayer
local env             = getgenv()

-- ============================================================
-- 2) حماية التشغيل المزدوج
-- ============================================================
-- أي تشغيل ثاني بنفس الجلسة يوصل خلال هالمدة (ثواني) يعتبر تشغيل تلقائي مكرر
-- (من زر إعادة دخول، تبديل سيرفر، تغيير لغة، التشغيل التلقائي...) ونتجاهله بصمت.
local DUP_WINDOW = 20

local now = tick()

-- وقت آخر تشغيل تلقائي (يكتبه الكود اللي بالطابور). ما نمسحه بعد القراءة،
-- عشان كل النسخ المكررة تشوفه
local launchAt   = env.CrypticAutoLaunchAt
local autoLaunch = type(launchAt) == "number" and (now - launchAt) < DUP_WINDOW

-- نفس الجلسة = نفس كائن اللاعب (lp).
-- بعد أي نقل أو إعادة دخول يتغير lp، فالعلامة القديمة ما تأثر.
local sameSession = env.CrypticHub_Loaded == true and env.CrypticHub_Player == lp

-- الجلسة بدأت قبل ثواني بس؟ إذاً هذا تشغيل مكرر مو يدوي
local startAt     = env.CrypticHub_StartAt
local justStarted = sameSession and type(startAt) == "number" and (now - startAt) < DUP_WINDOW

if sameSession and (autoLaunch or justStarted) then return end

-- نحجز الجلسة فوراً (قبل أي انتظار) عشان النسخة الثانية تلقاها محجوزة
if not sameSession then
    env.CrypticHub_Loaded  = true
    env.CrypticHub_Player  = lp
    env.CrypticHub_StartAt = now
end

-- ============================================================
-- 3) الإعدادات
-- ============================================================
local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "hm",
        Discord = "https://discord.gg/QSvQJs7BdP"
    },
    -- ملاحظة: سجل الماب (GameIds بالـ Universe ID) موجود في
    -- Cryptic/Maps/index.lua لإبقاء هذا الملف نظيف.
}

local RAW_BASE = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    Cryptic.Config.UserName, Cryptic.Config.RepoName, Cryptic.Config.Branch
)

local UserInputService = game:GetService("UserInputService")

-- يضبط نفسه تلقائياً حسب الجهاز: جوال (لمس بدون كيبورد) أو كمبيوتر
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local SESSION_V      = tostring(tick())            -- نفس الرقم لكل طلبات هالتشغيل (يتجاوز الكاش القديم)
local WORKER_START   = IS_MOBILE and 4 or 8        -- تحميلات متوازية (ينقص تلقائياً لو النت ضعيف أو فيه فشل)
local BASE_BUDGET    = IS_MOBILE and 0.006 or 0.010 -- وقت العمل (ثواني) قبل ما نعطي اللعبة فريم (يقل تلقائياً لو الجهاز بطيء)
local MODULE_TIMEOUT = 6                           -- مهلة الموديول الواحد قبل ما نكمل على اللي بعده

-- وضع آمن يدوي: لو احتجته مستقبلاً (تحميل واحد واحد + تنفس أكثر)
-- getgenv().CrypticSafeMode = true  قبل تشغيل السكربت
if env.CrypticSafeMode then
    WORKER_START = 1
    BASE_BUDGET  = 0.003
end

-- ============================================================
-- 4) التشغيل التلقائي بعد النقل / إعادة الدخول
-- ============================================================
local AUTOEXEC_FILE = "CrypticAutoExec.json"

-- كود يتحط بطابور النقل. conditional = true يعني: يشتغل بس لو التوغل لسا مفعّل
local function BuildLoader(conditional)
    local url = RAW_BASE .. "main.lua"

    local check = ""
    if conditional then
        check = string.format([[
    local on = false
    pcall(function()
        on = game:GetService("HttpService"):JSONDecode(readfile(%q)).enabled == true
    end)
    if not on then return end
]], AUTOEXEC_FILE)
    end

    return string.format([[
pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(2)
%s    getgenv().CrypticAutoLaunchAt = tick()
    loadstring(game:HttpGet(%q .. "?v=" .. tick()))()
end)
]], check, url)
end

local function QueueOnTeleport(code)
    local fn = queue_on_teleport
        or (syn and syn.queue_on_teleport)
        or (fluxus and fluxus.queue_on_teleport)
    if not fn then return false end
    return (pcall(fn, code))
end

local function AutoExecEnabled()
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(AUTOEXEC_FILE))
    end)
    return ok and type(data) == "table" and data.enabled == true
end

-- يجهّز التشغيل التلقائي مرة وحدة لكل جلسة (الطابور يشتغل بس على أول نقل،
-- فكل ما يشتغل السكربت نجهّزه من جديد)
local function ArmAutoExec()
    if env.CrypticAutoExecArmed == lp then return end
    if QueueOnTeleport(BuildLoader(true)) then
        env.CrypticAutoExecArmed = lp
    end
end
env.CrypticArmAutoExec = ArmAutoExec -- يستخدمه توغل التشغيل التلقائي

-- ============================================================
-- 5) محرك التحميل المسبق
-- ============================================================
local Sources  = {}  -- path -> نص الملف (أو false لو فشل)
local Inflight = {}  -- path -> true أثناء التحميل
local Compiled = {}  -- path -> true بعد ما انشغل (نفرّغ نصه من الذاكرة)

local RETRY_DELAYS = { 0.3, 0.8 } -- انتظار بين المحاولات (بالخلفية فقط)

local WorkerLimit = WORKER_START   -- الحد الحالي للتحميلات المتوازية (ينقص لو النت ضعيف)
local NetFails    = 0              -- عدد مرات فشل التحميل (غير 404)

-- يحمّل نص ملف. لو أحد ثاني يحمّله الحين ننتظره بدل ما نكرر الطلب.
-- attempts = عدد المحاولات (فشل 404 ما نعيده لأن الملف مو موجود أصلاً)
local function Fetch(path, attempts)
    local cached = Sources[path]
    if cached ~= nil then return cached or nil end

    if Inflight[path] then
        while Inflight[path] do task.wait() end
        return Sources[path] or nil
    end

    Inflight[path] = true
    attempts = attempts or 1
    local body
    for attempt = 1, attempts do
        local ok, res = pcall(game.HttpGet, game, RAW_BASE .. path .. "?v=" .. SESSION_V)
        if ok and type(res) == "string" and res ~= "" then
            body = res
            break
        end
        if tostring(res):find("404", 1, true) then break end

        -- فشل شبكة: كل 3 فشلات ننزّل التحميل المتوازي للنصف (لين يوصل 1 = تحميل عادي واحد واحد)
        NetFails = NetFails + 1
        if NetFails % 3 == 0 and WorkerLimit > 1 then
            WorkerLimit = math.max(1, math.floor(WorkerLimit / 2))
        end
        if attempt < attempts then task.wait(RETRY_DELAYS[attempt] or 1) end
    end
    Sources[path] = body or false
    Inflight[path] = nil
    return body
end

-- للاستخدام وقت البناء: محاولة وبعدها محاولة ثانية فورية (نفس سلوك النسخة القديمة)
local function GetSource(path)
    local src = Fetch(path, 1)
    if src then return src end
    Sources[path] = nil
    return Fetch(path, 1)
end

-- طابور تحميل مشترك + عمّال بالخلفية (عددهم يتبع WorkerLimit)
local Queue, QHead, Active = {}, 0, 0

local function Pump()
    while Active < WorkerLimit and QHead < #Queue do
        Active = Active + 1
        task.spawn(function()
            while Active <= WorkerLimit do
                QHead = QHead + 1
                local p = Queue[QHead]
                if p == nil then
                    QHead = QHead - 1
                    break
                end
                if not Compiled[p] then Fetch(p, 3) end
            end
            Active = Active - 1
        end)
    end
end

-- يضيف ملفات للطابور ويبدأ تحميلها بالتوازي بالخلفية (ما يوقف شي)
local function Prefetch(paths)
    for _, p in ipairs(paths) do
        table.insert(Queue, p)
    end
    Pump()
end

-- يعطي اللعبة فريم لو شغلنا أكثر من الميزانية. الميزانية تقل تلقائياً لو الجهاز بطيء
-- (نقيس طول الفريم من task.wait نفسها): فريم بطيء = ننتظر بعد كل ملف.
local lastYield = os.clock()
local frameDt   = 1 / 60
local function Breathe()
    local budget = BASE_BUDGET
    if frameDt > 0.045 then
        budget = 0
    elseif frameDt > 0.03 then
        budget = BASE_BUDGET * 0.5
    end
    if os.clock() - lastYield >= budget then
        local dt = task.wait()
        if type(dt) == "number" then frameDt = dt end
        lastYield = os.clock()
    end
end

-- يجيب الملف (من الكاش لو جاهز) ويشغّله ويرجع نتيجته
local function Import(path)
    local src = GetSource(path)
    if not src then return nil end
    local f = loadstring(src)
    if not f then return nil end
    -- نفرّغ النص من الذاكرة (مهم للأجهزة الضعيفة مع الملفات الكبيرة المشفرة)
    Sources[path] = nil
    Compiled[path] = true
    local ok, result = pcall(f)
    if ok then return result end
    warn("Cryptic Hub: error in " .. path .. " - " .. tostring(result))
    return nil
end

local ElementCache = {}
local function LoadElement(elementName)
    if ElementCache[elementName] then return ElementCache[elementName] end
    local func = Import("UI/Elements/" .. elementName .. ".lua")
    if func then
        ElementCache[elementName] = func
        return func
    end
    warn("Cryptic Hub: Failed to load element - " .. elementName)
    return nil
end

-- ============================================================
-- 6) i18n + سجل الماب + Physics Guard
-- ============================================================
-- نبدأ تحميل الأساسيات بالتوازي أول شي
Prefetch({ "i18n.lua", "Maps/index.lua", "Modules/Core/physics_guard.lua" })

do
    local registry = Import("Maps/index.lua")
    if type(registry) == "table" then
        Cryptic.GameIds = registry.GameIds or {}
    else
        Cryptic.GameIds = {}
    end
end

-- i18n يتحمل ويتاح عالمياً قبل أي شي
local i18n = Import("i18n.lua")
if i18n then
    i18n.Load()                        -- يقرأ اللغة المحفوظة لو موجودة
    getgenv().CrypticI18n = i18n       -- متاح لكل الموديولات
end

-- Physics Guard: يعمل بصمت، يمنع اهتزاز الفيزياء في كل الميزات
pcall(function() Import("Modules/Core/physics_guard.lua") end)

local function T(key)
    if i18n then return i18n.T(key) end
    return key
end

-- ============================================================
-- 7) هيكل التابات
-- ============================================================
-- قوائم ملفات التابات الخاصة
local TARGET_MAIN   = {"target_select"}
local TARGET_SPY    = {"target_spectate", "target_tp", "Target_follow", "target_esp", "skinz", "info_t"}
local TARGET_FUN    = {"bang", "target_facesit", "jark", "target_hug", "target_sit", "backpack", "carry", "target_dee", "lkm", "target_shit"}
local TARGET_TRICKS = {"target_fling", "bring_parts", "target_mimic", "copy_walk", "target_aimbot", "target_emotes"}
local OTHER_LIST    = {"lol", "animations", "vfly", "zero_gravity", "anti_block", "anti_sit", "fling_all", "night", "infinite_zoom", "no_camera_clip", "anti_afk", "aimbot"}

local function BuildStructure()
    Cryptic.Structure = {
        ["player"]   = { Icon = "👤", Key = "tab.player",   Folder = "Player",   Files = {"so", "blox", "gold", "auto_apple", "vi", "speed", "fly", "jumppower", "noclip", "antifling", "walkfling", "flyfling", "wallwalk", "nofall", "infinitejump", "3d", "restart", "out", "discord", "di2"} },
        ["tools"]    = { Icon = "🔧", Key = "tab.tools",    Folder = "Misc",     Files = {"lol", "tptool", "auto_tool", "fling_tool", "noclip_tool", "emotes", "esp", "nbc_esp", "tool_esp", "shiftlock", "invis_tool", "spin_tool", "x-ray", "fullbright", "no_fog", "camera"} },
        ["target"]   = { Icon = "🎯", Key = "tab.target",   Folder = "Combat",   Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling", "bring_parts", "carry", "jark", "Target_follow", "target_esp", "copy_skin1", "target_emotes", "target_facesit", "info_t", "skinz"} },
        ["server"]   = { Icon = "🌐", Key = "tab.server",   Folder = "Server",   Files = {"server", "rejoin", "join_id", "players"} },
        ["teleport"] = { Icon = "📍", Key = "tab.teleport", Folder = "Teleport", Files = {"lol", "tp_locations", "checkpoint"} },
        ["other"]    = { Icon = "⚡", Key = "tab.other",    Folder = "Other",    Files = OTHER_LIST },
        ["settings"] = { Icon = "⚙️", Key = "tab.settings", Folder = "Settings", Files = {"transparency", "anti_lag", "ui_lock", "ui_toggle", "auto_execute", "settings", "suggestion_box"} },
    }
    Cryptic.TabsOrder = {
        "player", "tools", "target", "other", "teleport", "server", "settings"
    }
end

-- التعرف على الماب بالـ Universe ID فقط (game.GameId)
local function GetMapPath()
    local p = Cryptic.GameIds and Cryptic.GameIds[game.GameId]
    return p and (p .. ".lua") or nil
end

local function InjectMapTab()
    local mapFilePath = GetMapPath()
    if not mapFilePath then return end

    local mapData = Import(mapFilePath)
    if type(mapData) ~= "table" then return end

    local id = "map_current"
    Cryptic.Structure[id] = { _isMapTab = true, _mapData = mapData }
    table.insert(Cryptic.TabsOrder, 2, id)
end

local function TabDisplayName(id)
    local data = Cryptic.Structure[id]
    if not data then return id end
    if data._isMapTab and data._mapData then
        return "🗺️ " .. data._mapData.Name
    end
    return T(data.Key)
end

local function TabIcon(id)
    local data = Cryptic.Structure[id]
    if not data or data._isMapTab then return nil end
    return data.Icon
end

-- ============================================================
-- 8) أدوات بناء التابات
-- ============================================================
local TAB_ELEMENTS = {
    "Button", "Toggle", "LockedToggle", "ExclusiveToggle", "TimedToggle", "Input", "LargeInput",
    "SpeedControl", "Dropdown", "PlayerSelector", "AddAutoOffToggle", "ProfileCard",
    "Line", "Label", "Paragraph", "Folder", "Versions", "HotkeyToggle"
}

local OPEN_ELEMENTS = {
    "Button", "Toggle", "LockedToggle", "ExclusiveToggle", "TimedToggle", "Input", "LargeInput",
    "SpeedControl", "Dropdown", "PlayerSelector", "ProfileCard", "Label", "Paragraph", "Folder", "Line"
}

-- يجمع كل الملفات اللي راح نحتاجها بترتيب الأولوية: واجهة، عناصر، ثم موديولات التابات
local function CollectPaths()
    local paths, seen = {}, {}
    local function add(p)
        if not seen[p] then
            seen[p] = true
            table.insert(paths, p)
        end
    end
    local function addModules(folder, list)
        for _, fname in ipairs(list) do
            add("Modules/" .. folder .. "/" .. fname .. ".lua")
        end
    end

    local mapPath = GetMapPath()
    if mapPath then add(mapPath) end

    add("UI/Core.lua")
    add("UI/LanguagePicker.lua")
    add("UI/Elements/Open.lua")
    if mapPath then add("UI/Elements/MapCard.lua") end

    for _, el in ipairs(TAB_ELEMENTS) do
        if el ~= "AddAutoOffToggle" then add("UI/Elements/" .. el .. ".lua") end
    end
    for _, el in ipairs(OPEN_ELEMENTS) do
        add("UI/Elements/" .. el .. ".lua")
    end

    for _, tabId in ipairs(Cryptic.TabsOrder) do
        local data = Cryptic.Structure[tabId]
        if data then
            if tabId == "target" then
                addModules("Combat", TARGET_MAIN)
                addModules("Combat", TARGET_SPY)
                addModules("Combat", TARGET_FUN)
                addModules("Combat", TARGET_TRICKS)
            elseif tabId == "other" then
                addModules("Other", OTHER_LIST)
                add("Modules/Other/build.lua")
            else
                addModules(data.Folder, data.Files)
            end
        end
    end

    add("Modules/Inbox.lua")
    return paths
end

-- يربط دوال Add... بالتاب (كل عنصر يتحمل أول ما ينطلب)
local function AttachElements(tab, elementNames)
    for _, el in ipairs(elementNames) do
        tab["Add" .. el] = function(self, ...)
            local f = LoadElement(el)
            if f then return f(self, ...) end
        end
    end
end

-- يسوي كرت Open داخل تاب. يرجع nil لو العنصر ما انحمل
local function MakeOpen(parentTab, title, icon)
    local openFunc = LoadElement("Open")
    if not openFunc then return nil end
    local openTab = openFunc(parentTab, title, icon)
    AttachElements(openTab, OPEN_ELEMENTS)
    return openTab
end

-- يعرض MakeOpen لباقي الملفات (مثل aimbot.lua) عشان تستخدم نفس كرت Open
getgenv().CrypticMakeOpen = MakeOpen

-- يشغّل مجموعة ملفات بسيطة (استيراد + pcall) على تاب معيّن
local function RunSimple(targetTab, folder, fileList, UI)
    for _, fname in ipairs(fileList) do
        local init = Import("Modules/" .. folder .. "/" .. fname .. ".lua")
        if type(init) == "function" then
            pcall(init, targetTab, UI)
        end
        Breathe()
    end
end

-- يشغّل الموديولات واحد ورا الثاني. كل موديول ياخذ مهلة؛
-- لو علّق (مثلاً WaitForChild ما لقى شي) نكمل على اللي بعده.
local function RunModules(targetTab, folder, fileList, UI)
    for _, fname in ipairs(fileList) do
        local filePath = (folder == "") and (fname .. ".lua") or ("Modules/" .. folder .. "/" .. fname .. ".lua")
        local init = Import(filePath)
        if type(init) == "function" then
            local done, ok, result = false, false, nil
            task.spawn(function()
                ok, result = pcall(init, targetTab, UI)
                done = true
            end)

            local t0 = tick()
            while not done and tick() - t0 < MODULE_TIMEOUT do
                task.wait()
            end

            if not done then
                warn("Cryptic Hub: module timed out - " .. fname)
            elseif ok and result ~= false then
                targetTab:AddLine()
            end
        end
        Breathe()
    end
end

-- يخلي التوغلات داخل كرت معيّن حصرية: تشغيل وحدة يطفي الباقي
local function MakeExclusiveGroup(openTab)
    local group = {}

    local function wrap(getObj, callback)
        return function(active)
            if active then
                local me = getObj()
                for _, other in ipairs(group) do
                    if other ~= me then
                        pcall(function() other:SetState(false) end)
                    end
                end
            end
            if callback then callback(active) end
        end
    end

    local origToggle = openTab.AddToggle
    openTab.AddToggle = function(self, label, callback)
        local obj
        obj = origToggle(self, label, wrap(function() return obj end, callback))
        if obj then table.insert(group, obj) end
        return obj
    end

    local origLocked = openTab.AddLockedToggle
    openTab.AddLockedToggle = function(self, label, reasonOrCb, callbackOrNil)
        local reason, callback
        if type(reasonOrCb) == "function" then
            reason, callback = "", reasonOrCb
        else
            reason, callback = reasonOrCb, callbackOrNil
        end
        local obj
        obj = origLocked(self, label, reason, wrap(function() return obj end, callback))
        if obj then table.insert(group, obj) end
        return obj
    end
end

-- ============================================================
-- 9) بناء كل تاب
-- ============================================================
local function BuildMapTab(tab, mapData, UI)
    if type(mapData.Render) == "function" then
        pcall(function() mapData.Render(tab, UI) end)
    else
        tab:AddLabel("🗺️ " .. T("tab.map_scripts"))
        local MapCardFunc = LoadElement("MapCard")
        if MapCardFunc then pcall(function() MapCardFunc(tab, mapData) end) end
    end
end

local function BuildTargetTab(tab, UI)
    RunSimple(tab, "Combat", TARGET_MAIN, UI)

    local spyTab = MakeOpen(tab, T("open.spy"), "👁️") or tab
    RunSimple(spyTab, "Combat", TARGET_SPY, UI)

    local funTab = MakeOpen(tab, T("open.fun"), "😂") or tab
    MakeExclusiveGroup(funTab)
    RunSimple(funTab, "Combat", TARGET_FUN, UI)

    local tricksTab = MakeOpen(tab, T("open.tricks"), "🎭") or tab
    RunSimple(tricksTab, "Combat", TARGET_TRICKS, UI)
end

local function BuildOtherTab(tab, data, UI)
    RunModules(tab, data.Folder, OTHER_LIST, UI)

    local buildTab = MakeOpen(tab, T("other.build.tab"), "🏗️") or tab
    local buildInit = Import("Modules/Other/build.lua")
    if type(buildInit) == "function" then pcall(function() buildInit(buildTab, UI) end) end
    tab:AddLine()
end

-- ============================================================
-- 10) إعادة الدخول للسيرفر بعد تغيير اللغة
-- ============================================================
local function RejoinForLanguage()
    -- بدون شرط: تغيير اللغة لازم يعيد التشغيل حتى لو التشغيل التلقائي مطفي.
    -- ولو التشغيل التلقائي مفعّل، النسخة المكررة تتجاهل نفسها بصمت.
    QueueOnTeleport(BuildLoader(false))

    local function notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = text, Duration = 5,
            })
        end)
    end

    notify(T("lang.rejoining"))
    local sameOk = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
    end)
    if sameOk then return end

    notify(T("lang.hopping"))
    local hopOk = false
    pcall(function()
        local cursor = ""
        for _ = 1, 4 do
            local apiUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId
                .. "/servers/Public?sortOrder=Asc&limit=100"
                .. (cursor ~= "" and ("&cursor=" .. cursor) or "")
            local res = game:HttpGet(apiUrl)
            if not res or res == "" then break end
            local data = HttpService:JSONDecode(res)
            if data and data.data then
                for _, srv in ipairs(data.data) do
                    if srv.id ~= game.JobId
                       and type(srv.playing) == "number"
                       and type(srv.maxPlayers) == "number"
                       and srv.playing < srv.maxPlayers then
                        local ok = pcall(function()
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, lp)
                        end)
                        if ok then hopOk = true return end
                    end
                end
                if data.nextPageCursor and data.nextPageCursor ~= "" then
                    cursor = data.nextPageCursor
                else break end
            else break end
        end
    end)
    if hopOk then return end

    notify(T("lang.fail"))
end

-- ============================================================
-- 11) تشغيل الواجهة والبوابة الرئيسية
-- ============================================================
local function StartCrypticHub()
    InjectMapTab()
    local UI = Import("UI/Core.lua")
    if not UI then return end

    local MainWin = UI:CreateWindow("Cryptic Hub / " .. Cryptic.Config.Discord)

    getgenv().CrypticOpenLangPicker = function()
        local Picker = Import("UI/LanguagePicker.lua")
        if Picker and i18n then
            Picker.Show(i18n, function(code)
                if not code then return end
                if code == i18n.Get() then return end
                i18n.Set(code)
                RejoinForLanguage()
            end, { closable = true, preselected = i18n.Get() })
        end
    end

    -- أزرار كل التابات تظهر فوراً (رخيص)، والمحتوى ينبني بعدها بالترتيب
    local tabs = {}
    for _, tabId in ipairs(Cryptic.TabsOrder) do
        local tabData = Cryptic.Structure[tabId]
        if tabData then
            local tab = MainWin:CreateTab(TabDisplayName(tabId), TabIcon(tabId))
            AttachElements(tab, TAB_ELEMENTS)
            table.insert(tabs, { id = tabId, data = tabData, tab = tab })
        end
    end

    -- بناء المحتوى تاب ورا تاب بخيط واحد: الملفات جاهزة من التحميل المسبق،
    -- والتنفس بين الملفات يمنع اللاق. أي تاب يفشل ما يوقف الباقي.
    task.spawn(function()
        for _, entry in ipairs(tabs) do
            local ok, err = pcall(function()
                if entry.data._isMapTab and entry.data._mapData then
                    BuildMapTab(entry.tab, entry.data._mapData, UI)
                elseif entry.id == "target" then
                    BuildTargetTab(entry.tab, UI)
                elseif entry.id == "other" then
                    BuildOtherTab(entry.tab, entry.data, UI)
                else
                    RunModules(entry.tab, entry.data.Folder, entry.data.Files, UI)
                end
            end)
            if not ok then
                warn("Cryptic Hub: tab failed - " .. tostring(entry.id) .. " - " .. tostring(err))
            end
        end
    end)
end

-- فحص صندوق الرسائل (Inbox)
local function RunInboxCheck()
    task.spawn(function()
        local CheckInbox = Import("Modules/Inbox.lua")
        if type(CheckInbox) == "function" then
            CheckInbox(Cryptic.Config)
        end
    end)
end

local function Boot()
    -- لو التشغيل التلقائي مفعّل نجهّزه للنقلة الجاية
    if AutoExecEnabled() then ArmAutoExec() end

    -- نبدأ تحميل كل الملفات بالتوازي من الحين (حتى أثناء اختيار اللغة)
    BuildStructure()
    Prefetch(CollectPaths())

    RunInboxCheck()

    if not i18n then
        StartCrypticHub()
        return
    end

    if i18n.HasSaved() then
        StartCrypticHub()
        return
    end

    local Picker = Import("UI/LanguagePicker.lua")
    if not Picker then
        StartCrypticHub()
        return
    end

    Picker.Show(i18n, function(code)
        if code then i18n.Set(code) end
        StartCrypticHub()
    end, { closable = false })
end

-- نظام الحماية من التشغيل المزدوج
-- (الجلسة انحجزت فوق؛ هنا نسأل المستخدم بس لو هو شغّل السكربت يدوياً مرة ثانية)
if sameSession then
    local Bindable = Instance.new("BindableFunction")
    Bindable.OnInvoke = function(buttonText)
        if buttonText == T("rerun.yes") then Boot() end
    end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = T("rerun.title") .. " ⚠️",
            Text     = T("rerun.text"),
            Duration = 15,
            Button1  = T("rerun.yes"),
            Button2  = T("rerun.cancel"),
            Callback = Bindable
        })
    end)
else
    Boot()
end
