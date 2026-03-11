-- [[ Cryptic Hub - Ultimate Walk Fling + Auto Noclip + Auto Respawn ]]
-- المطور: مدمج (Walk Fling + Noclip + Anti-Fling)

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local isToggleOn = false
    local flingConnection = nil
    local charAddedConnection = nil
    local bav = nil 
    local bv = nil  

    -- دالة الإشعار (تظهر مرة واحدة فقط لمدة 15 ثانية)
    local function NotifyWarning()
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub ⚠️",
                Text = "تحذير: لا تلمس الجدران، المس اللاعبين فقط! (يفضل تفعيل الطيران)\nWarning: Don't touch walls, touch players only! (Fly recommended)",
                Duration = 15
            })
        end)
    end

    -- دالة إعداد السكربت وتفعيله على الشخصية
    local function StartFling(char)
        if not isToggleOn then return end
        
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hrp or not hum then return end

        -- مسح الأدوات القديمة لتجنب التكرار
        if flingConnection then flingConnection:Disconnect() end
        if bav then bav:Destroy() end
        if bv then bv:Destroy() end

        -- 1. أداة الدوران (بقوة 20000)
        bav = Instance.new("BodyAngularVelocity")
        bav.Name = "CrypticFlingBAV"
        bav.AngularVelocity = Vector3.new(0, 20000, 0) 
        bav.MaxTorque = Vector3.new(0, math.huge, 0)
        bav.P = math.huge
        bav.Parent = hrp

        -- 2. أداة الثبات (لإعطاء تحكم في X و Z)
        bv = Instance.new("BodyVelocity")
        bv.Name = "CrypticFlingBV"
        bv.MaxForce = Vector3.new(math.huge, 0, math.huge) 
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp

        -- 3. حلقة التحكم المستمر (Stepped هو الأفضل لمنع التصادم)
        flingConnection = RunService.Stepped:Connect(function()
            if char and hrp and hum and hum.Health > 0 then
                
                -- [A] تحديث السرعة لتتطابق مع الحركة
                bv.Velocity = hum.MoveDirection * hum.WalkSpeed
                
                -- [B] حماية من السقف والقفز العشوائي
                if hrp.Velocity.Y > 40 or hrp.Velocity.Y < -40 then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, math.clamp(hrp.Velocity.Y, -40, 40), hrp.Velocity.Z)
                end

                -- [C] Noclip تلقائي للاعب (اختراق الجدران وكل شيء)
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end

                -- [D] Noclip للاعبين الآخرين (Anti-Fling لاختراقهم وتطييرهم)
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

    -- دالة إيقاف السكربت
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
            -- إرجاع التصادم للطبيعة
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end

    Tab:AddToggle("Walk Fling / الدفع بالمشي", function(state)
        isToggleOn = state

        if state then
            -- إرسال الإشعار لمرة واحدة ولمدة 15 ثانية
            NotifyWarning()
            
            -- تشغيل الميزة على الشخصية الحالية
            if LocalPlayer.Character then
                StartFling(LocalPlayer.Character)
            end
            
            -- تفعيل خاصية: الترسبين بعد ثانيتين
            if not charAddedConnection then
                charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                    if isToggleOn then
                        task.wait(2) -- الانتظار ثانيتين كما طلبت
                        StartFling(newChar)
                    end
                end)
            end
        else
            -- إيقاف كل شيء
            StopFling()
            if charAddedConnection then
                charAddedConnection:Disconnect()
                charAddedConnection = nil
            end
        end
    end)
end
