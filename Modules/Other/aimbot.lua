-- [[ Cryptic Hub – Misc Aim Bot (Full) ]]
-- Full-featured aimbot: nearest/selected targeting, FOV circle,
-- smoothness, head/chest, through-walls, silent aim

return function(Tab, UI)
    local Players      = game:GetService("Players")
    local RunService   = game:GetService("RunService")
    local UIS          = game:GetService("UserInputService")
    local StarterGui   = game:GetService("StarterGui")
    local Camera       = workspace.CurrentCamera
    local lp           = Players.LocalPlayer

    local i18n = getgenv().CrypticI18n
    local T    = (i18n and i18n.T) or function(k) return k end

    -- ══════════════════════ CONFIG ═══════════════════════════
    local cfg = {
        enabled       = false,
        mode          = "nearest",          -- "nearest" | "selected"
        part          = "Head",             -- "Head" | "HumanoidRootPart"
        fovEnabled    = true,
        fovSize       = 120,
        smooth        = 0.15,               -- 0 = instant, ~0.9 = very slow
        throughWalls  = false,
        silentAim     = false,
        prediction    = false,              -- bullet-drop compensation
    }

    -- ══════════════════════ NOTIFY ═══════════════════════════
    local function Notify(txt)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = txt, Duration = 4
            })
        end)
    end

    -- ══════════════════════ FOV CIRCLE ═══════════════════════
    -- Try Drawing library first (all major exploits on PC + mobile)
    local fovCircle, fovOutline
    local drawOk = pcall(function()
        fovOutline         = Drawing.new("Circle")
        fovOutline.Visible = false; fovOutline.Thickness = 3
        fovOutline.Color   = Color3.fromRGB(0,0,0)
        fovOutline.Filled  = false; fovOutline.NumSides = 64
        fovOutline.Radius  = cfg.fovSize + 1

        fovCircle         = Drawing.new("Circle")
        fovCircle.Visible = false; fovCircle.Thickness = 1.5
        fovCircle.Color   = Color3.fromRGB(255,255,255)
        fovCircle.Filled  = false; fovCircle.NumSides = 64
        fovCircle.Radius  = cfg.fovSize
    end)

    local function UpdateFov()
        local ctr = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local show = cfg.enabled and cfg.fovEnabled
        if fovCircle then
            fovCircle.Position  = ctr
            fovCircle.Radius    = cfg.fovSize
            fovCircle.Visible   = show
        end
        if fovOutline then
            fovOutline.Position = ctr
            fovOutline.Radius   = cfg.fovSize + 1
            fovOutline.Visible  = show
        end
    end

    -- ══════════════════════ HELPERS ══════════════════════════
    -- Get world position of the aim part on a character
    local function AimPos(char)
        if not char then return nil end
        local part = char:FindFirstChild(cfg.part) or
                     char:FindFirstChild("HumanoidRootPart") or
                     char:FindFirstChild("Torso")
        return part and part.Position or nil
    end

    -- Check line-of-sight (skips if throughWalls = true)
    local function IsVisible(char)
        if cfg.throughWalls then return true end
        local pos = AimPos(char)
        if not pos then return false end
        local origin = Camera.CFrame.Position
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {char, lp.Character or workspace}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local res = workspace:Raycast(origin, (pos - origin), rp)
        return res == nil   -- nothing blocking = visible
    end

    -- Screen-space distance from cursor/centre to a world position
    local function ScreenDist(worldPos)
        local vp, onScreen = Camera:WorldToViewportPoint(worldPos)
        if not onScreen then return math.huge end
        local centre = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        return (Vector2.new(vp.X, vp.Y) - centre).Magnitude
    end

    -- Pick the best enemy within FOV
    local function BestTarget()
        local best, bestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p == lp then continue end
            local char = p.Character; if not char then continue end
            local hum  = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local pos = AimPos(char); if not pos then continue end
            local d   = ScreenDist(pos)
            if d <= cfg.fovSize and d < bestDist and IsVisible(char) then
                bestDist = d; best = p
            end
        end
        return best
    end

    -- Smooth camera → world position
    local function SmoothCam(pos)
        local target = CFrame.lookAt(Camera.CFrame.Position, pos)
        local alpha  = math.clamp(1 - cfg.smooth, 0.03, 1)
        Camera.CFrame = Camera.CFrame:Lerp(target, alpha)
    end

    -- Rotate character body (Y-axis only) toward position
    local function BodyRotate(pos)
        local char = lp.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
        local gyro = root:FindFirstChild("CrypticAimGyro")
            or Instance.new("BodyGyro", root)
        gyro.Name        = "CrypticAimGyro"
        gyro.MaxTorque   = Vector3.new(0, math.huge, 0)
        gyro.P           = 500000; gyro.D = 100
        gyro.CFrame      = CFrame.lookAt(root.Position,
            Vector3.new(pos.X, root.Position.Y, pos.Z))
    end

    local function CleanGyro()
        local char = lp.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
        local g = root:FindFirstChild("CrypticAimGyro")
        if g then g:Destroy() end
    end

    -- ══════════════════════ SILENT AIM ═══════════════════════
    -- Hooks FindPartOnRay so bullets snap to the target hitbox
    local origFPOR, silentHooked = nil, false

    local function HookSilentAim()
        if silentHooked then return end
        if not (hookfunction and newcclosure) then return end
        local ok = pcall(function()
            origFPOR = hookfunction(workspace.FindPartOnRay,
                newcclosure(function(ws, ray, ...)
                    local tgt = (cfg.mode == "nearest") and BestTarget() or _G.ArwaTarget
                    if tgt and tgt.Character then
                        local ap = AimPos(tgt.Character)
                        if ap then
                            local d   = (ray.Origin - ap).Magnitude
                            local dir = (ap - ray.Origin).Unit * d
                            ray = Ray.new(ray.Origin, dir)
                        end
                    end
                    return origFPOR(ws, ray, ...)
                end))
        end)
        if ok then silentHooked = true end
    end

    local function UnhookSilentAim()
        if not silentHooked or not origFPOR then return end
        pcall(hookfunction, workspace.FindPartOnRay, origFPOR)
        silentHooked = false; origFPOR = nil
    end

    -- ══════════════════════ MAIN LOOP ════════════════════════
    local aimConn, fovConn

    local function StopAll()
        if aimConn  then aimConn:Disconnect();  aimConn  = nil end
        if fovConn  then fovConn:Disconnect();  fovConn  = nil end
        CleanGyro()
        UnhookSilentAim()
        UpdateFov()
    end

    local function StartAll()
        StopAll()
        if not cfg.enabled then return end
        if cfg.silentAim then HookSilentAim() end

        fovConn = RunService.RenderStepped:Connect(UpdateFov)

        aimConn = RunService.RenderStepped:Connect(function()
            if not cfg.enabled then return end
            local tgt = (cfg.mode == "nearest") and BestTarget() or _G.ArwaTarget
            if not tgt or not tgt.Character then return end
            local hum = tgt.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end
            local pos = AimPos(tgt.Character); if not pos then return end

            -- Optional velocity prediction (helps with moving targets)
            if cfg.prediction then
                local root = tgt.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local vel = root.AssemblyLinearVelocity
                    local dist = (Camera.CFrame.Position - pos).Magnitude
                    pos = pos + vel * (dist / 1000)
                end
            end

            SmoothCam(pos)
            BodyRotate(pos)
        end)
    end

    -- ══════════════════════ UI SECTIONS ══════════════════════
    -- ── Section helper (same dark-card style as build.lua) ───
    local TweenService = game:GetService("TweenService")
    local ACCENT   = Color3.fromRGB(0, 255, 150)
    local ACCENT2  = Color3.fromRGB(0, 150, 255)

    local function Tw(obj, props, t)
        TweenService:Create(obj,
            TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            props):Play()
    end

    local function GradStroke(frame, thickness)
        local s = Instance.new("UIStroke", frame)
        s.Thickness = thickness or 1.5; s.Transparency = 0.35
        local g = Instance.new("UIGradient", s)
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, ACCENT),
            ColorSequenceKeypoint.new(1, ACCENT2)
        }
        g.Rotation = 45
        return s
    end

    -- ── 1. MAIN TOGGLE ROW ────────────────────────────────────
    Tab:AddToggle(T("misc.aimbot.toggle"), function(on)
        cfg.enabled = on
        if on then
            StartAll()
            local tgt = (cfg.mode == "nearest") and BestTarget() or _G.ArwaTarget
            Notify(string.format(T("misc.aimbot.on_fmt"),
                tgt and tgt.DisplayName or "?"))
        else
            StopAll()
            Notify(T("misc.aimbot.off"))
        end
    end)

    Tab:AddLine()

    -- ── 2. TARGET MODE DROPDOWN ───────────────────────────────
    local nearestLabel  = T("misc.aimbot.nearest")
    local selectedLabel = T("misc.aimbot.selected")

    Tab:AddDropdown(T("misc.aimbot.target_mode"),
        { nearestLabel, selectedLabel },
        function(choice)
            cfg.mode = (choice == nearestLabel) and "nearest" or "selected"
        end)

    -- ── 3. AIM PART DROPDOWN ─────────────────────────────────
    local headLabel  = T("misc.aimbot.head")
    local chestLabel = T("misc.aimbot.chest")

    Tab:AddDropdown(T("misc.aimbot.aim_part"),
        { headLabel, chestLabel },
        function(choice)
            cfg.part = (choice == headLabel) and "Head" or "HumanoidRootPart"
        end)

    Tab:AddLine()

    -- ── 4. FOV TOGGLE ─────────────────────────────────────────
    Tab:AddToggle(T("misc.aimbot.fov_toggle"), function(on)
        cfg.fovEnabled = on
        UpdateFov()
    end)

    -- ── 5. FOV SIZE ────────────────────────────────────────────
    Tab:AddSpeedControl(T("misc.aimbot.fov_size"), function(on, val)
        if on then
            cfg.fovSize = math.clamp(tonumber(val) or 120, 10, 800)
            UpdateFov()
        end
    end, 120)

    Tab:AddLine()

    -- ── 6. SMOOTHNESS ─────────────────────────────────────────
    Tab:AddSpeedControl(T("misc.aimbot.smooth"), function(on, val)
        if on then
            -- val 0..100 → smooth 0..0.95
            cfg.smooth = math.clamp((tonumber(val) or 15) / 100, 0, 0.95)
        end
    end, 15)

    -- ── 7. THROUGH WALLS ──────────────────────────────────────
    Tab:AddToggle(T("misc.aimbot.through_walls"), function(on)
        cfg.throughWalls = on
    end)

    Tab:AddLine()

    -- ── 8. SILENT AIM ─────────────────────────────────────────
    Tab:AddToggle(T("misc.aimbot.silent"), function(on)
        cfg.silentAim = on
        if on and cfg.enabled then HookSilentAim()
        elseif not on         then UnhookSilentAim() end
    end)

    -- ── 9. PREDICTION ─────────────────────────────────────────
    Tab:AddToggle(T("misc.aimbot.prediction"), function(on)
        cfg.prediction = on
    end)

    Tab:AddLine()

    -- ── 10. INFO LABEL ────────────────────────────────────────
    Tab:AddLabel(T("misc.aimbot.info"))

    -- ══════════════════════ CLEANUP ══════════════════════════
    lp.CharacterRemoving:Connect(function()
        CleanGyro()
        UnhookSilentAim()
    end)

    -- Keep FOV centred when window is resized
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateFov)
end
