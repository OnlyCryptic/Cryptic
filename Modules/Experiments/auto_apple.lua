-- [[ Cryptic Hub - Auto Heal Apple / أكل التفاح التلقائي ]]
-- المطور: يامي (Yami) | الميزة: مسك، أكل (بانتظار مناسب)، إخفاء، وكول داون 8.1 ثواني

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
            -- 1. البحث عن التفاحة
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
                -- 2. حفظ سلاحك الحالي
                local currentEquipped = nil
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") and tool ~= apple then 
                        currentEquipped = tool; break 
                    end
                end

                -- 3. مسك التفاحة
                if apple.Parent ~= char then
                    hum:EquipTool(apple)
                    task.wait(0.5) -- زدت الوقت شوي عشان السيرفر يؤكد المسكة
                end

                -- 4. الضغط للأكل
                apple:Activate()
                
                -- السر هنا: لازم ننتظر التفاحة بيدك شوي عشان يكتمل الأكل وما ينلغي
                task.wait(1.5) 

                -- 5. إخفاء التفاحة وإرجاع سلاحك
                if currentEquipped and currentEquipped.Parent == lp.Backpack then
                    hum:EquipTool(currentEquipped)
                else
                    hum:UnequipTools()
                end

                -- 6. الكول داون الدقيق بعد ما خلصنا (8.1 ثواني)
                task.wait(8.1)
            end
        end
        
        isHealing = false
    end

    Tab:AddToggle("علاج تلقائي (تفاح) | Auto Heal Apple", function(state)
        isActive = state
        
        if state then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = "🍎 تم تفعيل العلاج", Duration = 3
            })
            
            task.spawn(function()
                while isActive do
                    local char = lp.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    
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
