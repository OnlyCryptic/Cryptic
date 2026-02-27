-- [[ Cryptic Hub - ميزة أداة الانتقال المطورة ]]
-- الملف: tptool.lua
-- الميزات: العودة بعد الموت + الترتيب التلقائي في الخانة 1

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    local keepGiving = false -- متغير للتحكم في استمرارية إعطاء الأداة

    -- وظيفة إنشاء وإعطاء الأداة
    local function giveTPTool()
        -- التأكد من أن الشخصية موجودة والحقيبة جاهزة
        local backpack = player:FindFirstChild("Backpack")
        if not backpack then return end

        -- منع التكرار
        if backpack:FindFirstChild("Cryptic TP") or (player.Character and player.Character:FindFirstChild("Cryptic TP")) then
            return
        end

        local tool = Instance.new("Tool")
        tool.Name = "Cryptic TP"
        tool.RequiresHandle = false
        tool.ToolTip = "انقر للانتقال | Arwa Hub"

        -- منطق الانتقال
        tool.Activated:Connect(function()
            local pos = mouse.Hit.p
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            end
        end)

        -- وضعها في الحقيبة (ستظهر في أول خانة متاحة)
        tool.Parent = backpack
        
        -- لضمان ظهورها في الخانة رقم 1، نقوم بتجهيزها (Equip) ثم إعادتها
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            task.wait(0.1)
            player.Character.Humanoid:EquipTool(tool)
            task.wait(0.1)
            player.Character.Humanoid:UnequipTools()
        end
    end

    -- ربط الميزة بالرسبيون (العودة بعد الموت)
    player.CharacterAdded:Connect(function()
        if keepGiving then
            task.wait(1) -- انتظار تحميل الحقيبة الجديدة
            giveTPTool()
        end
    end)

    -- إضافة الزر للواجهة مع نظام المراقبة
    Tab:AddToggle("أداة الانتقال المستمرة", function(active)
        keepGiving = active
        if active then
            giveTPTool()
            UI:Notify("تم تفعيل الأداة (ستبقى معك حتى لو مت)")
        else
            UI:Notify("تم إيقاف التزويد التلقائي")
            -- حذف الأداة إذا تم إطفاؤها
            local t = player.Backpack:FindFirstChild("Cryptic TP") or (player.Character and player.Character:FindFirstChild("Cryptic TP"))
            if t then t:Destroy() end
        end

        -- إرسال تقرير النشاط لديسكورد
        if UI.Logger then
            UI.Logger("تغيير ميزة", "أداة الانتقال المستمرة: " .. (active and "ON" or "OFF"))
        end
    end)

    Tab:AddParagraph("عند تفعيلها، ستظهر الأداة تلقائياً في الخانة رقم 1 في كل مرة تعود فيها للحياة.")
end
