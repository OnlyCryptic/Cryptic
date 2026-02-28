-- [[ Arwa Hub - ميزة تطيير الهدف (Fling) ]]
-- المطور: Arwa | الميزات: تطيير موجه، إيقاف التصادم تلقائياً

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    local isFlinging = false

    Tab:AddToggle("🌪️ تطيير الهدف", function(active)
        isFlinging = active
        if active then
            if _G.ArwaTarget then
                UI:Notify("🔥 جاري تطيير: " .. _G.ArwaTarget.DisplayName)
            else
                UI:Notify("⚠️ حدد لاعباً أولاً!")
            end
        else
            UI:Notify("❌ توقف وضع التطيير")
        end
    end)

    runService.Heartbeat:Connect(function()
        local target = _G.ArwaTarget
        if isFlinging and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = target.Character.HumanoidRootPart
            local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")

            if root and hum then
                -- 1. إلغاء التصادم لكي لا تتطيري أنتِ مع الخصم
                for _, part in pairs(lp.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end

                -- 2. الانتقال السريع لموقع الخصم مع تطبيق قوة دوران هائلة
                root.Velocity = Vector3.new(0, 50, 0) -- رفعة بسيطة
                root.RotVelocity = Vector3.new(0, 15000, 0) -- دوران مغزلي خارق
                
                -- الالتصاق بالخصم لتأكيد التطيير
                root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 0)
            end
        end
    end)
end
