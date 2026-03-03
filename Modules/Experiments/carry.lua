-- [[ Cryptic Hub - المصعد الفيزيائي ]]
-- المطور: يامي (Yami) | التحديث: تيلبورت سفلي + رفع بطيء وسلس + Noclip & Anti-Fling

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    
    local isCarrying = false
    local currentTarget = nil
    local liftConnection = nil

    -- 1. خانة البحث الذكية
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

    -- 2. زر تشغيل المصعد المرعب
    Tab:AddToggle("تشغيل المصعد 🚀", function(state)
        isCarrying = state
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if isCarrying then
            if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
                UI:Notify("⚠️ الرجاء تحديد لاعب موجود أولاً!")
                isCarrying = false
                return
            end
            
            local targetRoot = currentTarget.Character.HumanoidRootPart
            
            -- تفعيل وضعية الإغماء
            if hum then hum.PlatformStand = true end 
            
            -- [[ التيلبورت المباشر: تحت الهدف بـ 4 خطوات ومستلقي على الظهر ]]
            if root then
                root.CFrame = CFrame.new(targetRoot.Position.X, targetRoot.Position.Y - 4, targetRoot.Position.Z) * CFrame.Angles(math.rad(-90), 0, 0)
            end
            
            UI:Notify("🚀 جاري رفع الهدف ببطء...")
            
            -- حلقة الرفع الفيزيائية
            liftConnection = RunService.Heartbeat:Connect(function()
                if not isCarrying or not currentTarget or not currentTarget.Character then return end
                
                local tChar = currentTarget.Character
                local tRoot = tChar:FindFirstChild("HumanoidRootPart")

                if root and tRoot then
                    -- [[ تفعيل Noclip ]]
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            -- نخلي الجذع صلب بس عشان يقدر يرفع الهدف
                            part.CanCollide = (part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso")
                        end
                    end
                    
                    -- [[ الرفع السلس والمغناطيس ]]
                    -- 1. نعطي الشخصية سرعة رفع بطيئة جداً (شوي بشوي)
                    root.Velocity = Vector3.new(0, 6, 0) 
                    
                    -- 2. تفعيل Anti-Fling لضمان عدم الطيران العشوائي
                    root.RotVelocity = Vector3.zero 
                    
                    -- 3. مطابقة موقعك مع X و Z للهدف (عشان ما يطيح منك)، ونخلي Y يرتفع براحته مع الـ Velocity
                    root.CFrame = CFrame.new(tRoot.Position.X, root.Position.Y, tRoot.Position.Z) * CFrame.Angles(math.rad(-90), 0, 0)
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
