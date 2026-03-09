-- [[ Cryptic Hub - Auto Heal Apple / أكل التفاح التلقائي ]]
-- المطور: يامي (Yami) | الميزة: تبديل سريع مع كول داون دقيق (8.1 ثواني)

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    
    local isActive = false
    local isHealing = false

    local function HealCycle()
        if isHealing then return end
        isHealing = true

        local char = lp.Character
        local hum = char and char:FindFirstChild("Humanoid")

        if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
            -- 1. البحث عن التفاحة (باليد أو الحقيبة)
            local apple = nil
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "apple") or tool:FindFirstChild("Event")) then
                    apple = tool; break
                end
            end
            if not apple then
                for _, tool in pairs(lp.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "apple") or tool:FindFirstChild("Event")) then
                        apple = tool; break
                    end
                end
            end

            if apple then
                -- 2. حفظ السلاح اللي بيدك عشان نرجعه لك بعدين
                local currentEquipped = nil
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") and tool ~= apple then 
                        currentEquipped = tool; break 
                    end
                end

                -- 3. مسك التفاحة
                if apple.Parent ~= char then
                    hum:EquipTool(apple)
                    task.wait(0.2) -- وقت عشان السيرفر يستوعب المسكة
                end

                -- 4. الضغط (الأكل)
                apple:Activate()
                task.wait(0.3) -- وقت عشان الأنيميشن حق الأكل يتسجل

                -- 5. إزالة التفاحة وإرجاع وضعك الطبيعي
                if currentEquipped and currentEquipped.Parent == lp.Backpack then
                    hum:EquipTool(currentEquipped)
                else
                    hum:UnequipTools()
                end

                -- 6. الانتظار الدقيق (الكول داون اللي طلبته)
                task.wait(8.1)
            end
        end
        
        -- السماح بدورة علاج جديدة لو الدم لسه ناقص
        isHealing = false
    end

    Tab:AddToggle("علاج تلقائي (تفاح) | Auto Heal Apple", function(state)
        isActive = state
        
        if state then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = "🍎 تم تفعيل العلاج (كول داون 8.1 ثواني)", Duration = 3
            })
            
            task.spawn(function()
                while isActive do
                    local char = lp.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    
                    -- يفحص الدم طول الوقت، وإذا ناقص يبدأ دورة العلاج
                    if hum and hum.Health > 0 and hum.Health < hum.MaxHealth and not isHealing then
                        HealCycle()
                    end
                    task.wait(0.1)
                end
            end)
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = "❌ تم الإيقاف", Duration = 3
            })
        end
    end)
    
    Tab:AddLine()
end
