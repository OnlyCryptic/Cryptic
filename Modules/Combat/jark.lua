-- [[ Cryptic Hub - أداة الحركة السرية (Standalone Built-in V5) ]]
-- المطور: يامي | الميزات: إصلاح الاهتزاز (Memory Leak)، حركة يد واضحة، وتنظيف تلقائي

return function(Tab, UI)
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local UserInputService = game:GetService("UserInputService")
    local lp = Players.LocalPlayer
    
    local isActive = false
    local isProcessing = false
    local lastCharacter = nil
    local hasSortedThisLife = false

    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 3 })
        end)
    end

    -- ==========================================
    -- واجهة الزر العائم (UI)
    -- ==========================================
    local function EnsureCustomInventory()
        if lp.PlayerGui:FindFirstChild("CrypticJerkUI") then return end
        
        local sg = Instance.new("ScreenGui")
        sg.Name = "CrypticJerkUI"
        sg.ResetOnSpawn = false
        sg.Parent = lp.PlayerGui
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 55, 0, 18) 
        btn.Position = UDim2.new(0.5, 30, 0, 15) 
        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        btn.BackgroundTransparency = 0.60 
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = "Jerk Tool" 
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10 
        btn.Active = true
        btn.Parent = sg
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = btn

        local dragging, dragInput, dragStart, startPos, hasMoved = false, nil, nil, nil, false

        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                hasMoved = false
                dragStart = input.Position
                startPos = btn.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)

        btn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                if delta.Magnitude > 3 then 
                    hasMoved = true
                    btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end
        end)

        btn.MouseButton1Click:Connect(function()
            if hasMoved then return end 
            
            local char = lp.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if not hum then return end
            
            local toolInChar = char:FindFirstChild("Jerk Off")
            local toolInBackpack = lp.Backpack:FindFirstChild("Jerk Off")

            if toolInChar then
                hum:UnequipTools()
            elseif toolInBackpack then
                hum:EquipTool(toolInBackpack)
            end
        end)
    end

    local function RemoveCustomInventory()
        local ui = lp.PlayerGui:FindFirstChild("CrypticJerkUI")
        if ui then ui:Destroy() end
    end

    -- ==========================================
    -- صناعة الأداة برمجياً (إصلاح الأنميشن والاهتزاز)
    -- ==========================================
    local function CreateJerkTool(char)
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        local backpack = lp:FindFirstChildWhichIsA("Backpack")
        if not humanoid or not backpack then return nil end

        local existingTool = backpack:FindFirstChild("Jerk Off") or char:FindFirstChild("Jerk Off")
        if existingTool then return existingTool end

        local tool = Instance.new("Tool")
        tool.Name = "Jerk Off"
        tool.RequiresHandle = false
        tool.Parent = backpack

        local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
        local jorkin = false
        local track = nil

        local function stopTomfoolery()
            jorkin = false
            if track then track:Stop() end
        end

        tool.Equipped:Connect(function() jorkin = true end)
        tool.Unequipped:Connect(stopTomfoolery)
        humanoid.Died:Connect(stopTomfoolery)

        task.spawn(function()
            -- 🔴 تحميل الأنميشن مرة واحدة فقط لمنع اللاقات والاهتزاز
            local anim = Instance.new("Animation")
            anim.AnimationId = isR15 and "rbxassetid://698251653" or "rbxassetid://72042024"
            track = humanoid:LoadAnimation(anim)
            track.Priority = Enum.AnimationPriority.Action -- 🔴 إجبار اليد على الحركة فوق المشي

            while tool.Parent do 
                task.wait()
                if not jorkin then continue end

                track:Play()
                track:AdjustSpeed(isR15 and 0.7 or 0.65)
                track.TimePosition = 0.6
                
                local targetTime = isR15 and 0.7 or 0.65
                
                while jorkin and track.TimePosition < targetTime do 
                    task.wait() 
                end
                
                track:Stop()
            end
            
            -- تدمير الأنميشن عند مسح الأداة لتنظيف الذاكرة
            if track then track:Stop() track:Destroy() end
        end)

        return tool
    end

    -- ==========================================
    -- الترتيب وإدارة العملية
    -- ==========================================
    local function EnforceSlot2(targetTool)
        local backpack = lp.Backpack
        if not backpack then return false end
        
        local otherTools = {}
        for _, t in pairs(backpack:GetChildren()) do
            if t.Name ~= "Jerk Off" and t ~= targetTool then table.insert(otherTools, t) end
        end

        if #otherTools > 0 then
            local firstTool = otherTools[1]
            local tempFolder = Instance.new("Folder")
            firstTool.Parent = tempFolder
            targetTool.Parent = tempFolder
            for i = 2, #otherTools do otherTools[i].Parent = tempFolder end

            task.wait(0.05)

            firstTool.Parent = backpack
            targetTool.Parent = backpack
            for i = 2, #otherTools do otherTools[i].Parent = backpack end
            
            tempFolder:Destroy()
            return true
        end
        return false
    end

    local function ExecuteToolProcess()
        if isProcessing then return end
        isProcessing = true
        
        local char = lp.Character
        if not char then isProcessing = false return end

        if lastCharacter ~= char then
            lastCharacter = char
            hasSortedThisLife = false
            task.wait(1)
        end
        
        local foundTool = CreateJerkTool(char)

        if foundTool and not hasSortedThisLife then
            if foundTool.Parent == char then foundTool.Parent = lp.Backpack end
            EnforceSlot2(foundTool)
            EnsureCustomInventory()
            hasSortedThisLife = true 
        end
        
        task.wait(1)
        isProcessing = false
    end

    -- ==========================================
    -- زر التفعيل (Toggle)
    -- ==========================================
    Tab:AddToggle("أداة عاده سريه / Jerk tool ", function(state)
        isActive = state
        if state then
            SendRobloxNotification("Cryptic Hub", "🔄 تفعيل | Activated")
            lastCharacter = nil
            hasSortedThisLife = false

            task.spawn(function()
                while isActive do
                    if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.Health > 0 then
                        ExecuteToolProcess()
                    end
                    task.wait(2)
                end
            end)
        else
            RemoveCustomInventory()
            
            -- مسح الأداة برمجياً عند الإيقاف
            if lp.Backpack:FindFirstChild("Jerk Off") then lp.Backpack:FindFirstChild("Jerk Off"):Destroy() end
            if lp.Character and lp.Character:FindFirstChild("Jerk Off") then lp.Character:FindFirstChild("Jerk Off"):Destroy() end
            
            -- 🔴 منظف الأنميشن: يوقف أي حركة عالقة تعيق المشي!
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                for _, animTrack in pairs(lp.Character.Humanoid:GetPlayingAnimationTracks()) do
                    if animTrack.Animation.AnimationId == "rbxassetid://698251653" or animTrack.Animation.AnimationId == "rbxassetid://72042024" then
                        animTrack:Stop()
                    end
                end
            end
            
            SendRobloxNotification("Cryptic Hub", "🛑 تم الإيقاف | Deactivated")
        end
    end)
    
    Tab:AddLine()
end
