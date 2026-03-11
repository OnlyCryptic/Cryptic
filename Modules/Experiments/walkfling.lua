-- [[ Cryptic Hub - Ultimate Walk Fling + Anti-Fling + Smart Wall Detection ]]
-- المطور: مدمج (Walk Fling + Anti-Wall + Anti-Fling + Auto-Respawn)

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local isFlinging = false
    local flingConnection = nil
    local charAddedConnection = nil
    local bav = nil -- للتحكم في الدوران
    local bv = nil  -- للتحكم في الثبات
    local isPaused = false -- متغير لمعرفة هل الدوران متوقف مؤقتاً

    -- دالة الإشعارات المزدوجة
    local function Notify(arText, enText)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 3
            })
        end)
    end

    -- دالة التشغيل التي سيتم استدعاؤها في البداية وبعد كل ريسباون
    local function SetupFling(char)
        if not isFlinging then return end
        
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hrp or not hum then return end

        -- مسح الأدوات القديمة لتجنب التكرار
        if flingConnection then flingConnection:Disconnect() end
        if bav then bav:Destroy() end
        if bv then bv:Destroy() end

        -- 1. أداة الدوران (تطير اللاعبين)
        bav = Instance.new("BodyAngularVelocity")
        bav.Name = "CrypticFlingBAV"
        bav.AngularVelocity = Vector3.new(0, 20000, 0) 
        bav.MaxTorque = Vector3.new(0, math.huge, 0)
        bav.P = math.huge
        bav.Parent = hrp

        -- 2. أداة الثبات (تمنع ارتدادك من الجدران)
        bv = Instance.new("BodyVelocity")
        bv.Name = "CrypticFlingBV"
        bv.MaxForce = Vector3.new(math.huge, 0, math.huge) 
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp

        isPaused = false

        -- 3. حلقة التحكم المستمر
        flingConnection = RunService.Stepped:Connect(function()
            if char and hrp and hum and hum.Health > 0 then
                
                -- [A] حرية الحركة: تحديث سرعتك لتتطابق مع حركتك الحقيقية
                bv.Velocity = hum.MoveDirection * hum.WalkSpeed
                
                -- [B] حماية السقف: قفل السرعة العمودية لمنع الطيران
                if hrp.Velocity.Y > 40 or hrp.Velocity.Y < -40 then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, math.clamp(hrp.Velocity.Y, -40, 40), hrp.Velocity.Z)
                end

                -- [C] ميزة Anti-Fling: اختراق اللاعبين
                for _, otherPlayer in pairs(Players:GetPlayers()) do
                    if otherPlayer ~= LocalPlayer and otherPlayer.Character then
                        for _, part in pairs(otherPlayer.Character:GetChildren()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end

                -- [D] الذكاء الاصطناعي للجدران: إيقاف الدوران لمدة ثانيتين عند الاصطدام
                if not isPaused then
                    -- تحديد اتجاه الفحص (أمام اللاعب أو في اتجاه مشيه)
                    local checkDirection = (hum.MoveDirection.Magnitude > 0) and hum.MoveDirection or hrp.CFrame.LookVector
                    
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {char}
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude

                    -- فحص مسافة 3.5 أمام اللاعب
                    local hit = workspace:Raycast(hrp.Position, checkDirection * 3.5, rayParams)
                    
                    if hit and hit.Instance and hit.Instance.CanCollide then
                        -- تم اكتشاف جدار! إيقاف الدوران فوراً
                        isPaused = true
                        if bav then bav.AngularVelocity = Vector3.new(0, 0, 0) end
                        
                        -- الانتظار ثانيتين ثم إعادة التشغيل
                        task.spawn(function()
                            task.wait(2)
                            -- التحقق من أن الميزة ما زالت مفعلة واللاعب حي
                            if isFlinging and bav and hum.Health > 0 then
                                bav.AngularVelocity = Vector3.new(0, 20000, 0)
                            end
                            isPaused = false
                        end)
                    end
                end
                
            end
        end)
    end

    -- دالة الإيقاف
    local function StopFling()
        if flingConnection then flingConnection:Disconnect() flingConnection = nil end
        if bav then bav:Destroy() bav = nil end
        if bv then bv:Destroy() bv = nil end
        
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.RotVelocity = Vector3.new(0, 0, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end

    Tab:AddToggle("Walk Fling / الدفع بالمشي", function(state)
        isFlinging = state
        
        if state then
            Notify("🌪️ تم تفعيل الدفع بالمشي (المتطور)", "🌪️ Smart Walk Fling Activated")
            
            if LocalPlayer.Character then
                SetupFling(LocalPlayer.Character)
            end
            
            -- تفعيل مراقب الترسبين
            if not charAddedConnection then
                charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                    if isFlinging then
                        task.wait(1) -- ينتظر ثانية بعد الموت
                        SetupFling(newChar)
                    end
                end)
            end
        else
            StopFling()
            if charAddedConnection then
                charAddedConnection:Disconnect()
                charAddedConnection = nil
            end
        end
    end)
end
