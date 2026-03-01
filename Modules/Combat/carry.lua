-- [[ Cryptic Hub - ميزة حمل اللاعبين الحقيقية ]]
-- المطور: Cryptic | الميزات: رفع فيزيائي حقيقي، Noclip، Anti-Fling، مزامنة كاملة

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isCarrying = false
    local liftHeight = 0
    local liftSpeed = 0.03 -- سرعة الرفع (بطيئة جداً كما طلبت لتكون واقعية)

    -- 1. خانة البحث الذكي (تحديث الاسم بالكامل عند إغلاق الكيبورد)
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
            if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then
                bestMatch = p
                break 
            end
        end

        if bestMatch then
            _G.CrypticTarget = bestMatch
            InputField.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")
            UI:Notify("🎯 تم تحديد الهدف للرفع الحقيقي: " .. bestMatch.DisplayName)
        else
            _G.CrypticTarget = nil
            UI:Notify("❌ لم يتم العثور على اللاعب")
        end
    end)

    -- 2. زر تفعيل الرفع الحقيقي
    Tab:AddToggle("تست", function(active)
        isCarrying = active
        liftHeight = 0
        
        if active then
            if not _G.CrypticTarget or not _G.CrypticTarget.Character then
                isCarrying = false
                UI:Notify("⚠️ حدد لاعباً أولاً!")
                return
            end
            UI:Notify("✨ بدأت شخصيتك في رفع " .. _G.CrypticTarget.DisplayName .. " ببطء...")
        else
            UI:Notify("❌ توقف الرفع")
        end
    end)

    -- المحرك الفيزيائي (مزامنة شخصيتك مع الهدف)
    runService.Heartbeat:Connect(function()
        if not isCarrying or not _G.CrypticTarget then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetChar = _G.CrypticTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            -- [[ تفعيل Noclip و Anti-Fling لشخصيتك الأصلية ]]
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false -- Noclip
                    part.Velocity = Vector3.new(0, 0, 0) -- Anti-Fling
                    part.RotVelocity = Vector3.new(0, 0, 0)
                end
            end

            -- زيادة الارتفاع تدريجياً
            liftHeight = liftHeight + liftSpeed
            
            -- [[ الرفع الحقيقي ]]
            -- 1. جعل شخصيتك تذهب "تحت" الهدف بالضبط
            local targetPos = targetRoot.Position
            root.CFrame = CFrame.new(targetPos.X, targetPos.Y - 3.5 + liftHeight, targetPos.Z)
            
            -- 2. إعطاء قوة دفع للأعلى للهدف ولشخصيتك لضمان أن السيرفر يرى الرفع (FE)
            targetRoot.Velocity = Vector3.new(0, 10, 0) 
            root.Velocity = Vector3.new(0, 10, 0)

            -- 3. تثبيت الهدف فوقك بوضعية "النوم" (90 درجة)
            targetRoot.CFrame = root.CFrame * CFrame.new(0, 3.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
        end
    end)
end
