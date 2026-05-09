-- [[ Cryptic Hub - Fixed 3D Fly + Floating Mini Toggle ]]
-- Localized via i18n. الكي: player.fly.*
-- زر صغير عائم يظهر تلقائياً عند تفعيل الطيران من السكربت
-- يخليك توقف/تشغل الطيران بسرعة بدون ما تفتح القائمة كل مرة

return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T    = (i18n and i18n.T) or function(k) return k end

    local player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local UserInputService = game:GetService("UserInputService")
    local cam = workspace.CurrentCamera

    local flyEnabled = false   -- الزر الرئيسي في القائمة (لو متفعل = اعرض الزر العائم)
    local isFlying   = false   -- الحالة الفعلية للطيران (تتحكم فيها من الزر العائم أو الرئيسي)
    local flySpeed   = 50
    local bodyVel, bodyGyro, connection, deathConn
    local miniGui, miniButton

    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 3})
        end)
    end

    -- ===== الطيران الفعلي =====
    local function applyFly(active)
        isFlying = active
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")

        if isFlying and root and hum then
            if bodyVel  then bodyVel:Destroy()  end
            if bodyGyro then bodyGyro:Destroy() end

            bodyVel = Instance.new("BodyVelocity", root)
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

            bodyGyro = Instance.new("BodyGyro", root)
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.P = 5000

            hum.PlatformStand = true

            if connection then connection:Disconnect() end
            connection = RunService.RenderStepped:Connect(function()
                if isFlying and root and bodyVel then
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        local look  = cam.CFrame.LookVector
                        local right = cam.CFrame.RightVector

                        local flatLook  = Vector3.new(look.X, 0, look.Z)
                        if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end

                        local flatRight = Vector3.new(right.X, 0, right.Z)
                        if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end

                        local zInput = moveDir:Dot(flatLook)
                        local xInput = moveDir:Dot(flatRight)
                        local flyDir = (look * zInput) + (right * xInput)

                        if flyDir.Magnitude > 0 then
                            bodyVel.Velocity = flyDir.Unit * flySpeed
                        else
                            bodyVel.Velocity = Vector3.new(0, 0, 0)
                        end
                    else
                        bodyVel.Velocity = Vector3.new(0, 0, 0)
                    end
                    bodyGyro.CFrame = cam.CFrame
                end
            end)

            if deathConn then deathConn:Disconnect() end
            deathConn = hum.Died:Connect(function()
                if not isFlying then return end
                if connection then connection:Disconnect() connection = nil end
                if bodyVel  then pcall(function() bodyVel:Destroy()  end) bodyVel  = nil end
                if bodyGyro then pcall(function() bodyGyro:Destroy() end) bodyGyro = nil end
                task.wait(0.2)
                local newChar = player.Character
                local newHum  = newChar and newChar:FindFirstChild("Humanoid")
                if not newChar or not newHum or newHum.Health <= 0 then
                    newChar = player.CharacterAdded:Wait()
                end
                newChar:WaitForChild("HumanoidRootPart", 10)
                newChar:WaitForChild("Humanoid", 10)
                task.wait(0.3)
                if isFlying then applyFly(true) end
            end)
        else
            if connection then connection:Disconnect() connection = nil end
            if bodyVel  then pcall(function() bodyVel:Destroy()  end) bodyVel  = nil end
            if bodyGyro then pcall(function() bodyGyro:Destroy() end) bodyGyro = nil end
            if deathConn then deathConn:Disconnect() deathConn = nil end
            if hum then pcall(function() hum.PlatformStand = false end) end
        end
    end

    -- ===== الزر العائم =====
    local function refreshMini()
        if not miniButton then return end
        miniButton.BackgroundTransparency = 0.25
        if isFlying then
            miniButton.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
            miniButton.Text = "✈ ON"
        else
            miniButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            miniButton.Text = "✈ OFF"
        end
    end

    local function createMiniUI()
        if miniGui then return end
        local parent
        local ok = pcall(function() parent = (gethui and gethui()) or game:GetService("CoreGui") end)
        if not ok or not parent then parent = player:WaitForChild("PlayerGui") end

        miniGui = Instance.new("ScreenGui")
        miniGui.Name = "CrypticFlyMini"
        miniGui.ResetOnSpawn = false
        miniGui.IgnoreGuiInset = true
        miniGui.DisplayOrder = 9999
        miniGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() miniGui.Parent = parent end)

        local btn = Instance.new("TextButton")
        btn.Name = "FlyToggle"
        btn.Size = UDim2.new(0, 44, 0, 44)
        btn.Position = UDim2.new(1, -60, 0, 110)
        btn.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
        btn.BackgroundTransparency = 0.25
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextTransparency = 0
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.Text = "✈ ON"
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        btn.Active = true
        btn.Parent = miniGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1.5
        stroke.Transparency = 0.4
        stroke.Parent = btn

        miniButton = btn

        -- تمييز ذكي بين الضغط والسحب:
        -- لو الإصبع تحرك أكثر من 12 بكسل أو استمر بالضغط أكثر من 0.35 ثانية بدون رفع = سحب
        -- لو رفع الإصبع بسرعة وبدون حركة كبيرة = ضغط (تشغيل/إيقاف)
        local DRAG_THRESHOLD_PX = 12
        local CLICK_MAX_TIME    = 0.35

        local dragging  = false
        local moved     = false
        local dragStart, startPos, pressTime

        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
               or input.UserInputType == Enum.UserInputType.Touch then
                dragging  = true
                moved     = false
                dragStart = input.Position
                startPos  = btn.Position
                pressTime = tick()
                -- مؤشر بصري بسيط على الضغط (تعتيم خفيف)
                btn.BackgroundTransparency = 0.05
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
               or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                if not moved then
                    local dist = math.sqrt(delta.X * delta.X + delta.Y * delta.Y)
                    if dist > DRAG_THRESHOLD_PX then
                        moved = true
                    end
                end
                if moved then
                    btn.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end
        end)

        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
               or input.UserInputType == Enum.UserInputType.Touch then
                local heldFor = pressTime and (tick() - pressTime) or 0
                local isClick = (not moved) and (heldFor <= CLICK_MAX_TIME)
                dragging = false
                if isClick then
                    applyFly(not isFlying)
                end
                refreshMini() -- يعيد لون/شفافية الزر للحالة الطبيعية
            end
        end)

        refreshMini()
    end

    local function destroyMiniUI()
        if miniGui then
            pcall(function() miniGui:Destroy() end)
            miniGui = nil
            miniButton = nil
        end
    end

    -- ===== الزر الرئيسي في قائمة كرپتك =====
    Tab:AddSpeedControl(T("player.fly.label"), function(active, value)
        flyEnabled = active
        flySpeed   = value
        if active then
            createMiniUI()
            applyFly(true)
            refreshMini()
            Notify("Cryptic Hub", T("player.fly.on"))
        else
            applyFly(false)
            destroyMiniUI()
        end
    end, 50)
end
