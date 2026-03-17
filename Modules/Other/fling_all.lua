-- [[ Cryptic Hub - تطيير الجميع الذكي (Smart Auto Fling All V6) ]]
-- المطور: يامي | الميزات: استمرار بعد الموت، توازن مثالي، حماية من الانتحار، ودوران علوي

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer

    local isFlingAllActive = false
    local charAddedConnection = nil
    local flingTask = nil
    local bav, bp, bg = nil, nil, nil

    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 5
            })
        end)
    end

    -- دالة التنظيف وإيقاف المحركات
    local function CleanMovers()
        if bav then bav:Destroy() bav = nil end
        if bp then bp:Destroy() bp = nil end
        if bg then bg:Destroy() bg = nil end
    end

    -- دالة التشغيل الأساسية (مفصولة لتعمل عند التفعيل وعند الترسبن)
    local function StartFlingProcess(char)
        if not isFlingAllActive then return end
        
        local root = char:WaitForChild("HumanoidRootPart", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        local torso = char:WaitForChild("UpperTorso") or char:FindFirstChild("Torso")
        
        if not root or not hum or not torso then return end

        CleanMovers()
        hum.PlatformStand = true

        -- 🛡️ حماية من الموت العشوائي بسبب الفيزياء
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

        -- 1. أداة الدوران (للنصف العلوي فقط)
        bav = Instance.new("BodyAngularVelocity")
        bav.Name = "CrypticAutoFlingBAV"
        bav.AngularVelocity = Vector3.new(0, 50000, 0)
        bav.MaxTorque = Vector3.new(0, math.huge, 0)
        bav.P = math.huge
        bav.Parent = torso

        -- 2. أداة التتبع المغناطيسي
        bp = Instance.new("BodyPosition")
        bp.Name = "CrypticAutoFlingBP"
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.P = 15000 
        bp.D = 100
        bp.Parent = root

        -- 3. 🔴 مثبت التوازن (يمنعك من الانقلاب على رأسك تماماً!)
        bg = Instance.new("BodyGyro")
        bg.Name = "CrypticAutoFlingBG"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 50000
        bg.D = 500
        bg.CFrame = CFrame.new() -- يحافظ على استقامتك (واقف)
        bg.Parent = root

        -- تقليل وزن الجسم لتجنب القلتشات القاتلة
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Massless = true
                if part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end

        if flingTask then task.cancel(flingTask) end

        -- حلقة التتبع والضرب
        flingTask = task.spawn(function()
            while isFlingAllActive do
                for _, targetPlayer in ipairs(Players:GetPlayers()) do
                    if not isFlingAllActive then break end
                    
                    if targetPlayer ~= LocalPlayer and targetPlayer.Character then
                        local targetChar = targetPlayer.Character
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        local targetHum = targetChar:FindFirstChildOfClass("Humanoid")

                        if targetRoot and targetHum and targetHum.Health > 0 then
                            -- 🛡️ حماية: تجاهل اللاعب إذا سقط في الفراغ (لكي لا تموت معه)
                            if targetRoot.Position.Y > (workspace.FallenPartsDestroyHeight + 20) then
                                local isStationary = targetRoot.Velocity.Magnitude < 5
                                
                                if isStationary then
                                    local startTime = tick()
                                    local initialTargetY = targetRoot.Position.Y
                                    
                                    -- انتقال أولي للهدف
                                    root.CFrame = CFrame.new(targetRoot.Position)

                                    while isFlingAllActive and targetRoot and targetRoot.Parent and targetHum.Health > 0 and (tick() - startTime < 1.5) do
                                        -- توجيه البوصلة مع الحفاظ على الاستقامة
                                        bg.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(targetRoot.CFrame.LookVector.X, 0, targetRoot.CFrame.LookVector.Z))
                                        
                                        bp.Position = targetRoot.Position
                                        
                                        root.Velocity = Vector3.new(0, 0, 0)
                                        root.RotVelocity = Vector3.new(0, 0, 0)
                                        torso.RotVelocity = Vector3.new(0, 50000, 0)
                                        
                                        root.CanCollide = true
                                        root.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 1)

                                        if targetRoot.Velocity.Magnitude > 40 or math.abs(targetRoot.Position.Y - initialTargetY) > 10 then
                                            break 
                                        end
                                        
                                        RunService.Stepped:Wait()
                                    end
                                    root.CanCollide = false
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end

    local function StopFlingProcess()
        isFlingAllActive = false
        if flingTask then task.cancel(flingTask) flingTask = nil end
        CleanMovers()
        
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            
            if hum then 
                hum.PlatformStand = false 
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            end
            if torso then torso.RotVelocity = Vector3.new(0,0,0) end
            
            if root then
                root.Velocity = Vector3.new(0,0,0)
                root.RotVelocity = Vector3.new(0,0,0)
            end

            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Massless = false
                    part.CustomPhysicalProperties = nil
                    if part.Name == "HumanoidRootPart" then
                        part.CanCollide = false
                    else
                        part.CanCollide = true
                    end
                end
            end
        end
    end

    Tab:AddToggle("تطيير الجميع / Fling All", function(state)
        isFlingAllActive = state
        
        if state then
            Notify("🌪️ جاري مسح السيرفر...", "Scanning and flinging stationary players...")
            
            if LocalPlayer.Character then
                StartFlingProcess(LocalPlayer.Character)
            end
            
            -- 🔴 مراقب الموت: يعيد تشغيل الإعصار تلقائياً عند الترسبن
            if not charAddedConnection then
                charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                    if isFlingAllActive then
                        task.wait(1.5) -- انتظار قصير لتكتمل الشخصية
                        StartFlingProcess(newChar)
                    end
                end)
            end
        else
            if charAddedConnection then
                charAddedConnection:Disconnect()
                charAddedConnection = nil
            end
            StopFlingProcess()
            Notify("✅ توقف التطيير", "Fling All stopped")
        end
    end)
    
    Tab:AddLine()
end
