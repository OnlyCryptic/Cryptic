-- [[ Cryptic Hub - ميزة قفل التصويب (Aim Bot) ]]
-- المطور: يامي (Yami) | الميزات: تثبيت الكاميرا والجسم، نظام شيفت لوك، إشعارات 25 ثانية

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer
    local camera = workspace.CurrentCamera
    
    local isAimbotting = false
    local shiftLockOffset = Vector3.new(1.7, 0.5, 0)

    -- دالة إشعارات روبلوكس الرسمية (مدة 25 ثانية)
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 10, 
            })
        end)
    end

    -- [[ زر التشغيل بالاسم الجديد ]]
    Tab:AddToggle("ايم بوت / Aim Bot", function(active)
        isAimbotting = active
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if active then
            -- التأكد من وجود هدف في خانة البحث
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                isAimbotting = false
                SendRobloxNotification("Cryptic Hub", "⚠️ حدد لاعباً أولاً من مربع البحث!")
                return
            end

            -- تفعيل إزاحة الكاميرا (نظام شيفت لوك)
            if hum then hum.CameraOffset = shiftLockOffset end
            SendRobloxNotification("Cryptic Hub", "🎯 تم تفعيل القفل القتالي على: " .. _G.ArwaTarget.DisplayName)
        else
            -- إرجاع الحالة الطبيعية وتنظيف المحركات
            if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
            
            if root then
                local gyro = root:FindFirstChild("CrypticGyro")
                if gyro then gyro:Destroy() end
            end
            
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف قفل التصويب.")
        end
    end)

    -- [[ المحرك البرمجي للقفل التلقائي ]]
    runService.RenderStepped:Connect(function()
        -- استخدام المتغير المرتبط بملف البحث الخاص بك
        local target = _G.ArwaTarget
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if isAimbotting and target and target.Character and target.Character:FindFirstChild("Head") then
            local targetHead = target.Character.Head
            
            -- 1. تثبيت الكاميرا فوراً على رأس الخصم
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetHead.Position)
            
            -- 2. تثبيت جسم اللاعب (Character Pin) ليواجه الخصم دائماً
            if root then
                local gyro = root:FindFirstChild("CrypticGyro") or Instance.new("BodyGyro", root)
                gyro.Name = "CrypticGyro"
                gyro.MaxTorque = Vector3.new(0, math.huge, 0) -- قفل الدوران الأفقي فقط
                gyro.P = 100000 -- قوة تثبيت جبارة
                gyro.D = 100
                
                -- إجبار الجسم على النظر للخصم مهما تحرك
                gyro.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetHead.Position.X, root.Position.Y, targetHead.Position.Z))
            end

            -- التأكد من بقاء إزاحة الكاميرا نشطة
            if hum and hum.CameraOffset ~= shiftLockOffset then
                hum.CameraOffset = shiftLockOffset
            end
        end
    end)
end
