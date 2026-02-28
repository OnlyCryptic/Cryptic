-- [[ Cryptic Hub - ميزة أداة الانتقال الملكية ]]
-- الملف: tptool.lua
-- الميزات: الخانة 1 دائماً + عودة بعد الموت + إزاحة الأدوات الأخرى

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    local keepGiving = false

    -- وظيفة تنظيم الحقيبة لضمان الخانة رقم 1
    local function ForceSlotOne(tool)
        local backpack = player:FindFirstChild("Backpack")
        if not backpack or not tool then return end

        -- جلب كل الأدوات الموجودة حالياً (ما عدا أداتنا)
        local otherTools = {}
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item ~= tool then
                table.insert(otherTools, item)
                item.Parent = nil -- إزالتها مؤقتاً من الحقيبة
            end
        end

        -- وضع أداة الانتقال أولاً لتأخذ الرقم 1
        tool.Parent = backpack
        task.wait(0.05) 

        -- إعادة الأدوات الأخرى خلفها بالترتيب
        for _, item in pairs(otherTools) do
            item.Parent = backpack
        end
    end

    -- وظيفة إنشاء الأداة
    local function giveTPTool()
        local backpack = player:FindFirstChild("Backpack")
        if not backpack then return end

        -- إذا كانت موجودة مسبقاً، فقط ننظم مكانها
        local existing = backpack:FindFirstChild("Cryptic TP") or (player.Character and player.Character:FindFirstChild("Cryptic TP"))
        if existing then
            ForceSlotOne(existing)
            return
        end

        local tool = Instance.new("Tool")
        tool.Name = "Cryptic TP"
        tool.RequiresHandle = false
        tool.ToolTip = "Arwa Hub | Slot 1 Guaranteed"

        tool.Activated:Connect(function()
            local pos = mouse.Hit.p
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            end
        end)

        ForceSlotOne(tool)
    end

    -- نظام العودة بعد الموت (Reset/Death)
    player.CharacterAdded:Connect(function()
        if keepGiving then
            task.wait(1.5) -- انتظار تحميل الحقيبة بالكامل
            giveTPTool()
        end
    end)

    -- إضافة الزر للواجهة بنظام التبديل
    Tab:AddToggle("أداة الانتقال", function(active)
        keepGiving = active
        if active then
            giveTPTool()
            UI:Notify("تم التفعيل: الأداة الآن في الخانة 1")
        else
            local t = player.Backpack:FindFirstChild("Cryptic TP") or (player.Character and player.Character:FindFirstChild("Cryptic TP"))
            if t then t:Destroy() end
            UI:Notify("تم إيقاف الأداة المستمرة")
        end

        if UI.Logger then
            UI.Logger("تعديل أدوات", "أداة الانتقال المستمرة: " .. (active and "ON" or "OFF"))
        end
    end)

    Tab:AddParagraph("حتى لو حصلتِ على أسلحة جديدة، ستظل هذه الأداة في المركز الأول.")
end
