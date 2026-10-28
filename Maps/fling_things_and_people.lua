--[[
    Throw Map | FTAP-style | v0.1  (Arabic + English)
    الهيكل (نفس أسلوب Resonance):
      1) STR      : جدول الترجمة (en / ar) + دالة T(key, ...)
      2) Remotes  : البحث عن الريموتات داخل ReplicatedStorage مرة واحدة
      3) Features : دوال الميزات (بدون واجهة)
      4) Build    : بناء النافذة والتبويبات (تُعاد عند تغيير اللغة)
      5) Start    : تنظيف القديم ثم تشغيل Build

    لإضافة لغة أو نص جديد: أضف المفتاح في STR.en و STR.ar فقط.
]]

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui        = game:GetService("StarterGui")
local localPlayer       = Players.LocalPlayer

-- نفس نسخة المكتبة المستخدمة في Resonance (Obsidian)
local LIB_URL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/fb0b7b22604664ab94bea7c67e2a14ab1a47ec27/Library.lua"

-- ════════════════════════════════════════════════════════════
-- 1) الترجمة
-- ════════════════════════════════════════════════════════════
local STR = {
    en = {
        ["title"]            = "Throw Map",
        ["footer"]           = "Throw Map v0.1",

        ["tab.toys"]         = "Toys",
        ["tab.toys.desc"]    = "Spawn and manage your toys",
        ["tab.defense"]      = "Defense",
        ["tab.defense.desc"] = "Protect yourself from grabs",
        ["tab.map"]          = "Map",
        ["tab.map.desc"]     = "Map locations",
        ["tab.settings"]     = "Settings",
        ["tab.settings.desc"] = "Language and interface",

        ["toys.box"]         = "Toy Spawner",
        ["toys.name"]        = "Toy name",
        ["toys.name.ph"]     = "e.g. NinjaShuriken",
        ["toys.preset"]      = "Quick pick",
        ["toys.spawn"]       = "Spawn Toy",
        ["toys.clear"]       = "Delete My Toys",
        ["toys.count"]       = "Toys spawned: %d",
        ["toys.badname"]     = "Enter a toy name first",
        ["toys.noremote"]    = "Toy remote not found",
        ["toys.cleared"]     = "Deleted %d toys",

        ["def.box"]          = "Anti-Grab",
        ["def.antigrab"]     = "Anti-Grab",
        ["def.antigrab.tip"] = "Struggles automatically whenever someone holds you",
        ["def.noremote"]     = "Struggle remote not found",

        ["map.box"]          = "Teleport Points",
        ["map.point"]        = "Location",
        ["map.go"]           = "Teleport",
        ["map.none"]         = "No locations found on this map",
        ["map.pick"]         = "Choose a location first",
        ["map.nochar"]       = "Character not ready",

        ["set.box"]          = "Interface",
        ["set.lang"]         = "Language",
        ["set.unload"]       = "Unload Script",
    },

    ar = {
        ["title"]            = "سكربت الرمي",
        ["footer"]           = "سكربت الرمي v0.1",

        ["tab.toys"]         = "الألعاب",
        ["tab.toys.desc"]    = "إنشاء وإدارة ألعابك",
        ["tab.defense"]      = "الحماية",
        ["tab.defense.desc"] = "الحماية من الإمساك بك",
        ["tab.map"]          = "الماب",
        ["tab.map.desc"]     = "أماكن الماب",
        ["tab.settings"]     = "الإعدادات",
        ["tab.settings.desc"] = "اللغة والواجهة",

        ["toys.box"]         = "إنشاء الألعاب",
        ["toys.name"]        = "اسم اللعبة",
        ["toys.name.ph"]     = "مثال: NinjaShuriken",
        ["toys.preset"]      = "اختيار سريع",
        ["toys.spawn"]       = "إنشاء اللعبة",
        ["toys.clear"]       = "حذف ألعابي",
        ["toys.count"]       = "الألعاب الحالية: %d",
        ["toys.badname"]     = "اكتب اسم اللعبة أولاً",
        ["toys.noremote"]    = "ما لقيت ريموت الألعاب",
        ["toys.cleared"]     = "تم حذف %d لعبة",

        ["def.box"]          = "منع الإمساك",
        ["def.antigrab"]     = "منع الإمساك",
        ["def.antigrab.tip"] = "يقاوم تلقائياً كل ما أحد يمسكك",
        ["def.noremote"]     = "ما لقيت ريموت المقاومة",

        ["map.box"]          = "نقاط الانتقال",
        ["map.point"]        = "المكان",
        ["map.go"]           = "انتقال",
        ["map.none"]         = "ما في أماكن في هذا الماب",
        ["map.pick"]         = "اختر مكان أولاً",
        ["map.nochar"]       = "الشخصية غير جاهزة",

        ["set.box"]          = "الواجهة",
        ["set.lang"]         = "اللغة",
        ["set.unload"]       = "إيقاف السكربت",
    },
}

