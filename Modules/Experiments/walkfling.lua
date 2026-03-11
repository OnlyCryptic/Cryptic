-- [[ Cryptic Hub - The Ultimate Walk Fling (Tank Mode) ]]
return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local flingLoop = nil
    local bav = nil

    Tab:AddToggle("Walk Fling / .الدفع بالمشي", function(state)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if state then
            if not hrp or not hum then return end
            
            -- 1. تشغيل الدوران (قوة 10000 كافية جدا ومستقرة أكثر من 50000)
            bav = Instance.new("BodyAngularVelocity")
            bav.Name = "CrypticFling"
            bav.AngularVelocity = Vector3.new(0, 10000, 0)
            bav.MaxTorque = Vector3.new(0, math.huge, 0)
            bav.P = math.huge
            bav.Parent = hrp

            -- 2. تحويل اللاعب إلى "دبابة" (ثقيل جداً وبدون ارتداد)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    -- PhysicalProperties(Density, Friction, Elasticity, FrictionWeight, ElasticityWeight)
                    -- Density 100 = مستحيل شي لاعب يطيرك
                    -- Elasticity 0 = مستحيل ترتد أو تقلتش ملي تضرب فالحيط
                    part.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0, 100, 100)
                end
            end

            -- 3. نظام المراقبة الصارم (Strict Anti-Fling)
            flingLoop = RunService.Stepped:Connect(function()
                if char and hrp and hum then
                    -- منع التعثر أو الجلوس
                    if hum:GetState() == Enum.HumanoidStateType.FallingDown or hum:GetState() == Enum.HumanoidStateType.Ragdoll then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end

                    -- إذا حاولت اللعبة تطيير اللاعب (سرعة تفوق 50)
                    if hrp.Velocity.Magnitude > 50 then
                        -- إرجاع السرعة فوراً إلى سرعة المشي العادية + سرعة السقوط الطبيعية
                        local moveDir = hum.MoveDirection
                        local currentSpeed = hum.WalkSpeed
                        local fallSpeed = math.clamp(hrp.Velocity.Y, -50, 50) -- قفل سرعة الطيران العمودي
                        
                        hrp.Velocity = Vector3.new(moveDir.X * currentSpeed, fallSpeed, moveDir.Z * currentSpeed)
                    end
                end
            end)
        else
            -- حالة الإيقاف: مسح كل شيء وإرجاع اللاعب لحالته الطبيعية
            if flingLoop then flingLoop:Disconnect() flingLoop = nil end
            if bav then bav:Destroy() bav = nil end
            
            if hrp then
                hrp.RotVelocity = Vector3.new(0, 0, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
            
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        -- إرجاع الخصائص الفيزيائية الافتراضية
                        part.CustomPhysicalProperties = nil
                    end
                end
            end
        end
    end)
end
