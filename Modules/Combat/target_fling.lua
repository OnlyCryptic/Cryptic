-- [[ Cryptic Hub - ميزة تطيير الهدف (Fling) المطور ]]
-- المطور: أروى (Arwa) | الميزات: تشغيل إجباري دائماً (بدون فحص مزعج)، تتبع، عودة آمنة

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer
    
    local isFlinging = false
    local originalCFrame = nil 

    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 10, 
            })
        end)
    end

    Tab:AddToggle("تطيير الهدف / Fling", function(active)
        isFlinging = active
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if active then
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                isFlinging = false
                SendRobloxNotification("Cryptic Hub", "⚠️ حدد لاعباً أولاً من مربع البحث أعلى القائمة!")
                return
            end

            -- 🗑️ تم إزالة الفحص المزعج! السكربت الآن سيشتغل ويهاجم دائماً بقوة.

            if root then originalCFrame = root.CFrame end

            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true end
            end

            SendRobloxNotification("Cryptic Hub", "🔥 جاري تطيير وملاحقة: " .. _G.ArwaTarget.DisplayName)
        else
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
                
                if root then
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(0, 0, 0)
                    
                    if originalCFrame then
                        root.CFrame = originalCFrame
                        originalCFrame = nil
                    end
                end

                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Massless = false 
                        part.CustomPhysicalProperties = nil -- إعادة الفيزياء لطبيعتها
                    end
                end
            end
            SendRobloxNotification("Cryptic Hub", "❌ توقف التطيير وعدت لمكانك بأمان.")
        end
    end)

    runService.Heartbeat:Connect(function()
        if not isFlinging or not _G.ArwaTarget then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetChar = _G.ArwaTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" then
                        -- إجبار شخصيتك على الصلابة لتدمير الهدف
                        part.CanCollide = true
                        part.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 1)
                    else
                        part.CanCollide = false
                    end
                    part.Massless = true
                end
            end

            local targetVel = targetRoot.Velocity
            local predictedPos = targetRoot.Position + (targetVel * 0.1)

            local randX = math.random(-3, 3)
            local randY = math.random(-2, 3)
            local randZ = math.random(-3, 3)
            local randomOffset = Vector3.new(randX, randY, randZ)
            
            root.CFrame = CFrame.new(predictedPos + randomOffset)

            local rotX = math.random(-50000, 50000)
            local rotY = math.random(-50000, 50000)
            local rotZ = math.random(-50000, 50000)
            
            root.Velocity = Vector3.new(math.random(-1000, 1000), 5000, math.random(-1000, 1000))
            root.RotVelocity = Vector3.new(rotX, rotY, rotZ)
        end
    end)
end
