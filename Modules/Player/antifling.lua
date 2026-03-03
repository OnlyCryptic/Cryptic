-- [[ Cryptic Hub - ميزة مضاد الطيران (Anti-Fling) ]]
-- المطور: Cryptic | تجعلك تخترق اللاعبين لمنع التخريب

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    
    -- [[ دالة إرسال الإشعارات على شاشة اللعبة مباشرة ]]
    local function SendScreenNotify(title, text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
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
    Tab:AddToggle("مضاد التطيير / antifling", function(active)
        toggleAntiFling(active)
        
        -- إظهار الإشعار على الشاشة بناءً على حالة الزر
        if active then
            SendScreenNotify("Cryptic Hub", "تم تفعيل حماية الشبح (Anti-Fling) 🛡️")
        else
            SendScreenNotify("Cryptic Hub", "تم إيقاف الحماية 🛑")
        end
    end)
end
