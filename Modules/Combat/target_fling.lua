-- [[ Cryptic Hub - هجمات الاستهداف (Fling + Aimbot + Fling Parts) ]]
-- المطور: يامي | داخل سكشن واحد في تاب استهداف لاعب

return function(Tab, UI)
    local runService    = game:GetService("RunService")
    local Players       = game:GetService("Players")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui    = game:GetService("StarterGui")
    local TweenService  = game:GetService("TweenService")
    local Workspace     = game:GetService("Workspace")
    local lp            = Players.LocalPlayer
    local camera        = workspace.CurrentCamera

    -- =============================================
    -- دالة الإشعارات المشتركة
    -- =============================================
    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = "Cryptic Hub",
                Text     = arText .. "\n" .. enText,
                Duration = 10,
            })
        end)
    end

    -- =============================================
    -- متغيرات Fling
    -- =============================================
    local isFlinging     = false
    local originalCFrame = nil

    -- =============================================
    -- متغيرات Aimbot
    -- =============================================
    local isAimbotting    = false
    local shiftLockOffset = Vector3.new(1.7, 0.5, 0)

    -- =============================================
    -- متغيرات Fling with Parts
    -- =============================================
    local blackHoleActive           = false
    local DescendantAddedConnection = nil
    local updateLoop                = nil
    local networkLoop               = nil

    -- تجهيز نقطة الجذب
    local Folder = Workspace:FindFirstChild("CrypticBringFolder") or Instance.new("Folder")
    Folder.Name   = "CrypticBringFolder"
    Folder.Parent = Workspace

    local TargetPart = Workspace:FindFirstChild("CrypticTargetPart") or Instance.new("Part")
    TargetPart.Name        = "CrypticTargetPart"
    TargetPart.Parent      = Folder
    TargetPart.Anchored    = true
    TargetPart.CanCollide  = false
    TargetPart.Transparency = 1

    local Attachment1 = TargetPart:FindFirstChild("Attachment1") or Instance.new("Attachment", TargetPart)
    Attachment1.Name  = "Attachment1"

    if not getgenv().CrypticNetworkBypass then
        getgenv().CrypticNetworkBypass = { BaseParts = {} }
    end

    -- =============================================
    -- helpers لـ Fling with Parts
    -- =============================================
    local function isSafeToGrab(part)
        if not part:IsA("BasePart") then return false end
        if part.Anchored then return false end
        if part.Transparency == 1 then return false end
        local root = part.AssemblyRootPart
        if root and root.Parent and root.Parent:FindFirstChildOfClass("Humanoid") then return false end
        if part:FindFirstAncestorWhichIsA("Accessory") then return false end
        local tool = part:FindFirstAncestorWhichIsA("Tool")
        if tool and tool.Parent and tool.Parent:FindFirstChildOfClass("Humanoid") then return false end
        if lp.Character and part:IsDescendantOf(lp.Character) then return false end
        return true
    end

    local function ForcePart(v)
        if not isSafeToGrab(v) then return end
        if not table.find(getgenv().CrypticNetworkBypass.BaseParts, v) then
            table.insert(getgenv().CrypticNetworkBypass.BaseParts, v)
        end
        v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        v.CanCollide = false
        for _, x in ipairs(v:GetChildren()) do
            if x:IsA("BodyMover") or x:IsA("RocketPropulsion") or x:IsA("AlignPosition") or x:IsA("Torque") or x:IsA("Attachment") then
                x:Destroy()
            end
        end
        local Torque = Instance.new("Torque", v)
        Torque.Name   = "CrypticTorque"
        Torque.Torque = Vector3.new(100000, 100000, 100000)
        local AlignPosition = Instance.new("AlignPosition", v)
        AlignPosition.Name         = "CrypticAlign"
        AlignPosition.MaxForce     = math.huge
        AlignPosition.MaxVelocity  = math.huge
        AlignPosition.Responsiveness = 200
        local Attachment2 = Instance.new("Attachment", v)
        Attachment2.Name            = "CrypticAtt"
        Torque.Attachment0          = Attachment2
        AlignPosition.Attachment0   = Attachment2
        AlignPosition.Attachment1   = Attachment1
    end

    local function CleanUpParts()
        for _, Part in pairs(getgenv().CrypticNetworkBypass.BaseParts) do
            if Part and Part.Parent then
                if Part:FindFirstChild("CrypticAlign")  then Part.CrypticAlign:Destroy()  end
                if Part:FindFirstChild("CrypticTorque") then Part.CrypticTorque:Destroy() end
                if Part:FindFirstChild("CrypticAtt")    then Part.CrypticAtt:Destroy()    end
                Part.Velocity    = Vector3.new(0, 0, 0)
                Part.RotVelocity = Vector3.new(0, 0, 0)
                Part.CanCollide  = true
                Part.CustomPhysicalProperties = nil
            end
        end
        getgenv().CrypticNetworkBypass.BaseParts = {}
    end

    -- =============================================
    -- السكشن الرئيسي
    -- =============================================
    Tab:AddSection("⚔️ هجمات الاستهداف / Attack Features", function(S)

        -- ----------------------------------------
        -- 1. تطيير الهدف / Fling
        -- ----------------------------------------
        S:AddToggle("🔥 تطيير الهدف / Fling", function(active)
            isFlinging = active
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if active then
                if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                    isFlinging = false
                    Notify("⚠️ حدد لاعباً أولاً من مربع البحث!", "Select a player first!")
                    return
                end
                local targetChar  = _G.ArwaTarget.Character
                local myTorso     = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or root
                local targetTorso = targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("HumanoidRootPart")
                if myTorso and targetTorso then
                    local ok, canCollide = pcall(function()
                        return PhysicsService:CollisionGroupsAreCollidable(myTorso.CollisionGroup, targetTorso.CollisionGroup)
                    end)
                    if ok and not canCollide then
                        isFlinging = false
                        Notify("🚫 الماب يلغي التلامس (No-Collide)!", "Map disables collision, won't work here!")
                        return
                    end
                end
                if root then originalCFrame = root.CFrame end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true end
                Notify("🔥 جاري تطيير: " .. _G.ArwaTarget.DisplayName, "Flinging: " .. _G.ArwaTarget.DisplayName)
            else
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
                if root then
                    root.Velocity    = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(0, 0, 0)
                    if originalCFrame then root.CFrame = originalCFrame; originalCFrame = nil end
                end
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Massless = false
                            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                        end
                    end
                end
                Notify("❌ توقف التطيير وعدت بأمان.", "Fling stopped, returned safely.")
            end
        end)

        S:AddLine()

        -- ----------------------------------------
        -- 2. ايم بوت / Aimbot
        -- ----------------------------------------
        S:AddToggle("🎯 ايم بوت / Aim Bot", function(active)
            isAimbotting = active
            local char = lp.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if active then
                if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                    isAimbotting = false
                    Notify("⚠️ حدد لاعباً أولاً من مربع البحث!", "Select a player first!")
                    return
                end
                if hum then hum.CameraOffset = shiftLockOffset end
                Notify("🎯 قفل على: " .. _G.ArwaTarget.DisplayName, "Locked on: " .. _G.ArwaTarget.DisplayName)
            else
                if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
                if root then
                    local gyro = root:FindFirstChild("CrypticGyro")
                    if gyro then gyro:Destroy() end
                end
                Notify("❌ تم إيقاف الايم بوت.", "Aimbot deactivated.")
            end
        end)

        S:AddLine()

        -- ----------------------------------------
        -- 3. تطيره بالبلوكات / Fling with Parts
        -- ----------------------------------------
        S:AddToggle("🌪️ تطيره بالبلوكات / Fling Parts", function(state)
            blackHoleActive = state

            if state then
                local targetPlayer = _G.ArwaTarget
                if not targetPlayer then
                    Notify("⚠️ تنبيه", "حدد لاعباً أولاً! / Select a player first!")
                    blackHoleActive = false
                    return
                end
                Notify("🌪️ هجوم القطع", "جاري تطير: " .. targetPlayer.DisplayName .. "\nFlinging: " .. targetPlayer.DisplayName)

                if not networkLoop then
                    networkLoop = runService.Heartbeat:Connect(function()
                        pcall(function()
                            if sethiddenproperty then
                                sethiddenproperty(lp, "SimulationRadius", math.huge)
                            end
                        end)
                        for _, Part in pairs(getgenv().CrypticNetworkBypass.BaseParts) do
                            if Part and Part.Parent and Part.Velocity.Magnitude < 1 then
                                Part.Velocity = Vector3.new(0, -1, 0)
                            end
                        end
                    end)
                end

                for _, v in ipairs(Workspace:GetDescendants()) do ForcePart(v) end
                DescendantAddedConnection = Workspace.DescendantAdded:Connect(function(v)
                    if blackHoleActive then ForcePart(v) end
                end)

                updateLoop = runService.RenderStepped:Connect(function()
                    if blackHoleActive and _G.ArwaTarget and _G.ArwaTarget.Character then
                        local root = _G.ArwaTarget.Character:FindFirstChild("HumanoidRootPart")
                        if root then Attachment1.WorldCFrame = root.CFrame end
                    end
                end)
            else
                Notify("🛑 توقف", "تم إرجاع القطع.\nParts returned.")
                if DescendantAddedConnection then DescendantAddedConnection:Disconnect(); DescendantAddedConnection = nil end
                if updateLoop then updateLoop:Disconnect(); updateLoop = nil end
                if networkLoop then networkLoop:Disconnect(); networkLoop = nil end
                CleanUpParts()
            end
        end)

    end)

    -- =============================================
    -- محركات RenderStepped و Heartbeat (تشتغل دايماً)
    -- =============================================

    -- محرك Fling
    runService.Heartbeat:Connect(function()
        if not isFlinging or not _G.ArwaTarget then return end
        local char       = lp.Character
        local root       = char and char:FindFirstChild("HumanoidRootPart")
        local targetChar = _G.ArwaTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        if root and targetRoot then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" then
                        part.CanCollide = true
                        part.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 1)
                    else
                        part.CanCollide = false
                    end
                    part.Massless = true
                end
            end
            local targetVel  = targetRoot.Velocity
            local predictedPos = targetRoot.Position + (targetVel * 0.1)
            local randomOffset = Vector3.new(math.random(-3,3), math.random(-2,3), math.random(-3,3))
            root.CFrame    = CFrame.new(predictedPos + randomOffset)
            root.Velocity  = Vector3.new(math.random(-1000,1000), 5000, math.random(-1000,1000))
            root.RotVelocity = Vector3.new(math.random(-50000,50000), math.random(-50000,50000), math.random(-50000,50000))
        end
    end)

    -- محرك Aimbot
    runService.RenderStepped:Connect(function()
        if not isAimbotting then return end
        local target = _G.ArwaTarget
        if not target or not target.Character then return end
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end

        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetRoot.Position)

        if root then
            local gyro = root:FindFirstChild("CrypticGyro") or Instance.new("BodyGyro", root)
            gyro.Name      = "CrypticGyro"
            gyro.MaxTorque = Vector3.new(0, math.huge, 0)
            gyro.P         = 100000
            gyro.D         = 100
            gyro.CFrame    = CFrame.lookAt(
                root.Position,
                Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z)
            )
        end

        if hum and hum.CameraOffset ~= shiftLockOffset then
            hum.CameraOffset = shiftLockOffset
        end
    end)

end
