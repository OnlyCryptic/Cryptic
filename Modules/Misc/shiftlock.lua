-- [[ Cryptic Hub - ميزة الشيفت لوك للجوال V5 ]]
-- المطور: يامي (Yami) | التحديث: تفعيل تلقائي (أخضر)، حجم ميني، ولمس ذكي للجوال

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    
    local ShiftLockActive = false
    local Connection = nil

    -- دالة إشعارات روبلوكس الأصلية
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 4,
            })
        end)
    end
    
    -- [[ 1. تصميم الواجهة (UI) - دائرة ميني وشفافة ]]
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrypticShiftLock_V5"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- حماية الواجهة
    local success, _ = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        ScreenGui.Parent = lp:WaitForChild("PlayerGui")
    end
    ScreenGui.Enabled = false

    -- الدائرة الخارجية (الحجم الميني 35x35)
    local ShiftButton = Instance.new("ImageButton")
    ShiftButton.Name = "ToggleButton"
    ShiftButton.Parent = ScreenGui
    ShiftButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80) -- يبدأ باللون الأخضر!
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

    -- النص الداخلي
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = ShiftButton
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = "شيفت\nلوك"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 8
    TextLabel.TextWrapped = true
    TextLabel.TextTransparency = 0.2

    -- [[ 2. دالة التشغيل/الإيقاف ]]
    local ToggleShiftLock -- تعريف مسبق للدالة عشان نستخدمها باللمس
    ToggleShiftLock = function(state)
        ShiftLockActive = state
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if ShiftLockActive then
            -- تفعيل (أخضر شفاف)
            ShiftButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
            
            if hum then 
                hum.CameraOffset = Vector3.new(1.75, 0, 0)
                hum.AutoRotate = false
            end
            
            if Connection then Connection:Disconnect() end
            Connection = RunService.RenderStepped:Connect(function()
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character:FindFirstChild("Humanoid") then
                    local charRoot = lp.Character.HumanoidRootPart
                    local camLook = Camera.CFrame.LookVector
                    charRoot.CFrame = CFrame.new(charRoot.Position, charRoot.Position + Vector3.new(camLook.X, 0, camLook.Z))
                else
                    if Connection then Connection:Disconnect() Connection = nil end
                end
            end)
        else
            -- إيقاف (أحمر شفاف)
            ShiftButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            
            if hum then 
                hum.CameraOffset = Vector3.new(0, 0, 0)
                hum.AutoRotate = true
            end
            if Connection then
                Connection:Disconnect()
                Connection = nil
            end
        end
    end

    -- [[ 3. نظام السحب (Dragging) واللمس الذكي للجوال ]]
    local dragging, dragInput, dragStart, startPos
    local touchTime = 0 -- لحساب وقت اللمس (عشان نفرق بين الضغطة والسحبة)
    
    local function update(input)
        local delta = input.Position - dragStart
        ShiftButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    ShiftButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ShiftButton.Position
            touchTime = tick() -- تسجيل وقت بداية اللمس
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    -- إذا كانت اللمسة سريعة (أقل من 0.2 ثانية)، اعتبرها ضغطة زر لتغيير اللون
                    if tick() - touchTime < 0.2 then
                        ToggleShiftLock(not ShiftLockActive)
                    end
                end
            end)
        end
    end)
    
    ShiftButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- [[ 4. زر التحكم في الواجهة الرئيسية ]]
    Tab:AddToggle("قفل شاشه / shift lock", function(state)
        ScreenGui.Enabled = state 
        
        if state then
            -- [[ التعديل هنا: يشتغل تلقائي (أخضر) أول ما تفعله من السكربت ]]
            ToggleShiftLock(true) 
            SendRobloxNotification("Cryptic Hub", "✅ تم التفعيل! الشيفت لوك يعمل الآن.")
        else
            ToggleShiftLock(false)
            SendRobloxNotification("Cryptic Hub", "❌ تم إخفاء الزر وإلغاء الخاصية.")
        end
    end)
    
    Tab:AddLine()
end
