-- [[ Cryptic Hub - تطيير الجميع الذكي (Classic Spin & Safe V7) ]]
-- المطور: يامي | الميزات: الدوران الكلاسيكي الأصلي، حماية من الموت العشوائي، وتتبع ذكي

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer

    local isFlingAllActive = false
    local charAddedConnection = nil
    local flingTask = nil
    local steppedConn = nil
    local bav, bp = nil, nil

    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 5
            })
        end)
    end

    local function CleanMovers()
        if bav then bav:Destroy() bav = nil end
        if bp then bp:Destroy() bp = nil end
        if steppedConn then steppedConn:Disconnect() steppedConn = nil end
    end

    local function StartFlingProcess(char)
        if not isFlingAllActive then return end
        
        local root = char:WaitForChild("HumanoidRootPart", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        local torso = char:WaitForChild("UpperTorso") or char:FindFirstChild("Torso")
        
        if not root or not hum or not torso then return end

        CleanMovers()
        hum.PlatformStand = true
        
        -- إغلاق حالات السقوط لمنع الموت العشوائي
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

        -- 1. أداة الدوران الكلاسيكية (في الجذع العلوي فقط) نفس الـ Walk Fling!
        bav = Instance.new("BodyAngularVelocity")
        bav.Name = "CrypticUpperFlingBAV"
        bav.AngularVelocity = Vector3.new(0, 25000, 0) -- السرعة الكلاسيكية المجنونة
        bav.MaxTorque = Vector3.new(0, math.huge, 0)
        bav.P = math.huge
        bav.Parent = torso

        -- 2. أداة السحب المغناطيسي
        bp = Instance.new("BodyPosition")
        bp.Name = "CrypticFlingBP"
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.P = 15000
        bp.D = 100
        bp.Parent = root

        -- تخفيف وزن الشخصية ومنع التصادم المبدئي
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Massless = true
                part.CanCollide = false
            end
        end

        local currentTargetPos = nil

        -- 🔴 درع الاستقرار المستمر: يمنعك من الانقلاب ويحمي الكاميرا طوال الوقت!
        steppedConn = RunService.Stepped:Connect(function()
            if root and hum.Health > 0 then
                -- تصفير دوران الروت لتبقى واقفاً والكاميرا ثابتة
                root.RotVelocity = Vector3.new(0, 0, 0)
                
                if currentTargetPos then
                    bp.Position = currentTargetPos
                    root.CanCollide = true
                    root.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 1)
                else
                    root.CanCollide = false
                end
            end
        end)

        if flingTask then task.cancel(flingTask) end

        -- حلقة التتبع والانتقال
        flingTask = task.spawn(function()
            while isFlingAllActive do
                for _, targetPlayer in ipairs(Players:GetPlayers()) do
                    if not isFlingAllActive then break end
                    
                    if targetPlayer ~= LocalPlayer and targetPlayer.Character then
                        local targetChar = targetPlayer.Character
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        local targetHum = targetChar:FindFirstChildOfClass("Humanoid")

                        if targetRoot and targetHum and targetHum.Health > 0 then
                            -- تجاهل اللاعبين في الفراغ (لحمايتك من الانتحار)
                            if targetRoot.Position.Y > (workspace.FallenPartsDestroyHeight + 20) then
                                local isStationary = targetRoot.Velocity.Magnitude < 5
                                
                                if isStationary then
                                    local startTime = tick()
                                    local initialTargetY = targetRoot.Position.Y
                                    
                                    -- انتقال آمن أعلى الهدف قليلاً لتجنب ضرب الأرض بقوة
                                    root.Velocity = Vector3.new(0,0,0)
                                    root.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 1.5, 0))

                                    while isFlingAllActive and targetRoot and targetRoot.Parent and targetHum.Health > 0 and (tick() - startTime < 1.5) do
                                        currentTargetPos = targetRoot.Position
                                        
                                        -- التخطي السريع لو طار الهدف
                                        if targetRoot.Velocity.Magnitude > 40 or math.abs(targetRoot.Position.Y - initialTargetY) > 10 then
                                            break 
                                        end
                                        task.wait()
                                    end
                                    
                                    currentTargetPos = nil -- إيقاف التصادم بين كل لاعب والآخر
                                    root.Velocity = Vector3.new(0,0,0) -- إيقاف الزخم حتى لا تطير بعيداً
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
                    if part.Name ~= "HumanoidRootPart" then
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
            
            -- يعمل تلقائياً بعد الموت
            if not charAddedConnection then
                charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                    if isFlingAllActive then
                        task.wait(1.5) 
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
