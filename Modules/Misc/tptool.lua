-- [[ Cryptic Hub - ميزة أداة الانتقال الملكية / Royal TP Tool Feature ]]
-- المطور: يامي (Yami) | التحديث: إشعارات التفعيل فقط + ترجمة مزدوجة + زر تجهيز ذكي ملون

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    local UserInputService = game:GetService("UserInputService")
    local keepGiving = false

    -- دالة إرسال الإشعارات المزدوجة / Dual screen notification function
    local function SendScreenNotify(title, text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 4
            })
        end)
    end

    -- واجهة مخصصة لتجهيز الأداة صغيرة، شفافة، وقابلة للتحريك (أحمر/أخضر)
    local function EnsureCustomInventory()
        if player.PlayerGui:FindFirstChild("CrypticTP_UI") then return end
        
        local sg = Instance.new("ScreenGui")
        sg.Name = "CrypticTP_UI"
        sg.ResetOnSpawn = false
        sg.Parent = player.PlayerGui
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 0, 25) -- حجم صغير جداً
        btn.Position = UDim2.new(1, -110, 0.55, 0) -- تحت الزر الأول بشوي لو كانوا شغالين سوا
        btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- أحمر (غير مجهز) افتراضياً
        btn.BackgroundTransparency = 0.5 -- شفافية 50%
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = "أداة انتقال/Equip TP"
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 12
        btn.Active = true
        btn.Parent = sg
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn

        -- كود السحب والتحريك (Draggable)
        local dragging = false
        local dragInput, dragStart, startPos

        local function update(input)
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end

        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
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
                update(input)
            end
        end)

        -- وظيفة الزر وتجهيز الأداة
        btn.MouseButton1Click:Connect(function()
            if dragging then return end 
            
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
        
        -- حلقة للتحقق من حالة الأداة وتحديث اللون تلقائياً (أخضر = مجهز / أحمر = غير مجهز)
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

    -- دالة إخفاء الواجهة المخصصة عند الإيقاف
    local function RemoveCustomInventory()
        local ui = player.PlayerGui:FindFirstChild("CrypticTP_UI")
        if ui then ui:Destroy() end
    end

    -- وظيفة تنظيم الحقيبة لضمان الخانة رقم 1 / Organize backpack to ensure Slot 1
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

    -- وظيفة إنشاء الأداة / Tool creation function
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
        tool.RequiresHandle = false
        tool.ToolTip = "Cryptic Hub | Slot 1 Guaranteed"

        -- حدث النقر للانتقال / Click to teleport event
        tool.Activated:Connect(function()
            local pos = mouse.Hit.p
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            end
        end)

        ForceSlotOne(tool)
    end

    -- نظام العودة بعد الموت / Re-give after death system
    player.CharacterAdded:Connect(function()
        if keepGiving then
            task.wait(1.5) 
            giveTPTool()
        end
    end)

    -- إضافة الزر للواجهة بنظام التبديل / Toggle button
    Tab:AddToggle("أداة الانتقال / TP Tool", function(active)
        keepGiving = active
        if active then
            giveTPTool()
            EnsureCustomInventory()
            -- إشعار التفعيل المزدوج فقط / Activation notify only
            SendScreenNotify("Cryptic Hub", "✨ تم التفعيل: أداة الانتقال الآن في الخانة 1\n✨ Activated: TP Tool now in Slot 1")
        else
            -- إيقاف الميزة وحذف الأداة بصمت / Silent deactivation
            local t = player.Backpack:FindFirstChild("Cryptic TP") or (player.Character and player.Character:FindFirstChild("Cryptic TP"))
            if t then t:Destroy() end
            RemoveCustomInventory()
        end
    end)
end
