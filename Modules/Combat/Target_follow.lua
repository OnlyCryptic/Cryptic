-- [[ Cryptic Hub - تتبع لاعب (Target Follow) ]]
-- يمشي خلف الهدف بشكل طبيعي واحترافي مع noclip + antifling + nofall + تعديل المسافة

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local isFollowing = false
    local followConn = nil
    local physicsConn = nil

    -- إعدادات التتبع
    local followDistance = 4 -- المسافة الافتراضية خلف الهدف

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = ar .. "\n" .. en,
                Duration = 3,
            })
        end)
    end

    local function StopFollow()
        isFollowing = false
        if followConn then followConn:Disconnect() followConn = nil end
        if physicsConn then physicsConn:Disconnect() physicsConn = nil end

        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum then
            hum:MoveTo(root and root.Position or Vector3.new(0,0,0))
        end
    end

    -- ==============================
    -- زر التتبع الرئيسي
    -- ==============================
    Tab:AddToggle("تتبع الهدف / Follow Target", function(active)
        if active then
            local target = _G.ArwaTarget
            if not target or not target.Character then
                Notify("⚠️ حدد لاعباً أولاً!", "⚠️ Select a player first!")
                StopFollow()
                return
            end

            isFollowing = true
            Notify(
                "🚶 يتتبع: " .. target.DisplayName .. " | مسافة: " .. followDistance,
                "🚶 Following: " .. target.DisplayName .. " | Distance: " .. followDistance
            )

            -- لوب الفيزياء: noclip + antifling + nofall
            physicsConn = RunService.Stepped:Connect(function()
                if not isFollowing then return end
                local char = lp.Character
                if not char then return end

                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")

                -- NoClip: إلغاء تصادم شخصيتي
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end

                -- AntiFling: إلغاء تصادم اللاعبين الثانيين
                for _, pl in pairs(Players:GetPlayers()) do
                    if pl ~= lp and pl.Character then
                        for _, p in pairs(pl.Character:GetChildren()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end

                -- NoFall: تثبيت سرعة السقوط
                if root then
                    local vel = root.AssemblyLinearVelocity
                    if vel.Y < -40 then
                        root.AssemblyLinearVelocity = Vector3.new(vel.X, -40, vel.Z)
                    end
                end
            end)

            -- لوب التتبع الذكي
            followConn = RunService.Heartbeat:Connect(function()
                if not isFollowing then return end

                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")

                local tgt = _G.ArwaTarget
                local tgtChar = tgt and tgt.Character
                local tgtRoot = tgtChar and tgtChar:FindFirstChild("HumanoidRootPart")

                if not root or not hum or not tgtRoot then return end
                if hum.Health <= 0 then return end

                -- حساب نقطة خلف الهدف بالمسافة المحددة
                local tgtCF = tgtRoot.CFrame
                local targetPos = tgtCF * CFrame.new(0, 0, followDistance)
                local distance = (root.Position - tgtRoot.Position).Magnitude

                if distance > followDistance + 0.5 then
                    -- تحريك طبيعي بـ MoveTo
                    hum:MoveTo(targetPos.Position)
                else
                    -- وصلنا، استنى في مكانك
                    hum:MoveTo(root.Position)
                end
            end)

        else
            StopFollow()
            Notify("❌ توقف التتبع.", "❌ Follow stopped.")
        end
    end)

    -- ==============================
    -- تحكم في المسافة
    -- ==============================
    Tab:AddSpeedControl("مسافة التتبع / Follow Distance", 1, 20, followDistance, function(val)
        followDistance = val
    end)

    Tab:AddLine()
end
