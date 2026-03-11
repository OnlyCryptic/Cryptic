-- [[ Cryptic Hub - Main Menu (Bilingual) ]]
-- المطور: يامي (Yami) | التحديث: واجهة وإشعارات مزدوجة اللغة (عربي/إنجليزي)

return function(Tab, UI)
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    -- دالة إشعارات روبلوكس المزدوجة
    local function SendRobloxNotification(title, textAr, textEn)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = textAr .. "\n" .. textEn,
                Duration = 4,
            })
        end)
    end

    -- 1. البطاقة التعريفية الأنيقة
    if Tab.AddProfileCard then
        Tab:AddProfileCard(lp)
    end

    Tab:AddLine()

    -- 2. الحقوق (Credits)
    Tab:AddLabel("© Developer / المطور: Yami")
    Tab:AddLabel("Contact Discord / ديسكورد التواصل: @d8u_")

    Tab:AddLine()

    -- 3. زر الديسكورد
    Tab:AddButton("🔗 نسخ رابط الديسكورد / Copy Discord Link", function()
        pcall(function()
            setclipboard("https://discord.gg/QSvQJs7BdP")
            SendRobloxNotification(
                "Cryptic Hub ✅", 
                "تم نسخ رابط الديسكورد بنجاح!", 
                "Discord link copied successfully!"
            )
        end)
    end)

    -- 4. زر نسخ السكربت
    Tab:AddButton("📜 نسخ السكربت / Copy Script", function()
        pcall(function()
            local scriptLink = "loadstring(game:HttpGet('https://raw.githubusercontent.com/OnlyCryptic/Cryptic/main/main.lua'))()"
            setclipboard(scriptLink)
            SendRobloxNotification(
                "Cryptic Hub ✅", 
                "تم نسخ السكربت بنجاح! شاركه مع أصدقائك.", 
                "Script copied! Share it with your friends."
            )
        end)
    end)
end
