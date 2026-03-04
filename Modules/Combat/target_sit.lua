-- [[ Cryptic Hub - ميزة ركوب الرأس (Head Sit) المطور ]]
-- المطور: يامي (Yami) | الميزات: Anti-Fling، ملاحقة دقيقة، عودة آمنة، استقرار فيزيائي

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

            SendRobloxNotification("Cryptic Hub", "🪑 أنت الآن في أعلى نقطة فوق رأس: " .. _G.ArwaTarget.DisplayName)
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
            
            -- [[ نظام Anti-Fling ومنع الضرر ]]
            -- جعل الشخصية عديمة الوزن وعديمة التصادم لمنع القلتش
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Massless = true
                    -- تصفير السرعة اللحظي لمنع الطيران المفاجئ
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.RotVelocity = Vector3.new(0, 0, 0)
                end
            end

            -- الملاحقة في أعلى نقطة (تم رفع المسافة لـ 2.8 لضمان عدم التداخل)
            local targetVel = targetHead.Velocity
            root.Velocity = Vector3.new(0, 0, 0)
            
            -- الالتصاق بالملي فوق الرأس مع مراعاة سرعة الهدف
            root.CFrame = (targetHead.CFrame * CFrame.new(0, 2.8, 0)) + (targetVel * 0.05)
        end
    end)
end
