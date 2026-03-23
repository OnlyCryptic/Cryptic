-- [[ Cryptic Hub - معاينة سكن الهدف / Preview Target Skin ]]
-- يعرض شخصية الهدف عندك أنت بس محلياً

return function(Tab, UI)
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer

    local previewGui = nil
    local rotConn = nil
    local isActive = false

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = ar .. "\n" .. en,
                Duration = 3
            })
        end)
    end

    local function StopPreview()
        isActive = false
        if rotConn then rotConn:Disconnect() rotConn = nil end
        if previewGui then previewGui:Destroy() previewGui = nil end
    end

    Tab:AddToggle("معاينة سكن الهدف / Preview Skin", function(active)
        if active then
            local target = _G.ArwaTarget
            if not target or not target.Character then
                Notify("⚠️ حدد لاعباً أولاً!", "⚠️ Select a player first!")
                return
            end

            isActive = true

            -- سوي ScreenGui
            previewGui = Instance.new("ScreenGui")
            previewGui.Name = "CrypticSkinPreview"
            previewGui.ResetOnSpawn = false
            pcall(function() previewGui.Parent = CoreGui end)
            if not previewGui.Parent then previewGui.Parent = lp:WaitForChild("PlayerGui") end

            -- إطار خلفي
            local frame = Instance.new("Frame", previewGui)
            frame.Size = UDim2.new(0, 130, 0, 200)
            frame.Position = UDim2.new(0, 15, 0.5, -100)
            frame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
            frame.BackgroundTransparency = 0.1
            frame.Active = true
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
            local stroke = Instance.new("UIStroke", frame)
            stroke.Thickness = 1.5
            local grad = Instance.new("UIGradient", stroke)
            grad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
            }

            -- اسم الهدف
            local nameLbl = Instance.new("TextLabel", frame)
            nameLbl.Size = UDim2.new(1, 0, 0, 22)
            nameLbl.Position = UDim2.new(0, 0, 0, 4)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = target.DisplayName
            nameLbl.TextColor3 = Color3.fromRGB(0, 220, 130)
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextSize = 11
            nameLbl.TextWrapped = true

            -- زر الإغلاق
            local closeBtn = Instance.new("TextButton", frame)
            closeBtn.Size = UDim2.new(0, 20, 0, 20)
            closeBtn.Position = UDim2.new(1, -24, 0, 4)
            closeBtn.BackgroundTransparency = 1
            closeBtn.Text = "✕"
            closeBtn.TextColor3 = Color3.fromRGB(200, 75, 75)
            closeBtn.Font = Enum.Font.GothamBold
            closeBtn.TextSize = 12
            closeBtn.MouseButton1Click:Connect(StopPreview)

            -- ViewportFrame لعرض الشخصية
            local viewport = Instance.new("ViewportFrame", frame)
            viewport.Size = UDim2.new(1, -10, 1, -30)
            viewport.Position = UDim2.new(0, 5, 0, 28)
            viewport.BackgroundTransparency = 1
            viewport.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            viewport.Ambient = Color3.fromRGB(180, 180, 180)
            viewport.LightColor = Color3.fromRGB(255, 255, 255)
            viewport.LightDirection = Vector3.new(-1, -2, -1)
            Instance.new("UICorner", viewport).CornerRadius = UDim.new(0, 8)

            -- نسخ شخصية الهدف في الـ ViewportFrame
            local clonedChar = target.Character:Clone()
            -- شيل السكربتات عشان ما تسبب مشاكل
            for _, v in pairs(clonedChar:GetDescendants()) do
                if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
                    v:Destroy()
                end
            end
            -- شيل الـ HumanoidRootPart Animations
            local hum = clonedChar:FindFirstChildOfClass("Humanoid")
            if hum then
                local animator = hum:FindFirstChildOfClass("Animator")
                if animator then animator:Destroy() end
            end

            clonedChar.Parent = viewport

            -- كاميرا الـ ViewportFrame
            local vpCam = Instance.new("Camera", viewport)
            viewport.CurrentCamera = vpCam

            -- نحط الكاميرا تشوف الشخصية
            local rootPart = clonedChar:FindFirstChild("HumanoidRootPart")
            if rootPart then
                vpCam.CFrame = CFrame.new(
                    rootPart.Position + Vector3.new(0, 1, 4.5),
                    rootPart.Position + Vector3.new(0, 1, 0)
                )
            end

            -- دوران تلقائي للشخصية
            local angle = 0
            rotConn = RunService.RenderStepped:Connect(function(dt)
                if not isActive then return end
                angle = angle + dt * 40 -- سرعة الدوران
                if rootPart and rootPart.Parent then
                    clonedChar:SetPrimaryPartCFrame(
                        CFrame.new(rootPart.Position) * CFrame.Angles(0, math.rad(angle), 0)
                    )
                end

                -- تحديث اسم الهدف لو تغير
                if _G.ArwaTarget then
                    nameLbl.Text = _G.ArwaTarget.DisplayName
                end
            end)

            -- سحب الإطار
            local dragging, dragStart, startPos
            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = frame.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)
            local UIS = game:GetService("UserInputService")
            UIS.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                                 input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - dragStart
                    frame.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end)

            Notify("👁️ تعرض سكن: " .. target.DisplayName, "👁️ Previewing: " .. target.DisplayName)

        else
            StopPreview()
        end
    end)

    Tab:AddLine()
end
