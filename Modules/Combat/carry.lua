-- [[ Cryptic Hub - ميزة الرفع الذكي والمتزامن V3 ]]
-- المطور: Cryptic | التحديث: مزامنة حركة X/Z + رفع بطيء جداً

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isCarrying = false
    local liftHeight = 0
    local liftSpeed = 0.01 -- تقليل السرعة لتكون بطيئة جداً وواقعية

    -- 1. خانة البحث الذكي (نفس النظام المفضل لديك)
    local InputField = Tab:AddInput("البحث عن لاعب", "اكتب اليوزر وأغلق الكيبورد...", function() end)

    InputField.TextBox.FocusLost:Connect(function()
        local txt = InputField.TextBox.Text
        if txt == "" then _G.CrypticTarget = nil return end

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
            UI:Notify("🎯 تم قفل الهدف: " .. bestMatch.DisplayName)
        else
            _G.CrypticTarget = nil
            UI:Notify("❌ لاعب غير موجود")
        end
    end)

    -- 2. زر التفعيل
    Tab:AddToggle("🛌 رفع ذكي ومتزامن (Smart Carry)", function(active)
        isCarrying = active
        liftHeight = 0
        
        if active then
            if not _G.CrypticTarget or not _G.CrypticTarget.Character then
                isCarrying = false
                UI:Notify("⚠️ حدد لاعباً أولاً!")
                return
            end
            UI:Notify("🚀 بدأت المزامنة الذكية والرفع البطيء...")
        else
            UI:Notify("❌ توقف الرفع")
        end
    end)

    -- محرك المزامنة الفيزيائية (Smart Follow & Lift)
    runService.Heartbeat:Connect(function()
        if not isCarrying or not _G.CrypticTarget then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetChar = _G.CrypticTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            -- [[ تفعيل الحماية المطلقة لشخصيتك ]]
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false -- Noclip للوصول لتحت اللاعب
                    part.Velocity = Vector3.new(0, 0, 0) -- Anti-Fling لمنع الطيران المفاجئ
                    part.RotVelocity = Vector3.new(0, 0, 0)
                end
            end

            -- زيادة الارتفاع "ببطء شديد"
            liftHeight = liftHeight + liftSpeed
            
            -- [[ المزامنة الذكية ]]
            -- نأخذ إحداثيات اللاعب المستهدف (X و Z) لكي تتحرك معه أينما ذهب
            -- ونضيف الارتفاع المتزايد (Y) لكي تصعد به
            local tPos = targetRoot.Position
            root.CFrame = CFrame.new(tPos.X, tPos.Y - 3.5 + liftHeight, tPos.Z)

            -- [[ الرفع الحقيقي للجميع (FE) ]]
            -- إعطاء قوة دفع مستمرة لضمان أن السيرفر يرى الارتفاع
            targetRoot.Velocity = Vector3.new(targetRoot.Velocity.X, 10, targetRoot.Velocity.Z)
            root.Velocity = Vector3.new(0, 10, 0)

            -- تثبيت الهدف بوضعية النوم المتزامنة فوقك بالضبط
            targetRoot.CFrame = root.CFrame * CFrame.new(0, 3.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
        end
    end)
end
