-- [[ Cryptic Hub - أداة الحركة السرية (Smart Rig Tool V3.3) ]]
-- المطور: يامي (Yami) | الميزات: إخفاء صامت عند الإيقاف بدون إشعارات مزعجة

return function(Tab, UI)
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local UserInputService = game:GetService("UserInputService")
    local lp = Players.LocalPlayer
    
    local isActive = false
    local isProcessing = false
    local hasLoadedOnce = false 
    local toolNames = {["Jerk Off"] = true, ["Jerk Off R15"] = true}
    
    local lastCharacter = nil
    local hasSortedThisLife = false

    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 3 })
        end)
    end

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
        btn.BackgroundTransparency = 0.75 
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = "Jerk Tool" 
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10 
        btn.Active = true
        btn.Parent = sg
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = btn

        local dragging = false
        local dragInput, dragStart, startPos
        local hasMoved = false

        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                hasMoved = false
                dragStart = input.Position
                startPos = btn.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
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
            
            for _, t in pairs(char:GetChildren()) do
                if toolNames[t.Name] then
                    hum:UnequipTools()
                    return
                end
            end
            
            for _, t in pairs(lp.Backpack:GetChildren()) do
                if toolNames[t.Name] then
                    hum:EquipTool(t)
                    return
                end
            end
        end)
    end

    local function RemoveCustomInventory()
        local ui = lp.PlayerGui:FindFirstChild("CrypticJerkUI")
        if ui then ui:Destroy() end
    end

    local function DetectRigType(char)
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if hum.RigType == Enum.HumanoidRigType.R15 then return "R15" end
            if hum.RigType == Enum.HumanoidRigType.R6 then return "R6" end
        end
        if char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("RightFoot") then return "R15"
        elseif char:FindFirstChild("Torso") and not char:FindFirstChild("UpperTorso") then return "R6" end
        return "Unknown"
    end

    local function LoadBothScripts()
        if hasLoadedOnce then return end 
        pcall(function()
            loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))() 
            task.wait(0.5)
            loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))() 
            hasLoadedOnce = true
        end)
    end

    local function EnforceSlot2(targetTool)
        local backpack = lp.Backpack
        local otherTools = {}

        for _, t in pairs(backpack:GetChildren()) do
            if not toolNames[t.Name] and t ~= targetTool then table.insert(otherTools, t) end
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
        else
            return false
        end
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
        
        local foundTool = nil
        for _, t in pairs(char:GetChildren()) do if toolNames[t.Name] then foundTool = t break end end
        if not foundTool then 
            for _, t in pairs(lp.Backpack:GetChildren()) do if toolNames[t.Name] then foundTool = t break end end 
        end

        local rigType = DetectRigType(char)

        if not foundTool and not hasLoadedOnce then 
            if rigType == "R15" then
                pcall(function() loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))(); hasLoadedOnce = true end)
            elseif rigType == "R6" then
                pcall(function() loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))(); hasLoadedOnce = true end)
            else
                LoadBothScripts()
                SendRobloxNotification("Cryptic Hub", "⚠️ لم نتمكن من كشف النوع! تم تفعيل الاثنين | Unknown rig, both loaded")
                hasSortedThisLife = true
            end

            local tries = 0
            repeat 
                task.wait(0.5)
                tries = tries + 1
                foundTool = lp.Backpack:FindFirstChild("Jerk Off") or lp.Backpack:FindFirstChild("Jerk Off R15") or char:FindFirstChild("Jerk Off") or char:FindFirstChild("Jerk Off R15")
            until foundTool or tries > 10
        end

        if foundTool and not hasSortedThisLife then
            if foundTool.Parent == char then foundTool.Parent = lp.Backpack end
            local success = EnforceSlot2(foundTool)
            if not success and rigType ~= "Unknown" and not hasLoadedOnce then LoadBothScripts() end
            
            EnsureCustomInventory()
            hasSortedThisLife = true 
        end
        
        task.wait(1)
        isProcessing = false
    end

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
            -- 🟢 تم إزالة إشعار "تم الإيقاف" من هنا
            RemoveCustomInventory()
        end
    end)
end
