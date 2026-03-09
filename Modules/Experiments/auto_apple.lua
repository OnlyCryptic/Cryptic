-- [[ Cryptic Hub - Auto Heal Apple / أكل التفاح المخفي عند الدمج ]]
-- المطور: يامي (Yami) | الميزة: أكل الأداة من الحقيبة بدون مسكها + فقط عند نقصان الدم

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local isActive = false

    -- دالة أكل التفاحة المخفية
    local function ConsumeAppleSecretly()
        -- 1. نبحث عن التفاحة في الحقيبة (Backpack) عشان ما يمسكها بيده
        local targetTool = nil
        for _, tool in pairs(lp.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "apple") or tool:FindFirstChild("Event")) then
                targetTool = tool
                break
            end
        end

        -- لو كان ماسكها بيده بالغلط، نلقاها هنا
        if not targetTool and lp.Character then
            for _, tool in pairs(lp.Character:GetChildren()) do
                if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "apple") or tool:FindFirstChild("Event")) then
                    targetTool = tool
                    break
                end
            end
        end

        -- 2. إذا لقينا التفاحة، نضرب الـ RemoteEvent بدون ما نجهزها
        if targetTool then
            local remoteEvent = targetTool:FindFirstChild("Event")
            
            if remoteEvent and remoteEvent:IsA("RemoteEvent") then
                pcall(function()
                    -- إرسال الإشارة للسيرفر إننا أكلناها (وهي لسه مخفية)
                    remoteEvent:FireServer()
                end)
            end
        end
    end

    -- زر التفعيل في الواجهة
    Tab:AddToggle("علاج تلقائي تفاح (مخفي) | Auto Heal Apple", function(state)
        isActive = state
        
        if state then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = "🍎 تم تفعيل العلاج المخفي | Auto Heal Enabled", Duration = 3
            })
            
            -- حلقة فحص الدم
            task.spawn(function()
                while isActive do
                    local char = lp.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    
                    -- الفحص الذكي: هل اللاعب عايش؟ وهل دمه ناقص؟
                    if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
                        -- إذا تدمج، ياكل التفاحة مخفي
                        ConsumeAppleSecretly()
                        task.wait(0.5) -- سرعة الأكل وقت الدمج (نص ثانية عشان يعبي بسرعة)
                    else
                        task.wait(0.1) -- إذا دمه فل، يفحص كل جزء من الثانية بدون ما يسوي شيء
                    end
                end
            end)
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = "❌ تم الإيقاف | Auto Heal Disabled", Duration = 3
            })
        end
    end)
    
    Tab:AddLine()
end
