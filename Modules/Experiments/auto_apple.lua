-- [[ Cryptic Hub - Auto Heal Apple / أكل التفاح السريع عند الدمج ]]
-- المطور: يامي (Yami) | الميزة: تبديل سريع جداً (Micro-Equip) لتخطي حماية السيرفر

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local isActive = false
    local isHealing = false -- عشان ما يتداخل الأكل مع بعضه

    local function FastConsumeApple()
        local char = lp.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not char or not hum then return end

        -- البحث عن التفاحة في الحقيبة
        local targetTool = nil
        for _, tool in pairs(lp.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "apple") or tool:FindFirstChild("Event")) then
                targetTool = tool
                break
            end
        end

        if targetTool then
            isHealing = true
            
            -- 1. حفظ الأداة اللي اللاعب ماسكها حالياً (عشان نرجعها له)
            local currentEquipped = char:FindFirstChildOfClass("Tool")
            
            -- 2. تجهيز التفاحة بسرعة
            hum:EquipTool(targetTool)
            
            -- انتظار بسيط جداً (عشان السيرفر يستوعب إن التفاحة صارت باليد)
            task.wait(0.05) 
            
            -- 3. تفعيل الأكل (كأنك ضغطت كليك)
            targetTool:Activate()
            
            -- انتظار بسيط عشان أمر الأكل يوصل للسيرفر ويزيد الدم
            task.wait(0.15) 
            
            -- 4. إرجاع الوضع كما كان (سحب التفاحة وإرجاع السلاح القديم لو كان موجود)
            if currentEquipped and currentEquipped.Parent == lp.Backpack then
                hum:EquipTool(currentEquipped)
            else
                hum:UnequipTools()
            end
            
            isHealing = false
        end
    end

    Tab:AddToggle("علاج تلقائي تفاح (سريع) | Auto Heal Apple", function(state)
        isActive = state
        
        if state then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = "🍎 تم تفعيل العلاج السريع | Fast Heal Enabled", Duration = 3
            })
            
            task.spawn(function()
                while isActive do
                    local char = lp.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    
                    if hum and hum.Health > 0 and hum.Health < hum.MaxHealth and not isHealing then
                        FastConsumeApple()
                        task.wait(0.2) -- وقت استراحة بين كل تفاحة وتفاحة
                    else
                        task.wait(0.1)
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
