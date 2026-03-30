-- [[ Cryptic Hub - تطيير الجميع (Fling All V7) ]]

return function(Tab, UI)
    local Players        = game:GetService("Players")
    local RunService     = game:GetService("RunService")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui     = game:GetService("StarterGui")
    local LocalPlayer    = Players.LocalPlayer

    local isFlingAllActive    = false
    local charAddedConnection = nil
    local flingTask           = nil
    local steppedConn         = nil
    local bav, bp             = nil, nil

    -- إشعار ثنائي اللغة بدون إيموجي
    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = "Cryptic",
                Text     = ar .. " / " .. en,
                Duration = 3,
            })
        end)
    end

    local function CleanMovers()
        if bav         then bav:Destroy();          bav         = nil end
        if bp          then bp:Destroy();            bp          = nil end
        if steppedConn then steppedConn:Disconnect(); steppedConn = nil end
    end

    -- فحص دعم الماب للتلامس (نفس منطق fling_tool)
    local function MapSupportsCollision(hrp)
        local ok, col = pcall(function()
            return PhysicsService:CollisionGroupsAreCollidable(
                hrp.CollisionGroup, hrp.CollisionGroup)
        end)
        return not ok or col
    end

    local function StartFlingProcess(char)
        if not isFlingAllActive then return end

        local root  = char:WaitForChild("HumanoidRootPart", 5)
        local hum   = char:WaitForChild("Humanoid", 5)
        local torso = char:WaitForChild("UpperTorso") or char:FindFirstChild("Torso")

        if not root or not hum or not torso then return end

        CleanMovers()
        hum.PlatformStand = true
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead,        false) -- حماية 1: يمنع حالة الموت

        bav = Instance.new("BodyAngularVelocity")
        bav.Name            = "CrypticUpperFlingBAV"
        bav.AngularVelocity = Vector3.new(0, 25000, 0)
        bav.MaxTorque       = Vector3.new(0, math.huge, 0)
        bav.P               = math.huge
        bav.Parent          = torso

        bp = Instance.new("BodyPosition")
        bp.Name     = "CrypticFlingBP"
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.P        = 15000
        bp.D        = 100
        bp.Parent   = root

        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Massless   = true
                part.CanCollide = false
            end
        end

        local currentTargetPos = nil
        local lastSafePos      = root.Position  -- آخر موقع آمن للعودة إليه
        local safeY            = workspace.FallenPartsDestroyHeight + 60

        steppedConn = RunService.Stepped:Connect(function()
            if not root or not root.Parent then return end

            root.RotVelocity = Vector3.new(0, 0, 0)

            -- حماية 2: استعادة الصحة كل فريم
            pcall(function()
                if hum and hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end)

            if currentTargetPos then
                bp.Position = currentTargetPos
                root.CanCollide = true
                -- وزن معتدل بدل 100 لتقليل الأضرار الجانبية
                root.CustomPhysicalProperties = PhysicalProperties.new(50, 0, 0)
            else
                root.CanCollide = false
                -- حماية 3: لو سقطنا تحت الحد الآمن نرجع لآخر موقع
                if root.Position.Y < safeY then
                    pcall(function()
                        root.CFrame   = CFrame.new(lastSafePos + Vector3.new(0, 5, 0))
                        root.Velocity = Vector3.new(0, 0, 0)
                    end)
                else
                    lastSafePos = root.Position
                end
            end
        end)

        if flingTask then task.cancel(flingTask) end

        flingTask = task.spawn(function()
            while isFlingAllActive do
                for _, targetPlayer in ipairs(Players:GetPlayers()) do
                    if not isFlingAllActive then break end

                    if targetPlayer ~= LocalPlayer and targetPlayer.Character then
                        local targetChar = targetPlayer.Character
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        local targetHum  = targetChar:FindFirstChildOfClass("Humanoid")

                        if targetRoot and targetHum and targetHum.Health > 0 then
                            -- تأكد أن الهدف في منطقة آمنة قبل الانتقال إليه
                            if targetRoot.Position.Y > safeY then
                                local isStationary = targetRoot.Velocity.Magnitude < 5

                                if isStationary then
                                    local startTime      = tick()
                                    local initialTargetY = targetRoot.Position.Y

                                    root.Velocity = Vector3.new(0, 0, 0)
                                    root.CFrame   = CFrame.new(targetRoot.Position + Vector3.new(0, 1.5, 0))

                                    while isFlingAllActive and targetRoot and targetRoot.Parent
                                          and targetHum.Health > 0 and (tick() - startTime < 1.5) do
                                        currentTargetPos = targetRoot.Position
                                        if targetRoot.Velocity.Magnitude > 40
                                           or math.abs(targetRoot.Position.Y - initialTargetY) > 10 then
                                            break
                                        end
                                        task.wait()
                                    end

                                    currentTargetPos  = nil
                                    root.Velocity     = Vector3.new(0, 0, 0)
                                    -- ارجع لآخر موقع آمن بعد الفلينج مباشرةً
                                    pcall(function()
                                        root.CFrame = CFrame.new(lastSafePos + Vector3.new(0, 3, 0))
                                    end)
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
        if flingTask then task.cancel(flingTask); flingTask = nil end
        CleanMovers()

        local char = LocalPlayer.Character
        if char then
            local root  = char:FindFirstChild("HumanoidRootPart")
            local hum   = char:FindFirstChildOfClass("Humanoid")
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")

            if hum then
                hum.PlatformStand = false
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     true)
            end

            if torso then torso.RotVelocity = Vector3.new(0, 0, 0) end

            if root then
                root.Velocity    = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
            end

            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Massless              = false
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
            -- فحص دعم الماب للتلامس
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and not MapSupportsCollision(root) then
                isFlingAllActive = false
                Notify("الماب لا يدعم التلامس", "Map has no collision")
                return
            end

            Notify("يبحث عن لاعبين", "Scanning players")

            if LocalPlayer.Character then
                StartFlingProcess(LocalPlayer.Character)
            end

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
            Notify("توقف التطيير", "Fling All stopped")
        end
    end)
end
