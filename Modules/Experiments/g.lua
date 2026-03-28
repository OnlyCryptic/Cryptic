-- [[ Cryptic Hub - الطيران / Fly ]]

return function(Tab, UI)
    local player         = game.Players.LocalPlayer
    local RunService     = game:GetService("RunService")
    local StarterGui     = game:GetService("StarterGui")
    local UIS            = game:GetService("UserInputService")
    local cam            = workspace.CurrentCamera

    local isFlying       = false
    local flySpeed       = 50
    local verticalInput  = 0
    local bodyVel, bodyGyro, flyConn, deathConn
    local screenGui      = nil
    local updateScreenBtnColor = nil

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = text, Duration = 3
            })
        end)
    end

    local function syncScreenBtn()
        if updateScreenBtnColor then updateScreenBtnColor(isFlying) end
    end

    -- ── StopAll مصلح (بدون حركة غريبة) ───────────────────────────
    local function StopAll()
        isFlying = false
        verticalInput = 0

        if flyConn   then flyConn:Disconnect();   flyConn   = nil end
        if deathConn then deathConn:Disconnect(); deathConn = nil end

        -- أوقف الـ velocity أول قبل ما تدمر الـ objects
        if bodyVel then
            pcall(function() bodyVel.Velocity = Vector3.new(0, 0, 0) end)
            pcall(function() bodyVel:Destroy() end)
            bodyVel = nil
        end
        if bodyGyro then
            pcall(function() bodyGyro:Destroy() end)
            bodyGyro = nil
        end

        -- PlatformStand = false بعد frame واحد عشان ما يصير glitch
        task.defer(function()
            local char = player.Character
            local hum  = char and char:FindFirstChild("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum then hum.PlatformStand = false end
            -- استقرار الجسم بعد الطيران
            if root then
                local stab = Instance.new("BodyVelocity", root)
                stab.Velocity  = Vector3.new(0, 0, 0)
                stab.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
                game:GetService("Debris"):AddItem(stab, 0.1)
            end
        end)

        syncScreenBtn()
    end

    -- ── زر UI ─────────────────────────────────────────────────────
    local function makeBtn(parent, text, size, pos, bg)
        local b = Instance.new("TextButton", parent)
        b.Size                   = size
        b.Position               = pos
        b.Text                   = text
        b.BackgroundColor3       = bg
        b.BackgroundTransparency = 0.25
        b.TextColor3             = Color3.new(1, 1, 1)
        b.Font                   = Enum.Font.GothamBold
        b.TextSize               = 12
        b.BorderSizePixel        = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        return b
    end

    -- ── واجهة الشاشة (Draggable) ──────────────────────────────────
    local function setScreenGui(enabled)
        if screenGui then screenGui:Destroy(); screenGui = nil end
        updateScreenBtnColor = nil
        if not enabled then return end

        local gui = Instance.new("ScreenGui", player.PlayerGui)
        gui.Name             = "CrypticFlyUI"
        gui.ResetOnSpawn     = false
        gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
        screenGui = gui

        local frame = Instance.new("Frame", gui)
        frame.Size                   = UDim2.new(0, 52, 0, 138)
        frame.Position               = UDim2.new(0, 12, 0.5, -69)
        frame.BackgroundColor3       = Color3.fromRGB(20, 20, 30)
        frame.BackgroundTransparency = 0.35
        frame.BorderSizePixel        = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

        local dragBar = Instance.new("Frame", frame)
        dragBar.Size                   = UDim2.new(1, 0, 0, 14)
        dragBar.Position               = UDim2.new(0, 0, 0, 0)
        dragBar.BackgroundColor3       = Color3.fromRGB(60, 60, 90)
        dragBar.BackgroundTransparency = 0.3
        dragBar.BorderSizePixel        = 0
        Instance.new("UICorner", dragBar).CornerRadius = UDim.new(0, 8)

        local dragLabel = Instance.new("TextLabel", dragBar)
        dragLabel.Size                   = UDim2.new(1, 0, 1, 0)
        dragLabel.BackgroundTransparency = 1
        dragLabel.Text                   = "✦"
        dragLabel.TextColor3             = Color3.new(1, 1, 1)
        dragLabel.Font                   = Enum.Font.GothamBold
        dragLabel.TextSize               = 9

        local dragging, dragStart, startPos = false, nil, nil
        dragBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging  = true
                dragStart = input.Position
                startPos  = frame.Position
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        local btnSize = UDim2.new(1, -8, 0, 36)

        local toggleBtn = makeBtn(frame, "✈️", btnSize,
            UDim2.new(0, 4, 0, 18), Color3.fromRGB(50, 50, 70))

        updateScreenBtnColor = function(active)
            toggleBtn.BackgroundColor3 = active
                and Color3.fromRGB(0, 160, 75)
                or  Color3.fromRGB(50, 50, 70)
        end
        updateScreenBtnColor(isFlying)

        toggleBtn.MouseButton1Click:Connect(function()
            if isFlying then
                StopAll()
            else
                toggleFly(true, flySpeed)
                Notify("✈️ تم تفعيل الطيران!")
            end
        end)

        local upBtn = makeBtn(frame, "▲", btnSize,
            UDim2.new(0, 4, 0, 58), Color3.fromRGB(30, 90, 200))
        upBtn.MouseButton1Down:Connect(function() verticalInput =  1 end)
        upBtn.MouseButton1Up:Connect(function()
            if verticalInput == 1 then verticalInput = 0 end
        end)

        local downBtn = makeBtn(frame, "▼", btnSize,
            UDim2.new(0, 4, 0, 98), Color3.fromRGB(180, 50, 50))
        downBtn.MouseButton1Down:Connect(function() verticalInput = -1 end)
        downBtn.MouseButton1Up:Connect(function()
            if verticalInput == -1 then verticalInput = 0 end
        end)
    end

    -- ── الطيران الرئيسي ───────────────────────────────────────────
    function toggleFly(active, speedValue)
        flySpeed = speedValue or flySpeed
        if not active then StopAll(); return end

        isFlying = true
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")
        if not (root and hum) then isFlying = false; return end

        if bodyVel  then bodyVel:Destroy()  end
        if bodyGyro then bodyGyro:Destroy() end

        bodyVel          = Instance.new("BodyVelocity", root)
        bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVel.Velocity = Vector3.new(0, 0, 0)

        bodyGyro              = Instance.new("BodyGyro", root)
        bodyGyro.MaxTorque    = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P            = 5000
        bodyGyro.D            = 100

        hum.PlatformStand = true

        if flyConn then flyConn:Disconnect() end
        flyConn = RunService.RenderStepped:Connect(function()
            if not (isFlying and root and bodyVel) then return end

            local moveDir = hum.MoveDirection

            -- ── تحكم عمودي (كيبورد + أزرار الشاشة) ──
            local vInput = verticalInput
            if UIS:IsKeyDown(Enum.KeyCode.Space)       then vInput =  1 end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl)
            or UIS:IsKeyDown(Enum.KeyCode.C)           then vInput = -1 end

            -- ── اتجاه الطيران الأفقي (من الكاميرا مش الشاشة) ──
            local camCF   = cam.CFrame
            local look    = camCF.LookVector
            local right   = camCF.RightVector

            -- فصل المحور الأفقي فقط للحركة WASD
            local fLook   = Vector3.new(look.X,  0, look.Z)
            if fLook.Magnitude  > 0 then fLook  = fLook.Unit  end
            local fRight  = Vector3.new(right.X, 0, right.Z)
            if fRight.Magnitude > 0 then fRight = fRight.Unit end

            local zIn = moveDir:Dot(fLook)
            local xIn = moveDir:Dot(fRight)

            -- ── الاتجاه العمودي: الكاميرا نفسها لو تطلع فوق ──
            -- لو ما في input عمودي، خذ الـ pitch من الكاميرا
            local vertFromCam = 0
            if vInput == 0 then
                vertFromCam = look.Y  -- سالب = تحت، موجب = فوق
            else
                vertFromCam = vInput
            end

            local dir = (fLook * zIn) + (fRight * xIn) + Vector3.new(0, vertFromCam, 0)

            if dir.Magnitude > 0 then
                bodyVel.Velocity = dir.Unit * flySpeed
            else
                bodyVel.Velocity = Vector3.new(0, 0, 0)
            end

            -- ── Shift Lock Fix: نستخدم CFrame نظيف بدون roll ──
            local flatCF = CFrame.new(root.Position, root.Position + Vector3.new(look.X, 0, look.Z))
            bodyGyro.CFrame = flatCF
        end)

        -- ── مراقبة الموت ──
        if deathConn then deathConn:Disconnect() end
        deathConn = hum.Died:Connect(function()
            if not isFlying then return end
            local keepFlying = true
            StopAll()
            isFlying = keepFlying

            local newChar = player.Character
            local newHum  = newChar and newChar:FindFirstChild("Humanoid")
            if not newChar or not newHum or newHum.Health <= 0 then
                newChar = player.CharacterAdded:Wait()
            end
            newChar:WaitForChild("HumanoidRootPart", 10)
            newChar:WaitForChild("Humanoid", 10)
            task.wait(0.35)
            if isFlying then toggleFly(true, flySpeed) end
        end)

        syncScreenBtn()
    end

    -- ── Hub UI ────────────────────────────────────────────────────
    local flyDrop = Tab:AddToggleDropdown("طيران / Fly", function(active)
        if active then
            toggleFly(true, flySpeed)
            Notify("✈️ تم تفعيل الطيران!")
        else
            StopAll()
        end
    end)

    flyDrop:AddSpeedControl("السرعة / Speed", function(_, value)
        flySpeed = value
    end, flySpeed)

    flyDrop:AddToggle("أزرار الشاشة / Screen Buttons", function(enabled)
        setScreenGui(enabled)
    end)
end