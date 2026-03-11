-- [[ Cryptic Hub - Ultimate Walk Fling (Anti-Wall + Auto Respawn) ]]
-- المطور: يامي (Yami) | التحديث: حل مشكلة الجدران + إعادة التفعيل بعد الموت

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local isFlinging = false
    local flingLoop = nil
    local charAddedConnection = nil

    -- دالة الإشعارات
    local function Notify(arText, enText)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 3
            })
        end)
    end

    -- دالة إعداد الشخصية للطيران (يتم استدعاؤها في البداية وبعد كل ريسباون)
    local function SetupFling(char)
        if not isFlinging then return end
        
        -- انتظار تحميل أجزاء الشخصية
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hrp or not hum then return end

        -- تحويل اللاعب لكتلة لا ترتد نهائياً (تمنع الموت عند الاصطدام)
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                -- Density=100 (ثقيل جداً), Elasticity=0 (بدون ارتداد نهائياً)
                part.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0)
            end
        end

        if flingLoop then flingLoop:Disconnect() end
        
        -- حلقة التحكم المستمر
        flingLoop = RunService.Heartbeat:Connect(function()
            if char and hrp and hum and hum.Health > 0 then
                -- 1. الدوران المباشر (أفضل من BodyAngularVelocity لعدم التفاعل مع الجدران)
                hrp.RotVelocity = Vector3.new(0, 25000, 0)
                
                -- 2. التحكم الصارم في السرعة لمنع الجدران أو السقف من دفعك
                local moveDir = hum.MoveDirection
                local walkSpeed = hum.WalkSpeed
                
                -- نحافظ على سرعة السقوط والقفز الطبيعية، لكن نحدها بين -50 و 50 لمنع الطيران الفوق
                local safeYVelocity = math.clamp(hrp.Velocity.Y, -50, 50)
                
                -- إجبار الشخصية على التحرك فقط في الاتجاه الذي تريده أنت
                hrp.Velocity = Vector3.new(moveDir.X * walkSpeed, safeYVelocity, moveDir.Z * walkSpeed)

                -- 3. ميزة Anti-Fling (اختراق اللاعبين لمنع ارتداد القوة لك)
                for _, otherPlayer in pairs(Players:GetPlayers()) do
                    if otherPlayer ~= LocalPlayer and otherPlayer.Character then
                        for _, part in pairs(otherPlayer.Character:GetChildren()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end
        end)
    end

    -- دالة الإيقاف الكلي
    local function StopFling()
        if flingLoop then flingLoop:Disconnect() flingLoop = nil end
        
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.RotVelocity = Vector3.new(0, 0, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
            
            -- إرجاع الخصائص الفيزيائية الافتراضية
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = nil
                end
            end
        end
    end

    Tab:AddToggle("Walk Fling / .الدفع بالمشي", function(state)
        isFlinging = state
        
        if state then
            Notify("🌪️ تم تفعيل الدفع بالمشي (آمن 100%)", "🌪️ Walk Fling Activated")
            
            -- تفعيل فوري للشخصية الحالية
            if LocalPlayer.Character then
                SetupFling(LocalPlayer.Character)
            end
            
            -- [[ الميزة الجديدة: إعادة التفعيل التلقائي بعد الموت (Respawn) ]]
            if not charAddedConnection then
                charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                    if isFlinging then
                        task.wait(1) -- الانتظار ثانية واحدة بعد الترسبين كما طلبت
                        SetupFling(newChar)
                    end
                end)
            end
        else
            -- حالة الإيقاف
            StopFling()
            
            -- فصل مراقب الترسبين
            if charAddedConnection then
                charAddedConnection:Disconnect()
                charAddedConnection = nil
            end
        end
    end)
end
