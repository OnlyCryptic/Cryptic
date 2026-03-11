-- [[ Cryptic Walk Fling - PC & Mobile Friendly ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- انتظار تحميل الشخصية والواجهة
repeat task.wait() until LocalPlayer.Character and LocalPlayer:FindFirstChildOfClass("PlayerGui")

-- إنشاء الواجهة 
local gui = Instance.new("ScreenGui")
gui.Name = "CrypticWalkFling"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 180, 0, 50)
toggle.Position = UDim2.new(0.5, -90, 0.1, 0) -- كيبدا الفوق باش ما يغطيش أزرار اللعب
toggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggle.TextColor3 = Color3.fromRGB(0, 255, 150)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 16
toggle.Text = "Walk Fling: OFF"
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", toggle)
stroke.Color = Color3.fromRGB(0, 255, 150)
stroke.Thickness = 2
toggle.Parent = gui

-- [[ ميزة السحب (Dragging) للحاسوب والهواتف ]]
local dragging, dragInput, dragStart, startPos
toggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggle.Position
    end
end)
toggle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        toggle.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
toggle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- [[ نظام الـ Walk Fling الكارثي (بدون اهتمام بـ FPS) ]]
local flingEnabled = false
local connection

toggle.MouseButton1Click:Connect(function()
    flingEnabled = not flingEnabled
    
    -- تغيير اللون والنص حسب الحالة
    toggle.Text = flingEnabled and "Walk Fling: ON" or "Walk Fling: OFF"
    toggle.TextColor3 = flingEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 150)
    stroke.Color = toggle.TextColor3

    if connection then connection:Disconnect() end
    
    if flingEnabled then
        connection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            -- تطبيق الدفع بقوة 750,000 على أي شخص يلمسك
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Touched:Connect(function(hit)
                        local target = hit.Parent
                        local targetRoot = target and target:FindFirstChild("HumanoidRootPart")
                        
                        -- التأكد أنه لاعب آخر وليس شخصيتك
                        if targetRoot and target ~= char then
                            local strength = 750000 
                            local dir = (targetRoot.Position - root.Position).Unit
                            targetRoot.Velocity = dir * strength + Vector3.new(0, strength/10, 0)
                        end
                    end)
                end
            end
        end)
    end
end)
