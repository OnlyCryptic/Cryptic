-- [[ Cryptic Hub - حمل اللاعب المطور (Carry Player) ]]
-- المطور: يامي (Yami) | الميزات: التقاط عند السقوط، تحكم بالأسهم (WASD)

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local PhysicsService = game:GetService("PhysicsService")
    local uis = game:GetService("UserInputService") -- إضافة خدمة التحكم بالأسهم
    local StarterGui = game:GetService("StarterGui")
    local camera = workspace.CurrentCamera
    local lp = players.LocalPlayer
    
    local isCarrying = false
    local liftHeight = -7
    local liftSpeed = 0.05 -- تسريع الرفع قليلاً ليكون متجاوباً أكثر
    
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 4,
            })
        end)
    end

    Tab:AddToggle("حمل اللاعب / Carry Player", function(active)
        isCarrying = active
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if active then
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                isCarrying = false
                SendRobloxNotification("Cryptic Hub", "⚠️ حدد لاعباً أولاً من مربع البحث أعلى القائمة!")
                return
            end
            
            local targetChar = _G.ArwaTarget.Character
            local myTorso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or root
            local targetTorso = targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("HumanoidRootPart")
            
            if myTorso and targetTorso then
                local success, canCollide = pcall(function()
                    return PhysicsService:CollisionGroupsAreCollidable(myTorso.CollisionGroup, targetTorso.CollisionGroup)
                end)
                
                if success and not canCollide then
                    isCarrying = false
                    SendRobloxNotification("Cryptic Hub", "🚫 هذا الماب يلغي تلامس اللاعبين (No-Collide)، الخدعة لن تعمل هنا!")
                    return 
                end
            end
            
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true end
            end
            
            liftHeight = -7
            SendRobloxNotification("Cryptic Hub", "🚀 جاري الرفع! (استخدم الأسهم/WASD للتحرك به)")
        else
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
                
                if root then
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(0, 0, 0)
                    -- تعديل زاوية اللاعب ليقف على قدميه بدلاً من بقائه مستلقياً
                    root.CFrame = root.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
                end

                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Massless = false 
                    end
                end
            end
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف الحمل وتنظيف الفيزياء")
        end
    end)

    -- [[ المحرك الفيزيائي الذكي ]]
    runService.Heartbeat:Connect(function()
        if not isCarrying or not _G.ArwaTarget then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetChar = _G.ArwaTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" then
                        part.CanCollide = true
                    else
                        part.CanCollide = false
                    end
                    part.Massless = true
                end
            end

            local tPos = targetRoot.Position
            local tVel = targetRoot.Velocity

            -- [[ 1. نظام الحماية من السقوط (Auto-Catch) ]]
            -- إذا سرعة نزول اللاعب قوية (طاح من فوقك)، نلتقطه بسرعة!
            if tVel.Y < -15 then
                liftHeight = -6 -- نسوي تيليبورت تحته بـ 6 مسامير عشان نلقطه
            else
                -- وضع حد أقصى للرفع عشان ما تخترق جسمه ويزحلق
                if liftHeight < -2.5 then 
                    liftHeight = liftHeight + liftSpeed
                end
            end

            -- [[ 2. نظام القيادة بالأسهم (WASD & Arrows) ]]
            local moveOffset = Vector3.new(0, 0, 0)
            if uis:IsKeyDown(Enum.KeyCode.W) or uis:IsKeyDown(Enum.KeyCode.Up) then moveOffset = moveOffset + camera.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) or uis:IsKeyDown(Enum.KeyCode.Down) then moveOffset = moveOffset - camera.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) or uis:IsKeyDown(Enum.KeyCode.Left) then moveOffset = moveOffset - camera.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) or uis:IsKeyDown(Enum.KeyCode.Right) then moveOffset = moveOffset + camera.CFrame.RightVector end
            
            moveOffset = Vector3.new(moveOffset.X, 0, moveOffset.Z)
            if moveOffset.Magnitude > 0 then
                moveOffset = moveOffset.Unit * 1.5 -- سرعة تحركك به أفقياً
            end

            -- تطبيق الموقع (مكان الهدف + حركتك بالأسهم + الارتفاع)
            root.CFrame = CFrame.new(tPos.X + moveOffset.X, tPos.Y + liftHeight, tPos.Z + moveOffset.Z) * CFrame.Angles(math.rad(90), 0, 0)
            
            -- قوة دفع فيزيائية مستمرة للأعلى
            root.Velocity = Vector3.new(0, 15, 0)
            root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end
