-- [[ Cryptic Hub - Auto Apple / أكل التفاح التلقائي ]]
-- المطور: يامي (Yami) | الميزة: تجهيز التفاحة تلقائياً وأكلها باستخدام Activate والـ RemoteEvent

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local isActive = false

    -- دالة البحث عن التفاحة وأكلها
    local function ConsumeApple()
        local char = lp.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not char or not hum then return end

        -- 1. البحث عن التفاحة (في اليد أو الحقيبة)
        -- ملاحظة: يبحث عن أي أداة في اسمها كلمة Apple أو أداة داخلها RemoteEvent اسمه Event
        local targetTool = nil
        
        -- فحص اليد أولاً
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "apple") or tool:FindFirstChild("Event")) then
                targetTool = tool
                break
            end
        end

        -- فحص الحقيبة إذا مو باليد
        if not targetTool then
            for _, tool in pairs(lp.Backpack:GetChildren()) do
                if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "apple") or tool:FindFirstChild("Event")) then
                    targetTool = tool
                    break
                end
            end
        end

        -- 2. إذا لقينا التفاحة، نجهزها وناكلها
        if targetTool then
            -- تجهيزها باليد إذا كانت بالحقيبة
            if targetTool.Parent == lp.Backpack then
                hum:EquipTool(targetTool)
                task.wait(0.2) -- انتظار بسيط عشان السيرفر يستوعب المسكة
            end

            -- طريقة 1: محاكاة ضغطة الماوس (الطريقة الرسمية)
            targetTool:Activate()

            -- طريقة 2: ضرب الـ RemoteEvent اللي اكتشفناه في الكود حقك (كخطة بديلة قوية)
            local remoteEvent = targetTool:FindFirstChild("Event")
            if remoteEvent and remoteEvent:IsA("RemoteEvent") then
                pcall(function()
                    -- نرسل الإشارة للسيرفر (بعض المابات تطلب نص معين مثل "Eat" أو بدون نص)
                    remoteEvent:FireServer() 
                    remoteEvent:FireServer("Eat")
                end)
            end
        end
    end

    -- زر التفعيل في الواجهة
    Tab:AddToggle("أكل التفاح التلقائي | Auto Apple", function(state)
        isActive = state
        
        if state then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = "🍎 تم تفعيل الأكل التلقائي | Auto Apple Enabled", Duration = 3
            })
            
            -- حلقة التكرار (Loop) طول ما الزر شغال
            task.spawn(function()
                while isActive do
                    -- التأكد إن اللاعب عايش قبل ما ياكل
                    if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.Health > 0 then
                        ConsumeApple()
                    end
                    task.wait(1) -- السرعة (ياكل كل ثانية، تقدر تقللها لو تبي أسرع)
                end
            end)
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = "❌ تم الإيقاف | Auto Apple Disabled", Duration = 3
            })
        end
    end)
    
    Tab:AddLine()
end
