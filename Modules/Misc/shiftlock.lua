-- [[ Cryptic Hub - ميزة الشيفت لوك للجوال V6.1 / Mobile Shift Lock ]]
-- المطور: يامي (Yami) | التحديث: نظام ذكي للجلوس + مكان جديد ومعدل + دمج الأكواد

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    
    local ShiftLockActive = false
    local WasActiveBeforeSitting = false -- المتغير الذكي لحفظ حالة الشفت لوك قبل الجلوس
    local Connection = nil
    local SitConnection = nil

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
    
    -- [[ 1. تصميم الواجهة (UI) - مكان معدل وحجم أصغر وإطار برتقالي ]]
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
    ShiftButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80) -- أخضر البداية
    ShiftButton.BackgroundTransparency = 0.6 
    
    -- المكان الافتراضي المعدل (مرفوع قليلاً للأعلى)
    ShiftButton.Position = UDim2.new(1, -75, 0.35, 0) -- تم تعديل Y إلى 0.55 لرفعه
    
    -- الحجم المعدل (أصغر للنصف تقريباً)
    ShiftButton.Size = UDim2.new(0, 25, 0, 25) -- تم تعديل الحجم إلى 25x25
    ShiftButton.AnchorPoint = Vector2.new(0.5, 0.5)
    ShiftButton.Image = "" 
    ShiftButton.ClipsDescendants = true
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ShiftButton
    
    -- الإطار البرتقالي 
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 100, 0)
    UIStroke.Transparency = 0.2
    UIStroke.Thickness = 1.5 -- تم تقليل السمك قليلاً ليتناسب مع الحجم الصغير
    UIStroke.Parent = ShiftButton

    -- النص الداخلي
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = ShiftButton
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = "Shift\nLock"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 7 -- تم تصغير حجم النص ليتناسب مع حجم الزر
    TextLabel.TextWrapped = true

    -- [[ 2. دالة التشغيل/الإيقاف الأساسية ]]
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

    -- [[ 3. نظام المراقبة الذكي للجلوس والنهوض ]]
    local function MonitorSitting(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        
        if SitConnection then SitConnection:Disconnect() end
        SitConnection = hum:GetPropertyChangedSignal("Sit"):Connect(function()
            if hum.Sit then
                -- إذا جلس: احفظ الحالة وأطفئ الشفت لوك فوراً
                if ShiftLockActive then
                    WasActiveBeforeSitting = true
                    UpdateShiftLock(false)
                else
                    WasActiveBeforeSitting = false
                end
            else
                -- إذا نهض: أعد تشغيله فقط إذا كان شغال قبل الجلوس
                if WasActiveBeforeSitting then
                    UpdateShiftLock(true)
                end
            end
        end)
    end

    if lp.Character then MonitorSitting(lp.Character) end
    lp.CharacterAdded:Connect(MonitorSitting)

    -- [[ 4. نظام السحب واللمس الذكي ]]
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
                    -- إذا كانت ضغطة سريعة (أقل من 0.2 ثانية) نعتبرها كليك وليست سحب
                    if tick() - touchTime < 0.2 then
                        local char = lp.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        -- منع التشغيل اليدوي إذا كان اللاعب جالساً
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

    -- [[ 5. زر التحكم في الواجهة الرئيسية ]]
    Tab:AddToggle("قفل شاشة / Shift Lock", function(state)
        ScreenGui.Enabled = state 
        if state then
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            -- إذا فعل الميزة من الواجهة وهو جالس، نحفظها كمفعلة لكن لا نشغلها إلا لما يقوم
            if hum and hum.Sit then
                WasActiveBeforeSitting = true
                UpdateShiftLock(false)
            else
                WasActiveBeforeSitting = true
                UpdateShiftLock(true) 
            end
            Notify("✅ تم التفعيل! الزر متاح الآن على الشاشة.", "✅ Activated! Button is now available on screen.")
        else
            WasActiveBeforeSitting = false
            UpdateShiftLock(false)
        end
    end)
end
