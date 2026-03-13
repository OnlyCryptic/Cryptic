-- [[ Cryptic Hub - ميزة ركوب الرأس (Head Sit) المطور ]]
-- المطور: يامي (Yami) | الميزات: نزول مباشر، إشعارات مزدوجة، جلوس دقيق وملاصق

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer
    
    local isSitting = false

    -- دالة الإشعارات المزدوجة (عربي/إنجليزي)
    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 5, 
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
                Notify(
                    "⚠️ حدد لاعباً أولاً من خانة البحث!",
                    "⚠️ Select a player first from the search box!"
                )
                return
            end

            if hum then 
                hum.Sit = true 
            end

            Notify(
                "🪑 تم الركوب! أنت الآن فوق رأس: " .. _G.ArwaTarget.DisplayName,
                "🪑 Sitting on: " .. _G.ArwaTarget.DisplayName
            )
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
            
            Notify(
                "❌ تم النزول في موقعك الحالي.",
                "❌ Got off at your current location."
            )
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

            -- الملاحقة على مسافة مقربة جداً ومضبوطة (1.6) ليكون الجلوس واقعياً على الأكتاف والرأس
            root.Velocity = Vector3.new(0, 0, 0)
            root.CFrame = targetHead.CFrame * CFrame.new(0, 1.9, 0)
        end
    end)
end
