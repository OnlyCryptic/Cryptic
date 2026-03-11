-- [[ Cryptic Hub - ميزة مضاد الطيران (Anti-Fling) ]]
-- المطور: يامي (Yami) | تجعلك تخترق اللاعبين لمنع التخريب

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    
    -- [[ دالة إرسال الإشعارات المزدوجة (عربي/إنجليزي) ]]
    local function Notify(arText, enText)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 3 -- مدة بقاء الإشعار على الشاشة (3 ثواني)
            })
        end)
    end
    
    local isAntiFling = false
    local connection

    local function toggleAntiFling(active)
        isAntiFling = active
        
        if isAntiFling then
            -- نستخدم Stepped لأنه ينفذ قبل حساب الفيزياء في اللعبة
            connection = RunService.Stepped:Connect(function()
                if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
                
                -- المرور على كل اللاعبين في السيرفر
                for _, otherPlayer in pairs(Players:GetPlayers()) do
                    -- التأكد أنه ليس أنت، وأن لديه شخصية
                    if otherPlayer ~= lp and otherPlayer.Character then
                        -- نستخدم GetChildren بدلاً من GetDescendants لتخفيف الضغط
                        for _, part in pairs(otherPlayer.Character:GetChildren()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                -- إغلاق التصادم محلياً (على شاشتك فقط)
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        else
            -- إيقاف الميزة لتوفير موارد الهاتف
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end

    -- إضافة زر التبديل للواجهة
    Tab:AddToggle("مضاد التطيير / Anti-Fling", function(active)
        toggleAntiFling(active)
        
        -- إظهار الإشعار المزدوج على الشاشة عند التفعيل فقط
        if active then
            Notify(
                "🛡️ تم تفعيل حماية الشبح (Anti-Fling)",
                "🛡️ Anti-Fling activated"
            )
        end
        -- إذا تم إيقاف الميزة (active = false) لن يظهر أي إشعار وتنطفئ بصمت
    end)
end
