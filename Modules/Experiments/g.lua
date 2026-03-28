-- [[ Cryptic Hub - الطيران / Fly ]]

return function(Tab, UI)
    local player         = game.Players.LocalPlayer
    local RunService     = game:GetService("RunService")
    local StarterGui     = game:GetService("StarterGui")
    local UIS            = game:GetService("UserInputService")
    local cam            = workspace.CurrentCamera

    local isFlying       = false
    local flySpeed       = 50
    local verticalInput  = 0        -- 1 = صعود، -1 = نزول، 0 = لا شيء
    local bodyVel, bodyGyro, flyConn, deathConn
    local screenGui      = nil
    local flyDropRef     = nil      -- مرجع لـ ToggleDropdown لتحديث حالته من الشاشة
    local updateScreenBtnColor = nil

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title = "Cryptic Hub", Text = text, Duration = 3})
        end)
    end

    -- ── تحديث زر الشاشة بعد تغيير الحالة ────────────────────────
    local function syncScreenBtn()
        if updateScreenBtnColor then updateScreenBtnColor(isFlying) end
    end

    -- ── دالة إنشاء زر ────────────────────────────────────────────
    local function makeBtn(parent, text, size, pos, bg)
        local b = Instance.new("TextButton", parent)
        b.Size = size; b.Position = pos
        b.Text = text
        b.BackgroundColor3 = bg
        b.BackgroundTransparency = 0.25
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 15
        b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
        return b
    end

    -- ── واجهة الشاشة ──────────────────────────────────────────────
    local function setScreenGui(enabled)
        if screenGui then screenGui:Destroy(); screenGui = nil end
        updateScreenBtnColor = nil
        if not enabled then return end

        local gui = Instance.new("ScreenGui", player.PlayerGui)
        gui.Name = "CrypticFlyUI"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui = gui

        -- حاوية الأزرار (يسار الشاشة وسط)
        local frame = Instance.new("Frame", gui)
        frame.Size = UDim2.new(0, 70, 0, 175)
        frame.Position = UDim2.new(0, 14, 0.5, -87)
        frame.BackgroundTransparency = 1

        -- زر التشغيل/الإيقاف
        local toggleBtn = makeBtn(frame, "✈️",
            UDim2.new(1, 0, 0, 55),
            UDim2.new(0, 0, 0, 0),
            Color3.fromRGB(50, 50, 70))

        updateScreenBtnColor = function(active)
            toggleBtn.BackgroundColor3 = active
                and Color3.fromRGB(0, 170, 85)
                or  Color3.fromRGB(50, 50, 70)
        end
        updateScreenBtnColor(isFlying)

        toggleBtn.MouseButton1Click:Connect(function()
            if flyDropRef then
                flyDropRef:SetActive(not isFlying)
            end
        end)

        -- زر الصعود ▲
        local upBtn = makeBtn(frame, "▲",
            UDim2.new(1, 0, 0, 55),
            UDim2.new(0, 0, 0, 62),
            Color3.fromRGB(30, 90, 200))

        upBtn.MouseButton1Down:Connect(function() verticalInput = 1 end)
        upBtn.MouseButton1Up:Connect(function()
            if verticalInput == 1 then verticalInput = 0 end
        end)

        -- زر النزول ▼
        local downBtn = makeBtn(frame, "▼",
            UDim2.new(1, 0, 0, 55),
            UDim2.new(0, 0, 0, 120),
            Color3.fromRGB(180, 50, 50))

        downBtn.MouseButton1Down:Connect(function() verticalInput = -1 end)
        downBtn.MouseButton1Up:Connect(function()
            if verticalInput == -1 then verticalInput = 0 end
        end)
    end

    -- ── دالة الطيران ──────────────────────────────────────────────
    local function toggleFly(active, speedValue)
        isFlying = active
        flySpeed = speedValue or flySpeed
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

            if flyConn then flyConn:Disconnect() end
            flyConn = RunService.RenderStepped:Connect(function()
                if not (isFlying and root and bodyVel) then return end

                local moveDir = hum.MoveDirection

                -- صعود/نزول: أزرار الشاشة أو الكيبورد (Space / LeftCtrl أو C)
                local vInput = verticalInput
                if UIS:IsKeyDown(Enum.KeyCode.Space)       then vInput =  1 end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl)
                or UIS:IsKeyDown(Enum.KeyCode.C)           then vInput = -1 end

                if moveDir.Magnitude > 0 or vInput ~= 0 then
                    local look  = cam.CFrame.LookVector
                    local right = cam.CFrame.RightVector

                    local fLook  = Vector3.new(look.X,  0, look.Z)
                    if fLook.Magnitude  > 0 then fLook  = fLook.Unit  end
                    local fRight = Vector3.new(right.X, 0, right.Z)
                    if fRight.Magnitude > 0 then fRight = fRight.Unit end

                    local zIn = moveDir:Dot(fLook)
                    local xIn = moveDir:Dot(fRight)
                    local dir = (fLook * zIn) + (fRight * xIn) + Vector3.new(0, vInput, 0)

                    bodyVel.Velocity = dir.Magnitude > 0
                        and dir.Unit * flySpeed
                        or  Vector3.new(0, 0, 0)
                else
                    bodyVel.Velocity = Vector3.new(0, 0, 0)
                end

                bodyGyro.CFrame = cam.CFrame
            end)

            -- مراقبة الموت → إعادة التشغيل بعد الريسبون
            if deathConn then deathConn:Disconnect() end
            deathConn = hum.Died:Connect(function()
                if not isFlying then return end
                if flyConn  then flyConn:Disconnect();                   flyConn  = nil end
                if bodyVel  then pcall(function() bodyVel:Destroy()  end); bodyVel  = nil end
                if bodyGyro then pcall(function() bodyGyro:Destroy() end); bodyGyro = nil end
                task.wait(0.2)
                local newChar = player.Character
                local newHum  = newChar and newChar:FindFirstChild("Humanoid")
                if not newChar or not newHum or newHum.Health <= 0 then
                    newChar = player.CharacterAdded:Wait()
                end
                newChar:WaitForChild("HumanoidRootPart", 10)
                newChar:WaitForChild("Humanoid", 10)
                task.wait(0.3)
                if isFlying then toggleFly(true, flySpeed) end
            end)

        else
            if flyConn  then flyConn:Disconnect();  flyConn  = nil end
            if bodyVel  then pcall(function() bodyVel:Destroy()  end); bodyVel  = nil end
            if bodyGyro then pcall(function() bodyGyro:Destroy() end); bodyGyro = nil end
            if deathConn then deathConn:Disconnect(); deathConn = nil end
            if hum then hum.PlatformStand = false end
            verticalInput = 0
        end

        syncScreenBtn()
    end

    -- ── واجهة Hub ─────────────────────────────────────────────────
    local flyDrop = Tab:AddToggleDropdown("طيران / Fly", function(active)
        toggleFly(active, flySpeed)
        if active then Notify("✈️ تم تفعيل الطيران!") end
    end)
    flyDropRef = flyDrop

    -- التحكم في السرعة
    flyDrop:AddSpeedControl("السرعة / Speed", function(_, value)
        flySpeed = value
    end, flySpeed)

    -- أزرار على الشاشة (زر طيران + صعود + نزول)
    flyDrop:AddToggle("أزرار الشاشة / Screen Buttons", function(enabled)
        setScreenGui(enabled)
    end)
end
