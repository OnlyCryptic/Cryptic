-- [[ Cryptic Hub - ميزة ركوب الرأس (Head Sit) المطور ]]
-- المطور: يامي (Yami) | الميزات: مسافة مقربة، Anti-Fling، ملاحقة دقيقة، عودة آمنة

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer
    
    local isSitting = false
    local originalCFrame = nil 

    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 15, 
            })
        end)
    end

    Tab:AddToggle("ركوب الرأس / Head Sit", function(active)
        isSitting = active
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if active then
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                isSitting = false
                if hum then hum.Sit = false end
                SendRobloxNotification("Cryptic Hub", "⚠️ حدد لاعباً أولاً من مربع البحث!")
                return
            end

            if root then
                originalCFrame = root.CFrame
            end

            if hum then 
                hum.Sit = true 
            end

            SendRobloxNotification("Cryptic Hub", "🪑 تم الركوب! أنت الآن قبعة لـ: " .. _G.ArwaTarget.DisplayName)
        else
            if char and root then
                if hum then hum.Sit = false end
                
                -- إرجاع الخصائص الطبيعية وإيقاف Anti-Fling
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)

                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Massless = false
                        part.CanCollide = true
                    end
                end

                if originalCFrame then
                    root.CFrame = originalCFrame
                    originalCFrame = nil
                end
            end
            SendRobloxNotification("Cryptic Hub", "❌ تم النزول والعودة لمكانك بسلام")
        end
    end)

    runService.Heartbeat:Connect(function()
        if not isSitting or not _G.ArwaTarget then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local targetChar = _G.ArwaTarget.Character
        local targetHead = targetChar and targetChar:FindFirstChild("Head")

        if root and targetHead and hum then
            hum.Sit = true
            
            -- [[ نظام Anti-Fling المحسن ]]
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Massless = true
                    -- تصفير مستمر للسرعة لمنع القلتشات أثناء الحركة السريعة للهدف
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.RotVelocity = Vector3.new(0, 0, 0)
                end
            end

            -- الملاحقة في نقطة مقربة (المسافة الآن 2.4 بدلاً من 2.8)
            local targetVel = targetHead.Velocity
            root.Velocity = Vector3.new(0, 0, 0)
            
            -- الالتصاق بالملي فوق الرأس مع تعويض سرعة الهدف لثبات عالي
            root.CFrame = (targetHead.CFrame * CFrame.new(0, 2.4, 0)) + (targetVel * 0.05)
        end
    end)
end
