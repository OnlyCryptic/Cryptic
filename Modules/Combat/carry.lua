-- [[ Cryptic Hub - ميزة حمل اللاعبين V2 ]]
-- المطور: Cryptic | التحديث: استخدام TextBox لضمان الظهور

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isCarrying = false
    local targetName = ""
    local liftHeight = 0
    local liftSpeed = 0.1

    -- 1. إضافة صندوق كتابة لادخال اسم اللاعب
    Tab:AddTextBox("اكتب اسم اللاعب هنا", function(text)
        targetName = text
        UI:Notify("🎯 الهدف الحالي: " .. text)
    end)

    -- 2. زر التفعيل
    Tab:AddToggle("🛌 تفعيل حمل اللاعب (Carry)", function(active)
        isCarrying = active
        liftHeight = 0
        
        if active then
            -- البحث عن اللاعب بالاسم المكتوب
            local found = false
            for _, p in pairs(players:GetPlayers()) do
                if p.Name:lower():find(targetName:lower()) and p ~= lp then
                    targetName = p.Name
                    found = true
                    break
                end
            end

            if not found or targetName == "" then
                isCarrying = false
                UI:Notify("⚠️ لم يتم العثور على اللاعب! تأكد من الاسم")
                return
            end
            UI:Notify("✨ جاري حمل " .. targetName .. " ببطء...")
        else
            UI:Notify("❌ تم إيقاف الحمل")
        end
    end)

    -- المحرك الرئيسي للحركة
    runService.Heartbeat:Connect(function()
        if not isCarrying then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetPlr = players:FindFirstChild(targetName)
        local targetChar = targetPlr and targetPlr.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            -- تفعيل Noclip و Anti-Fling لشخصيتك
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Velocity = Vector3.new(0, 0, 0)
                end
            end

            liftHeight = liftHeight + liftSpeed
            local basePos = targetRoot.Position
            
            -- وضعيتك تحت الهدف والرفع التدريجي
            root.CFrame = CFrame.new(basePos.X, basePos.Y - 3 + liftHeight, basePos.Z)
            targetRoot.CFrame = root.CFrame * CFrame.new(0, 3, 0) * CFrame.Angles(math.rad(90), 0, 0)
            targetRoot.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end
