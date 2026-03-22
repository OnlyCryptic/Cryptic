-- [[ Cryptic Hub - حقيبة ظهر (Backpack) ]]
-- الوصف: تثبت شخصيتك جالس على ظهر الهدف ويشوفك الكل

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer

    local isBackpacking = false
    local loopConn = nil
    local animTrack = nil

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = ar .. "\n" .. en,
                Duration = 4,
            })
        end)
    end

    local function StopBackpack()
        isBackpacking = false
        if loopConn then loopConn:Disconnect() loopConn = nil end

        if animTrack then
            animTrack:Stop()
            animTrack:Destroy()
            animTrack = nil
        end

        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if hum then
                hum.PlatformStand = false
                hum.AutoRotate = true
            end
            if root then
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
            end
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Massless = false
                    p.CanCollide = true
                end
            end
        end
    end

    Tab:AddToggle("حقيبة ظهر / Backpack", function(active)
        if active then
            local target = _G.ArwaTarget
            if not target or not target.Character then
                Notify("⚠️ حدد لاعباً أولاً!", "⚠️ Select a player first!")
                StopBackpack()
                return
            end

            isBackpacking = true

            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local animator = hum and hum:FindFirstChildOfClass("Animator")

            if hum then
                hum.PlatformStand = true
                hum.AutoRotate = false
            end

            -- تشغيل أنيميشن جلوس يشوفه الكل
            if animator then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://2506281703"
                animTrack = animator:LoadAnimation(anim)
                animTrack.Priority = Enum.AnimationPriority.Action4
                animTrack.Looped = true
                animTrack:Play()
            end

            Notify(
                "🎒 أنت الآن حقيبة ظهر لـ: " .. target.DisplayName,
                "🎒 You are now a backpack for: " .. target.DisplayName
            )

            loopConn = runService.Heartbeat:Connect(function()
                if not isBackpacking then return end

                local myChar = lp.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

                local tgt = _G.ArwaTarget
                local tgtChar = tgt and tgt.Character
                local tgtTorso = tgtChar and (
                    tgtChar:FindFirstChild("UpperTorso") or
                    tgtChar:FindFirstChild("Torso")
                )

                if not myRoot or not tgtTorso then return end

                for _, p in pairs(myChar:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Massless = true
                        p.CanCollide = false
                        p.Velocity = Vector3.new(0, 0, 0)
                        p.RotVelocity = Vector3.new(0, 0, 0)
                    end
                end

                if myHum then
                    myHum.PlatformStand = true
                    myHum.AutoRotate = false
                end

                myRoot.Velocity = Vector3.new(0, 0, 0)
                myRoot.CFrame = tgtTorso.CFrame
                    * CFrame.new(0, 0.2, 1.2)
                    * CFrame.Angles(0, math.pi, 0)
            end)

        else
            StopBackpack()
            Notify("❌ نزلت من الظهر.", "❌ Got off the back.")
        end
    end)

    Tab:AddLine()
end
