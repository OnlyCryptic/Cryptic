-- [[ Cryptic Hub - المصعد الفيزيائي (نظام Toggle) ]]
-- المطور: Cryptic | التحديث: تحويله لزر تشغيل عادي مستمر (مثل Wall Walk)

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isCarrying = false
    local liftHeight = -7
    local liftSpeed = 0.05 
    local hbConnection = nil

    -- 1. خانة البحث عن اللاعب
    local InputField = Tab:AddInput("حدد الهدف 🎯", "اكتب اسم اللاعب هنا...", function() end)

    -- ربط البحث بصندوق النص
    task.spawn(function()
        repeat task.wait() until InputField and InputField.TextBox
        InputField.TextBox.FocusLost:Connect(function()
            local txt = InputField.TextBox.Text
            if txt == "" then _G.CrypticTarget = nil return end
            
            local search = txt:lower()
            local bestMatch = nil
            for _, p in pairs(players:GetPlayers()) do
                if p ~= lp and (p.Name:lower():sub(1, #search) == search or p.DisplayName:lower():sub(1, #search) == search) then
                    bestMatch = p
                    break 
                end
            end

            if bestMatch then
                _G.CrypticTarget = bestMatch
                InputField.SetText(bestMatch.DisplayName)
                UI:Notify("🎯 تم تحديد: " .. bestMatch.DisplayName)
            else
                _G.CrypticTarget = nil
                UI:Notify("❌ لاعب غير موجود")
            end
        end)
    end)

    -- 2. زر التشغيل (Toggle عادي مثل Wall Walk)
    Tab:AddToggle("تشغيل المصعد الفيزيائي", function(state)
        isCarrying = state
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if isCarrying then
            -- التحقق من وجود هدف
            if not _G.CrypticTarget or not _G.CrypticTarget.Character then
                isCarrying = false
                UI:Notify("⚠️ حدد لاعباً أولاً!")
                -- محاولة إطفاء الزر شكلياً إذا لزم الأمر (اختياري)
                return
            end
            
            liftHeight = -7 -- إعادة التصفير للبداية من تحت الأرض
            if hum then hum.PlatformStand = true end
            if root then root.Anchored = true end
        else
            -- إرجاع الشخصية لوضعها الطبيعي فور الإيقاف
            if hum then hum.PlatformStand = false end
            if root then 
                root.Anchored = false 
                root.Velocity = Vector3.new(0,0,0)
                root.RotVelocity = Vector3.new(0,0,0)
            end
        end
    end)

    -- 3. المحرك الموحد (Heartbeat)
    runService.Heartbeat:Connect(function()
        if not isCarrying or not _G.CrypticTarget or not _G.CrypticTarget.Character then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetRoot = _G.CrypticTarget.Character:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            -- نفاذية الأطراف وقوة الدفع
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = (part.Name == "HumanoidRootPart" or part.Name:find("Torso"))
                    part.Velocity = Vector3.new(0, 35, 0)
                end
            end

            -- الصعود التدريجي
            if liftHeight < 5 then liftHeight = liftHeight + liftSpeed end
            
            -- التثبيت تحت الهدف بوضعية النوم
            root.CFrame = CFrame.new(targetRoot.Position.X, targetRoot.Position.Y + liftHeight, targetRoot.Position.Z) * CFrame.Angles(math.rad(90), 0, 0)
            root.RotVelocity = Vector3.new(0,0,0)
        end
    end)
end
