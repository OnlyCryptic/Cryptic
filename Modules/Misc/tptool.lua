-- [[ Cryptic Hub - ميزة أداة الانتقال الملكية / Royal TP Tool Feature ]]
-- المطور: يامي (Yami) | التحديث: واجهة علوية صغيرة جداً + تحريك بإصبعين فقط للموبايل + إصلاح الهاندل

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    local UserInputService = game:GetService("UserInputService")
    local keepGiving = false

    -- دالة إرسال الإشعارات المزدوجة
    local function SendScreenNotify(title, text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 4
            })
        end)
    end

    -- واجهة مخصصة لتجهيز الأداة صغيرة، شفافة، وقابلة للتحريك بإصبعين
    local function EnsureCustomInventory()
        if player.PlayerGui:FindFirstChild("CrypticTP_UI") then return end
        
        local sg = Instance.new("ScreenGui")
        sg.Name = "CrypticTP_UI"
        sg.ResetOnSpawn = false
        sg.Parent = player.PlayerGui
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 70, 0, 22) -- 🟢 حجم صغير جداً (70x22)
        btn.Position = UDim2.new(0.5, -35, 0, 15) -- 🟢 الموقع: فوق في المنتصف تماماً
        btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        btn.BackgroundTransparency = 0.5 
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = "TP Tool" -- 🟢 اسم مختصر ليناسب الحجم الصغير
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.Active = true
        btn.Parent = sg
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn

        -- كود السحب والتحريك (Draggable) - معدل ليعمل بإصبعين فقط على الجوال
        local dragging = false
        local dragInput, dragStart, startPos
        local hasMoved = false

        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = btn.Position
                hasMoved = false

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
                local isTouch = input.UserInputType == Enum.UserInputType.Touch
                local touches = UserInputService:GetTouches()
                
                -- 🟢 الشرط: إذا كان موبايل (Touch) لازم إصبعين على الأقل في الشاشة عشان يتحرك! (أو ماوس للكمبيوتر)
                if (isTouch and #touches >= 2) or (input.UserInputType == Enum.UserInputType.MouseMovement) then
                    local delta = input.Position - dragStart
                    btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    if delta.Magnitude > 5 then
                        hasMoved = true -- لتسجيل أنه تم التحريك لمنع الضغط عليه بالخطأ
                    end
                end
            end
        end)

        -- وظيفة الزر وتجهيز الأداة
        btn.MouseButton1Click:Connect(function()
            if hasMoved then return end -- 🟢 إذا كان اللاعب يسحب الزر، لا تعتبرها ضغطة تشغيل
            
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if not hum then return end
            
            local equipped = char:FindFirstChild("Cryptic TP")
            if equipped then
                hum:UnequipTools()
            else
                local inBackpack = player.Backpack:FindFirstChild("Cryptic TP")
                if inBackpack then
                    hum:EquipTool(inBackpack)
                end
            end
        end)
        
        task.spawn(function()
            while sg.Parent do
                local char = player.Character
                if char and char:FindFirstChild("Cryptic TP") then
                    btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- أخضر
                else
                    btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- أحمر
                end
                task.wait(0.2)
            end
        end)
    end

    local function RemoveCustomInventory()
        local ui = player.PlayerGui:FindFirstChild("CrypticTP_UI")
        if ui then ui:Destroy() end
    end

    local function ForceSlotOne(tool)
        local backpack = player:FindFirstChild("Backpack")
        if not backpack or not tool then return end

        local otherTools = {}
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item ~= tool then
                table.insert(otherTools, item)
                item.Parent = nil 
            end
        end

        tool.Parent = backpack
        task.wait(0.05) 

        for _, item in pairs(otherTools) do
            item.Parent = backpack
        end
    end

    -- وظيفة إنشاء الأداة (مع الهاندل الوهمي)
    local function giveTPTool()
        local backpack = player:FindFirstChild("Backpack")
        if not backpack then return end

        local existing = backpack:FindFirstChild("Cryptic TP") or (player.Character and player.Character:FindFirstChild("Cryptic TP"))
        if existing then
            ForceSlotOne(existing)
            return
        end

        local tool = Instance.new("Tool")
        tool.Name = "Cryptic TP"
        tool.RequiresHandle = true -- 🟢 تفعيل الـ Handle لكي تعمل الأداة
        tool.ToolTip = "Cryptic Hub | Click to Teleport"

        -- 🟢 مقبض (Handle) وهمي ومخفي لكي تقرأ اللعبة الضغطة وتنقلك
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(0.5, 0.5, 0.5)
        handle.Transparency = 1 
        handle.CanCollide = false
        handle.Massless = true
        handle.Parent = tool

        tool.Activated:Connect(function()
            local pos = mouse.Hit.p
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            end
        end)

        ForceSlotOne(tool)
    end

    player.CharacterAdded:Connect(function()
        if keepGiving then
            task.wait(1.5) 
            giveTPTool()
        end
    end)

    Tab:AddToggle("أداة الانتقال / TP Tool", function(active)
        keepGiving = active
        if active then
            giveTPTool()
            EnsureCustomInventory()
            SendScreenNotify("Cryptic Hub", "✨ تم التفعيل: أداة الانتقال الآن في الخانة 1\n✨ Activated: TP Tool now in Slot 1")
        else
            local t = player.Backpack:FindFirstChild("Cryptic TP") or (player.Character and player.Character:FindFirstChild("Cryptic TP"))
            if t then t:Destroy() end
            RemoveCustomInventory()
        end
    end)
end
