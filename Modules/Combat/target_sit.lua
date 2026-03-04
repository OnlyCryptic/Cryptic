-- [[ Cryptic Hub - ميزة ركوب الرأس (Head Sit) المطور ]]
-- المطور: يامي (Yami) | الميزات: نزول مباشر في نفس المكان، Anti-Fling، ثبات عالي

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer
    
    local isSitting = false

    -- دالة إشعارات روبلوكس الرسمية
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 15, 
            })
        end)
    end

    -- [[ زر التفعيل ]]
    Tab:AddToggle("ركوب الرأس / Head Sit", function(active)
        isSitting = active
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if active then
            -- التأكد من وجود هدف (استخدام المتغير المرتبط بملف البحث الخاص بك)
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                isSitting = false
                if hum then hum.Sit = false end
                SendRobloxNotification("Cryptic Hub", "⚠️ حدد لاعباً أولاً من خانة البحث!")
                return
            end

            if hum then 
                hum.Sit = true 
            end

            SendRobloxNotification("Cryptic Hub", "🪑 تم الركوب! أنت الآن فوق رأس: " .. _G.ArwaTarget.DisplayName)
        else
            -- [[ النزول في نفس المكان مع تنظيف الفيزياء ]]
            if char and root then
                if hum then hum.Sit = false end
                
                -- تصفير السرعة اللحظية لضمان نزول مستقر بدون "قلتش"
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)

                -- إرجاع الخصائص الطبيعية للجسم
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Massless = false
                        part.CanCollide = true
                    end
                end
            end
            SendRobloxNotification("Cryptic Hub", "❌ تم النزول في موقعك الحالي.")
        end
    end)

    -- [[ المحرك الفيزيائي للملاحقة الدقيقة ]]
    runService.Heartbeat:Connect(function()
        if not isSitting or not _G.ArwaTarget then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local targetChar = _G.ArwaTarget.Character
        local targetHead = targetChar and targetChar:FindFirstChild("Head")

        if root and targetHead and hum then
            hum.Sit = true
            
            -- نظام Anti-Fling مستمر أثناء الركوب
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Massless = true
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.RotVelocity = Vector3.new(0, 0, 0)
                end
            end

            -- الملاحقة على مسافة مقربة (2.4)
            local targetVel = targetHead.Velocity
            root.Velocity = Vector3.new(0, 0, 0)
            
            -- الالتصاق فوق الرأس
            root.CFrame = (targetHead.CFrame * CFrame.new(0, 2.4, 0)) + (targetVel * 0.05)
        end
    end)
end
