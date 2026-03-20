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

        -- التأكد أن اللاعب حي ودمه ناقص
        if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
            local apple = nil

            -- البحث عن التفاحة في الشخصية (إذا كانت في اليد)
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "apple") or tool:FindFirstChild("Event")) then
                    apple = tool
                    break
                end
            end

            -- البحث عن التفاحة في الحقيبة (Backpack) إذا لم تكن في اليد
            if not apple then
                for _, tool in pairs(lp.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "apple") or tool:FindFirstChild("Event")) then
                        apple = tool
                        break
                    end
                end
            end

            if apple then
                -- حفظ الأداة المجهزة حالياً عشان نرجعها بعد الأكل
                local currentEquipped = nil
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") and tool ~= apple then 
                        currentEquipped = tool
                        break 
                    end
                end

                -- مسك التفاحة
                if apple.Parent ~= char then
                    hum:EquipTool(apple)
                    task.wait(0.5)
                end

                -- تفعيل التفاحة (أكل)
                apple:Activate()
                task.wait(1.5) -- انتظار حتى يكتمل الأكل

                -- إرجاع الأداة اللي كانت بيدك أو إخفاء التفاحة
                if currentEquipped and currentEquipped.Parent == lp.Backpack then
                    hum:EquipTool(currentEquipped)
                else
                    hum:UnequipTools()
                end

                -- كول داون قبل ما يقدر يأكل تفاحة ثانية
                task.wait(8.1)
            end
        end
        isHealing = false
    end

    -- مثال لربط الكود مع الـ Toggle في واجهتك (تقدر تعدله حسب مكتبتك):
    -- Tab:CreateToggle({
    --    Name = "Auto Eat Apple",
    --    CurrentValue = false,
    --    Callback = function(Value)
    --        isActive = Value
    --        while isActive do
    --            task.wait(0.1)
    --            HealCycle()
    --        end
    --    end
    -- })
end
