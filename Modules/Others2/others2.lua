-- [[ Cryptic Hub - Admin Panel (Attribute Trigger) ]]
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

return function(tab, UI)
    local OWNER_ID = 3875086037
    if LocalPlayer.UserId ~= OWNER_ID then return end

    local selectedTargetName = nil

    local function notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 3 })
        end)
    end

    local function getTargetPlayerByName(name)
        if not name or name == "لا توجد لاعبين نشطين بالسيرفر" or name == "جاري البحث..." then return nil end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name == name or p.DisplayName == name then
                return p
            end
        end
        return nil
    end

    tab:AddParagraph("Cryptic Admin (Attribute Sync)", "التحكم الفوري المضمون عبر سمات الشخصية.")

    local playerDropdown = tab:AddDropdown("اختر اللاعب بالسيرفر", {"جاري البحث..."}, function(selected)
        selectedTargetName = selected
    end)

    -- دالة لتفعيل أمر عبر الـ Attribute (تتحدث لدى الجميع في السيرفر تلقائياً)
    local function triggerCommand(actionName)
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                -- وضع إشارة مؤقتة على شخصيتك يراها الجميع
                char:SetAttribute("CrypticCmd", actionName)
                char:SetAttribute("CrypticTime", tick())
                
                -- إزالة الإشارة بعد ثانية واحدة حتى تكون نظيفة
                task.delay(1, function()
                    if char and char:GetAttribute("CrypticCmd") == actionName then
                        char:SetAttribute("CrypticCmd", "NONE")
                    end
                end)
            end
        end)
    end

    tab:AddButton("⚡ سحب اللاعب (.come)", function()
        local target = getTargetPlayerByName(selectedTargetName)
        if target then
            triggerCommand("COME")
            notify("Admin", "تم إرسال أمر السحب إلى: " .. target.Name)
        else
            notify("خطأ", "اختر لاعب صحيح!")
        end
    end)

    tab:AddButton("❄️ تجميد / إلغاء تجميد (Freeze)", function()
        local target = getTargetPlayerByName(selectedTargetName)
        if target then
            triggerCommand("FREEZE")
            notify("Admin", "تم إرسال أمر التجميد إلى: " .. target.Name)
        else
            notify("خطأ", "اختر لاعب صحيح!")
        end
    end)

    tab:AddButton("💀 قتل اللاعب (Kill)", function()
        local target = getTargetPlayerByName(selectedTargetName)
        if target then
            triggerCommand("KILL")
            notify("Admin", "تم إرسال أمر القتل إلى: " .. target.Name)
        else
            notify("خطأ", "اختر لاعب صحيح!")
        end
    end)

    tab:AddButton("🚪 طرد حقيقي (Kick)", function()
        local target = getTargetPlayerByName(selectedTargetName)
        if target then
            triggerCommand("KICK")
            notify("Admin", "تم إرسال أمر الطرد إلى: " .. target.Name)
        else
            notify("خطأ", "اختر لاعب صحيح!")
        end
    end)

    local function updateList()
        local activeNames = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(activeNames, p.Name)
            end
        end
        if #activeNames == 0 then
            activeNames = {"لا توجد لاعبين نشطين بالسيرفر"}
        end
        pcall(function()
            if playerDropdown and type(playerDropdown.Refresh) == "function" then
                playerDropdown.Refresh(activeNames)
            end
        end)
    end

    tab:AddButton("🔄 تحديث القائمة", function()
        updateList()
        notify("Admin", "تم التحديث!")
    end)

    task.spawn(function()
        while task.wait(3) do
            updateList()
        end
    end)
end
