-- [[ Cryptic Hub - التفاحة التلقائية / Auto Apple ]]
-- المطور: أروى (Arwa) | التحديث: أكل سريع بدون إظهار الأداة (تعبئة دم تلقائية)
-- Note: Smart tool manipulation for Natural Disaster Survival

return function(Tab, UI)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- [[ الإعدادات / Config ]]
    local Config = {
        Enabled = false,
        HealThreshold = 95 -- السكربت بياكل التفاحة إذا صار دمك أقل من هذا الرقم
    }

    -- دالة الإشعارات المزدوجة (للتفعيل فقط)
    local function Notify(ar, en)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub [Exp]",
                Text = ar .. "\n" .. en,
                Duration = 4
            })
        end)
    end

    -- زر التشغيل
    Tab:AddToggle("أكل التفاحة تلقائياً / Auto Apple", function(state)
        Config.Enabled = state
        
        if state then
            Notify("🍏 تم تفعيل الأكل التلقائي", "🍏 Auto Apple Activated")
        end
        -- إيقاف صامت بدون إزعاج
    end)

    -- [[ محرك الأكل الذكي ]]
    task.spawn(function()
        while task.wait(0.2) do -- فحص كل 0.2 ثانية
            if not Config.Enabled then continue end

            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local backpack = LocalPlayer:FindFirstChild("Backpack")

            -- التأكد أن اللاعب حي ودمه ناقص عن القيمة المحددة
            if hum and hum.Health > 0 and hum.Health < Config.HealThreshold and backpack then
                
                -- البحث عن التفاحة في الحقيبة أو في يد اللاعب
                local apple = backpack:FindFirstChild("Green Apple") or backpack:FindFirstChild("Apple") 
                           or char:FindFirstChild("Green Apple") or char:FindFirstChild("Apple")

                if apple then
                    -- الخدعة: تجهيز الأداة، تفعيلها، ثم إخفاؤها فوراً
                    if apple.Parent == backpack then
                        hum:EquipTool(apple) -- سحب التفاحة
                    end
                    
                    apple:Activate() -- محاكاة ضغطة الشاشة للأكل
                    
                    -- إرجاعها فوراً للحقيبة عشان ما تبين بيدك
                    task.delay(0.05, function()
                        if apple.Parent == char then
                            apple.Parent = backpack
                        end
                    end)
                end
            end
        end
    end)
end
