-- [[ Cryptic Hub - المصعد الفيزيائي (الرفع المرعب) ]]
-- المطور: يامي (Yami) | التحديث: Noclip + Anti-Fling + وضعية الاستلقاء والنظر للأعلى

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    
    local isCarrying = false
    local liftHeight = -6 -- البداية من تحت الأرض بمسافة ممتازة
    local liftSpeed = 0.03 -- سرعة بطيئة جداً (شوي بشوي)
    local currentTarget = nil
    local liftConnection = nil

    -- 1. خانة البحث الذكية (تعمل عند إغلاق الكيبورد)
    local InputField = Tab:AddInput("البحث عن لاعب 🎯", "اكتب بداية اليوزر وأغلق الكيبورد...", function() end)

    task.spawn(function()
        repeat task.wait() until InputField and InputField.TextBox
        
        InputField.TextBox.FocusLost:Connect(function()
            local txt = InputField.TextBox.Text
            if txt == "" then 
                currentTarget = nil
                return 
            end

            local bestMatch = nil
            local search = txt:lower()

            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then
                    bestMatch = p
                    break 
                end
            end

            if bestMatch then
                currentTarget = bestMatch
                InputField.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")
                UI:Notify("🎯 تم تحديد الهدف: " .. bestMatch.DisplayName)
            else
                currentTarget = nil
                UI:Notify("❌ لم يتم العثور على لاعب")
            end
        end)
    end)

    Tab:AddLine()

    -- 2. زر تشغيل المصعد
    Tab:AddToggle("تشغيل المصعد 🚀", function(state)
        isCarrying = state
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if isCarrying then
            if not currentTarget or not currentTarget.Character then
                UI:Notify("⚠️ الرجاء تحديد لاعب موجود أولاً!")
                isCarrying = false
                return
            end
            
            liftHeight = -6 -- تصفير المسافة للبداية من تحت الأرض
            if hum then hum.PlatformStand = true end -- وضعية الإغماء/النوم
            
            UI:Notify("🚀 جاري رفع: " .. currentTarget.DisplayName .. " (ببطء)")
            
            -- تشغيل حلقة الرفع الفيزيائية (المرعبة)
            liftConnection = RunService.Heartbeat:Connect(function()
                if not isCarrying or not currentTarget or not currentTarget.Character then return end
                
                local tChar = currentTarget.Character
                local tRoot = tChar:FindFirstChild("HumanoidRootPart")

                if root and tRoot then
                    -- [[ تفعيل Anti-Fling و Noclip ]]
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            -- Noclip كامل باستثناء الجذع لضمان رفع الهدف وعدم التعليق في الأرض
                            part.CanCollide = (part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso")
                            
                            -- قوة رفع هادئة + حماية من الطيران العشوائي
                            part.Velocity = Vector3.new(0, 10, 0)
                            part.RotVelocity = Vector3.zero -- Anti-Fling أساسي
                        end
                    end
                    
                    -- تأكيد الـ Anti-Fling على الـ Root (أهم قطعة)
                    root.RotVelocity = Vector3.zero

                    -- الرفع شوي بشوي (حد أقصى 5 خطوات فوق الهدف)
                    if liftHeight < 5 then 
                        liftHeight = liftHeight + liftSpeed 
                    end
                    
                    -- [[ وضعية النوم وتشوف لفوق من تحت الأرض ]]
                    -- CFrame.Angles(math.rad(-90), 0, 0) يجعلك مستلقياً على ظهرك ووجهك للسماء
                    root.CFrame = CFrame.new(tRoot.Position.X, tRoot.Position.Y + liftHeight, tRoot.Position.Z) * CFrame.Angles(math.rad(-90), 0, 0)
                end
            end)

        else
            -- الإيقاف وإرجاع الطبيعة
            if liftConnection then
                liftConnection:Disconnect()
                liftConnection = nil
            end
            
            if hum then hum.PlatformStand = false end
            if root then 
                root.Velocity = Vector3.zero
                root.RotVelocity = Vector3.zero
            end
            UI:Notify("🛑 تم إيقاف المصعد")
        end
    end)
end
