-- [[ Cryptic Hub - Mobile Shift Lock V6.1 ]]
return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local ShiftLockActive = false
    local WasActiveBeforeSitting = false
    local Connection = nil
    local SitConnection = nil

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = text,
                Duration = 4,
            })
        end)
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrypticShiftLock_V6.1"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local success, _ = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not success then ScreenGui.Parent = lp:WaitForChild("PlayerGui") end
    ScreenGui.Enabled = false

    local ShiftButton = Instance.new("ImageButton")
    ShiftButton.Name = "ToggleButton"
    ShiftButton.Parent = ScreenGui
    ShiftButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    ShiftButton.BackgroundTransparency = 0.6

    ShiftButton.Position = UDim2.new(1, -75, 0.35, 0)
    ShiftButton.Size = UDim2.new(0, 25, 0, 25)
    ShiftButton.AnchorPoint = Vector2.new(0.5, 0.5)
    ShiftButton.Image = ""
    ShiftButton.ClipsDescendants = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ShiftButton

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 100, 0)
    UIStroke.Transparency = 0.2
    UIStroke.Thickness = 1.5
    UIStroke.Parent = ShiftButton

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = ShiftButton
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = "Shift\nLock"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 7
    TextLabel.TextWrapped = true

    local function UpdateShiftLock(state)
        ShiftLockActive = state
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if ShiftLockActive then
            ShiftButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
            if hum then
                hum.CameraOffset = Vector3.new(1.75, 0, 0)
                hum.AutoRotate = false
            end
            if Connection then Connection:Disconnect() end
            Connection = RunService.RenderStepped:Connect(function()
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                    local charRoot = lp.Character.HumanoidRootPart
                    local camLook = Camera.CFrame.LookVector
                    charRoot.CFrame = CFrame.new(charRoot.Position, charRoot.Position + Vector3.new(camLook.X, 0, camLook.Z))
                end
            end)
        else
            ShiftButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            if hum then
                hum.CameraOffset = Vector3.new(0, 0, 0)
                hum.AutoRotate = true
            end
            if Connection then Connection:Disconnect(); Connection = nil end
        end
    end

    local function MonitorSitting(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end

        if SitConnection then SitConnection:Disconnect() end
        SitConnection = hum:GetPropertyChangedSignal("Sit"):Connect(function()
            if hum.Sit then
                if ShiftLockActive then
                    WasActiveBeforeSitting = true
                    UpdateShiftLock(false)
                else
                    WasActiveBeforeSitting = false
                end
            else
                if WasActiveBeforeSitting then
                    UpdateShiftLock(true)
                end
            end
        end)
    end

    if lp.Character then MonitorSitting(lp.Character) end
    lp.CharacterAdded:Connect(MonitorSitting)

    local dragging, dragInput, dragStart, startPos
    local touchTime = 0

    ShiftButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ShiftButton.Position
            touchTime = tick()

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if tick() - touchTime < 0.2 then
                        local char = lp.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Sit then return end

                        WasActiveBeforeSitting = not ShiftLockActive
                        UpdateShiftLock(not ShiftLockActive)
                    end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            ShiftButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    Tab:AddToggle(T("misc.shiftlock.label"), function(state)
        ScreenGui.Enabled = state
        if state then
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if hum and hum.Sit then
                WasActiveBeforeSitting = true
                UpdateShiftLock(false)
            else
                WasActiveBeforeSitting = true
                UpdateShiftLock(true)
            end
            Notify(T("misc.shiftlock.on"))
        else
            WasActiveBeforeSitting = false
            UpdateShiftLock(false)
        end
    end)
end
