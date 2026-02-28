-- [[ Arwa Hub - ميزة مضاد الطيران (Anti-Fling) ]]
-- المطور: Arwa | تجعلك تخترقين اللاعبين لمنع التخريب

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    
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
                    -- التأكد أنه ليس أنتِ، وأن لديه شخصية
                    if otherPlayer ~= lp and otherPlayer.Character then
                        -- نستخدم GetChildren بدلاً من GetDescendants لتخفيف الضغط على الجوال
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
    Tab:AddToggle("مضاد التطيير", function(active)
        toggleAntiFling(active)
        UI:Notify(active and "تم تفعيل حماية الشبح (Anti-Fling) 🛡️" or "تم إيقاف الحماية")
    end)
    
    -- إضافة وصف صغير تحت الزر للتوضيح
    Tab:AddParagraph("هذه الميزة تجعلكِ تخترقين اللاعبين لمنعهم من تطييرك خارج الماب.")
end