local LANG_NAMES = { en = "English", ar = "العربية" }   -- الاسم يظهر بلغته دائماً
local LANG_LIST  = { "English", "العربية" }

local function DetectLang()
    local saved = getgenv().TM_Lang
    if saved and STR[saved] then return saved end
    local ok, id = pcall(function() return game:GetService("LocalizationService").RobloxLocaleId end)
    if ok and type(id) == "string" and id:sub(1, 2) == "ar" then return "ar" end
    return "en"
end

local Lang = DetectLang()

local function T(key, ...)
    local s = (STR[Lang] and STR[Lang][key]) or STR.en[key] or key
    if select("#", ...) > 0 then
        local ok, out = pcall(string.format, s, ...)
        return ok and out or s
    end
    return s
end

-- ════════════════════════════════════════════════════════════
-- 2) الريموتات (نفس طريقة fn21 في Resonance: مجلد + اسم، مع مهلة)
-- ════════════════════════════════════════════════════════════
local function FindRemote(folder, name)
    local f = ReplicatedStorage:WaitForChild(folder, 0.5)
    return f and f:WaitForChild(name, 0.5)
end

local Remotes = {
    Struggle     = FindRemote("CharacterEvents", "Struggle"),
    SpawnToy     = FindRemote("MenuToys", "SpawnToyRemoteFunction"),
    DestroyToy   = FindRemote("MenuToys", "DestroyToy"),
}

-- ════════════════════════════════════════════════════════════
-- 3) الميزات (منطق فقط)
-- ════════════════════════════════════════════════════════════
local State = { AntiGrab = false }
local Library -- يُحمّل في Start

local function Notify(text)
    local ok = Library and pcall(function()
        Library:Notify({ Title = T("title"), Description = text, Time = 3 })
    end)
    if not ok then
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = T("title"), Text = text, Duration = 3 })
        end)
    end
end

local function MyToyFolder()
    return workspace:FindFirstChild(localPlayer.Name .. "SpawnedInToys")
end

local function CountToys()
    local f = MyToyFolder()
    if not f then return 0 end
    local n = 0
    for _, c in ipairs(f:GetChildren()) do
        if c:IsA("Model") then n = n + 1 end
    end
    return n
end

local function SpawnToy(name)
    if type(name) ~= "string" or name:gsub("%s", "") == "" then
        return Notify(T("toys.badname"))
    end
    if not Remotes.SpawnToy then return Notify(T("toys.noremote")) end
    local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return Notify(T("map.nochar")) end

    task.spawn(function()
        -- ننتظر حتى تسمح اللعبة بإنشاء لعبة جديدة
        local can = localPlayer:FindFirstChild("CanSpawnToy")
        local t0 = os.clock()
        while can and can.Value == false and os.clock() - t0 < 5 do task.wait() end

        local pos = CFrame.new(root.Position + Vector3.new(0, 15, 0)) + Vector3.new(0, 0, 20)
        local rotPart = workspace:FindFirstChild("RotateOrientPart")
        local rot = rotPart and rotPart.Rotation or Vector3.zero
        pcall(function() Remotes.SpawnToy:InvokeServer(name, pos, rot) end)
    end)
end

local function ClearMyToys()
    local f = MyToyFolder()
    if not (f and Remotes.DestroyToy) then return Notify(T("toys.noremote")) end
    local n = 0
    for _, c in ipairs(f:GetChildren()) do
        if c:IsA("Model") then
            Remotes.DestroyToy:FireServer(c)
            n = n + 1
        end
    end
    Notify(T("toys.cleared", n))
end

