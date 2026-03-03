-- [[ Cryptic Hub - القائمة الرئيسية ]]
-- المطور: يامي (Yami) | التحديث: استبدال إشعارات الواجهة بإشعارات روبلوكس الأصلية

return function(Tab, UI)
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    -- دالة إشعارات روبلوكس الأصلية
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 4,
            })
        end)
    end

    -- 1. البطاقة التعريفية الأنيقة
    if Tab.AddProfileCard then
        Tab:AddProfileCard(lp)
    end

    Tab:AddLine()

    -- 2. زر الديسكورد
    Tab:AddButton("🔗 نسخ رابط الديسكورد", function()
        pcall(function()
            setclipboard("https://discord.gg/QSvQJs7BdP")
            SendRobloxNotification("Cryptic Hub", "✅ تم نسخ رابط الديسكورد بنجاح!")
        end)
    end)

    Tab:AddLine()

    -- 3. الحقوق
    Tab:AddLabel("© جميع الحقوق محفوظة للمطور: يامي (Yami)")
    Tab:AddLabel("ديسكورد التواصل: @d8u_")
end
