-- [[ Cryptic Hub - ميزة حمل اللاعبين الاحترافية ]]
-- المطور: Cryptic | الميزات: بحث ذكي، رفع حقيقي (FE)، تحديث تلقائي للأسماء

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isCarrying = false
    local liftHeight = 0
    local liftSpeed = 0.05 -- سرعة الرفع البطيئة جداً لتظهر بشكل حقيقي

    -- 1. خانة البحث بنظام البحث الذكي المطور
    local InputField = Tab:AddInput("البحث عن لاعب", "اكتب بداية اليوزر وأغلق الكيبورد...", function() end)

    InputField.TextBox.FocusLost:Connect(function()
        local txt = InputField.TextBox.Text
        if txt == "" then 
            _G.CrypticTarget = nil
            return 
        end

        local bestMatch = nil
        local search = txt:lower()

        for _, p in pairs(players:GetPlayers()) do
            -- نظام البحث الذكي (مطابقة بداية الاسم)
            if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then
                bestMatch = p
                break 
            end
        end

        if bestMatch then
            _G.CrypticTarget = bestMatch
            -- تحديث نص الخانة ليظهر الاسم الكامل والاسم المستعار
            InputField.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")
            UI:Notify("🎯 تم تحديد الهدف: " .. bestMatch.DisplayName)
        else
            _G.CrypticTarget = nil
            UI:Notify("❌ لم يتم العثور على اللاعب")
        end
    end)

    -- 2. زر تفعيل ميزة الحمل والرفع الحقيقي
    Tab:AddToggle("🛌 تفعيل الرفع الحقيقي (Carry)", function(active)
        isCarrying = active
        liftHeight = 0
        
        if active then
            if not _G.CrypticTarget then
                isCarrying = false
                UI:Notify("⚠️ يجب تحديد لاعب من خانة البحث أولاً!")
                return
            end
            UI:Notify("✨ جاري البدء في الرفع الحقيقي لـ " .. _G.CrypticTarget.DisplayName)
        else
            UI:Notify("❌ تم إيقاف الرفع")
        end
    end)

    -- المحرك البرمجي للرفع الفيزيائي (Real Physics Lift)
    runService.Heartbeat:Connect(function()
        if not isCarrying or not _G.CrypticTarget then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetChar = _G.CrypticTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            -- تفعيل Noclip و Anti-Fling لضمان ثبات العملية
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end

            -- زيادة الارتفاع ببطء شديد (الرفع الحقيقي)
            liftHeight = liftHeight + liftSpeed
            
            -- لكي يظهر الرفع للآخرين (FE)، نستخدم الـ Velocity مع الـ CFrame
            local targetPos = targetRoot.Position
            
            -- وضع شخصيتك تحت اللاعب المستهدف بالضبط لكي تبدو كأنها تحمله
            root.CFrame = CFrame.new(targetPos.X, targetPos.Y - 3.5 + liftHeight, targetPos.Z)
            root.Velocity = Vector3.new(0, 5, 0) -- دفع خفيف للأعلى لضمان المزامنة

            -- تثبيت اللاعب المستهدف فوقك بوضعية "النوم"
            targetRoot.CFrame = root.CFrame * CFrame.new(0, 3.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
            
            -- إعطاء اللاعب المستهدف سرعة للأعلى لكي يراه الجميع وهو يرتفع
            targetRoot.Velocity = Vector3.new(0, 10, 0) 
        end
    end)
end
