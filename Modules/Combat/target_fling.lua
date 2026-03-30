-- [[ Cryptic Hub - تطيير الهدف (Target Fling V7) ]]

return function(Tab, UI)
    local Players        = game:GetService("Players")
    local RunService     = game:GetService("RunService")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui     = game:GetService("StarterGui")
    local LocalPlayer    = Players.LocalPlayer

    local isFlinging    = false
    local originalCFrame = nil
    local bav, bp       = nil, nil
    local steppedConn   = nil

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

    -- تنظيف أدوات الفيزياء
    local function CleanMovers()
        if bav          then bav:Destroy();          bav         = nil end
        if bp           then bp:Destroy();           bp          = nil end
        if steppedConn  then steppedConn:Disconnect(); steppedConn = nil end
    end

    -- فحص دعم الماب للتلامس (نفس منطق fling_tool)
    local function MapSupportsCollision(hrp)
        local ok, col = pcall(function()
            return PhysicsService:CollisionGroupsAreCollidable(
                hrp.CollisionGroup, hrp.CollisionGroup)
        end)
        return not ok or col   -- لو فشل الفحص نفترض يدعم
    end

    -- [[ زر التفعيل ]]
    Tab:AddToggle("تطيير الهدف / Fling Target", function(active)
        isFlinging = active

        local char  = LocalPlayer.Character
        local root  = char and char:FindFirstChild("HumanoidRootPart")
        local hum   = char and char:FindFirstChildOfClass("Humanoid")
        local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))

        if active then

            -- 1. فحص وجود الهدف
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                isFlinging = false
                Notify("حدد لاعباً أولاً", "Select a player first")
                return
            end

            -- 2. فحص دعم الماب للتلامس
            if root and not MapSupportsCollision(root) then
                isFlinging = false
                Notify("الماب لا يدعم التلامس", "Map has no collision")
                return
            end

            if not root or not hum or not torso then return end

            -- 3. حفظ الموقع للعودة الآمنة
            originalCFrame = root.CFrame

            -- 4. تجهيز الشخصية
            CleanMovers()
            hum.PlatformStand = true
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,      false)

            bav = Instance.new("BodyAngularVelocity")
            bav.Name            = "CrypticTargetFlingBAV"
            bav.AngularVelocity = Vector3.new(0, 25000, 0)
            bav.MaxTorque       = Vector3.new(0, math.huge, 0)
            bav.P               = math.huge
            bav.Parent          = torso

            bp = Instance.new("BodyPosition")
            bp.Name     = "CrypticTargetFlingBP"
            bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bp.P        = 15000
            bp.D        = 100
            bp.Parent   = root

            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Massless    = true
                    part.CanCollide  = false
                end
            end

            Notify("يدور على: " .. _G.ArwaTarget.DisplayName,
                   "Flinging: "  .. _G.ArwaTarget.DisplayName)

            -- 5. لوب التتبع
            steppedConn = RunService.Stepped:Connect(function()
                if root and hum.Health > 0 and _G.ArwaTarget and _G.ArwaTarget.Character then
                    local targetRoot = _G.ArwaTarget.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        root.RotVelocity = Vector3.new(0, 0, 0)
                        bp.Position      = targetRoot.Position
                        root.CanCollide  = true
                        root.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 1)
                    end
                end
            end)

        else
            -- [[ إيقاف والعودة الآمنة ]]
            CleanMovers()

            if char and root and hum then
                hum.PlatformStand = false
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     true)

                root.Velocity    = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
                if torso then torso.RotVelocity = Vector3.new(0, 0, 0) end

                if originalCFrame then
                    root.CFrame    = originalCFrame
                    originalCFrame = nil
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

            Notify("توقف التطيير", "Fling stopped")
        end
    end)
end
