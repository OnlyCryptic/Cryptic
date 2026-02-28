-- [[ Arwa Hub - ميزة الشيفت لوك للجوال ]]
-- المطور: Arwa | تجعل الكاميرا مثبتة خلف اللاعب للتحكم الاحترافي

return function(Tab, UI)
    local players = game:GetService("Players")
    local runService = game:GetService("RunService")
    local lp = players.LocalPlayer
    local camera = workspace.CurrentCamera
    
    local isShiftLock = false
    local connection = nil
    local offset = Vector3.new(1.7, 0.5, 0) -- إزاحة الكاميرا الجانبية الاحترافية

    local function toggleShiftLock(active)
        isShiftLock = active
        local char = lp.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if active and hum and root then
            UI:Notify("✅ تم تفعيل الشيفت لوك")
            
            -- حلقة التحديث لجعل الشخصية تدور مع الكاميرا
            connection = runService.RenderStepped:Connect(function()
                if isShiftLock and char and root and hum then
                    -- 1. جعل الكاميرا مائلة قليلاً لليمين (مثل الكمبيوتر)
                    hum.CameraOffset = hum.CameraOffset:Lerp(offset, 0.1)
                    
                    -- 2. إجبار الشخصية على النظر لنفس اتجاه الكاميرا أثناء الحركة
                    if hum.MoveDirection.Magnitude > 0 then
                        local lookVec = camera.CFrame.LookVector
                        root.CFrame = root.CFrame:Lerp(CFrame.new(root.Position, root.Position + Vector3.new(lookVec.X, 0, lookVec.Z)), 0.15)
                    end
                end
            end)
        else
            -- إرجاع الكاميرا لوضعها الطبيعي
            if connection then connection:Disconnect() end
            if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
            UI:Notify("❌ تم إيقاف الشيفت لوك")
        end
    end

    Tab:AddToggle("🔒 تشغيل الشيفت لوك (Shift Lock)", function(active)
        toggleShiftLock(active)
    end)
    
    Tab:AddParagraph("مفيد جداً في مابات الباركور والقتال لتوجيه الشخصية بدقة.")
end
