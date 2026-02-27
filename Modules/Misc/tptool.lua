-- [[ Cryptic Hub - ميزة أداة الانتقال (TP Tool) ]]
-- الملف: tptool.lua

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()

    -- وظيفة إعطاء الأداة للاعب
    local function giveTPTool()
        -- التأكد من عدم وجود الأداة مسبقاً لمنع التكرار
        if player.Backpack:FindFirstChild("Cryptic TP") or (player.Character and player.Character:FindFirstChild("Cryptic TP")) then
            UI:Notify("الأداة موجودة معك بالفعل!")
            return
        end

        local tool = Instance.new("Tool")
        tool.Name = "Cryptic TP"
        tool.RequiresHandle = false -- لكي لا نحتاج لمقبض حقيقي (مريحة للهاتف)
        tool.ToolTip = "اضغط في أي مكان للانتقال إليه"

        -- منطق الانتقال عند الضغط
        tool.Activated:Connect(function()
            local pos = mouse.Hit.p -- جلب إحداثيات النقطة التي ضغطتِ عليها
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- رفع اللاعب قليلاً للأعلى عند الانتقال لضمان عدم التعليق في الأرض
                player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                UI:Notify("تم الانتقال بنجاح!")
            end
        end)

        tool.Parent = player.Backpack
        UI:Notify("تم إضافة أداة الانتقال للحقيبة!")
        
        -- إرسال تقرير للمراقبة
        if UI.Logger then
            UI.Logger("استخدام ميزة", "قام المستخدم بإضافة أداة الانتقال (TP Tool)")
        end
    end

    -- إضافة الزر للواجهة
    Tab:AddButton("الحصول على أداة الانتقال", function()
        giveTPTool()
    end)

    Tab:AddParagraph("ملاحظة: أمسك الأداة ثم اضغط في المكان الذي تريد الذهاب إليه.")
end
