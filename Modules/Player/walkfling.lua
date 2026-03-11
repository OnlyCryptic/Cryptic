-- [[ Cryptic Hub - Ultimate Walk Fling + Auto Noclip ]]
-- المطور: مدمج (Walk Fling + Noclip) | التحديث: دوران النصف العلوي فقط مع كاميرا ثابتة

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local isToggleOn = false
    local flingConnection = nil
    local charAddedConnection = nil
    local bav = nil 
    local bv = nil  

    -- دالة الإشعار
    local function NotifyWarning()
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub ⚠️",
                Text = "تم تفعيل الدفع بالنصف العلوي!\nالكاميرا ثابتة الآن.",
                Duration = 10
            })
        end)
    end

    -- دالة إعداد السكربت وتفعيله على الشخصية
    local function StartFling(char)
        if not isToggleOn then return end
        
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        -- نحدد الجذع (النصف العلوي) بناءً على نوع الشخصية (R15 أو R6)
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        
        if not hrp or not hum or not torso then return end

        -- مسح الأدوات القديمة لتجنب التكرار
        if flingConnection then flingConnection:Disconnect() end
        if bav then bav:Destroy() end
        if bv then bv:Destroy() end

        -- 1. أداة الدوران (نحطها في الجذع العلوي بدل الـ RootPart عشان الكاميرا ما تدور)
        bav = Instance.new("BodyAngularVelocity")
        bav.Name = "CrypticUpperFlingBAV"
        bav.AngularVelocity = Vector3.new(0, 25000, 0) -- سرعة دوران قوية
        bav.MaxTorque = Vector3.new(0, math.huge, 0)
        bav.P = math.huge
        bav.Parent = torso -- هنا السر!

        -- 2. أداة الثبات (لإعطاء تحكم سلس في المشي X و Z)
        bv = Instance.new("BodyVelocity")
        bv.Name = "CrypticFlingBV"
        bv.MaxForce = Vector3.new(math.huge, 0, math.huge) 
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp

        -- 3. حلقة التحكم المستمر
        flingConnection = RunService.Stepped:Connect(function()
            if char and hrp and hum and torso and hum.Health > 0 then
                
                -- [A] تحديث السرعة لتتطابق مع حركة اللاعب (تقدر تتحكم بحرية)
                bv.Velocity = Vector3.new(hum.MoveDirection.X * hum.WalkSpeed, hrp.Velocity.Y, hum.MoveDirection.Z * hum.WalkSpeed)
                
                -- [B] تثبيت الـ RootPart تماماً عشان الكاميرا ما تهتز وتدور
                hrp.RotVelocity = Vector3.new(0, 0, 0)

                -- [C] حماية من السقف والقفز العشوائي عشان ما تقلتش
                if hrp.Velocity.Y > 40 or hrp.Velocity.Y < -40 then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, math.clamp(hrp.Velocity.Y, -40, 40), hrp.Velocity.Z)
                end

                -- [D] Noclip تلقائي للاعب
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end

                -- [E] Noclip للاعبين الآخرين (Anti-Fling)
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
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            
            if hrp then
                hrp.RotVelocity = Vector3.new(0, 0, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
            if torso then
                torso.RotVelocity = Vector3.new(0, 0, 0)
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
            NotifyWarning()
            
            if LocalPlayer.Character then
                StartFling(LocalPlayer.Character)
            end
            
            if not charAddedConnection then
                charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                    if isToggleOn then
                        task.wait(2)
                        StartFling(newChar)
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