local function GetWaypoints()
    local list, map = {}, {}
    local wp = workspace:FindFirstChild("Waypoints")
    if wp then
        for _, c in ipairs(wp:GetChildren()) do
            if c.Name ~= "CharacterWaypoint" then
                list[#list + 1] = c.Name
                map[c.Name] = c
            end
        end
    end
    table.sort(list)
    return list, map
end

local function TeleportTo(inst)
    local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return Notify(T("map.nochar")) end
    root.CFrame = inst:GetPivot() + Vector3.new(0, 5, 0)
end

-- ════════════════════════════════════════════════════════════
-- 4) الواجهة
-- ════════════════════════════════════════════════════════════
local function Build()
    local Options = Library.Options

    local Window = Library:CreateWindow({
        Title = "<b>" .. T("title") .. "</b>",
        Footer = T("footer"),
        ToggleKeybind = Enum.KeyCode.RightShift,
        Center = true,
        AutoShow = true,
        EnableSidebarResize = true,
        CornerRadius = 6,
    })

    local Tabs = {
        Toys     = Window:AddTab(T("tab.toys"),     "shapes",   T("tab.toys.desc")),
        Defense  = Window:AddTab(T("tab.defense"),  "shield",   T("tab.defense.desc")),
        Map      = Window:AddTab(T("tab.map"),      "map-pin",  T("tab.map.desc")),
        Settings = Window:AddTab(T("tab.settings"), "settings", T("tab.settings.desc")),
    }

    -- ── الألعاب ──
    do
        local Box = Tabs.Toys:AddLeftGroupbox(T("toys.box"), "shapes")

        Box:AddInput("ToyName", {
            Default = "NinjaShuriken",
            Text = T("toys.name"),
            Placeholder = T("toys.name.ph"),
            Finished = false,
        })
        -- أسماء ألعاب مؤكدة من كود Resonance
        Box:AddDropdown("ToyPreset", {
            Values = { "NinjaShuriken", "PalletLightBrown", "YouDecoy" },
            Default = 1,
            Text = T("toys.preset"),
            Callback = function(v)
                if v and Options.ToyName then Options.ToyName:SetValue(v) end
            end,
        })
        Box:AddButton({
            Text = T("toys.spawn"),
            Func = function() SpawnToy(Options.ToyName and Options.ToyName.Value) end,
        })
        Box:AddButton({ Text = T("toys.clear"), Func = ClearMyToys })

        local Counter = Box:AddLabel(T("toys.count", CountToys()))
        local acc = 0
        Library:GiveSignal(RunService.Heartbeat:Connect(function(dt)
            acc = acc + dt
            if acc < 1 then return end
            acc = 0
            pcall(function() Counter:SetText(T("toys.count", CountToys())) end)
        end))
    end

    -- ── الحماية ──
    do
        local Box = Tabs.Defense:AddLeftGroupbox(T("def.box"), "shield")
        Box:AddToggle("AntiGrab", {
            Text = T("def.antigrab"),
            Tooltip = T("def.antigrab.tip"),
            Default = State.AntiGrab,
            Callback = function(v)
                State.AntiGrab = v
                if v and not Remotes.Struggle then Notify(T("def.noremote")) end
            end,
        })

        local isHeld = localPlayer:FindFirstChild("IsHeld")
        local acc = 0
        Library:GiveSignal(RunService.Heartbeat:Connect(function(dt)
            if not State.AntiGrab or not Remotes.Struggle then return end
            if not (isHeld and isHeld.Value) then return end
            acc = acc + dt
            if acc < 1 / 30 then return end
            acc = 0
            Remotes.Struggle:FireServer()
        end))
    end

    -- ── الماب ──
    do
        local Box = Tabs.Map:AddLeftGroupbox(T("map.box"), "map-pin")
        local list, map = GetWaypoints()
        if #list == 0 then
            Box:AddLabel(T("map.none"), true)
        else
            Box:AddDropdown("MapPoint", {
                Values = list, Default = 1, Searchable = true, Text = T("map.point"),
            })
            Box:AddButton({
                Text = T("map.go"),
                Func = function()
                    local inst = map[Options.MapPoint and Options.MapPoint.Value]
                    if not inst then return Notify(T("map.pick")) end
                    TeleportTo(inst)
                end,
            })
        end
    end

    -- ── الإعدادات ──
    do
        local Box = Tabs.Settings:AddLeftGroupbox(T("set.box"), "settings")
        Box:AddDropdown("Language", {
            Values = LANG_LIST,
            Default = LANG_NAMES[Lang],
            Text = T("set.lang"),
            Callback = function(v)
                local code = (v == LANG_NAMES.ar) and "ar" or "en"
                if code == Lang then return end
                Lang = code
                getgenv().TM_Lang = code
                task.defer(function() getgenv().TM_Start() end)   -- إعادة بناء الواجهة باللغة الجديدة
            end,
        })
        Box:AddButton({
            Text = T("set.unload"),
            Func = function() getgenv().TM_Cleanup() end,
        })
    end
end

-- ════════════════════════════════════════════════════════════
-- 5) التشغيل / التنظيف
-- ════════════════════════════════════════════════════════════
local function Cleanup()
    if Library then pcall(function() Library:Unload() end) end
    Library = nil
end
if getgenv().TM_Cleanup then pcall(getgenv().TM_Cleanup) end   -- ينظف نسخة قديمة لو أعدت التشغيل
getgenv().TM_Cleanup = Cleanup

local function Start()
    Cleanup()   -- أي نسخة قديمة (من إعادة التشغيل أو تغيير اللغة)
    local ok, lib = pcall(function() return loadstring(game:HttpGet(LIB_URL))() end)
    if not (ok and lib) then
        warn("[ThrowMap] failed to load UI library: " .. tostring(lib))
        return
    end
    Library = lib
    local built, err = pcall(Build)
    if not built then warn("[ThrowMap] UI error: " .. tostring(err)) end
end
getgenv().TM_Start = Start

Start()