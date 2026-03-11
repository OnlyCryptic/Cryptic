-- [[ Cryptic Hub - Safe Walk Fling Module ]]
return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local flingConnection = nil

    Tab:AddToggle("Walk Fling / الدفع بالمشي", function(state)
        if state then
            local char = LocalPlayer.Character
            if char then
                -- 1. إزالة الاحتكاك من كل أجزاء الجسم باش ما تطيرش راسك
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                    end
                end
            end
            
            -- تشغيل ميزة الدفع
            flingConnection = RunService.Stepped:Connect(function()
                char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    
                    if hrp and hum then
                        -- 2. منع الشخصية من السقوط والتعثر (Anti-Trip)
                        if hum:GetState() == Enum.HumanoidStateType.FallingDown or hum:GetState() == Enum.HumanoidStateType.Ragdoll then
                            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end
                        
                        -- الدوران السريع لضرب اللاعبين الآخرين
                        hrp.RotVelocity = Vector3.new(0, 50000, 0)
                        
                        -- 3. حماية من الطيران العشوائي للسماء أو السقوط تحت الماب
                        if hrp.Velocity.Y > 50 or hrp.Velocity.Y < -50 then
                            hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                        end
                    end
                end
            end)
        else
            -- إيقاف الميزة
            if flingConnection then
                flingConnection:Disconnect()
                flingConnection = nil
            end
            
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.RotVelocity = Vector3.new(0, 0, 0)
                end
                
                -- إرجاع الاحتكاك الطبيعي للشخصية
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        -- الخصائص الافتراضية للفيزياء في روبلوكس
                        part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
                    end
                end
            end
        end
    end)
end
