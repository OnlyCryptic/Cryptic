-- [[ Cryptic Hub - Auto Heal Apple / أكل التفاح الذكي + حاسبة الكول داون ]]
-- المطور: يامي (Yami) | الميزة: احترام الكول داون، حاسبة وقت، وتعديل السرعة من الواجهة

return function(Tab, UI)
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local lp = Players.LocalPlayer
    
    local isActive = false
    local isHealing = false
    local EAT_COOLDOWN = 1.5 -- السرعة الافتراضية

    -- [[ 1. دالة العلاج الذكي ]]
    local function SmartConsumeApple()
        if isHealing then return end
        isHealing = true

        local char = lp.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not char or not hum then isHealing = false return end

        local apple = nil
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "apple") or tool:FindFirstChild("Event")) then
                apple = tool; break
            end
        end
        if not apple then
            for _, tool in pairs(lp.Backpack:GetChildren()) do
                if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "apple") or tool:FindFirstChild("Event")) then
                    apple = tool; break
                end
            end
        end

        if apple then
            local currentEquipped = nil
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") and tool ~= apple then currentEquipped = tool; break end
            end

            if apple.Parent ~= char then
                hum:EquipTool(apple)
                task.wait(0.3)
            end

            while isActive and hum.Health > 0 and hum.Health < hum.MaxHealth and apple.Parent == char do
                apple:Activate() 
                task.wait(EAT_COOLDOWN) 
            end

            if hum.Health >= hum.MaxHealth or not isActive then
                if currentEquipped and currentEquipped.Parent == lp.Backpack then
                    hum:EquipTool(currentEquipped)
                else
                    hum:UnequipTools()
                end
            end
        end
        isHealing = false
    end

    -- [[ 2. واجهة حاسبة الكول داون (محدثة لتدعم كل المشغلات) ]]
    local function OpenCooldownCalculator()
        local guiName = "CrypticCooldownUI"
        
        -- التخطي الذكي لحماية المشغلات (لتجنب عدم ظهور الواجهة)
        local targetParent
        if gethui then
            targetParent = gethui()
        else
            local s, r = pcall(function() return game:GetService("CoreGui") end)
            if s and r then targetParent = r else targetParent = lp:WaitForChild("PlayerGui") end
        end

        if targetParent:FindFirstChild(guiName) then targetParent[guiName]:Destroy() end

        local sg = Instance.new("ScreenGui")
        sg.Name = guiName
        sg.ResetOnSpawn = false
        sg.Parent = targetParent

        local frame = Instance.new("Frame", sg)
        frame.Size = UDim2.new(0, 260, 0, 110)
        frame.Position = UDim2.new(0.5, -130, 0.2, 0)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        local title = Instance.new("TextLabel", frame)
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundTransparency = 1
        title.Text = "⏱️ حاسبة الكول داون | Cooldown Calc"
        title.TextColor3 = Color3.fromRGB(0, 255, 150)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14

        local status = Instance.new("TextLabel", frame)
        status.Size = UDim2.new(1, -20, 0, 40)
        status.Position = UDim2.new(0, 10, 0, 30)
        status.BackgroundTransparency = 1
        status.Text = "تدمج، ثم كل تفاحتين ورا بعض..."
        status.TextColor3 = Color3.new(1, 1, 1)
        status.Font = Enum.Font.Gotham
        status.TextSize = 13
        status.TextWrapped = true

        local closeBtn = Instance.new("TextButton", frame)
        closeBtn.Size = UDim2.new(0, 100, 0, 25)
        closeBtn.Position = UDim2.new(0.5, -50, 1, -30)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.Text = "إغلاق | Close"
        closeBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

        local dragging, dragInput, dragStart, startPos
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = frame.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        local connection
        local lastTime = 0
        local lastHealth = lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.Health or 100

        local function trackHealth(char)
            local hum = char:WaitForChild("Humanoid")
            lastHealth = hum.Health
            if connection then connection:Disconnect() end
            
            connection = hum:GetPropertyChangedSignal("Health"):Connect(function()
                if hum.Health > lastHealth then
                    local currentTime = tick()
                    if lastTime == 0 then
                        lastTime = currentTime
                        status.Text = "✅ سُجلت الزيادة! كُل مرة ثانية للقياس..."
                        status.TextColor3 = Color3.fromRGB(255, 200, 0)
                    else
                        local diff = currentTime - lastTime
                        local formatted = math.floor(diff * 10) / 10 -- تقريب دقيق
                        status.Text = "الكول داون: " .. tostring(formatted) .. " ثانية"
                        status.TextColor3 = Color3.fromRGB(0, 255, 150)
                        lastTime = currentTime 
                    end
                end
                lastHealth = hum.Health
            end)
        end

        if lp.Character then trackHealth(lp.Character) end
        lp.CharacterAdded:Connect(trackHealth)

        closeBtn.MouseButton1Click:Connect(function()
            if connection then connection:Disconnect() end
            sg:Destroy()
        end)
    end

    -- [[ 3. أزرار الواجهة الرئيسية (التفعيل، التعديل، والحاسبة) ]]
    
    Tab:AddToggle("علاج تلقائي (ذكي) | Auto Heal", function(state)
        isActive = state
        if state then
            task.spawn(function()
                while isActive do
                    local char = lp.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 and hum.Health < hum.MaxHealth and not isHealing then
                        SmartConsumeApple()
                    end
                    task.wait(0.5)
                end
            end)
        end
    end)

    -- ميزة جديدة: خانة لكتابة سرعة الأكل مباشرة (الافتراضي 1.5)
    Tab:AddInput("وقت الكول داون | Cooldown Time", "اكتب الرقم (مثال: 1.5)", function(text)
        local newNumber = tonumber(text)
        if newNumber then
            EAT_COOLDOWN = newNumber
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "نجاح", Text = "تم تغيير السرعة إلى: " .. tostring(newNumber) .. " ثانية", Duration = 3
            })
        end
    end)

    Tab:AddButton("⏱️ فتح حاسبة الكول داون | Open Calc UI", function()
        pcall(function() OpenCooldownCalculator() end)
    end)
    
    Tab:AddLine()
end
