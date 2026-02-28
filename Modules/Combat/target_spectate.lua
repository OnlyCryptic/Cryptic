-- [[ Arwa Hub - ميزة مراقبة الهدف (Spectate) ]]
-- المطور: Arwa | الميزات: تتبع تلقائي، عودة سريعة للكاميرا

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    
    local isSpectating = false

    Tab:AddToggle("👁️ مراقبة الهدف (Spectate)", function(active)
        isSpectating = active
        if active then
            if _G.ArwaTarget then
                UI:Notify("👁️ جاري مراقبة: " .. _G.ArwaTarget.DisplayName)
            else
                UI:Notify("⚠️ حدد لاعباً أولاً!")
            end
        else
            -- إرجاع الكاميرا لشخصيتكِ فوراً عند الإيقاف
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = lp.Character.Humanoid
                UI:Notify("❌ توقفت المراقبة")
            end
        end
    end)

    -- حلقة التتبع لضمان بقاء الكاميرا مع الهدف حتى لو مات أو تغير
    runService.RenderStepped:Connect(function()
        if isSpectating then
            local target = _G.ArwaTarget
            if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                -- قفل الكاميرا على الشخصية المستهدفة
                camera.CameraSubject = target.Character.Humanoid
            else
                -- إذا اختفى الهدف، تعود الكاميرا لكِ تلقائياً لتجنب تعليق الرؤية
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    camera.CameraSubject = lp.Character.Humanoid
                end
            end
        end
    end)
end
