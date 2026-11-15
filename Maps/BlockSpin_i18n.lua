-- [[ Cryptic Hub - Map: Block Spin ]]
-- Needs Maps/BlockSpin_i18n.lua next to it (translations). Set the Block Spin PlaceId in the hub.

-- ============================================================
-- 1. Translations: English fallback here, other languages load from Maps/BlockSpin_i18n.lua
-- ============================================================
local I18N_FILE = "Maps/BlockSpin_i18n.lua"
local I18N_URL  = ""  -- optional raw URL of BlockSpin_i18n.lua (used if the file is not found locally)
local EN = {
    ["bs.sec.combat"] = "Combat",
    ["bs.sec.weapons"] = "Weapons",
    ["bs.sec.visuals"] = "Visuals / ESP",
    ["bs.sec.farm"] = "Farm",
    ["bs.sec.shop"] = "Shop",
    ["bs.sec.player"] = "Player",
    ["bs.sec.friends"] = "Friends",
    ["bs.ui.hint"] = "Tap a section to open / close it",
    ["bs.ui.target"] = "Target",
    ["bs.ui.none"] = "None",
    ["bs.ui.stopall"] = "Stop All",
    ["bs.ui.stopped"] = "Everything stopped",
    ["bs.silent"] = "Silent Aim",
    ["bs.assist"] = "Aim Assist (Camera)",
    ["bs.wall"] = "Wall Check",
    ["bs.line"] = "Target Line",
    ["bs.showfov"] = "Show FOV Circle",
    ["bs.predict"] = "Smart Prediction",
    ["bs.fov"] = "FOV Radius",
    ["bs.strength"] = "Aim Strength",
    ["bs.hitpart"] = "Hit Part",
    ["bs.part.head"] = "Head",
    ["bs.part.neck"] = "Neck",
    ["bs.part.chest"] = "Chest",
    ["bs.autoshoot"] = "Auto Shoot",
    ["bs.shootrange"] = "Auto Shoot Range (m)",
    ["bs.gunmod"] = "Gun Mod",
    ["bs.gm.recoil"] = "No Recoil",
    ["bs.gm.accuracy"] = "Accuracy+",
    ["bs.gm.range"] = "Range+",
    ["bs.gm.firerate"] = "Fire Rate+",
    ["bs.gm.reload"] = "Fast Reload",
    ["bs.gm.auto"] = "Full Auto",
    ["bs.aura"] = "Melee Aura",
    ["bs.autoatk"] = "Auto Melee Attack",
    ["bs.meleerange"] = "Melee Range",
    ["bs.esp.box"] = "ESP Box",
    ["bs.esp.lines"] = "ESP Lines",
    ["bs.esp.hl"] = "ESP Highlight",
    ["bs.esp.name"] = "ESP Names",
    ["bs.esp.hp"] = "ESP Health",
    ["bs.esp.dist"] = "ESP Distance",
    ["bs.esp.weapon"] = "ESP Weapons",
    ["bs.esp.items"] = "ESP Items",
    ["bs.esp.range"] = "ESP Range",
    ["bs.fish"] = "Auto Fish",
    ["bs.minigame"] = "Auto Minigame (Fish / ATM)",
    ["bs.sell"] = "Auto Sell Fish",
    ["bs.bait"] = "Auto Buy Bait",
    ["bs.skipcrate"] = "Skip Crates",
    ["bs.pickup"] = "Auto Pickup",
    ["bs.pickrange"] = "Pickup Radius",
    ["bs.spot"] = "Cast Spot (1-5)",
    ["bs.quests"] = "Claim All Quests",
    ["bs.sellnow"] = "Sell Fish Now",
    ["bs.tp.sell"] = "TP Sell Point",
    ["bs.tp.bait"] = "TP Bait Shop",
    ["bs.status"] = "Status",
    ["bs.st.idle"] = "Idle",
    ["bs.st.cast"] = "Casting",
    ["bs.st.wait"] = "Waiting for bite",
    ["bs.st.mini"] = "Minigame",
    ["bs.st.nobait"] = "No bait",
    ["bs.st.norod"] = "No fishing rod",
    ["bs.catches"] = "Catches",
    ["bs.buy.pistol"] = "Pistol Ammo",
    ["bs.buy.rifle"] = "Rifle Ammo",
    ["bs.buy.shotgun"] = "Shotgun Ammo",
    ["bs.buy.guncrate"] = "Gun Crate",
    ["bs.buy.carcrate"] = "Car Crate",
    ["bs.buy.near"] = "Go near the shop first",
    ["bs.buy.sent"] = "Purchase request sent",
    ["bs.stamina"] = "Infinite Stamina",
    ["bs.hotbar"] = "Infinite Hotbar",
    ["bs.antiragdoll"] = "Anti Ragdoll",
    ["bs.antisit"] = "Anti Auto Sit",
    ["bs.respawn"] = "Auto Respawn",
    ["bs.fr.refresh"] = "Refresh List",
    ["bs.fr.clear"] = "Clear Friends",
    ["bs.fr.hint"] = "Tap a player to add / remove a friend",
    ["bs.fr.empty"] = "No other players",
    ["bs.fr.tag"] = "FRIEND",
    ["bs.n.nogun"] = "Equip a gun first",
    ["bs.n.nohook"] = "Silent Aim needs hookfunction support",
    ["bs.n.nonet"] = "Game Net module not found",
    ["bs.n.sellsent"] = "Sell request sent",
    ["bs.n.quests"] = "Quests claimed",
}

local function LoadI18n()
    local env = getgenv()
    if env.BS_I18N then return env.BS_I18N end
    local src
    pcall(function() if isfile and isfile(I18N_FILE) then src = readfile(I18N_FILE) end end)
    if not src and I18N_URL ~= "" then pcall(function() src = game:HttpGet(I18N_URL) end) end
    if type(src) == "string" then
        local f = loadstring(src)
        if f then
            local ok, r = pcall(f)
            if ok and type(r) == "table" and type(r.TR) == "table" then env.BS_I18N = r; return r end
        end
    end
    return nil
end

local function RegisterTranslations()
    local i18n = getgenv().CrypticI18n
    if not i18n or not i18n.Register then return end
    local data = LoadI18n()
    if not data then
        pcall(i18n.Register, "en", EN)
        return
    end
    for _, lang in ipairs(data.LANGS) do
        local t = {}
        for key, row in pairs(data.TR) do t[key] = row[lang] or row.en end
        pcall(i18n.Register, lang, t)
    end
end

