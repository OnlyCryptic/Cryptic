-- [[ Cryptic Hub - ميزة أداة الانتقال الملكية / Royal TP Tool Feature ]]
-- المطور: يامي (Yami) | التحديث: إشعارات التفعيل فقط + ترجمة مزدوجة / Update: Activation notify only + Dual translation

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
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
            -- إشعار التفعيل المزدوج فقط / Activation notify only
            SendScreenNotify("Cryptic Hub", "✨ تم التفعيل: أداة الانتقال الآن في الخانة 1\n✨ Activated: TP Tool now in Slot 1")
        else
            -- إيقاف الميزة وحذف الأداة بصمت / Silent deactivation
            local t = player.Backpack:FindFirstChild("Cryptic TP") or (player.Character and player.Character:FindFirstChild("Cryptic TP"))
            if t then t:Destroy() end
        end
    end)
end
