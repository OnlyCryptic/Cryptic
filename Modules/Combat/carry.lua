-- [[ Cryptic Hub - خدعة حمل اللاعبين المحدثة ]]
-- المطور: Cryptic | التحديث: إضافة قائمة اختيار اللاعبين + تحديث تلقائي

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isCarrying = false
    local selectedPlayerName = ""
    local liftHeight = 0
    local liftSpeed = 0.1 -- سرعة الرفع البطيء

    -- وظيفة لجلب قائمة الأسماء الحالية في السيرفر
    local function getPlayerNames()
        local names = {}
        for _, p in pairs(players:GetPlayers()) do
            if p ~= lp then
                table.insert(names, p.Name)
            end
        end
        return names
    end

    -- 1. إضافة قائمة منسدلة لاختيار اللاعب
    local playerDropdown = Tab:AddDropdown("اختر اللاعب المراد حمله", getPlayerNames(), function(val)
        selectedPlayerName = val
        UI:Notify("🎯 تم تحديد الهدف: " .. val)
    end)

    -- 2. زر لتحديث قائمة اللاعبين يدوياً (اختياري)
    Tab:AddButton("🔄 تحديث قائمة الأسماء", function()
        playerDropdown:Refresh(getPlayerNames())
        UI:Notify("✅ تم تحديث قائمة اللاعبين")
    end)

    -- 3. زر تفعيل ميزة الحمل
    Tab:AddToggle("🛌 تفعيل حمل اللاعب (Carry)", function(active)
        isCarrying = active
        liftHeight = 0
        
        if active then
            if selectedPlayerName == "" or not players:FindFirstChild(selectedPlayerName) then
                isCarrying = false
                UI:Notify("⚠️ الرجاء اختيار لاعب من القائمة أولاً!")
                return
            end
            UI:Notify("✨ جاري حمل " .. selectedPlayerName .. " ورفعه ببطء...")
        else
            UI:Notify("❌ تم إيقاف عملية الحمل")
        end
    end)

    -- المحرك البرمجي للحركة
    runService.Heartbeat:Connect(function()
        if not isCarrying then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetPlr = players:FindFirstChild(selectedPlayerName)
        local targetChar = targetPlr and targetPlr.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            -- تفعيل Noclip و Anti-Fling لشخصيتك لضمان السلاسة
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Velocity = Vector3.new(0, 0, 0)
                end
            end

            -- زيادة الارتفاع ببطء (تأثير الطيران السحري)
            liftHeight = liftHeight + liftSpeed
            
            -- تثبيت موقعك تحت الهدف مباشرة
            local basePos = targetRoot.Position
            root.CFrame = CFrame.new(basePos.X, basePos.Y - 3 + liftHeight, basePos.Z)

            -- تثبيت الخصم بوضعية "النوم" فوقك
            targetRoot.CFrame = root.CFrame * CFrame.new(0, 3, 0) * CFrame.Angles(math.rad(90), 0, 0)
            targetRoot.Velocity = Vector3.new(0, 0, 0)
        end
    end)

    -- تحديث القائمة تلقائياً عند دخول لاعب جديد
    players.PlayerAdded:Connect(function()
        playerDropdown:Refresh(getPlayerNames())
    end)
    
    players.PlayerRemoving:Connect(function()
        playerDropdown:Refresh(getPlayerNames())
    end)
end
