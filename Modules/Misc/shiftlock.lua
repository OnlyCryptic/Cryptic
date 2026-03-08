-- [[ Cryptic Hub - ميزة الشيفت لوك للجوال V5 / Mobile Shift Lock ]]
-- المطور: يامي (Yami) | التحديث: إشعار تفعيل فقط + ترجمة مزدوجة / Update: Activation notify only + Dual language

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    
    local ShiftLockActive = false
    local Connection = nil

    -- دالة الإشعارات المزدوجة / Dual notification function
    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 4,
            })
        end)
    end
    
    -- [[ 1. تصميم الواجهة (UI) - دائرة ميني وشفافة ]]
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrypticShiftLock_V5"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local success, _ = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        ScreenGui.Parent = lp:WaitForChild("PlayerGui")
    end
    ScreenGui.Enabled = false

    local ShiftButton = Instance.new("ImageButton")
    ShiftButton.Name = "ToggleButton"
    ShiftButton.Parent = ScreenGui
    ShiftButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80) -- أخضر البداية
    ShiftButton.BackgroundTransparency = 0.6 
    ShiftButton.Position = UDim2.new(0.85, 0, 0.6, 0)
    ShiftButton.Size = UDim2.new(0, 35, 0, 35)
    ShiftButton.Image = "" 
    ShiftButton.ClipsDescendants = true
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ShiftButton
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Transparency = 0.8
    UIStroke.Thickness = 1
    UIStroke.Parent = ShiftButton

    -- النص الداخلي (عربي وانجليزي)
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = ShiftButton
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = "شيفت لوك\nShift Lock"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 7
    TextLabel.TextWrapped = true
    TextLabel.TextTransparency = 0.2

    -- [[ 2. دالة التشغيل/الإيقاف ]]
    local ToggleShiftLock
    ToggleShiftLock = function(state)
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

    -- [[ 3. نظام السحب واللمس الذكي ]]
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
                        ToggleShiftLock(not ShiftLockActive)
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

    -- [[ 4. زر التحكم في الواجهة الرئيسية ]]
    Tab:AddToggle("قفل شاشة / Shift Lock", function(state)
        ScreenGui.Enabled = state 
        if state then
            ToggleShiftLock(true) 
            -- إشعار التفعيل المزدوج فقط / Activation notify only
            Notify("✅ تم التفعيل! الزر متاح الآن على الشاشة.", "✅ Activated! Button is now available on screen.")
        else
            ToggleShiftLock(false)
            -- إيقاف صامت: لا توجد إشعارات هنا
        end
    end)
end
