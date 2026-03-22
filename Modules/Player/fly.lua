-- [[ Cryptic Hub - الطيران المطور / Advanced Fly ]]

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local CoreGui = game:GetService("CoreGui")
    local cam = workspace.CurrentCamera

    local isFlying = false
    local flySpeed = 50
    local bodyVel, bodyGyro, connection, deathConn
    local verticalVel = 0

    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local isPC = UserInputService.KeyboardEnabled

    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 3})
        end)
    end

    -- ==============================
    -- أزرار جوال/تابلت
    -- ==============================
    local mobileGui = nil

    local function CreateMobileButtons()
        if mobileGui then mobileGui:Destroy() end
        if isPC then return end

        mobileGui = Instance.new("ScreenGui")
        mobileGui.Name = "CrypticFlyButtons"
        mobileGui.ResetOnSpawn = false
        pcall(function() mobileGui.Parent = CoreGui end)
        if not mobileGui.Parent then mobileGui.Parent = player:WaitForChild("PlayerGui") end

        local function MakeBtn(text, pos, onDown, onUp)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 52, 0, 52)
            btn.Position = pos
            btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            btn.BackgroundTransparency = 0.3
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(0, 255, 150)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 20
            btn.Parent = mobileGui
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(0, 255, 150)
            stroke.Thickness = 1.5
            btn.MouseButton1Down:Connect(onDown)
            btn.MouseButton1Up:Connect(onUp)
            btn.TouchLongPress:Connect(onDown)
            return btn
        end

        MakeBtn("▲", UDim2.new(1, -70, 0.5, -110),
            function() verticalVel = 1 end,
            function() verticalVel = 0 end)

        MakeBtn("▼", UDim2.new(1, -70, 0.5, -50),
            function() verticalVel = -1 end,
            function() verticalVel = 0 end)
    end

    local function RemoveMobileButtons()
        if mobileGui then mobileGui:Destroy() mobileGui = nil end
        verticalVel = 0
    end

    -- ==============================
    -- منطق الطيران (نفس الأصلي + تصليحات)
    -- ==============================
    local function StartFly()
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        if bodyVel then bodyVel:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        if connection then connection:Disconnect() end

        bodyVel = Instance.new("BodyVelocity", root)
        bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

        bodyGyro = Instance.new("BodyGyro", root)
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 5000

        hum.PlatformStand = true

        connection = RunService.RenderStepped:Connect(function()
            if not isFlying or not root or not bodyVel then return end

            local moveDir = hum.MoveDirection
            local look = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector

            -- ارتفاع/نزول
            local yVel = 0
            if not isPC then
                yVel = verticalVel * flySpeed
            else
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then yVel = flySpeed
                elseif UserInputService:IsKeyDown(Enum.KeyCode.Q) then yVel = -flySpeed end
            end

            if moveDir.Magnitude > 0 then
                local flatLook = Vector3.new(look.X, 0, look.Z)
                if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
                local flatRight = Vector3.new(right.X, 0, right.Z)
                if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end

                local zInput = moveDir:Dot(flatLook)
                local xInput = moveDir:Dot(flatRight)
                local flyDir = (look * zInput) + (right * xInput)

                if flyDir.Magnitude > 0 then
                    bodyVel.Velocity = Vector3.new(flyDir.Unit.X * flySpeed, yVel, flyDir.Unit.Z * flySpeed)
                    bodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + Vector3.new(flyDir.Unit.X, 0, flyDir.Unit.Z))
                else
                    bodyVel.Velocity = Vector3.new(0, yVel, 0)
                    local flatLook = Vector3.new(look.X, 0, look.Z)
                    if flatLook.Magnitude > 0 then
                        bodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + flatLook)
                    end
                end
            else
                bodyVel.Velocity = Vector3.new(0, yVel, 0)
                -- واقف: يواجه الكاميرا أفقياً بدون ميل
                local flatLook = Vector3.new(look.X, 0, look.Z)
                if flatLook.Magnitude > 0 then
                    bodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + flatLook)
                end
            end
        end)

        if not isPC then CreateMobileButtons() end
    end

    local function StopFly()
        if connection then connection:Disconnect() connection = nil end
        if bodyVel then bodyVel:Destroy() bodyVel = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        RemoveMobileButtons()
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end

    -- ==============================
    -- إعادة تشغيل بعد الموت
    -- ==============================
    local function WatchDeath()
        if deathConn then deathConn:Disconnect() end
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        deathConn = hum.Died:Connect(function()
            if not isFlying then return end
            player.CharacterAdded:Wait()
            task.wait(0.5)
            if isFlying then StartFly(); WatchDeath() end
        end)
    end

    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if isFlying then StartFly(); WatchDeath() end
    end)

    -- ==============================
    -- الزر الرئيسي
    -- ==============================
    Tab:AddSpeedControl("طيران / Fly", function(active, value)
        isFlying = active
        flySpeed = value

        if active then
            StartFly()
            WatchDeath()
            local hint = isPC
                and "✈️ تم تفعيل الطيران!\nE = ارتفاع | Q = نزول"
                or "✈️ تم تفعيل الطيران!\n▲▼ للارتفاع والنزول"
            Notify("Cryptic Hub", hint)
        else
            StopFly()
            if deathConn then deathConn:Disconnect() deathConn = nil end
        end
    end, 50)
end
