-- [[ Cryptic Hub - Walk Fling Module (Controllable) ]]
return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local flingConnection = nil

    Tab:AddToggle("Walk Fling / الدفع بالمشي", function(state)
        if state then
            -- حالة التفعيل: الدوران على المحور Y فقط
            flingConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- ركز هنا: خلينا X و Z صفر، ودرنا 50000 غير فـ Y
                        -- هادشي كيخليك واقف مقاد ومتحكم فالمشي/الطيران ديالك 100%
                        hrp.RotVelocity = Vector3.new(0, 50000, 0)
                    end
                end
            end)
        else
            -- حالة الإيقاف: إرجاع اللاعب لطبيعته
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
            end
        end
    end)
end
