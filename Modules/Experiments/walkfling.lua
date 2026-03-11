-- [[ Cryptic Hub - Walk Fling Module ]]
return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local flingConnection = nil

    -- إضافة زر التفعيل والإيقاف داخل الهاب مباشرة
    Tab:AddToggle("Walk Fling / الدفع بالمشي", function(state)
        if state then
            -- حالة التفعيل: تشغيل الدوران الخيالي
            flingConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- السر الحقيقي ديال Fling: دوران بسرعة 50 ألف
                        hrp.RotVelocity = Vector3.new(50000, 50000, 50000)
                    end
                end
            end)
        else
            -- حالة الإيقاف: فصل الاتصال وإرجاع اللاعب لطبيعته
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
