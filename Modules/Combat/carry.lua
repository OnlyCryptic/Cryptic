-- [[ Cryptic Hub - حمل اللاعب المطور (Carry Player) ]]
-- الميزات: تحكم جوال (ضغط مطول)، التقاط ذكي عند السقوط الطويل فقط لتجنب الموت

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui = game:GetService("StarterGui")
    local CoreGui = game:GetService("CoreGui")
    local lp = players.LocalPlayer
    
    local isCarrying = false
    local liftHeight = -7
    local carryGui = nil
    
    -- إعدادات السرعة والتحكم
    local liftSpeed = 0.5 
    local isHoldingUp = false
    local isHoldingDown = false
    local holdConnection = nil
    
    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 10,
            })
        end)
    end

    local function SetupHeightUI()
        if carryGui then carryGui:Destroy() end
        
        carryGui = Instance.new("ScreenGui")
        carryGui.Name = "CrypticCarryUI"
        carryGui.ResetOnSpawn = false
        pcall(function() carryGui.Parent = CoreGui end)
        if not carryGui.Parent then carryGui.Parent = lp:WaitForChild("PlayerGui") end

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 65, 0, 140)
        frame.Position = UDim2.new(1, -85, 0.5, -70)
        frame.BackgroundTransparency = 1
        frame.Parent = carryGui

        local upBtn = Instance.new("TextButton")
        upBtn.Size = UDim2.new(1, 0, 0.5, -5)
        upBtn.Position = UDim2.new(0, 0, 0, 0)
        upBtn.Text = "🔼"
        upBtn.TextScaled = true
        upBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        upBtn.BackgroundTransparency = 0.2
        upBtn.TextColor3 = Color3.new(1, 1, 1)
        upBtn.Parent = frame

        local downBtn = Instance.new("TextButton")
        downBtn.Size = UDim2.new(1, 0, 0.5, -5)
        downBtn.Position = UDim2.new(0, 0, 0.5, 5)
        downBtn.Text = "🔽"
        downBtn.TextScaled = true
        downBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        downBtn.BackgroundTransparency = 0.2
        downBtn.TextColor3 = Color3.new(1, 1, 1)
        downBtn.Parent = frame

        -- نظام الضغط المطول
        upBtn.MouseButton1Down:Connect(function() isHoldingUp = true end)
        upBtn.MouseButton1Up:Connect(function() isHoldingUp = false end)
        upBtn.MouseLeave:Connect(function() isHoldingUp = false end)

        downBtn.MouseButton1Down:Connect(function() isHoldingDown = true end)
        downBtn.MouseButton1Up:Connect(function() isHoldingDown = false end)
        downBtn.MouseLeave:Connect(function() isHoldingDown = false end)

        if holdConnection then holdConnection:Disconnect() end
        holdConnection = runService.RenderStepped:Connect(function()
            if isHoldingUp then
                liftHeight = liftHeight + liftSpeed
            elseif isHoldingDown then
                liftHeight = liftHeight - liftSpeed
            end
        end)
    end

    local function RemoveHeightUI()
        isHoldingUp = false
        isHoldingDown = false
        if holdConnection then 
            holdConnection:Disconnect() 
            holdConnection = nil 
        end
        if carryGui then 
            carryGui:Destroy() 
            carryGui = nil 
        end
    end

    Tab:AddToggle("حمل اللاعب / Carry Player", function(active)
        isCarrying = active
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if active then
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                isCarrying = false
                Notify(
                    "⚠️ حدد لاعباً أولاً من مربع البحث!",
                    "⚠️ Select a player first!"
                )
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
                    Notify(
                        "🚫 هذا الماب يلغي تلامس اللاعبين!",
                        "🚫 Map disables collision!"
                    )
                    return 
                end
            end
            
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true end
            end
            
            liftHeight = -7
            SetupHeightUI()
            
            Notify(
                "🚀 جاري الرفع! (اضغط مطولاً للتحكم)",
                "🚀 Lifting! (Hold to control)"
            )
        else
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
                
                if root then
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(0, 0, 0)
                    root.CFrame = root.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
                end

                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Massless = false 
                        part.CanCollide = true
                    end
                end
            end
            RemoveHeightUI()
            Notify(
                "❌ تم إيقاف الحمل وعدت لطبيعتك.",
                "❌ Carry stopped."
            )
        end
    end)

    -- [[ المحرك الفيزيائي + نظام الالتقاط الذكي ]]
    runService.Heartbeat:Connect(function()
        if not isCarrying or not _G.ArwaTarget then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local myHum = char and char:FindFirstChildOfClass("Humanoid")
        local targetChar = _G.ArwaTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot and myHum then
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
            -- استخدام AssemblyLinearVelocity إذا كانت متوفرة أو Velocity كبديل
            local tVel = targetRoot.AssemblyLinearVelocity or targetRoot.Velocity

            -- [[ نظام الالتقاط الذكي (Smart Catch) ]]
            -- إذا تعدت سرعة السقوط -40 (بمعنى أنه يسقط من مكان مرتفع أو خارج الماب وليس مجرد قفزة عادية)
            if tVel.Y < -40 and liftHeight > -7 then
                liftHeight = -7 -- انزل تحته فوراً لالتقاطه
            end

            root.CFrame = CFrame.new(tPos.X, tPos.Y + liftHeight, tPos.Z) * CFrame.Angles(math.rad(90), 0, 0)
            
            root.Velocity = Vector3.new(0, 15, 0)
            root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end
