-- [[ Cryptic Hub - Perfect Walk Fling Module ]]
return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local flingConnection = nil

    Tab:AddToggle("Walk Fling / الدفع .بالمشي", function(state)
        if state then
            flingConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    
                    if hrp and hum then
                        -- دوران بسرعة 5000 (آمنة ليك ومميتة للاعبين الآخرين)
                        hrp.RotVelocity = Vector3.new(0, 5000, 0)
                        
                        -- إلغاء التصادم لأجزاء جسمك باش ما تحتكش مع الأرض وتطير راسك
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        else
            -- إيقاف الميزة وإرجاع الحالة الطبيعية
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
                
                -- إرجاع التصادم للأجزاء الضرورية
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end)
end
