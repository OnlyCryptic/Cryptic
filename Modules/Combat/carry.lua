-- [[ Cryptic Hub - ميزة حمل اللاعبين ]]
-- المطور: Cryptic | التحديث: التوافق مع AddInput الخاص بالواجهة

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isCarrying = false
    local targetName = ""
    local liftHeight = 0
    local liftSpeed = 0.1 -- سرعة الرفع البطيء

    -- 1. إضافة مربع الإدخال (يجب استخدامه لأنه المدعوم في ملف الـ UI الخاص بك)
    Tab:AddInput("اسم اللاعب المستهدف", "اكتب الاسم هنا...", function(text)
        targetName = text
    end)

    -- 2. زر التفعيل
    Tab:AddToggle("🛌 حمل اللاعب (Carry)", function(active)
        isCarrying = active
        liftHeight = 0
        
        if active then
            -- البحث عن اللاعب بالاسم المكتوب
            local foundPlayer = nil
            for _, p in pairs(players:GetPlayers()) do
                if p.Name:lower():find(targetName:lower()) and p ~= lp then
                    foundPlayer = p
                    targetName = p.Name -- تحديث الاسم بالكامل
                    break
                end
            end

            if not foundPlayer or targetName == "" then
                isCarrying = false
                UI:Notify("⚠️ لم يتم العثور على اللاعب! تأكد من كتابة الاسم")
                return
            end
            UI:Notify("✨ جاري حمل " .. targetName .. " ورفعه ببطء...")
        else
            UI:Notify("❌ تم إيقاف عملية الحمل")
        end
    end)

    -- المحرك البرمجي للحركة
    runService.Heartbeat:Connect(function()
        if not isCarrying then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetPlr = players:FindFirstChild(targetName)
        local targetChar = targetPlr and targetPlr.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            -- تفعيل Noclip و Anti-Fling لشخصيتك لضمان السلاسة على Redmi Note 10s
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Velocity = Vector3.new(0, 0, 0)
                end
            end

            -- تأثير الرفع التدريجي
            liftHeight = liftHeight + liftSpeed
            
            -- وضع شخصيتك تحت الهدف والرفع
            local basePos = targetRoot.Position
            root.CFrame = CFrame.new(basePos.X, basePos.Y - 3 + liftHeight, basePos.Z)

            -- جعل الخصم بوضعية النوم فوقك
            targetRoot.CFrame = root.CFrame * CFrame.new(0, 3, 0) * CFrame.Angles(math.rad(90), 0, 0)
            targetRoot.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end
