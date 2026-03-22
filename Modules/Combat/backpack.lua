-- [[ Cryptic Hub - حقيبة ظهر (Backpack) ]]
-- الوصف: تثبت شخصيتك على ظهر الهدف كأنك حقيبة ظهر

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer

    local isBackpacking = false
    local loopConn = nil

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
            if hum then
                hum.PlatformStand = true
                hum.AutoRotate = false
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
                -- نحاول نلصق على الـ Torso أو UpperTorso (ظهر الجسم)
                local tgtTorso = tgtChar and (
                    tgtChar:FindFirstChild("UpperTorso") or
                    tgtChar:FindFirstChild("Torso")
                )

                if not myRoot or not tgtTorso then return end

                -- تجميد فيزياء شخصيتي
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

                -- اللصق على الظهر:
                -- CFrame.new(0, 0, 1.2) = خطوة للخلف (ظهر الجسم)
                -- CFrame.new(0, -0.5, 0) = نزلت شوي لتبدو طبيعية
                myRoot.CFrame = tgtTorso.CFrame
                    * CFrame.new(0, -0.5, 1.2)
                    * CFrame.Angles(0, math.pi, 0) -- وجهي للخلف (نفس اتجاه الظهر)
            end)

        else
            StopBackpack()
            Notify("❌ نزلت من الظهر.", "❌ Got off the back.")
        end
    end)

    Tab:AddLine()
end