-- ============================================================
-- 2. Render
-- ============================================================
local function Render(tab, UI)
    RegisterTranslations()

    -- ── إدارة التشغيل المتكرر: كل Render له رقم، وأي لوب قديم ينتهي لحاله ──
    getgenv().BS_RunId = (getgenv().BS_RunId or 0) + 1
    local RUN = getgenv().BS_RunId
    local function Alive() return getgenv().BS_RunId == RUN end

    if getgenv().BS_Conns then
        for _, c in ipairs(getgenv().BS_Conns) do
            pcall(function() c:Disconnect() end)
        end
    end
    local Conns = {}
    getgenv().BS_Conns = Conns
    local function TrackConn(c) Conns[#Conns + 1] = c; return c end
    local function OnCleanup(fn) TrackConn({ Disconnect = fn }) end

    local i18n = getgenv().CrypticI18n
    local function T(k) return (i18n and i18n.T and i18n.T(k)) or k end
    local function TX(k)
        local s = T(k)
        if s == nil or s == "" or s == k then
            return EN[k] or k
        end
        return s
    end

    local Players          = game:GetService("Players")
    local RS               = game:GetService("ReplicatedStorage")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace        = game:GetService("Workspace")
    local StarterGui       = game:GetService("StarterGui")
    local TweenService     = game:GetService("TweenService")
    local VIM
    pcall(function() VIM = game:GetService("VirtualInputManager") end)

    local lp     = Players.LocalPlayer
    local PG     = lp:WaitForChild("PlayerGui")
    local camera = Workspace.CurrentCamera

    local function Notify(text, dur)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = "Block Spin", Text = text, Duration = dur or 3 })
        end)
    end

    local function hudParent()
        local ok, h = pcall(function() return gethui and gethui() end)
        if ok and h then return h end
        local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
        if ok2 and cg then
            local probe = Instance.new("Folder")
            local ok3 = pcall(function() probe.Parent = cg end)
            probe:Destroy()
            if ok3 then return cg end
        end
        return PG
    end

    local function ModuleAt(...)
        local o = RS
        for _, n in ipairs({ ... }) do
            o = o and o:FindFirstChild(n)
        end
        if o and o:IsA("ModuleScript") then
            local ok, m = pcall(require, o)
            if ok then return m end
        end
        return nil
    end

    -- ══════════════════════════════════════════════════════════
    -- الإعدادات (كل شيء مطفي افتراضياً)
    -- ══════════════════════════════════════════════════════════
    local S = {
        SilentAim = false, AimAssist = false, WallCheck = false, TargetLine = true, ShowFOV = false,
        Predict = true, FOV = 120, Strength = 40, HitPart = "Head",
        AutoShoot = false, ShootRange = 90,
        GunMod = false, GM = { Recoil = true, Accuracy = true, Range = true, FireRate = true, Reload = true, Auto = true },
        Aura = false, AutoMelee = false, MeleeRange = 20,
        ESP = { Box = false, Lines = false, Highlight = false, Name = false, Health = false, Dist = false, Weapon = false, Items = false },
        ESPRange = 1500,
        Fish = false, Minigame = false, AutoSell = false, AutoBait = false, SkipCrates = false,
        Pickup = false, PickRadius = 85, Spot = 1,
        Stamina = false, Hotbar = false, AntiRagdoll = false, AntiSit = false, Respawn = false,
    }
    local E = S.ESP
    local Friends = {}

    local C_GREEN  = Color3.fromRGB(0, 255, 150)
    local C_BLUE   = Color3.fromRGB(0, 150, 255)
    local C_RED    = Color3.fromRGB(255, 90, 90)
    local C_PURPLE = Color3.fromRGB(130, 150, 255)
    local C_CYAN   = Color3.fromRGB(0, 205, 255)
    local C_ORANGE = Color3.fromRGB(255, 150, 50)
    local C_GOLD   = Color3.fromRGB(255, 205, 55)
    local DIM      = Color3.fromRGB(110, 110, 130)
    local CARD     = Color3.fromRGB(16, 16, 22)
    local C_VIS    = Color3.fromRGB(0, 255, 60)
    local C_HID    = Color3.fromRGB(255, 50, 50)
    local C_FRIEND = Color3.fromRGB(46, 245, 109)
    local RarityColors = {
        Common = Color3.fromRGB(255, 255, 255), Uncommon = Color3.fromRGB(99, 255, 52),
        Rare = Color3.fromRGB(51, 170, 255), Epic = Color3.fromRGB(237, 44, 255),
        Legendary = Color3.fromRGB(255, 150, 0), Omega = Color3.fromRGB(255, 20, 51),
    }

    -- ══════════════════════════════════════════════════════════
    -- طبقة الشبكة: نستعمل موديول Net الخاص باللعبة (يدير العدادات تلقائياً)
    -- ══════════════════════════════════════════════════════════
    local Net
    pcall(function()
        local m = RS:WaitForChild("Modules", 5)
        local c = m and m:WaitForChild("Core", 5)
        local n = c and c:WaitForChild("Net", 5)
        if n then Net = require(n) end
    end)
    if not Net then Notify(TX("bs.n.nonet"), 5) end
    local Remotes    = RS:FindFirstChild("Remotes")
    local SendRemote = Remotes and Remotes:FindFirstChild("Send")

    local function NetSend(...)
        if Net and type(Net.send) == "function" then return pcall(Net.send, ...) end
        return false
    end
    local function NetGet(...)
        if Net and type(Net.get) == "function" then
            local ok, res = pcall(Net.get, ...)
            if ok then return res end
        end
        return nil
    end

    -- ══════════════════════════════════════════════════════════
    -- أدوات مشتركة: رؤية / أجزاء الهدف / توقع الحركة
    -- ══════════════════════════════════════════════════════════
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true

    local function Visible(char, part, origin)
        local cam = camera
        if not cam or not char or not part then return false end
        origin = origin or cam.CFrame.Position
        rayParams.FilterDescendantsInstances = { lp.Character }
        local dir = part.Position - origin
        if dir.Magnitude < 0.01 then return true end
        local hit = Workspace:Raycast(origin, dir, rayParams)
        return hit == nil or hit.Instance:IsDescendantOf(char)
    end

    local function AimPart(char)
        if not char then return nil, Vector3.zero end
        local head  = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        local p = S.HitPart
        if p == "Head" then return head or torso, Vector3.zero end
        if p == "Neck" then
            if torso then return torso, Vector3.new(0, torso.Size.Y * 0.08, 0) end
            return head, Vector3.zero
        end
        if torso then return torso, Vector3.new(0, -torso.Size.Y * 0.30, 0) end
        return head, Vector3.zero
    end

    local function Predict(part, off)
        local pos = part.Position + (off or Vector3.zero)
        if not S.Predict then return pos end
        local root = part.Parent and part.Parent:FindFirstChild("HumanoidRootPart")
        local vel = root and root.AssemblyLinearVelocity or Vector3.zero
        local ping = 0.1
        pcall(function() ping = lp:GetNetworkPing() end)
        ping = math.clamp(ping, 0.03, 0.6)
        return pos + Vector3.new(vel.X, vel.Y * 0.4, vel.Z) * ping * 1.3
    end

    local function IsAlivePlayer(pl)
        local ch = pl.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        return hum ~= nil and hum.Health > 0 and root ~= nil
    end

    -- ── اختيار الهدف: ثابت (Sticky) لا يقفز بين اللاعبين ────────
    local Lock = { pl = nil, at = 0, vis = false }
    local CurrentTarget = nil

    local function Evaluate(pl, center, origin)
        if pl == lp or Friends[pl.Name] then return nil end
        local char = pl.Character
        if not char then return nil end
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head") or root
        if not hum or hum.Health <= 0 or not root or not head then return nil end
        local sp, on = camera:WorldToViewportPoint(head.Position)
        if not on or sp.Z <= 0 then return nil end
        local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        local wd = (root.Position - origin).Magnitude
        local vis = Visible(char, head)
        if S.WallCheck and not vis then return nil end
        local score = sd + math.min(wd, 300) * 0.26 - (vis and 8 or 0)
        return { Player = pl, Screen = sd, Score = score, Vis = vis }
    end

    local function GetTarget()
        local now = os.clock()
        if now - Lock.at < 0.055 then return Lock.pl end
        Lock.at = now
        if not camera then Lock.pl = nil; return nil end
        local vp = camera.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local origin = myRoot and myRoot.Position or camera.CFrame.Position
        local radius = S.FOV

        local lockedInfo = Lock.pl and Lock.pl.Parent == Players and Evaluate(Lock.pl, center, origin) or nil
        if lockedInfo and lockedInfo.Screen > radius * 3 then lockedInfo = nil end

        local best
        for _, pl in ipairs(Players:GetPlayers()) do
            local info = Evaluate(pl, center, origin)
            if info and info.Screen <= radius and (not best or info.Score < best.Score) then best = info end
        end

        local chosen = lockedInfo
        if lockedInfo then
            if best and best.Player ~= Lock.pl and lockedInfo.Screen >= 100
               and best.Screen <= lockedInfo.Screen * 0.5 and best.Score <= lockedInfo.Score - 30 then
                chosen = best
            end
        else
            chosen = best
        end
        Lock.pl  = chosen and chosen.Player or nil
        Lock.vis = chosen and chosen.Vis or false
        return Lock.pl
    end

    -- ══════════════════════════════════════════════════════════
    -- الطبقة المرئية: FOV + خط الهدف + ESP (كلها في ScreenGui واحدة)
    -- ══════════════════════════════════════════════════════════
    local Overlay = Instance.new("ScreenGui")
    Overlay.Name = "BS_" .. tostring(math.random(100000, 999999))
    Overlay.ResetOnSpawn = false
    Overlay.IgnoreGuiInset = true
    Overlay.DisplayOrder = 60
    Overlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Overlay.Parent = hudParent()
    OnCleanup(function() pcall(function() Overlay:Destroy() end) end)

    local FovCircle = Instance.new("Frame", Overlay)
    FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    FovCircle.BackgroundTransparency = 1
    FovCircle.Visible = false
    FovCircle.ZIndex = 5
    Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)
    local FovStroke = Instance.new("UIStroke", FovCircle)
    FovStroke.Thickness = 1.5
    FovStroke.Color = Color3.new(1, 1, 1)
    FovStroke.Transparency = 0.25

    local TLine = Instance.new("Frame", Overlay)
    TLine.AnchorPoint = Vector2.new(0.5, 0.5)
    TLine.BorderSizePixel = 0
    TLine.Visible = false
    TLine.ZIndex = 6
    Instance.new("UICorner", TLine).CornerRadius = UDim.new(1, 0)
    local TMark = Instance.new("Frame", Overlay)
    TMark.AnchorPoint = Vector2.new(0.5, 0.5)
    TMark.Size = UDim2.fromOffset(10, 10)
    TMark.Rotation = 45
    TMark.BackgroundTransparency = 1
    TMark.Visible = false
    TMark.ZIndex = 7
    local TMarkStroke = Instance.new("UIStroke", TMark)
    TMarkStroke.Thickness = 2

    -- ── ESP اللاعبين ──────────────────────────────────────────
    local EspObj = {}

    local function MkLabel(size, font)
        local l = Instance.new("TextLabel", Overlay)
        l.BackgroundTransparency = 1
        l.Size = UDim2.fromOffset(180, size + 3)
        l.Font = font
        l.TextSize = size
        l.TextColor3 = Color3.new(1, 1, 1)
        l.TextStrokeTransparency = 0.35
        l.Visible = false
        l.ZIndex = 4
        return l
    end

    local function MakeESP(pl)
        local g = {}
        local box = Instance.new("Frame", Overlay)
        box.BackgroundTransparency = 1; box.BorderSizePixel = 0; box.Visible = false; box.ZIndex = 3
        g.Stroke = Instance.new("UIStroke", box)
        g.Stroke.Thickness = 1.3
        g.Box = box
        local tr = Instance.new("Frame", Overlay)
        tr.AnchorPoint = Vector2.new(0.5, 0.5); tr.BorderSizePixel = 0; tr.Visible = false; tr.ZIndex = 2
        g.Tracer = tr
        local hb = Instance.new("Frame", Overlay)
        hb.BackgroundColor3 = Color3.fromRGB(12, 12, 12); hb.BackgroundTransparency = 0.25
        hb.BorderSizePixel = 0; hb.Visible = false; hb.ZIndex = 3
        local hf = Instance.new("Frame", hb)
        hf.AnchorPoint = Vector2.new(0, 1); hf.Position = UDim2.new(0, 0, 1, 0)
        hf.BorderSizePixel = 0; hf.ZIndex = 4
        g.HpBg, g.HpFill = hb, hf
        g.Name = MkLabel(11, Enum.Font.GothamBold)
        g.Name.AnchorPoint = Vector2.new(0.5, 1)
        g.Info = MkLabel(10, Enum.Font.Gotham)
        g.Info.AnchorPoint = Vector2.new(0.5, 0)
        EspObj[pl] = g
        return g
    end

    local function HideESP(g)
        g.Box.Visible = false; g.Tracer.Visible = false; g.HpBg.Visible = false
        g.Name.Visible = false; g.Info.Visible = false
        if g.HL then g.HL.Enabled = false end
    end

    local function DestroyESP(pl)
        local g = EspObj[pl]
        if not g then return end
        for _, k in ipairs({ "Box", "Tracer", "HpBg", "Name", "Info", "HL" }) do
            if g[k] then pcall(function() g[k]:Destroy() end) end
        end
        EspObj[pl] = nil
    end
    TrackConn(Players.PlayerRemoving:Connect(function(pl)
        DestroyESP(pl)
        if Lock.pl == pl then Lock.pl = nil end
    end))
    OnCleanup(function() for pl in pairs(EspObj) do DestroyESP(pl) end end)

    local function WeaponText(pl, g, now)
        if now - (g.wAt or 0) < 0.6 then return g.wText, g.wColor end
        g.wAt = now
        local names, color = {}, nil
        local function scan(container)
            if not container then return end
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") and t.Name ~= "Fists" and #names < 3 then
                    names[#names + 1] = tostring(t:GetAttribute("DisplayName") or t.Name)
                    local rc = RarityColors[t:GetAttribute("RarityName")]
                    if rc then color = rc end
                end
            end
        end
        scan(pl.Character)
        scan(pl:FindFirstChildOfClass("Backpack"))
        g.wText = table.concat(names, " • ")
        g.wColor = color
        return g.wText, g.wColor
    end

    local function UpdateESP()
        local anyOn = E.Box or E.Lines or E.Highlight or E.Name or E.Health or E.Dist or E.Weapon
        if not anyOn then
            for _, g in pairs(EspObj) do
                if g.Box.Visible or g.Name.Visible or g.Tracer.Visible or g.HpBg.Visible or g.Info.Visible or (g.HL and g.HL.Enabled) then
                    HideESP(g)
                end
            end
            return
        end
        local cam = camera
        if not cam then return end
        local vp = cam.ViewportSize
        local camPos = cam.CFrame.Position
        local now = os.clock()
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= lp then
                local g = EspObj[pl] or MakeESP(pl)
                local char = pl.Character
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not (hum and root) or hum.Health <= 0 then
                    HideESP(g)
                else
                    local dist = (root.Position - camPos).Magnitude
                    local topV = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 3.1, 0))
                    local botV = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3.4, 0))
                    if dist > S.ESPRange or topV.Z <= 0 or botV.Z <= 0 then
                        HideESP(g)
                    else
                        local friend = Friends[pl.Name] == true
                        if now - (g.visAt or 0) > 0.2 then
                            g.visAt = now + math.random() * 0.05
                            g.vis = Visible(char, root)
                        end
                        local col = friend and C_FRIEND or (g.vis and C_VIS or C_HID)
                        local h = math.abs(botV.Y - topV.Y)
                        local w = h * 0.55
                        local cx = (topV.X + botV.X) / 2
                        local top = math.min(topV.Y, botV.Y)

                        if E.Box then
                            g.Box.Position = UDim2.fromOffset(cx - w / 2, top)
                            g.Box.Size = UDim2.fromOffset(w, h)
                            g.Stroke.Color = col
                            g.Box.Visible = true
                        else g.Box.Visible = false end

                        if E.Lines then
                            local fx, fy = cx, top + h
                            local sx, sy = vp.X / 2, vp.Y - 4
                            local dx, dy = fx - sx, fy - sy
                            g.Tracer.Position = UDim2.fromOffset((sx + fx) / 2, (sy + fy) / 2)
                            g.Tracer.Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy), 1.5)
                            g.Tracer.Rotation = math.deg(math.atan2(dy, dx))
                            g.Tracer.BackgroundColor3 = col
                            g.Tracer.Visible = true
                        else g.Tracer.Visible = false end

                        if E.Health then
                            local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                            g.HpBg.Position = UDim2.fromOffset(cx - w / 2 - 6, top)
                            g.HpBg.Size = UDim2.fromOffset(3, h)
                            g.HpFill.Size = UDim2.new(1, 0, pct, 0)
                            g.HpFill.BackgroundColor3 = pct > 0.6 and Color3.fromRGB(0, 255, 60)
                                or (pct > 0.3 and Color3.fromRGB(255, 200, 40) or Color3.fromRGB(255, 50, 50))
                            g.HpBg.Visible = true
                        else g.HpBg.Visible = false end

                        if E.Name then
                            g.Name.Position = UDim2.fromOffset(cx, top - 2)
                            local nm = pl.DisplayName ~= "" and pl.DisplayName or pl.Name
                            g.Name.Text = friend and ("[" .. TX("bs.fr.tag") .. "] " .. nm) or nm
                            g.Name.TextColor3 = friend and C_FRIEND or Color3.new(1, 1, 1)
                            g.Name.Visible = true
                        else g.Name.Visible = false end

                        local line, lineColor = nil, Color3.fromRGB(225, 225, 240)
                        if E.Dist then line = string.format("%dm", math.floor(dist * 0.28)) end
                        if E.Weapon then
                            local wt, wc = WeaponText(pl, g, now)
                            if wt and wt ~= "" then
                                line = line and (line .. "  " .. wt) or wt
                                if wc then lineColor = wc end
                            end
                        end
                        if line then
                            g.Info.Position = UDim2.fromOffset(cx, top + h + 2)
                            g.Info.Text = line
                            g.Info.TextColor3 = lineColor
                            g.Info.Visible = true
                        else g.Info.Visible = false end

                        if E.Highlight then
                            local hl = g.HL
                            if not hl or not hl.Parent then
                                hl = Instance.new("Highlight")
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.FillTransparency = 0.55
                                hl.OutlineTransparency = 0.15
                                hl.Parent = Overlay
                                g.HL = hl
                            end
                            if hl.Adornee ~= char then hl.Adornee = char end
                            hl.FillColor = col; hl.OutlineColor = col
                            hl.Enabled = true
                        elseif g.HL then g.HL.Enabled = false end
                    end
                end
            end
        end
    end

    -- ── ESP العناصر المرمية: فحص خفيف 2 مرة بالثانية ────────────
    local DroppedItems
    task.spawn(function() DroppedItems = Workspace:WaitForChild("DroppedItems", 15) end)
    local itemMarks = {}
    local function ClearItemMarks()
        for m, bb in pairs(itemMarks) do pcall(function() bb:Destroy() end); itemMarks[m] = nil end
    end
    OnCleanup(ClearItemMarks)
    task.spawn(function()
        while Alive() do
            task.wait(0.5)
            if not E.Items or not DroppedItems then
                if next(itemMarks) then ClearItemMarks() end
            else
                pcall(function()
                    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                    local seen = {}
                    for _, model in ipairs(DroppedItems:GetChildren()) do
                        if model:IsA("Model") then
                            local zone = model:FindFirstChild("PickUpZone") or model:FindFirstChildWhichIsA("BasePart")
                            if zone then
                                seen[model] = true
                                local bb = itemMarks[model]
                                if not bb or not bb.Parent then
                                    bb = Instance.new("BillboardGui")
                                    bb.Size = UDim2.fromOffset(130, 30)
                                    bb.StudsOffset = Vector3.new(0, 1.5, 0)
                                    bb.AlwaysOnTop = true
                                    bb.LightInfluence = 0
                                    bb.Adornee = zone
                                    bb.Parent = Overlay
                                    local l1 = Instance.new("TextLabel", bb)
                                    l1.Name = "N"; l1.Size = UDim2.new(1, 0, 0.55, 0); l1.BackgroundTransparency = 1
                                    l1.Font = Enum.Font.GothamBold; l1.TextSize = 12; l1.TextStrokeTransparency = 0.25
                                    l1.Text = tostring(model:GetAttribute("DisplayName") or model.Name)
                                    l1.TextColor3 = RarityColors[model:GetAttribute("RarityName")] or Color3.new(1, 1, 1)
                                    local l2 = Instance.new("TextLabel", bb)
                                    l2.Name = "D"; l2.Position = UDim2.new(0, 0, 0.55, 0); l2.Size = UDim2.new(1, 0, 0.45, 0)
                                    l2.BackgroundTransparency = 1; l2.Font = Enum.Font.Gotham; l2.TextSize = 10
                                    l2.TextColor3 = Color3.fromRGB(225, 225, 240); l2.TextStrokeTransparency = 0.4
                                    itemMarks[model] = bb
                                end
                                local dist = myRoot and (zone.Position - myRoot.Position).Magnitude or 0
                                bb.Enabled = dist <= S.ESPRange
                                local dl = bb:FindFirstChild("D")
                                if dl then dl.Text = string.format("%dm", math.floor(dist * 0.28)) end
                            end
                        end
                    end
                    for m, bb in pairs(itemMarks) do
                        if not seen[m] then pcall(function() bb:Destroy() end); itemMarks[m] = nil end
                    end
                end)
            end
        end
    end)

    -- ── حلقة الرسم الرئيسية: هدف + FOV + خط + ايم مساعد + ESP ──
    local function RenderStep(dt)
        camera = Workspace.CurrentCamera or camera
        if not camera then return end
        local need = S.SilentAim or S.AimAssist or S.TargetLine
        CurrentTarget = need and GetTarget() or nil
        local vp = camera.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)

        if S.ShowFOV then
            FovCircle.Position = UDim2.fromOffset(center.X, center.Y)
            FovCircle.Size = UDim2.fromOffset(S.FOV * 2, S.FOV * 2)
            FovStroke.Color = CurrentTarget and C_VIS or Color3.new(1, 1, 1)
            FovCircle.Visible = true
        else FovCircle.Visible = false end

        local tChar = CurrentTarget and CurrentTarget.Character
        local part, off
        if tChar then part, off = AimPart(tChar) end

        if S.AimAssist and part then
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local pos = Predict(part, off)
                local power = math.clamp(S.Strength, 5, 100) / 100
                local alpha = 1 - (1 - power) ^ (math.clamp(dt, 0, 0.1) * 60)
                camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, pos), alpha)
            end
        end

        if S.TargetLine and part then
            local sp, on = camera:WorldToViewportPoint(part.Position + (off or Vector3.zero))
            if on and sp.Z > 0 then
                local to = Vector2.new(sp.X, sp.Y)
                local from = Vector2.new(center.X, vp.Y - 6)
                local diff = to - from
                local col = Lock.vis and C_VIS or C_HID
                TLine.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
                TLine.Size = UDim2.fromOffset(diff.Magnitude, 2)
                TLine.Rotation = math.deg(math.atan2(diff.Y, diff.X))
                TLine.BackgroundColor3 = col
                TLine.Visible = true
                TMark.Position = UDim2.fromOffset(to.X, to.Y)
                TMarkStroke.Color = col
                TMark.Visible = true
            else TLine.Visible = false; TMark.Visible = false end
        else TLine.Visible = false; TMark.Visible = false end

        UpdateESP()
    end
    TrackConn(RunService.RenderStepped:Connect(function(dt) pcall(RenderStep, dt) end))

    -- ══════════════════════════════════════════════════════════
    -- Silent Aim: هوك واحد على FireServer يقرأ دائماً أحدث نسخة
    -- ══════════════════════════════════════════════════════════
    local ShootOverride = false
    getgenv().BS_FireHook = function(args)
        if not Alive() or not S.SilentAim or ShootOverride or args[2] ~= "shoot_gun" then return end
        local target = CurrentTarget
        if not target or not target.Character then return end
        local part, off = AimPart(target.Character)
        local myHead = lp.Character and lp.Character:FindFirstChild("Head")
        if not part or not myHead then return end
        local pos = Predict(part, off)
        if args[4] ~= nil then
            args[4] = CFrame.new(myHead.Position, pos)
            args[5] = { { { Instance = part, Normal = Vector3.new(0, 1, 0), Position = pos } } }
        end
    end

    local HookOK = getgenv().BS_HookInstalled == true
    if not HookOK and SendRemote and type(hookfunction) == "function" then
        local wrap = newcclosure or function(f) return f end
        local ok = pcall(function()
            local old
            old = hookfunction(SendRemote.FireServer, wrap(function(self, ...)
                local f = getgenv().BS_FireHook
                if f and self == SendRemote then
                    local a = table.pack(...)
                    if pcall(f, a) then return old(self, table.unpack(a, 1, a.n)) end
                end
                return old(self, ...)
            end))
        end)
        HookOK = ok
        getgenv().BS_HookInstalled = ok
    end

    -- ══════════════════════════════════════════════════════════
    -- الأسلحة
    -- ══════════════════════════════════════════════════════════
    local ItemsFolder = RS:FindFirstChild("Items")
    local function GunTemplate(name)
        local f = ItemsFolder and ItemsFolder:FindFirstChild("gun")
        return f and f:FindFirstChild(name, true) or nil
    end
    local function IsGunTool(t)
        if not t or not t:IsA("Tool") or t.Name == "Fists" then return false end
        return t:GetAttribute("AmmoType") ~= nil or t:GetAttribute("current_ammo") ~= nil or GunTemplate(t.Name) ~= nil
    end
    local function IsMeleeTool(t)
        if not t or not t:IsA("Tool") then return false end
        if t.Name == "Fists" then return true end
        local f = ItemsFolder and ItemsFolder:FindFirstChild("melee")
        return f ~= nil and f:FindFirstChild(t.Name) ~= nil
    end
    local function HasGun(pl)
        for _, c in ipairs({ pl.Character, pl:FindFirstChildOfClass("Backpack") }) do
            if c then
                for _, t in ipairs(c:GetChildren()) do
                    if IsGunTool(t) then return true end
                end
            end
        end
        return false
    end

    -- ── Auto Shoot: 360°، أهداف مسلحة ومكشوفة وخارج المناطق الآمنة ──
    local SAFE_FLAGS = { "SafeZone", "InSafeZone", "IsInSafeZone", "InSafeArea", "IsSafe", "Protected", "IsProtected",
        "Invulnerable", "SpawnProtected", "SpawnProtection", "SafeZoneActive", "SafeArea", "InProtectionZone", "Shielded" }
    local function Truthy(v) return v == true or v == 1 or v == "true" or v == "True" or v == "1" end
    local function IsProtected(pl, char)
        if char:FindFirstChildOfClass("ForceField") then return true end
        local hum = char:FindFirstChildOfClass("Humanoid")
        for _, o in ipairs({ pl, char, hum }) do
            if o then
                for _, k in ipairs(SAFE_FLAGS) do
                    if Truthy(o:GetAttribute(k)) then return true end
                end
            end
        end
        return false
    end

    local function ShotInterval(gun)
        local fr = gun:GetAttribute("fire_rate")
        local sec = 0.22
        if type(fr) == "number" and fr == fr and fr > 0 then
            if fr <= 1 then sec = fr elseif fr <= 35 then sec = 1 / fr else sec = 60 / fr end
        end
        return math.clamp(sec, 0.12, 0.75)
    end

    local AS = { last = 0, scanAt = 0, locked = nil }
    local function ValidShootTarget(pl, myHead, rangeStuds)
        if pl == lp or Friends[pl.Name] then return nil end
        local char = pl.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        if not hum or hum.Health <= 0 or not root or not head then return nil end
        local d = (root.Position - myHead.Position).Magnitude
        if d > rangeStuds then return nil end
        if not HasGun(pl) or IsProtected(pl, char) then return nil end
        if not Visible(char, head, myHead.Position) then return nil end
        return d
    end

    local function AutoShootStep()
        if not S.AutoShoot or not Net then return end
        local now = os.clock()
        if now < AS.scanAt then return end
        AS.scanAt = now + 0.08
        local char = lp.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local head = char and char:FindFirstChild("Head")
        local gun  = char and char:FindFirstChildOfClass("Tool")
        if not hum or hum.Health <= 0 or not head or not IsGunTool(gun) then return end
        if now - AS.last < ShotInterval(gun) then return end
        local ammo = gun:GetAttribute("current_ammo")
        if type(ammo) == "number" and ammo <= 0 then return end

        local range = S.ShootRange / 0.28
        local target = AS.locked
        if not (target and target.Parent == Players and ValidShootTarget(target, head, range)) then
            target = nil
            local bestD
            for _, pl in ipairs(Players:GetPlayers()) do
                local d = ValidShootTarget(pl, head, range)
                if d and (not bestD or d < bestD) then bestD, target = d, pl end
            end
            AS.locked = target
        end
        if not target then return end
        local part, off = AimPart(target.Character)
        if not part then return end
        local pos = Predict(part, off)
        ShootOverride = true
        NetSend("shoot_gun", gun, CFrame.new(head.Position, pos),
            { { { Instance = part, Normal = Vector3.new(0, 1, 0), Position = pos } } })
        ShootOverride = false
        AS.last = now
    end
    TrackConn(RunService.Heartbeat:Connect(function() pcall(AutoShootStep) end))

    -- ── Gun Mod: تعديل خصائص السلاح المجهّز فقط، مع استرجاع الأصل ──
    local GM = { Orig = setmetatable({}, { __mode = "k" }), Conns = {} }
    local GM_FEATURE = { Recoil = "Recoil", Accuracy = "Accuracy", Range = "Range", FireRate = "FireRate", Reload = "Reload", Auto = "Automatic" }
    local GM_NAMES = {
        Accuracy = { "accuracy", "Accuracy" }, Range = { "range", "Range" },
        Recoil = { "Recoil", "recoil" }, Reload = { "reload_time", "ReloadTime" },
    }
    local function GMAttr(gun, feature)
        if feature == "FireRate" then
            if gun:GetAttribute("fire_rate") ~= nil then return "fire_rate" end
            for n in pairs(gun:GetAttributes()) do
                if type(n) == "string" and n:sub(-3) == "486" then return n end
            end
        elseif feature == "Automatic" then
            if gun:GetAttribute("automatic") ~= nil then return "automatic" end
            for n in pairs(gun:GetAttributes()) do
                if type(n) == "string" and n:sub(-3) == "492" then return n end
            end
        else
            for _, n in ipairs(GM_NAMES[feature] or {}) do
                if gun:GetAttribute(n) ~= nil then return n end
            end
        end
        return nil
    end
    local function Finite(v) return type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge and math.abs(v) < 1e9 end
    local function GMValue(feature, o)
        if feature == "Automatic" then return type(o) == "boolean" and true or nil end
        if not Finite(o) then return nil end
        if feature == "Accuracy" then
            if o < 0 then return nil end
            if o <= 1 then return math.max(o, 0.95) end
            return math.max(o, math.min(o * 1.12, 100))
        elseif feature == "Range" then
            if o <= 0 then return nil end
            return math.max(o, math.min(o * 2, 1200))
        elseif feature == "Recoil" then
            if o < 0 then return nil end
            return 0
        elseif feature == "FireRate" then
            if o <= 0 then return nil end
            return o < 1 and 0.001 or 9999
        elseif feature == "Reload" then
            if o <= 0 then return nil end
            return math.min(o, math.max(0.18, o * 0.70))
        end
        return nil
    end
    local function GMApply(gun)
        if not S.GunMod or not IsGunTool(gun) then return end
        for flag, feature in pairs(GM_FEATURE) do
            if S.GM[flag] then
                local attr = GMAttr(gun, feature)
                if attr then
                    local rec = GM.Orig[gun]
                    if not rec then rec = {}; GM.Orig[gun] = rec end
                    local st = rec[feature]
                    local base = st and st.Original or gun:GetAttribute(attr)
                    local want = GMValue(feature, base)
                    if want ~= nil and want ~= base then
                        if not st then rec[feature] = { Attr = attr, Original = base, Applied = want } end
                        if gun:GetAttribute(attr) ~= want then pcall(gun.SetAttribute, gun, attr, want) end
                    end
                end
            end
        end
    end
    local function GMRestore(gun, only)
        local rec = GM.Orig[gun]
        if not rec then return end
        for feature, st in pairs(rec) do
            if not only or only == feature then
                pcall(function()
                    if gun:GetAttribute(st.Attr) == st.Applied then gun:SetAttribute(st.Attr, st.Original) end
                end)
                rec[feature] = nil
            end
        end
        if not next(rec) then GM.Orig[gun] = nil end
    end
    local function GMRestoreAll(only)
        local list = {}
        for gun in pairs(GM.Orig) do list[#list + 1] = gun end
        for _, gun in ipairs(list) do GMRestore(gun, only) end
    end
    local function GMApplyEquipped()
        local char = lp.Character
        if not char then return end
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then GMApply(t) end
        end
    end
    local function GMBind(char)
        for _, c in ipairs(GM.Conns) do pcall(function() c:Disconnect() end) end
        table.clear(GM.Conns)
        if not char then return end
        GM.Conns[#GM.Conns + 1] = char.ChildAdded:Connect(function(t)
            if t:IsA("Tool") then
                task.delay(0.08, function()
                    if Alive() and S.GunMod and t.Parent == char then GMApply(t) end
                end)
            end
        end)
        GM.Conns[#GM.Conns + 1] = char.ChildRemoved:Connect(function(t)
            if t:IsA("Tool") then GMRestore(t) end
        end)
        GMApplyEquipped()
    end
    GMBind(lp.Character)
    TrackConn(lp.CharacterAdded:Connect(function(c) GMBind(c) end))
    OnCleanup(function()
        for _, c in ipairs(GM.Conns) do pcall(function() c:Disconnect() end) end
        GMRestoreAll()
    end)

    -- ── Melee Aura + Auto Attack ──────────────────────────────
    local Aura = { Orig = setmetatable({}, { __mode = "k" }) }
    local function AuraApply(tool)
        if not S.Aura or not IsMeleeTool(tool) then return end
        local rec = Aura.Orig[tool]
        if not rec then
            local names = {}
            for n in pairs(tool:GetAttributes()) do names[#names + 1] = n end
            table.sort(names)
            if #names < 7 then return end
            local k6, k7 = names[6], names[7]
            if type(tool:GetAttribute(k6)) ~= "number" or type(tool:GetAttribute(k7)) ~= "number" then return end
            rec = { K6 = k6, K7 = k7, O6 = tool:GetAttribute(k6), O7 = tool:GetAttribute(k7) }
            Aura.Orig[tool] = rec
        end
        pcall(function() tool:SetAttribute(rec.K6, 360); tool:SetAttribute(rec.K7, 20) end)
    end
    local function AuraEach(cb)
        local bp = lp:FindFirstChildOfClass("Backpack")
        for _, c in ipairs({ lp.Character, bp }) do
            if c then
                for _, t in ipairs(c:GetChildren()) do
                    if IsMeleeTool(t) then cb(t) end
                end
            end
        end
    end
    local function AuraRestore()
        for tool, rec in pairs(Aura.Orig) do
            if tool and tool.Parent then
                pcall(function()
                    if tool:GetAttribute(rec.K6) == 360 then tool:SetAttribute(rec.K6, rec.O6) end
                    if tool:GetAttribute(rec.K7) == 20 then tool:SetAttribute(rec.K7, rec.O7) end
                end)
            end
            Aura.Orig[tool] = nil
        end
    end
    OnCleanup(AuraRestore)
    task.spawn(function()
        while Alive() do
            task.wait(0.35)
            if S.Aura then pcall(AuraEach, AuraApply) end
        end
    end)
    task.spawn(function()
        while Alive() do
            task.wait(0.4)
            if S.AutoMelee and Net then
                pcall(function()
                    local char = lp.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if not root then return end
                    local tool
                    for _, c in ipairs(char:GetChildren()) do
                        if IsMeleeTool(c) then tool = c; break end
                    end
                    if not tool then return end
                    local list, aimPos = {}, nil
                    local ping = 0.1
                    pcall(function() ping = lp:GetNetworkPing() end)
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl ~= lp and not Friends[pl.Name] and IsAlivePlayer(pl) then
                            local tr = pl.Character.HumanoidRootPart
                            local th = pl.Character:FindFirstChild("Head")
                            if th and (root.Position - tr.Position).Magnitude <= S.MeleeRange then
                                list[#list + 1] = pl
                                aimPos = aimPos or (th.Position + tr.AssemblyLinearVelocity * math.clamp(ping, 0, 1))
                            end
                        end
                    end
                    if #list == 0 or not aimPos then return end
                    if (aimPos - root.Position).Magnitude < 0.001 then aimPos = root.Position + root.CFrame.LookVector end
                    NetSend("melee_attack", tool, list, CFrame.lookAt(root.Position, aimPos), 0.75)
                end)
            end
        end
    end)

    -- ══════════════════════════════════════════════════════════
    -- الفارم
    -- ══════════════════════════════════════════════════════════
    local ROD_NAMES = { "FishingRodUltimate", "FishingRodAdvanced", "FishingRodPro", "FishingRodRegular" }
    local CAST_POSITIONS = {
        Vector3.new(82.11319, 245.16185, 922.22076), Vector3.new(87.578094, 245.05617, 922.16223),
        Vector3.new(86.844086, 244.8289, 920.0074),  Vector3.new(87.49276, 245.28297, 924.3126),
        Vector3.new(89.351, 245.19716, 923.49896),
    }
    local SELL_POS = Vector3.new(-252.746, 252.839, 379.64)
    local BAIT_POS = Vector3.new(-135.954, 251.811, 154.499)
    local FISH = { Bass = true, Perch = true, Salmon = true, ["Northern Pike"] = true, Dolphinfish = true,
        Coelacanth = true, Tuna = true, Sailfish = true, Marlin = true }
    local BAIT_TIERS = {
        { Name = "PrawntecUltimate", Level = 45 }, { Name = "PrawntecPro", Level = 30 },
        { Name = "PrawntecRegular", Level = 25 }, { Name = "WormtecUltimate", Level = 15 },
        { Name = "WormtecPro", Level = 8 }, { Name = "WormtecRegular", Level = 1 },
    }

    local function MyRoot()
        local c = lp.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end
    local function DistTo(pos)
        local r = MyRoot()
        return r and (r.Position - pos).Magnitude or math.huge
    end

    local function IsRod(t)
        if not t or not t:IsA("Tool") then return false end
        if string.find(string.lower(t.Name), "rod", 1, true) then return true end
        for _, n in ipairs(ROD_NAMES) do if t.Name == n then return true end end
        return false
    end
    local function FindRodTool()
        for _, c in ipairs({ lp.Character, lp:FindFirstChildOfClass("Backpack") }) do
            if c then
                for _, t in ipairs(c:GetChildren()) do
                    if IsRod(t) then return t end
                end
            end
        end
        return nil
    end
    -- يقرأ معرّفات السنارة والطعم من قائمة العناصر في الواجهة (نفس طريقة السورس)
    local function GetRodBaitUid()
        local rod, bait
        local items = PG:FindFirstChild("Items")
        local holder = items and items:FindFirstChild("ItemsHolder")
        local sf = holder and holder:FindFirstChild("ItemsScrollingFrame")
        if sf then
            for _, child in ipairs(sf:GetChildren()) do
                if child.Name ~= "Folder" and child.Name ~= "UIGridLayout" and child.Name ~= "ItemTemplate" then
                    local nm = child:FindFirstChild("ItemName")
                    if nm and nm.Text then
                        local low = string.lower(nm.Text)
                        if string.find(low, "rod", 1, true) then rod = child.Name end
                        if string.find(low, "wormtec", 1, true) or string.find(low, "prawntec", 1, true) then bait = child.Name end
                    end
                end
            end
        end
        return rod, bait
    end

    -- ── Minigame (صيد / ATM): موديول اللعبة أولاً ثم الواجهة كاحتياط ──
    local Mini = { mod = nil, searchedAt = 0, deep = false, lastClick = 0, active = false, seen = 0 }
    getgenv().BS_MiniRef = getgenv().BS_MiniRef or {}
    local MiniRef = getgenv().BS_MiniRef
    pcall(function()
        if not getgenv().BS_KeybindHooked then
            local KB = ModuleAt("Modules", "Game", "Keybinds")
            if KB and type(KB.hook_action) == "function" then
                local orig = KB.hook_action
                KB.hook_action = function(name, fn, ...)
                    if name == "minigame_click" then MiniRef.fn = fn end
                    return orig(name, fn, ...)
                end
                getgenv().BS_KeybindHooked = true
            end
        end
    end)
    local function ScanForMini(root)
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("ModuleScript") and d.Name == "SliderMinigame" then
                local ok, r = pcall(require, d)
                if ok and type(r) == "table" then return r end
            end
        end
        return nil
    end
    local function FindMini()
        if Mini.mod then return Mini.mod end
        if os.clock() - Mini.searchedAt < 3 then return nil end
        Mini.searchedAt = os.clock()
        Mini.mod = ScanForMini(RS)
        if not Mini.mod and not Mini.deep then
            Mini.deep = true
            Mini.mod = ScanForMini(game)
        end
        return Mini.mod
    end
    local function GuiVisible(o)
        local p = o
        while p and p ~= PG do
            if p:IsA("GuiObject") and not p.Visible then return false end
            if p:IsA("ScreenGui") and not p.Enabled then return false end
            p = p.Parent
        end
        return true
    end
    local function GuiMini()
        local sl = PG:FindFirstChild("SliderMinigame")
        if not sl or not GuiVisible(sl) then return false, false end
        local needles, targets = {}, {}
        for _, o in ipairs(sl:GetDescendants()) do
            if o:IsA("Frame") and GuiVisible(o) then
                local sz = o.AbsoluteSize
                if sz.X >= 1 and sz.X <= 8 and sz.Y >= 15 and sz.Y <= 75 then needles[#needles + 1] = o
                elseif sz.X >= 15 and sz.X <= 260 and sz.Y >= 15 and sz.Y <= 75 then targets[#targets + 1] = o end
            end
        end
        for _, n in ipairs(needles) do
            local ny = n.AbsolutePosition.Y + n.AbsoluteSize.Y / 2
            for _, t in ipairs(targets) do
                local ty = t.AbsolutePosition.Y + t.AbsoluteSize.Y / 2
                if math.abs(ty - ny) <= (n.AbsoluteSize.Y + t.AbsoluteSize.Y) / 2 + 6 then
                    local nx = n.AbsolutePosition.X + n.AbsoluteSize.X / 2
                    return true, (nx >= t.AbsolutePosition.X and nx <= t.AbsolutePosition.X + t.AbsoluteSize.X)
                end
            end
        end
        return true, false
    end
    local function MiniState()
        local m = FindMini()
        if m then
            local ok, active, aligned = pcall(function()
                if not (m.enabled and m.enabled.get() == true) then return false, false end
                local n, t, s = m.needle_pos.get(), m.target_pos.get(), m.target_size.get() / 2
                return true, (n >= t - s and n <= t + s)
            end)
            if ok then return active, aligned end
        end
        return GuiMini()
    end
    local function MiniClick()
        if MiniRef.fn and pcall(MiniRef.fn, true) then return end
        local vp = camera and camera.ViewportSize or Vector2.new(800, 600)
        if VIM then
            local ok = pcall(function()
                VIM:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, true, game, 1)
                VIM:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, false, game, 1)
            end)
            if ok then return end
        end
        if type(mouse1click) == "function" then pcall(mouse1click) end
    end
    TrackConn(RunService.Heartbeat:Connect(function()
        if not (S.Minigame or S.Fish) then Mini.active = false; return end
        local active, aligned = MiniState()
        Mini.active = active
        if active then Mini.seen = os.clock() end
        if active and aligned and os.clock() - Mini.lastClick >= 0.15 then
            Mini.lastClick = os.clock()
            MiniClick()
        end
    end))

    -- ── Auto Fish ─────────────────────────────────────────────
    local Fish = { status = "st.idle", lineOut = false, castAt = 0, sawMini = false, miniAt = 0, catches = 0, warnAt = 0 }
    local function EquipRod()
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        local cur = char:FindFirstChildOfClass("Tool")
        if cur and IsRod(cur) then return cur end
        if cur then pcall(hum.UnequipTools, hum); task.wait(0.05) end
        local rod = FindRodTool()
        if not rod then
            local uid = GetRodBaitUid()
            if uid then NetGet("toggle_equip_item", tostring(uid)); task.wait(0.1); rod = FindRodTool() end
        end
        if rod and rod.Parent ~= char then hum:EquipTool(rod); task.wait(0.1) end
        cur = char:FindFirstChildOfClass("Tool")
        if cur and IsRod(cur) then return cur end
        return nil
    end
    local function Cast()
        local rodUid, baitUid = GetRodBaitUid()
        if not baitUid then Fish.status = "st.nobait"; return false end
        if not rodUid then Fish.status = "st.norod"; return false end
        local rod = EquipRod()
        if not rod then Fish.status = "st.norod"; return false end
        NetGet("equip_ammo_on_item", rodUid, baitUid)
        NetGet("throw_rod", rod, CAST_POSITIONS[S.Spot] or CAST_POSITIONS[1])
        return true
    end
    task.spawn(function()
        while Alive() do
            task.wait(0.12)
            if not S.Fish then
                Fish.lineOut = false
                Fish.status = "st.idle"
            else
                pcall(function()
                    local now = os.clock()
                    if Mini.active then
                        Fish.status = "st.mini"; Fish.sawMini = true; Fish.miniAt = now
                        return
                    end
                    if Fish.lineOut then
                        if Fish.sawMini and now - Fish.miniAt > 0.8 then
                            Fish.catches = Fish.catches + 1
                            Fish.lineOut, Fish.sawMini = false, false
                            task.wait(0.5)
                        elseif now - Fish.castAt > 45 then
                            Fish.lineOut = false
                            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                            if hum then pcall(hum.UnequipTools, hum) end
                        else
                            Fish.status = "st.wait"
                            return
                        end
                    end
                    Fish.status = "st.cast"
                    if Cast() then
                        Fish.lineOut, Fish.castAt, Fish.sawMini = true, os.clock(), false
                    else
                        if now - Fish.warnAt > 6 then Fish.warnAt = now; Notify(TX("bs." .. Fish.status), 3) end
                        task.wait(1.5)
                    end
                end)
            end
        end
    end)

    -- ── بيع السمك / شراء الطعم ────────────────────────────────
    local Data, ItemUtils
    task.spawn(function()
        Data = ModuleAt("Modules", "Core", "Data")
        ItemUtils = ModuleAt("Modules", "Game", "Inventory", "ItemUtils")
    end)
    local function HasFish()
        local found = false
        pcall(function()
            if ItemUtils and Data then
                ItemUtils.iterate_through_items(Data, function(it)
                    if it and it.name and FISH[it.name] then found = true end
                end)
            end
        end)
        if found then return true end
        pcall(function()
            local items = PG:FindFirstChild("Items")
            local sf = items and items:FindFirstChild("ItemsHolder") and items.ItemsHolder:FindFirstChild("ItemsScrollingFrame")
            if sf then
                for _, c in ipairs(sf:GetChildren()) do
                    local a = c:GetAttribute("ItemType")
                    if a and string.lower(tostring(a)) == "fish" then found = true; break end
                end
            end
        end)
        return found
    end
    local function SellFishNow()
        NetGet("sell_all_fish")
        Notify(TX("bs.n.sellsent"), 2)
    end
    local function BestBait()
        local lvl = 1
        pcall(function()
            local D = Data or ModuleAt("Modules", "Core", "Data")
            local XP = ModuleAt("Modules", "Game", "Skills", "XPFormula")
            if D and D.xp and XP and XP.xp_to_level then
                for k, v in pairs(D.xp) do
                    if string.find(string.lower(tostring(k)), "fish", 1, true) then lvl = XP.xp_to_level(v) or 1; break end
                end
            end
        end)
        for _, b in ipairs(BAIT_TIERS) do
            if lvl >= b.Level then return b.Name end
        end
        return "WormtecRegular"
    end
    task.spawn(function()
        local sold = false
        while Alive() do
            task.wait(0.35)
            if S.AutoSell then
                pcall(function()
                    if DistTo(SELL_POS) <= 5 then
                        if not sold then
                            sold = true
                            if HasFish() then
                                task.wait(0.25)
                                SellFishNow()
                            end
                        end
                    else sold = false end
                end)
            else sold = false end
        end
    end)
    task.spawn(function()
        while Alive() do
            task.wait(0.6)
            if S.AutoBait then
                pcall(function()
                    if DistTo(BAIT_POS) > 25 then return end
                    local _, baitUid = GetRodBaitUid()
                    if baitUid then return end
                    local shop = Workspace:FindFirstChild("ShopZone_Hardware")
                    if shop then NetGet("purchase_consumable", shop, BestBait()) end
                end)
            end
        end
    end)

    -- ── Skip Crates: يسرّع أنيميشن فتح الصناديق ────────────────
    local SkipAPI = (function()
        local ENV = getgenv()
        if ENV.BS_SkipCrate and type(ENV.BS_SkipCrate.Destroy) == "function" then pcall(ENV.BS_SkipCrate.Destroy) end
        local st = { Enabled = false, Running = true, Crate = nil, Util = nil, OrigTween = nil, Wrapped = nil }
        st.Crate = ModuleAt("Modules", "Game", "CrateSystem", "Crate")
        st.Util  = ModuleAt("Modules", "Core", "Util")
        if st.Util and type(st.Util.tween) == "function" then
            st.OrigTween = st.Util.tween
            st.Wrapped = function(inst, info, props, ...)
                if st.Enabled and inst and inst:IsA("NumberValue") and typeof(info) == "TweenInfo"
                   and type(props) == "table" and props.Value == 1 and info.Time > 0 then
                    info = TweenInfo.new(0, info.EasingStyle, info.EasingDirection)
                end
                return st.OrigTween(inst, info, props, ...)
            end
            st.Util.tween = st.Wrapped
        end
        local stepConn = RunService.Stepped:Connect(function()
            if not (st.Running and st.Enabled) then return end
            pcall(function()
                local char = lp.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local animator = hum and hum:FindFirstChildOfClass("Animator")
                if animator then
                    for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do
                        local n = string.lower(tostring(tr.Name))
                        if n:find("crate", 1, true) or n:find("use", 1, true) then pcall(function() tr:Stop(0) end) end
                    end
                end
            end)
        end)
        task.spawn(function()
            while st.Running do
                task.wait(0.1)
                if st.Enabled and st.Crate then
                    pcall(function()
                        local objs = st.Crate.class and st.Crate.class.objects
                        if type(objs) == "table" then
                            for _, c in pairs(objs) do
                                local o = c.states and c.states.open
                                if o and type(o.set) == "function" then o.set(true) end
                            end
                        end
                        local sk = st.Crate.skipping
                        if sk and type(sk.set) == "function" then sk.set(true) end
                    end)
                end
            end
        end)
        local API = {}
        function API.SetEnabled(on) st.Enabled = (on == true) end
        function API.Destroy()
            st.Enabled, st.Running = false, false
            pcall(function() stepConn:Disconnect() end)
            if st.Util and st.Util.tween == st.Wrapped and st.OrigTween then st.Util.tween = st.OrigTween end
            if ENV.BS_SkipCrate == API then ENV.BS_SkipCrate = nil end
        end
        ENV.BS_SkipCrate = API
        return API
    end)()
    OnCleanup(function() pcall(SkipAPI.Destroy) end)

    -- ── Auto Pickup ───────────────────────────────────────────
    local pickedAt = setmetatable({}, { __mode = "k" })
    task.spawn(function()
        while Alive() do
            task.wait(0.25)
            if S.Pickup and DroppedItems and Net then
                pcall(function()
                    local root = MyRoot()
                    if not root then return end
                    local now, n = os.clock(), 0
                    for _, model in ipairs(DroppedItems:GetChildren()) do
                        if model:IsA("Model") then
                            local zone = model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChild("PickUpZone")
                            if zone and (root.Position - zone.Position).Magnitude <= S.PickRadius
                               and now - (pickedAt[model] or 0) >= 0.25 then
                                pickedAt[model] = now
                                n = n + 1
                                task.spawn(NetGet, "pickup_dropped_item", model)
                                if n >= 6 then break end
                            end
                        end
                    end
                end)
            end
        end
    end)

    local function ClaimAllQuests()
        task.spawn(function()
            local q = PG:FindFirstChild("Quests")
            local h = q and q:FindFirstChild("QuestsHolder")
            local sf = h and h:FindFirstChild("QuestsScrollingFrame")
            if not sf then Notify(TX("bs.buy.near"), 3); return end
            for _, row in ipairs(sf:GetChildren()) do
                if row:IsA("Frame") or row:IsA("TextButton") or row:IsA("ImageButton") then
                    pcall(NetGet, "claim_quest", row.Name)
                    task.wait(0.2)
                end
            end
            Notify(TX("bs.n.quests"), 3)
        end)
    end

    -- ── المتجر ────────────────────────────────────────────────
    local function ShopOptions(kind)
        local map = Workspace:FindFirstChild("Map")
        local tiles = map and map:FindFirstChild("Tiles")
        local store, crateName
        if kind == "car" then
            local tile = tiles and tiles:FindFirstChild("PrestigeDealerAndHousing")
            store = tile and tile:FindFirstChild("PrestigeCarDealer") or Workspace:FindFirstChild("PrestigeCarDealer", true)
            crateName = "Car Crate"
        else
            local tile = tiles and tiles:FindFirstChild("GunShopTile")
            store = tile and tile:FindFirstChild("PatriotWeapons") or Workspace:FindFirstChild("PatriotWeapons", true)
            crateName = (kind == "ammo") and "Ammo Crate" or "Weapon Crate"
        end
        local interior = store and store:FindFirstChild("Interior")
        local crates = interior and interior:FindFirstChild("Crates")
        local crate = crates and crates:FindFirstChild(crateName)
        return crate and crate:FindFirstChild("CrateOptions") or nil
    end
    local function BuyCrate(kind, option)
        task.spawn(function()
            local opts = ShopOptions(kind)
            if not opts then Notify(TX("bs.buy.near"), 3); return end
            local opt = opts:FindFirstChild(option) or opts:FindFirstChildWhichIsA("Instance")
            if not opt then Notify(TX("bs.buy.near"), 3); return end
            local r = NetGet("open_crate", opt, "money")
            if r then Notify(TX("bs.buy.sent"), 2) end
        end)
    end

    local function TeleportTo(pos)
        local root = MyRoot()
        if root then root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
    end

    -- ══════════════════════════════════════════════════════════
    -- اللاعب
    -- ══════════════════════════════════════════════════════════
    -- ── Infinite Stamina ──────────────────────────────────────
    local Stam = { bar = nil, orig = nil }
    local function StaminaFallback()
        for _, o in ipairs({ lp, lp.Character }) do
            if o then
                pcall(function()
                    for name, v in pairs(o:GetAttributes()) do
                        if tostring(name):lower():find("stamina", 1, true) and type(v) == "number" then
                            o:SetAttribute(name, v <= 1.5 and 1 or math.max(v, 100))
                        end
                    end
                end)
            end
        end
    end
    local function SetStamina(on)
        if on then
            pcall(function()
                local sprint = ModuleAt("Modules", "Game", "Sprint")
                if not (sprint and sprint.consume_stamina) then return end
                local getter = getupvalue or (debug and debug.getupvalue)
                if not getter then return end
                local a, b = getter(sprint.consume_stamina, 2)
                local up = (type(a) == "string" and b ~= nil) and b or a
                if type(up) == "table" and rawget(up, "sprint_bar") and type(up.sprint_bar.update) == "function" then
                    Stam.bar = up.sprint_bar
                    Stam.orig = Stam.orig or Stam.bar.update
                    local o = Stam.orig
                    Stam.bar.update = function() return o(function() return 1 end) end
                end
            end)
        else
            pcall(function()
                if Stam.bar and Stam.orig then Stam.bar.update = Stam.orig end
            end)
            Stam.bar, Stam.orig = nil, nil
        end
    end
    OnCleanup(function() SetStamina(false) end)
    task.spawn(function()
        while Alive() do
            task.wait(0.4)
            if S.Stamina then pcall(StaminaFallback) end
        end
    end)

    -- ── Infinite Hotbar ───────────────────────────────────────
    getgenv().BS_HotbarOn = false
    local function TryHotbarHook()
        if getgenv().BS_HotbarHooked then return end
        if type(getgc) ~= "function" or type(hookfunction) ~= "function" then return end
        pcall(function()
            for _, fn in pairs(getgc(true)) do
                if type(fn) == "function" then
                    local name
                    pcall(function()
                        if debug and debug.getinfo then name = debug.getinfo(fn).name end
                        if not name and debug and debug.info then name = debug.info(fn, "n") end
                    end)
                    if name == "get_max_items" then
                        local orig
                        local ok = pcall(function()
                            orig = hookfunction(fn, function(...)
                                if getgenv().BS_HotbarOn then return 999 end
                                return orig(...)
                            end)
                        end)
                        if ok and type(orig) == "function" then getgenv().BS_HotbarHooked = true; return end
                    end
                end
            end
        end)
    end

    -- ── Anti Ragdoll ──────────────────────────────────────────
    local RagdollMod
    task.spawn(function() RagdollMod = ModuleAt("Modules", "Game", "Ragdoll") end)
    task.spawn(function()
        while Alive() do
            task.wait(0.1)
            if S.AntiRagdoll then
                pcall(function()
                    local ragdolled = false
                    if RagdollMod and RagdollMod.is_ragdolling and RagdollMod.is_ragdolling.get then
                        ragdolled = RagdollMod.is_ragdolling.get()
                    end
                    if ragdolled then
                        if RagdollMod.is_ragdolling.set then RagdollMod.is_ragdolling.set(false) end
                        NetSend("end_ragdoll_early")
                        NetSend("clear_ragdoll")
                    end
                end)
            end
        end
    end)

    -- ── Anti Auto Sit ─────────────────────────────────────────
    local function IsVehicleSeat(seat)
        if seat:IsA("VehicleSeat") then return true end
        local vf = Workspace:FindFirstChild("Vehicles")
        if vf and seat:IsDescendantOf(vf) then return true end
        local model = seat:FindFirstAncestorOfClass("Model")
        return model ~= nil and (model:FindFirstChildOfClass("VehicleSeat") or model:FindFirstChild("DriverSeat", true)
            or model:FindFirstChild("DriveSeat", true) or model:GetAttribute("IsVehicle")) and true or false
    end
    local seatsOff = setmetatable({}, { __mode = "k" })
    local function SetSeats(disabled)
        task.spawn(function()
            for _, o in ipairs(Workspace:GetDescendants()) do
                if o:IsA("Seat") and not IsVehicleSeat(o) then
                    if disabled then seatsOff[o] = true; o.Disabled = true
                    elseif seatsOff[o] then o.Disabled = false; seatsOff[o] = nil end
                end
            end
        end)
    end
    TrackConn(Workspace.DescendantAdded:Connect(function(o)
        if S.AntiSit and o:IsA("Seat") and not IsVehicleSeat(o) then seatsOff[o] = true; o.Disabled = true end
    end))
    local function BindSit(char)
        local hum = char and (char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5))
        if not hum then return end
        TrackConn(hum.Seated:Connect(function(seated, seat)
            if seated and S.AntiSit and seat and not IsVehicleSeat(seat) then
                hum.Sit = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end))
    end
    task.spawn(function() BindSit(lp.Character) end)
    TrackConn(lp.CharacterAdded:Connect(function(c) task.spawn(BindSit, c) end))
    OnCleanup(function() for s in pairs(seatsOff) do pcall(function() s.Disabled = false end) end end)

    -- ── Auto Respawn ──────────────────────────────────────────
    task.spawn(function()
        local busy = false
        while Alive() do
            task.wait(0.5)
            if S.Respawn and not busy then
                local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    busy = true
                    task.spawn(function()
                        task.wait(6)
                        if S.Respawn then NetSend("death_screen_request_respawn") end
                        task.wait(1)
                        busy = false
                    end)
                end
            end
        end
    end)


    -- ══════════════════════════════════════════════════════════
    -- 3. الواجهة (نفس ستايل تاب MM2)
    -- ══════════════════════════════════════════════════════════
    local function Tw(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    -- سلايدر: سحب + أزرار - / + (الضغط المطوّل يكرر)
    local function AddSlider(text, minV, maxV, defaultV, step, suffix, callback)
        tab.Order = tab.Order + 1
        suffix = suffix or ""
        local OFF_CLR = Color3.fromRGB(45, 45, 55)

        local R = Instance.new("Frame", tab.Page)
        R.LayoutOrder = tab.Order
        R.Size = UDim2.new(0.98, 0, 0, 76)
        R.BackgroundColor3 = CARD; R.BackgroundTransparency = 0.1; R.BorderSizePixel = 0
        Instance.new("UICorner", R).CornerRadius = UDim.new(0, 10)
        local Stroke = Instance.new("UIStroke", R)
        Stroke.Thickness = 1.2; Stroke.Transparency = 0.55
        local SG = Instance.new("UIGradient", Stroke)
        SG.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, C_GREEN), ColorSequenceKeypoint.new(1, C_BLUE) }
        SG.Rotation = 45

        local Lbl = Instance.new("TextLabel", R)
        Lbl.Text = text; Lbl.Size = UDim2.new(1, -90, 0, 24); Lbl.Position = UDim2.new(0, 10, 0, 6)
        Lbl.TextColor3 = Color3.fromRGB(210, 210, 225); Lbl.BackgroundTransparency = 1
        Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Font = Enum.Font.GothamSemibold
        Lbl.TextSize = 12; Lbl.TextTruncate = Enum.TextTruncate.AtEnd

        local ValLbl = Instance.new("TextLabel", R)
        ValLbl.Size = UDim2.new(0, 70, 0, 24); ValLbl.Position = UDim2.new(1, -80, 0, 6)
        ValLbl.BackgroundTransparency = 1; ValLbl.TextColor3 = C_GREEN
        ValLbl.TextXAlignment = Enum.TextXAlignment.Right; ValLbl.Font = Enum.Font.GothamBold; ValLbl.TextSize = 13

        local function mkStepBtn(txt, pos)
            local b = Instance.new("TextButton", R)
            b.Size = UDim2.new(0, 38, 0, 34); b.Position = pos
            b.BackgroundColor3 = OFF_CLR; b.BackgroundTransparency = 0.1; b.BorderSizePixel = 0
            b.Text = txt; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamBold
            b.TextSize = 18; b.AutoButtonColor = false
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            return b
        end
        local Minus = mkStepBtn("-", UDim2.new(0, 8, 0, 36))
        local Plus  = mkStepBtn("+", UDim2.new(1, -46, 0, 36))

        local Track = Instance.new("Frame", R)
        Track.Size = UDim2.new(1, -108, 0, 8); Track.Position = UDim2.new(0, 54, 0, 49)
        Track.BackgroundColor3 = OFF_CLR; Track.BorderSizePixel = 0
        Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
        local Fill = Instance.new("Frame", Track)
        Fill.Size = UDim2.new(0, 0, 1, 0); Fill.BackgroundColor3 = C_GREEN; Fill.BorderSizePixel = 0
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
        local FG = Instance.new("UIGradient", Fill)
        FG.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, C_GREEN), ColorSequenceKeypoint.new(1, C_BLUE) }
        local Knob = Instance.new("Frame", Track)
        Knob.Size = UDim2.new(0, 22, 0, 22); Knob.AnchorPoint = Vector2.new(0.5, 0.5)
        Knob.Position = UDim2.new(0, 0, 0.5, 0); Knob.BackgroundColor3 = Color3.new(1, 1, 1)
        Knob.BorderSizePixel = 0; Knob.ZIndex = 2
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        local Hit = Instance.new("TextButton", R)
        Hit.Size = UDim2.new(1, -108, 0, 46); Hit.Position = UDim2.new(0, 54, 0, 30)
        Hit.BackgroundTransparency = 1; Hit.Text = ""; Hit.AutoButtonColor = false; Hit.ZIndex = 3

        local value = math.clamp(defaultV, minV, maxV)
        local function render()
            local a = (value - minV) / (maxV - minV)
            Fill.Size = UDim2.new(a, 0, 1, 0)
            Knob.Position = UDim2.new(a, 0, 0.5, 0)
            ValLbl.Text = tostring(value) .. suffix
        end
        render()
        local function setValue(v)
            v = math.clamp(math.floor(v / step + 0.5) * step, minV, maxV)
            if v == value then return end
            value = v; render(); pcall(callback, value)
        end
        local function isPress(i)
            return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
        end
        local function setFromX(x)
            local w = Track.AbsoluteSize.X
            if w <= 0 then return end
            setValue(minV + math.clamp((x - Track.AbsolutePosition.X) / w, 0, 1) * (maxV - minV))
        end
        local dragging = false
        Hit.InputBegan:Connect(function(i)
            if isPress(i) then
                dragging = true
                pcall(function() tab.Page.ScrollingEnabled = false end)
                Tw(Knob, { Size = UDim2.new(0, 28, 0, 28) }); Tw(Stroke, { Transparency = 0.1 })
                setFromX(i.Position.X)
            end
        end)
        TrackConn(UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                setFromX(i.Position.X)
            end
        end))
        TrackConn(UserInputService.InputEnded:Connect(function(i)
            if dragging and isPress(i) then
                dragging = false
                pcall(function() tab.Page.ScrollingEnabled = true end)
                Tw(Knob, { Size = UDim2.new(0, 22, 0, 22) }); Tw(Stroke, { Transparency = 0.55 })
            end
        end))
        local holdId = nil
        local function bindStep(btn, dir)
            btn.InputBegan:Connect(function(i)
                if not isPress(i) then return end
                local id = {}
                holdId = id
                Tw(btn, { BackgroundColor3 = C_BLUE })
                setValue(value + dir * step)
                task.spawn(function()
                    task.wait(0.4)
                    while holdId == id and Alive() do
                        setValue(value + dir * step)
                        task.wait(0.06)
                    end
                end)
            end)
            btn.InputEnded:Connect(function(i)
                if isPress(i) then holdId = nil; Tw(btn, { BackgroundColor3 = OFF_CLR }) end
            end)
        end
        bindStep(Minus, -1); bindStep(Plus, 1)
    end

    -- ── حاوية تمرير خاصة تتبع حجم النافذة فعلياً ─────────────
    getgenv().BS_SecOpen = getgenv().BS_SecOpen or {}
    local SecOpen = getgenv().BS_SecOpen
    local PAGE = tab.Page
    do
        local sc = Instance.new("ScrollingFrame")
        sc.Name = "BSScroll"
        sc.BackgroundTransparency = 1; sc.BorderSizePixel = 0; sc.LayoutOrder = 0
        sc.Active = true; sc.ScrollingEnabled = true
        sc.ScrollingDirection = Enum.ScrollingDirection.Y
        sc.CanvasSize = UDim2.new(0, 0, 0, 0)
        sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sc.ScrollBarThickness = 3
        sc.ScrollBarImageColor3 = Color3.fromRGB(120, 125, 140)
        sc.Size = UDim2.new(1, 0, 0, 260)
        sc.Parent = PAGE
        local ll = Instance.new("UIListLayout", sc)
        ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Padding = UDim.new(0, 8)
        ll.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local pd = Instance.new("UIPadding", sc)
        pd.PaddingBottom = UDim.new(0, 16)
        pcall(function() PAGE.ScrollingEnabled = false end)

        local GRIP_PX = 36
        local function fit()
            local h, scale = 0, 1
            local ok = pcall(function()
                local curH = sc.Size.Y.Offset
                if curH > 0 and sc.AbsoluteSize.Y > 0 then scale = math.clamp(sc.AbsoluteSize.Y / curH, 0.2, 5) end
                h = PAGE.AbsoluteWindowSize.Y
                local a = PAGE.Parent
                while a and a:IsA("GuiObject") do
                    if a.ClipsDescendants then
                        h = math.min(h, a.AbsolutePosition.Y + a.AbsoluteSize.Y - sc.AbsolutePosition.Y)
                        break
                    end
                    a = a.Parent
                end
            end)
            if ok and h > 60 then
                h = math.floor(h / scale)
                if sc.Size.Y.Offset ~= h then sc.Size = UDim2.new(1, 0, 0, h) end
                local pad = math.ceil(GRIP_PX / scale) + 4
                if pd.PaddingBottom.Offset ~= pad then pd.PaddingBottom = UDim.new(0, pad) end
            end
        end
        local acc = 0
        TrackConn(RunService.Heartbeat:Connect(function(dt)
            acc = acc + dt
            if acc < 0.2 then return end
            acc = 0; fit()
        end))
        task.defer(fit)
        PAGE = sc
        tab.Page = sc
    end

    local function Card(parent, h)
        tab.Order = tab.Order + 1
        local f = Instance.new("Frame", parent)
        f.LayoutOrder = tab.Order
        f.Size = UDim2.new(0.98, 0, 0, h)
        f.BackgroundColor3 = CARD; f.BackgroundTransparency = 0.08; f.BorderSizePixel = 0
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
        return f
    end

    local function MakeLabel(parent, text, color, size, height)
        tab.Order = tab.Order + 1
        local l = Instance.new("TextLabel", parent)
        l.LayoutOrder = tab.Order
        l.Size = UDim2.new(0.98, 0, 0, height or 20)
        l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = color or DIM
        l.Font = Enum.Font.Gotham; l.TextSize = size or 11; l.TextWrapped = true
        return l
    end

    -- ── بطاقة الحالة العلوية ─────────────────────────────────
    local infoCard = Card(PAGE, 44)
    local infoStroke = Instance.new("UIStroke", infoCard)
    infoStroke.Thickness = 1.4; infoStroke.Transparency = 0.45; infoStroke.Color = C_GREEN
    local infoKey = Instance.new("TextLabel", infoCard)
    infoKey.Size = UDim2.new(0.4, 0, 1, 0); infoKey.Position = UDim2.new(0, 14, 0, 0)
    infoKey.BackgroundTransparency = 1; infoKey.Text = "🎯  " .. TX("bs.ui.target")
    infoKey.TextColor3 = DIM; infoKey.Font = Enum.Font.GothamSemibold; infoKey.TextSize = 12
    infoKey.TextXAlignment = Enum.TextXAlignment.Left
    local infoVal = Instance.new("TextLabel", infoCard)
    infoVal.Size = UDim2.new(0.6, -14, 1, 0); infoVal.Position = UDim2.new(0.4, 0, 0, 0)
    infoVal.BackgroundTransparency = 1; infoVal.Text = TX("bs.ui.none")
    infoVal.TextColor3 = C_GREEN; infoVal.Font = Enum.Font.GothamBlack; infoVal.TextSize = 13
    infoVal.TextXAlignment = Enum.TextXAlignment.Right; infoVal.TextTruncate = Enum.TextTruncate.AtEnd

    -- ── قسم قابل للطي + عدّاد الميزات المفعّلة ───────────────
    local function MakeSection(id, title, color, defaultOpen)
        tab.Order = tab.Order + 1
        local Hdr = Instance.new("TextButton", PAGE)
        Hdr.LayoutOrder = tab.Order; Hdr.Size = UDim2.new(0.98, 0, 0, 50)
        Hdr.BackgroundColor3 = CARD; Hdr.BackgroundTransparency = 0.08
        Hdr.BorderSizePixel = 0; Hdr.Text = ""; Hdr.AutoButtonColor = false
        Instance.new("UICorner", Hdr).CornerRadius = UDim.new(0, 12)
        local st = Instance.new("UIStroke", Hdr)
        st.Thickness = 1.3; st.Transparency = 0.55; st.Color = color
        local bar = Instance.new("Frame", Hdr)
        bar.Size = UDim2.new(0, 5, 1, -16); bar.Position = UDim2.new(0, 8, 0, 8)
        bar.BackgroundColor3 = color; bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        local TL = Instance.new("TextLabel", Hdr)
        TL.Size = UDim2.new(1, -130, 1, 0); TL.Position = UDim2.new(0, 24, 0, 0)
        TL.BackgroundTransparency = 1; TL.Text = title; TL.TextColor3 = Color3.fromRGB(230, 230, 242)
        TL.Font = Enum.Font.GothamBold; TL.TextSize = 13
        TL.TextXAlignment = Enum.TextXAlignment.Left; TL.TextTruncate = Enum.TextTruncate.AtEnd
        local Badge = Instance.new("TextLabel", Hdr)
        Badge.Size = UDim2.new(0, 46, 0, 22); Badge.Position = UDim2.new(1, -92, 0.5, -11)
        Badge.BackgroundColor3 = color; Badge.BackgroundTransparency = 0.7
        Badge.TextColor3 = Color3.new(1, 1, 1); Badge.Font = Enum.Font.GothamBlack
        Badge.TextSize = 11; Badge.Text = "0"; Badge.Visible = false
        Instance.new("UICorner", Badge).CornerRadius = UDim.new(1, 0)
        local Arr = Instance.new("TextLabel", Hdr)
        Arr.Size = UDim2.new(0, 28, 1, 0); Arr.Position = UDim2.new(1, -38, 0, 0)
        Arr.BackgroundTransparency = 1; Arr.Text = ">"; Arr.TextColor3 = DIM
        Arr.Font = Enum.Font.GothamBlack; Arr.TextSize = 18

        tab.Order = tab.Order + 1
        local Cont = Instance.new("Frame", PAGE)
        Cont.LayoutOrder = tab.Order; Cont.Size = UDim2.new(0.98, 0, 0, 0)
        Cont.BackgroundTransparency = 1; Cont.ClipsDescendants = true
        local LL = Instance.new("UIListLayout", Cont)
        LL.SortOrder = Enum.SortOrder.LayoutOrder; LL.Padding = UDim.new(0, 6)
        LL.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local pad = Instance.new("UIPadding", Cont)
        pad.PaddingTop = UDim.new(0, 4); pad.PaddingBottom = UDim.new(0, 8)

        local sec = { cont = Cont, count = 0, color = color }
        function sec.refresh()
            Badge.Visible = sec.count > 0
            Badge.Text = "ON " .. sec.count
        end
        local isOpen = false
        local function apply(open, animate)
            isOpen = open; SecOpen[id] = open
            Cont.AutomaticSize = open and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
            Cont.Size = UDim2.new(0.98, 0, 0, 0)
            local d = animate and 0.2 or 0
            Tw(Arr, { Rotation = open and 90 or 0, TextColor3 = open and color or DIM }, d)
            Tw(st, { Transparency = open and 0.15 or 0.55 }, d)
        end
        local startOpen = SecOpen[id]
        if startOpen == nil then startOpen = defaultOpen end
        if startOpen then task.defer(function() apply(true, false) end) end
        Hdr.MouseButton1Click:Connect(function() apply(not isOpen, true) end)
        return sec
    end

    -- يدخل عناصر الهب (Toggle/Slider) داخل القسم
    local function InSection(sec, fn)
        local before = {}
        for _, c in ipairs(PAGE:GetChildren()) do before[c] = true end
        tab.Page = sec.cont
        local ok, err = pcall(fn)
        tab.Page = PAGE
        if not ok then
            warn("[BS UI] " .. tostring(err))
            local e = Instance.new("TextLabel", sec.cont)
            e.Size = UDim2.new(1, 0, 0, 40); e.BackgroundTransparency = 1
            e.TextWrapped = true; e.TextSize = 11; e.Font = Enum.Font.Gotham
            e.TextColor3 = Color3.fromRGB(255, 120, 120); e.Text = "UI error: " .. tostring(err)
            e.LayoutOrder = 9999
        end
        for _, c in ipairs(PAGE:GetChildren()) do
            if not before[c] and c:IsA("GuiObject") then c.Parent = sec.cont end
        end
    end

    local allToggles = {}
    local function Tog(sec, text, cb, keep)
        local on = false
        local t = tab:AddToggle(text, function(v)
            v = v and true or false
            if v ~= on then
                on = v
                sec.count = sec.count + (v and 1 or -1)
                sec.refresh()
            end
            cb(v)
        end)
        if not keep then allToggles[#allToggles + 1] = t end
        return t
    end

    -- شبكة أزرار بعمودين (ترجع الأزرار لتغيير نصها لاحقاً)
    local function Grid(sec, items)
        tab.Order = tab.Order + 1
        local G = Instance.new("Frame", sec.cont)
        G.LayoutOrder = tab.Order; G.Size = UDim2.new(0.98, 0, 0, 0)
        G.AutomaticSize = Enum.AutomaticSize.Y; G.BackgroundTransparency = 1
        local GL = Instance.new("UIGridLayout", G)
        GL.CellSize = UDim2.new(0.5, -4, 0, 50)
        GL.CellPadding = UDim2.new(0, 8, 0, 8)
        GL.SortOrder = Enum.SortOrder.LayoutOrder
        local buttons = {}
        for i, it in ipairs(items) do
            local col = it.color or sec.color
            local B = Instance.new("TextButton", G)
            B.LayoutOrder = i
            B.BackgroundColor3 = col; B.BackgroundTransparency = 0.82
            B.BorderSizePixel = 0; B.AutoButtonColor = false
            B.Text = it.text; B.TextColor3 = Color3.fromRGB(235, 235, 245)
            B.Font = Enum.Font.GothamBold; B.TextSize = 12
            B.TextWrapped = true; B.TextTruncate = Enum.TextTruncate.AtEnd
            Instance.new("UICorner", B).CornerRadius = UDim.new(0, 11)
            local s = Instance.new("UIStroke", B)
            s.Thickness = 1.3; s.Color = col; s.Transparency = 0.4
            B.MouseEnter:Connect(function() Tw(B, { BackgroundTransparency = 0.65 }, 0.1) end)
            B.MouseLeave:Connect(function() Tw(B, { BackgroundTransparency = 0.82 }, 0.1) end)
            B.MouseButton1Click:Connect(function()
                B.BackgroundTransparency = 0.3
                Tw(B, { BackgroundTransparency = 0.82 }, 0.25)
                pcall(it.fn, B)
            end)
            buttons[i] = B
        end
        return buttons, G
    end

    -- ── حلقة تحديث البطاقات (4 مرات بالثانية) ─────────────────
    local farmStatus
    do
        local acc = 0
        TrackConn(RunService.Heartbeat:Connect(function(dt)
            acc = acc + dt
            if acc < 0.25 then return end
            acc = 0
            pcall(function()
                local tgt = CurrentTarget
                if tgt and tgt.Character and IsAlivePlayer(tgt) then
                    local r = MyRoot()
                    local d = r and math.floor((tgt.Character.HumanoidRootPart.Position - r.Position).Magnitude * 0.28) or 0
                    infoVal.Text = (tgt.DisplayName ~= "" and tgt.DisplayName or tgt.Name) .. "  •  " .. d .. "m"
                    infoVal.TextColor3 = Lock.vis and C_VIS or C_HID
                    infoStroke.Color = infoVal.TextColor3
                else
                    infoVal.Text = TX("bs.ui.none"); infoVal.TextColor3 = DIM; infoStroke.Color = C_GREEN
                end
                if farmStatus then
                    farmStatus.Text = "📊  " .. TX("bs.status") .. ": " .. TX("bs." .. Fish.status)
                        .. "   |   " .. TX("bs.catches") .. ": " .. Fish.catches
                end
            end)
        end))
    end

    MakeLabel(PAGE, TX("bs.ui.hint"), DIM, 11, 20)

    -- ═════════════ القتال ═════════════
    local secCombat = MakeSection("combat", "🎯  " .. TX("bs.sec.combat"), C_RED, true)
    InSection(secCombat, function()
        Tog(secCombat, "🎯  " .. TX("bs.silent"), function(v)
            S.SilentAim = v
            if v and not HookOK then Notify(TX("bs.n.nohook"), 4) end
        end)
        Tog(secCombat, "🧲  " .. TX("bs.assist"), function(v) S.AimAssist = v end)
        Tog(secCombat, "🧱  " .. TX("bs.wall"), function(v) S.WallCheck = v end)
        Tog(secCombat, "📈  " .. TX("bs.predict"), function(v) S.Predict = v end, true):SetState(true)
        Tog(secCombat, "➖  " .. TX("bs.line"), function(v) S.TargetLine = v end, true):SetState(true)
        Tog(secCombat, "⭕  " .. TX("bs.showfov"), function(v) S.ShowFOV = v end)
        AddSlider(TX("bs.fov"), 20, 800, S.FOV, 5, "", function(v) S.FOV = v end)
        AddSlider(TX("bs.strength"), 5, 100, S.Strength, 5, "%", function(v) S.Strength = v end)
    end)
    local parts = { "Head", "Neck", "Chest" }
    local partIdx = 1
    local partBtn
    do
        local btns = Grid(secCombat, {
            { text = "🎯  " .. TX("bs.hitpart") .. ": " .. TX("bs.part.head"), fn = function()
                partIdx = partIdx % #parts + 1
                S.HitPart = parts[partIdx]
                partBtn.Text = "🎯  " .. TX("bs.hitpart") .. ": " .. TX("bs.part." .. string.lower(S.HitPart))
            end },
        })
        partBtn = btns[1]
    end

    -- ═════════════ الأسلحة ═════════════
    local secWeap = MakeSection("weapons", "🔫  " .. TX("bs.sec.weapons"), C_ORANGE, false)
    InSection(secWeap, function()
        Tog(secWeap, "🔫  " .. TX("bs.autoshoot"), function(v)
            S.AutoShoot = v
            if v then AS.scanAt = 0 end
        end)
        AddSlider(TX("bs.shootrange"), 30, 120, S.ShootRange, 5, "m", function(v) S.ShootRange = v end)
        Tog(secWeap, "🛠️  " .. TX("bs.gunmod"), function(v)
            S.GunMod = v
            if v then GMApplyEquipped() else GMRestoreAll() end
        end)
        local function sub(flag, feature, key, icon)
            Tog(secWeap, icon .. "  " .. TX(key), function(v)
                S.GM[flag] = v
                if v then if S.GunMod then GMApplyEquipped() end else GMRestoreAll(feature) end
            end, true):SetState(true)
        end
        sub("Recoil", "Recoil", "bs.gm.recoil", "🎯")
        sub("Accuracy", "Accuracy", "bs.gm.accuracy", "🔬")
        sub("Range", "Range", "bs.gm.range", "📏")
        sub("FireRate", "FireRate", "bs.gm.firerate", "⚡")
        sub("Reload", "Reload", "bs.gm.reload", "🔄")
        sub("Auto", "Automatic", "bs.gm.auto", "🔁")
        Tog(secWeap, "🗡️  " .. TX("bs.aura"), function(v)
            S.Aura = v
            if not v then AuraRestore() end
        end)
        Tog(secWeap, "⚔️  " .. TX("bs.autoatk"), function(v) S.AutoMelee = v end)
        AddSlider(TX("bs.meleerange"), 10, 30, S.MeleeRange, 1, "", function(v) S.MeleeRange = v end)
    end)

    -- ═════════════ الرؤية ═════════════
    local secVis = MakeSection("visuals", "👁️  " .. TX("bs.sec.visuals"), C_GREEN, false)
    InSection(secVis, function()
        Tog(secVis, "⬜  " .. TX("bs.esp.box"),    function(v) E.Box = v end)
        Tog(secVis, "📐  " .. TX("bs.esp.lines"),  function(v) E.Lines = v end)
        Tog(secVis, "✨  " .. TX("bs.esp.hl"),     function(v) E.Highlight = v end)
        Tog(secVis, "🏷️  " .. TX("bs.esp.name"),   function(v) E.Name = v end)
        Tog(secVis, "❤️  " .. TX("bs.esp.hp"),     function(v) E.Health = v end)
        Tog(secVis, "📏  " .. TX("bs.esp.dist"),   function(v) E.Dist = v end)
        Tog(secVis, "🔫  " .. TX("bs.esp.weapon"), function(v) E.Weapon = v end)
        Tog(secVis, "📦  " .. TX("bs.esp.items"),  function(v) E.Items = v end)
        AddSlider(TX("bs.esp.range"), 100, 5000, S.ESPRange, 100, "", function(v) S.ESPRange = v end)
    end)

    -- ═════════════ الفارم ═════════════
    local secFarm = MakeSection("farm", "🎣  " .. TX("bs.sec.farm"), C_BLUE, false)
    InSection(secFarm, function()
        Tog(secFarm, "🎣  " .. TX("bs.fish"), function(v)
            S.Fish = v
            if v then Fish.lineOut = false end
        end)
        Tog(secFarm, "🎯  " .. TX("bs.minigame"), function(v) S.Minigame = v end)
        Tog(secFarm, "💰  " .. TX("bs.sell"), function(v) S.AutoSell = v end)
        Tog(secFarm, "🪱  " .. TX("bs.bait"), function(v) S.AutoBait = v end)
        Tog(secFarm, "⏩  " .. TX("bs.skipcrate"), function(v)
            S.SkipCrates = v
            SkipAPI.SetEnabled(v)
        end)
        Tog(secFarm, "🧲  " .. TX("bs.pickup"), function(v) S.Pickup = v end)
        AddSlider(TX("bs.pickrange"), 20, 500, S.PickRadius, 5, "", function(v) S.PickRadius = v end)
        AddSlider(TX("bs.spot"), 1, 5, S.Spot, 1, "", function(v) S.Spot = v; Fish.lineOut = false end)
    end)
    farmStatus = MakeLabel(secFarm.cont, "📊  " .. TX("bs.status") .. ": " .. TX("bs.st.idle"), C_CYAN, 11, 22)
    Grid(secFarm, {
        { text = "💰  " .. TX("bs.sellnow"), fn = SellFishNow },
        { text = "📜  " .. TX("bs.quests"),  fn = ClaimAllQuests },
        { text = "📍  " .. TX("bs.tp.sell"), color = C_CYAN, fn = function() TeleportTo(SELL_POS) end },
        { text = "📍  " .. TX("bs.tp.bait"), color = C_CYAN, fn = function() TeleportTo(BAIT_POS) end },
    })

    -- ═════════════ المتجر ═════════════
    local secShop = MakeSection("shop", "🛒  " .. TX("bs.sec.shop"), C_GOLD, false)
    Grid(secShop, {
        { text = "🔫  " .. TX("bs.buy.pistol"),   fn = function() BuyCrate("ammo", "Pistol") end },
        { text = "🎯  " .. TX("bs.buy.rifle"),    fn = function() BuyCrate("ammo", "Rifle") end },
        { text = "💥  " .. TX("bs.buy.shotgun"),  fn = function() BuyCrate("ammo", "Shotgun") end },
        { text = "📦  " .. TX("bs.buy.guncrate"), fn = function() BuyCrate("gun", "Basic") end },
        { text = "🚗  " .. TX("bs.buy.carcrate"), fn = function() BuyCrate("car", "Basic") end },
    })

    -- ═════════════ اللاعب ═════════════
    local secPlayer = MakeSection("player", "🧍  " .. TX("bs.sec.player"), C_PURPLE, false)
    InSection(secPlayer, function()
        Tog(secPlayer, "🏃  " .. TX("bs.stamina"), function(v) S.Stamina = v; SetStamina(v) end)
        Tog(secPlayer, "🎒  " .. TX("bs.hotbar"), function(v)
            S.Hotbar = v
            getgenv().BS_HotbarOn = v
            if v then TryHotbarHook() end
        end)
        Tog(secPlayer, "🛡️  " .. TX("bs.antiragdoll"), function(v) S.AntiRagdoll = v end)
        Tog(secPlayer, "🪑  " .. TX("bs.antisit"), function(v) S.AntiSit = v; SetSeats(v) end)
        Tog(secPlayer, "♻️  " .. TX("bs.respawn"), function(v) S.Respawn = v end)
    end)

    -- ═════════════ الأصدقاء ═════════════
    local secFr = MakeSection("friends", "🤝  " .. TX("bs.sec.friends"), C_CYAN, false)
    MakeLabel(secFr.cont, TX("bs.fr.hint"), DIM, 11, 22)
    tab.Order = tab.Order + 1
    local FrList = Instance.new("Frame", secFr.cont)
    FrList.LayoutOrder = tab.Order; FrList.Size = UDim2.new(0.98, 0, 0, 0)
    FrList.AutomaticSize = Enum.AutomaticSize.Y; FrList.BackgroundTransparency = 1
    local FrLayout = Instance.new("UIListLayout", FrList)
    FrLayout.SortOrder = Enum.SortOrder.LayoutOrder; FrLayout.Padding = UDim.new(0, 5)

    local function RefreshFriends()
        for _, c in ipairs(FrList:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
        local n = 0
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= lp then
                n = n + 1
                local b = Instance.new("TextButton", FrList)
                b.LayoutOrder = n; b.Size = UDim2.new(1, 0, 0, 34)
                b.BorderSizePixel = 0; b.AutoButtonColor = false
                b.Font = Enum.Font.GothamSemibold; b.TextSize = 12
                b.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
                local pd = Instance.new("UIPadding", b); pd.PaddingLeft = UDim.new(0, 12)
                local function paint()
                    local f = Friends[pl.Name]
                    b.BackgroundColor3 = f and C_FRIEND or Color3.fromRGB(45, 45, 55)
                    b.BackgroundTransparency = f and 0.65 or 0.2
                    b.TextColor3 = f and Color3.fromRGB(190, 255, 210) or Color3.fromRGB(215, 215, 230)
                    b.Text = (f and "✅  " or "▫️  ") .. (pl.DisplayName ~= "" and pl.DisplayName or pl.Name) .. "  (@" .. pl.Name .. ")"
                end
                paint()
                b.MouseButton1Click:Connect(function()
                    Friends[pl.Name] = (not Friends[pl.Name]) or nil
                    if Lock.pl == pl then Lock.pl = nil end
                    AS.locked = nil
                    paint()
                end)
            end
        end
        if n == 0 then
            local l = Instance.new("TextLabel", FrList)
            l.Size = UDim2.new(1, 0, 0, 24); l.BackgroundTransparency = 1; l.Text = TX("bs.fr.empty")
            l.TextColor3 = DIM; l.Font = Enum.Font.Gotham; l.TextSize = 11
        end
    end
    Grid(secFr, {
        { text = "🔄  " .. TX("bs.fr.refresh"), fn = RefreshFriends },
        { text = "🗑️  " .. TX("bs.fr.clear"), color = C_RED, fn = function()
            table.clear(Friends); RefreshFriends()
        end },
    })
    RefreshFriends()
    TrackConn(Players.PlayerAdded:Connect(function() task.delay(0.5, RefreshFriends) end))
    TrackConn(Players.PlayerRemoving:Connect(function(pl)
        Friends[pl.Name] = nil
        task.delay(0.2, RefreshFriends)
    end))

    -- ═════════════ إيقاف الكل ═════════════
    tab.Order = tab.Order + 1
    local StopB = Instance.new("TextButton", PAGE)
    StopB.LayoutOrder = tab.Order; StopB.Size = UDim2.new(0.98, 0, 0, 50)
    StopB.BackgroundColor3 = C_RED; StopB.BackgroundTransparency = 0.8
    StopB.BorderSizePixel = 0; StopB.AutoButtonColor = false
    StopB.Text = "⛔  " .. TX("bs.ui.stopall")
    StopB.TextColor3 = Color3.fromRGB(255, 200, 200)
    StopB.Font = Enum.Font.GothamBlack; StopB.TextSize = 13
    Instance.new("UICorner", StopB).CornerRadius = UDim.new(0, 12)
    local sbs = Instance.new("UIStroke", StopB)
    sbs.Thickness = 1.4; sbs.Color = C_RED; sbs.Transparency = 0.35
    StopB.MouseButton1Click:Connect(function()
        for _, t in ipairs(allToggles) do pcall(function() t:SetState(false) end) end
        Notify(TX("bs.ui.stopped"), 2)
        StopB.BackgroundTransparency = 0.4
        Tw(StopB, { BackgroundTransparency = 0.8 }, 0.3)
    end)
    do
        local sp = Instance.new("Frame", PAGE)
        sp.LayoutOrder = tab.Order + 1; sp.Size = UDim2.new(0.98, 0, 0, 14)
        sp.BackgroundTransparency = 1; sp.BorderSizePixel = 0
    end
end

-- ============================================================
-- 4. إرجاع الجدول
-- ============================================================
return {
    Name   = "Block Spin",
    Render = Render,
}
